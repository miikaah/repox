const std = @import("std");
const fs = std.fs;
const process = std.process;
const mem = std.mem;
const Allocator = mem.Allocator;

pub fn joinPath(allocator: Allocator, s: []const u8, s2: []const u8) []u8 {
    return fs.path.join(allocator, &[_][]const u8{ s, s2 }) catch |err| {
        std.log.err("Failed to join paths {s} and {s}: {}", .{ s, s2, err });
        process.exit(1);
    };
}
