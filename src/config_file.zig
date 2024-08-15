const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const process = std.process;
const Allocator = mem.Allocator;

const DEFAULT_CONFIG_DIRNAME = ".repox";
const DEFAULT_CONFIG_FILENAME = "repoxSettings.json";

pub const ConfigFile = struct {
    allocator: Allocator,
    default_config_dir: []const u8,
    default_config_file: []const u8,

    pub const ApiSettings = struct {
        repodir: []u8,
        repolist: [][]u8,
    };

    pub const Settings = struct {
        repodir: []u8,
        repolist: [][]u8,
        buffer: []u8,
        buffer_size: usize,
    };

    fn construct(allocator: Allocator) !ConfigFile {
        const env_map = try allocator.create(process.EnvMap);
        env_map.* = try process.getEnvMap(allocator);

        const homedir = env_map.get("HOME") orelse env_map.get("USERPROFILE") orelse "";
        const default_config_dir = try fs.path.join(allocator, &[_][]const u8{ homedir, DEFAULT_CONFIG_DIRNAME });
        const default_config_file = try fs.path.join(allocator, &[_][]const u8{ default_config_dir, DEFAULT_CONFIG_FILENAME });

        return .{
            .default_config_dir = default_config_dir,
            .default_config_file = default_config_file,
            .allocator = allocator,
        };
    }

    pub fn init(allocator: Allocator) Settings {
        const config_file = @This().construct(allocator) catch |err| {
            std.log.err("Failed to contruct ConfigFile: {}", .{err});
            process.exit(1);
        };

        return config_file.read();
    }

    pub fn read(self: ConfigFile) Settings {
        const error_code = 2;
        const file = fs.openFileAbsolute(self.default_config_file, .{}) catch |err| {
            // TODO: Create a new config dir if not exists etc init
            std.log.err("Failed to open config file for read: {}", .{err});
            process.exit(error_code);
        };
        defer file.close();

        const file_size = file.getEndPos() catch |err| {
            std.log.err("Failed to get file end position: {}", .{err});
            process.exit(error_code);
        };
        const buffer = self.allocator.alloc(u8, file_size) catch |err| {
            std.log.err("Failed to allocate memory for file buffer: {}", .{err});
            process.exit(error_code);
        };
        const buffer_size = file.readAll(buffer) catch |err| {
            std.log.err("Failed to read file to buffer: {}", .{err});
            process.exit(error_code);
        };
        const parsed = std.json.parseFromSliceLeaky(ApiSettings, self.allocator, buffer, .{}) catch |err| {
            std.log.err("Failed to parse buffer to JSON: {}", .{err});
            process.exit(error_code);
        };

        return .{
            .repodir = parsed.repodir,
            .repolist = parsed.repolist,
            .buffer = buffer,
            .buffer_size = buffer_size,
        };
    }

    pub fn write(self: ConfigFile) void {
        const error_code = 3;
        const file = fs.openFileAbsolute(self.default_config_file, .{}) catch |err| {
            std.log.err("Failed to open config file for write: {}\n", .{err});
            process.exit(error_code);
        };
        defer file.close();
    }
};
