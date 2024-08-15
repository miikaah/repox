const std = @import("std");
const fs = std.fs;
const json = std.json;
const log = std.log;
const mem = std.mem;
const process = std.process;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const array = @import("array.zig");
const joinPath = @import("path.zig").joinPath;

const DEFAULT_CONFIG_DIRNAME = ".repox";
const DEFAULT_CONFIG_FILENAME = "repoxSettings.json";

pub const ConfigFile = struct {
    allocator: Allocator,
    default_config_dir: []const u8,
    default_config_file: []const u8,

    pub const ApiConfig = struct {
        repodir: []u8,
        repolist: [][]u8,
    };

    pub const InnerConfig = struct {
        repodir: []u8,
        repolist: ArrayList([]u8),
    };

    pub const Config = struct {
        repodir: []u8,
        repolist: ArrayList([]u8),
        buffer: []u8,
    };

    fn construct(allocator: Allocator) !ConfigFile {
        const env_map = try allocator.create(process.EnvMap);
        env_map.* = try process.getEnvMap(allocator);

        const homedir = env_map.get("HOME") orelse env_map.get("USERPROFILE") orelse "";
        const default_config_dir = joinPath(
            allocator,
            homedir,
            DEFAULT_CONFIG_DIRNAME,
        );
        const default_config_file = joinPath(
            allocator,
            default_config_dir,
            DEFAULT_CONFIG_FILENAME,
        );

        return .{
            .default_config_dir = default_config_dir,
            .default_config_file = default_config_file,
            .allocator = allocator,
        };
    }

    pub fn init(allocator: Allocator) ConfigFile {
        return @This().construct(allocator) catch |err| {
            log.err("Failed to contruct ConfigFile: {}", .{err});
            process.exit(1);
        };
    }

    pub fn read(self: ConfigFile) Config {
        const error_code = 2;
        const file = fs.openFileAbsolute(
            self.default_config_file,
            .{},
        ) catch |err| {
            // TODO: Create a new config dir if not exists etc init
            log.err("Failed to open config file for read: {}", .{err});
            process.exit(error_code);
        };
        defer file.close();

        const file_size = file.getEndPos() catch |err| {
            log.err("Failed to get file end position: {}", .{err});
            process.exit(error_code);
        };
        const buffer = self.allocator.alloc(u8, file_size) catch |err| {
            log.err("Failed to allocate memory for file buffer: {}", .{err});
            process.exit(error_code);
        };
        _ = file.readAll(buffer) catch |err| {
            log.err("Failed to read file to buffer: {}", .{err});
            process.exit(error_code);
        };
        const parsed = std.json.parseFromSliceLeaky(
            ApiConfig,
            self.allocator,
            buffer,
            .{},
        ) catch |err| {
            log.err("Failed to parse buffer to JSON: {}", .{err});
            process.exit(error_code);
        };

        var repolist = ArrayList([]u8).init(self.allocator);
        for (parsed.repolist) |s| {
            repolist.append(s) catch |err| {
                log.err("Failed to append: {}", .{err});
                process.exit(error_code);
            };
        }

        return .{
            .repodir = parsed.repodir,
            .repolist = repolist,
            .buffer = buffer,
        };
    }

    pub fn write(self: ConfigFile, config: InnerConfig) void {
        const error_code = 3;
        const file = fs.openFileAbsolute(
            self.default_config_file,
            .{ .mode = .read_write },
        ) catch |err| {
            log.err("Failed to open config file for write: {}", .{err});
            process.exit(error_code);
        };
        defer file.close();

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();

        const repolist = array.copyStringArrayListItemsToOwnedSlice(
            gpa.allocator(),
            config.repolist,
        );
        defer gpa.allocator().free(repolist);

        const payload: ApiConfig = .{
            .repodir = config.repodir,
            .repolist = repolist,
        };

        const json_slice = json.stringifyAlloc(
            self.allocator,
            payload,
            .{ .whitespace = .indent_2 },
        ) catch |err| {
            log.err("Failed to stringify config: {}", .{err});
            process.exit(error_code);
        };

        // TODO: validate that JSON file write succeeded
        file.writeAll(json_slice) catch |err| {
            log.err("Failed to write file: {}", .{err});
            process.exit(error_code);
        };
        file.setEndPos(json_slice.len) catch |err| {
            log.err("Failed to truncate file: {}", .{err});
            process.exit(error_code);
        };
    }
};
