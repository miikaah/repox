const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const array = @import("array.zig");
const fs = @import("fs.zig");
const joinPath = @import("path.zig").joinPath;
const print = @import("print.zig");
const compareAsciiStrings = @import("sort.zig").compareAsciiStrings;

const DEFAULT_CONFIG_DIRNAME = ".repox";
const DEFAULT_CONFIG_FILENAME = "repoxSettings.json";

const stdout = std.io.getStdOut().writer();

pub const ConfigFile = struct {
    allocator: Allocator,
    default_config_dir: []u8,
    default_config_file: []u8,

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
        const env_map = try allocator.create(std.process.EnvMap);
        env_map.* = try std.process.getEnvMap(allocator);

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
            std.log.err("Failed to contruct ConfigFile: {}", .{err});
            std.process.exit(1);
        };
    }

    pub fn read(self: ConfigFile) Config {
        const error_code = 2;
        const file = std.fs.openFileAbsolute(
            self.default_config_file,
            .{},
        ) catch |err| switch (err) {
            error.FileNotFound => blk: {
                // TODO: Add colors to texts
                print.generic("Config file doesn't exist {s}\n", "");

                if (!fs.dirExists(self.default_config_dir)) {
                    std.fs.makeDirAbsolute(self.default_config_dir) catch |e| {
                        std.log.err("Failed to create config dir: {}", .{e});
                        std.process.exit(error_code);
                    };
                    print.generic("Created {s}\n", self.default_config_dir);
                }

                const f = std.fs.createFileAbsolute(
                    self.default_config_file,
                    .{ .read = true },
                ) catch |e| {
                    std.log.err("Failed to create config file: {}", .{e});
                    std.process.exit(error_code);
                };

                write(self, .{
                    .repodir = self.default_config_dir,
                    .repolist = ArrayList([]u8).init(self.allocator),
                });
                print.generic("Wrote config file to {s}\n", self.default_config_file);

                break :blk f;
            },
            else => |e| {
                std.log.err("Failed to open config file for read: {}", .{e});
                std.process.exit(error_code);
            },
        };
        defer file.close();

        const file_size = file.getEndPos() catch |err| {
            std.log.err("Failed to get file end position: {}", .{err});
            std.process.exit(error_code);
        };
        const buffer = self.allocator.alloc(u8, file_size) catch |err| {
            std.log.err("Failed to allocate memory for file buffer: {}", .{err});
            std.process.exit(error_code);
        };
        _ = file.readAll(buffer) catch |err| {
            std.log.err("Failed to read file to buffer: {}", .{err});
            std.process.exit(error_code);
        };
        const parsed = std.json.parseFromSliceLeaky(
            ApiConfig,
            self.allocator,
            buffer,
            .{},
        ) catch |err| {
            std.log.err("Failed to parse buffer to JSON: {}", .{err});
            std.process.exit(error_code);
        };

        var repolist = ArrayList([]u8).init(self.allocator);
        for (parsed.repolist) |s| {
            repolist.append(s) catch |err| {
                std.log.err("Failed to append: {}", .{err});
                std.process.exit(error_code);
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
        const file = std.fs.openFileAbsolute(
            self.default_config_file,
            .{ .mode = .read_write },
        ) catch |err| {
            std.log.err("Failed to open config file for write: {}", .{err});
            std.process.exit(error_code);
        };
        defer file.close();

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();

        const repolist = array.copyStringArrayListItemsToOwnedSlice(
            gpa.allocator(),
            config.repolist,
        );
        defer gpa.allocator().free(repolist);

        std.mem.sort([]u8, repolist, {}, compareAsciiStrings);

        const payload: ApiConfig = .{
            .repodir = config.repodir,
            .repolist = repolist,
        };

        const json_slice = std.json.stringifyAlloc(
            self.allocator,
            payload,
            .{ .whitespace = .indent_2 },
        ) catch |err| {
            std.log.err("Failed to stringify config: {}", .{err});
            std.process.exit(error_code);
        };

        file.writeAll(json_slice) catch |err| {
            std.log.err("Failed to write file: {}", .{err});
            std.process.exit(error_code);
        };
        file.setEndPos(json_slice.len) catch |err| {
            std.log.err("Failed to truncate file: {}", .{err});
            std.process.exit(error_code);
        };
    }
};
