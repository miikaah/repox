const std = @import("std");
const fs = @import("fs.zig");
const joinPath = @import("path.zig").joinPath;
const expectEqualSlices = std.testing.expectEqualSlices;

pub fn expectEqualStringArrays(expected_slice: []const []const u8, slice: [][]u8) !void {
    for (slice, 0..) |item, index| {
        try expectEqualSlices(u8, expected_slice[index], item);
    }
}

pub fn ensureTestDirsExist() !void {
    const allocator = std.testing.allocator;
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(cwd);

    const tmp = joinPath(allocator, cwd, "tmp");
    defer allocator.free(tmp);

    if (!fs.dirExists(tmp)) {
        std.fs.makeDirAbsolute(tmp) catch |e| {
            std.log.err("Failed to create test tmp dir: {}", .{e});
            std.process.exit(1);
        };
    }

    const dirs = &[_][]const u8{ "foo", "bar", "baz" };
    for (dirs) |dir| {
        const d = joinPath(allocator, tmp, dir);
        defer allocator.free(d);

        if (!fs.dirExists(d)) {
            std.fs.makeDirAbsolute(d) catch |e| {
                std.log.err("Failed to create test dir: {}", .{e});
                std.process.exit(1);
            };
        }
    }
}
