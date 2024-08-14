const std = @import("std");
const fs = std.fs;
const io = std.io;
const mem = std.mem;
const heap = std.heap;
const process = std.process;
const eql = mem.eql;
// const c = @cImport({
//     @cInclude("stdlib.h");
// });
const ConfigFile = @import("config_file.zig").ConfigFile;

fn printHelp(stdout: fs.File.Writer) !void {
    try stdout.print("\nRepox commands:\n", .{});
    try stdout.print("help  -h, --help \t Print this help\n", .{});
    try stdout.print("dir \t\t\t Set repository directory\n", .{});
    try stdout.print("show \t\t\t Print current config\n", .{});
    try stdout.print("add \t\t\t Add repositories\n", .{});
    try stdout.print("remove \t\t\t Remove repositories\n", .{});
    try stdout.print("empty \t\t\t Remove all repositories\n", .{});
    try stdout.print("\n", .{});
    try stdout.print("fetch \t\t\t Run git fetch in all repositories\n", .{});
    try stdout.print("fs \t\t\t Run git fetch && git status in all repositories\n", .{});
    try stdout.print("status \t\t\t Run git status in all repositories\n", .{});
    try stdout.print("clean \t\t\t Remove node_modules directory in all repos\n", .{});
    try stdout.print("install  i \t\t Run npm i in all repos\n", .{});
    try stdout.print("pull \t\t\t Run git pull --rebase in all repos\n", .{});
    try stdout.print("pi \t\t\t Run git pull --rebase && npm i in all repos\n", .{});
    try stdout.print("\n", .{});
}

pub fn main() !void {
    // _ = c.system("git status");
    const stdout = io.getStdOut().writer();
    const stderr = io.getStdErr().writer();
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();

    const argv = try process.argsAlloc(arena.allocator());
    // defer process.argsFree(arena.allocator(), argv); // No need to call argsFree because using arena allocator

    const args = argv[1..];
    if (args.len < 1) {
        try printHelp(stdout);
        return;
    }

    const cmd = args[0];

    if (eql(u8, cmd, "-h") or eql(u8, cmd, "--help") or eql(u8, cmd, "help")) {
        try printHelp(stdout);
        return;
    }

    const settings = ConfigFile.init(arena.allocator());

    if (eql(u8, cmd, "show")) {
        try stdout.print("{s}\n", .{settings.buffer});
        return;
    }

    if (cmd.len > 0) {
        try stderr.print("Command {s} not found\n", .{cmd});
        return;
    }
}
