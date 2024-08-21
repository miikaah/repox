const std = @import("std");
const fs = @import("fs.zig");
const joinPath = @import("path.zig").joinPath;
const ensureTestDirsExist = @import("testing.zig").ensureTestDirsExist;
const expect = std.testing.expect;

fn beforeAll() !void {
    try ensureTestDirsExist();
}

test {
    try beforeAll();
}

test "assertDirExists - returns void if dir exists" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer arena.deinit();

    const tmp = joinPath(allocator, cwd, "tmp");

    fs.assertDirExists(tmp);

    try expect(true);
}

test "dirExists - returns true if dir exists" {
    try expect(fs.dirExists("/tmp"));
}

test "dirExists - returns false if dir not exists" {
    try expect(!fs.dirExists("/not-exists"));
}

test "assertAllReposExist - returns void when all repos exist" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer arena.deinit();

    const tmp = joinPath(allocator, cwd, "tmp");

    var repolist = std.ArrayList([]u8).init(allocator);
    try repolist.append(@constCast("foo"));
    try repolist.append(@constCast("bar"));
    try repolist.append(@constCast("baz"));

    const buffer = try allocator.alloc(u8, 0);

    const config = .{
        .repodir = tmp,
        .repolist = repolist,
        .buffer = buffer,
    };

    fs.assertAllReposExist(allocator, config);

    try expect(true);
}
