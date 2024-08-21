const std = @import("std");
const fs = @import("fs.zig");
const joinPath = @import("path.zig").joinPath;
const expect = std.testing.expect;

fn beforeAll() !void {
    const allocator = std.testing.allocator;
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(cwd);

    const tmp = joinPath(allocator, cwd, "tmp");
    defer allocator.free(tmp);

    if (!fs.dirExists(tmp)) {
        std.fs.makeDirAbsolute(tmp) catch |e| {
            std.log.err("Failed to create config dir: {}", .{e});
            std.process.exit(1);
        };
    }
}

test {
    try beforeAll();
}

test "dirExists - returns true if dir exists" {
    try expect(fs.dirExists("/tmp"));
}

test "dirExists - returns false if dir not exists" {
    try expect(!fs.dirExists("/not-exists"));
}
