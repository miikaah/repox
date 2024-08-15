const std = @import("std");

pub fn joinPath(allocator: std.mem.Allocator, s: []const u8, s2: []const u8) []u8 {
    return std.fs.path.join(allocator, &[_][]const u8{ s, s2 }) catch |err| {
        std.log.err("Failed to join paths {s} and {s}: {}", .{ s, s2, err });
        std.process.exit(1);
    };
}
