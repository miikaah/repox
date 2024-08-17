const std = @import("std");
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
    @cInclude("string.h");
    @cInclude("unistd.h");
});
const Config = @import("config_file.zig").ConfigFile.Config;
const fs = @import("fs.zig");
const joinPath = @import("path.zig").joinPath;
const print = @import("print.zig");

pub fn gitFetch() void {
    _ = c.system("git fetch");
    print.ok();
}

pub fn gitFetchStatus() void {
    _ = c.system("git fetch && git status");
    print.ok();
}

pub fn gitStatus() void {
    _ = c.system("git status");
    print.ok();
}

pub fn readProcessStdout(
    allocator: std.mem.Allocator,
    cmd: []const u8,
) []u8 {
    const file = c.popen(@ptrCast(cmd), "r");
    defer _ = c.pclose(file);

    var buffer = allocator.alloc(u8, 4096) catch |err| {
        std.log.err("Failed to allocate memory for buffer {}", .{err});
        std.process.exit(1);
    };
    const line = allocator.alloc(u8, 1024) catch |err| {
        std.log.err("Failed to allocate memory for line buffer {}", .{err});
        std.process.exit(1);
    };

    var len: usize = 0;
    while (c.fgets(line.ptr, @intCast(line.len - 1), file) != null) {
        const cstr = c.strdup(@ptrCast(line));
        const zstr: [:0]u8 = std.mem.span(cstr);
        const line_copy = allocator.dupe(u8, zstr) catch |err| {
            std.log.err("Failed to allocate memory for line copy {}", .{err});
            std.process.exit(1);
        };

        if (len + line_copy.len <= buffer.len) {
            std.mem.copyForwards(u8, buffer[len..], line_copy);
            len += line_copy.len;
        } else {
            std.log.err("Buffer full {d}", .{len});
            break;
        }
    }

    return buffer[0..len];
}

pub fn getOriginDefaultGitBranch(allocator: std.mem.Allocator) []const u8 {
    return readProcessStdout(allocator, "git rev-parse --abbrev-ref origin/HEAD");
}

pub fn getCurrentGitBranch(allocator: std.mem.Allocator) []const u8 {
    return readProcessStdout(allocator, "git branch --show-current");
}

pub fn isOnDefaultBranch(allocator: std.mem.Allocator) bool {
    const origin_branch = getOriginDefaultGitBranch(allocator);
    const current_branch = getCurrentGitBranch(allocator);

    // Remove origin from origin/...
    // This only works if the default branch doesn't have / in it
    var it = std.mem.split(u8, origin_branch, "/");
    var len: i32 = 0;
    var default_branch: []const u8 = "";
    while (it.next()) |x| {
        if (len > 0) {
            default_branch = x;
            break;
        }
        len += 1;
    }

    return std.mem.eql(u8, default_branch, current_branch);
}

pub fn runInAllRepos(allocator: std.mem.Allocator, config: Config, cb: fn () void) void {
    fs.assertDirExists(config.repodir);
    fs.assertAllReposExist(allocator, config);

    for (config.repolist.items) |repo| {
        const cwd = joinPath(allocator, config.repodir, repo);
        const code = c.chdir(cwd.ptr);
        if (code != 0) {
            std.log.err("Failed to change to current working directory {s} error code {d}", .{ cwd, code });
            std.process.exit(1);
        }

        print.header(repo);
        if (isOnDefaultBranch(allocator)) {
            cb();
        }
        print.footer();
    }
}
