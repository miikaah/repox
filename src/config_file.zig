const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const process = std.process;
const Allocator = mem.Allocator;

pub const ConfigFile = struct {
    settings: Settings,
    allocator: Allocator,
    state: State,

    pub const Settings = struct {
        repodir: []const u8,
        repolist: [][]const u8,
    };

    pub const State = struct {
        pub fn promote(self: State, allocator: Allocator) !ConfigFile {
            const repolist: [][]const u8 = try allocator.alloc([]const u8, 0);

            return .{
                .settings = .{
                    .repodir = ".repox",
                    .repolist = repolist,
                },
                .allocator = allocator,
                .state = self,
            };
        }
    };

    pub fn init(stdout: fs.File.Writer, allocator: Allocator) ConfigFile {
        const config_file = (State{}).promote(allocator) catch |err| {
            std.debug.print("Failed to allocate memory for ConfigFile: {}\n", .{err});
            process.exit(1);
        };

        config_file.read(stdout) catch |err| {
            std.debug.print("Failed to read config file: {}\n", .{err});
            process.exit(2);
        };

        return config_file;
    }

    pub fn read(self: ConfigFile, stdout: fs.File.Writer) !void {
        const env_map = try self.allocator.create(process.EnvMap);
        env_map.* = try process.getEnvMap(self.allocator);

        const homedir = env_map.get("HOME") orelse env_map.get("USERPROFILE") orelse "";
        try stdout.print("Hello {s}\n", .{homedir});
    }
};
