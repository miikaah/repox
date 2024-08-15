const std = @import("std");
const fs = std.fs;
const io = std.io;
const heap = std.heap;
const process = std.process;
// const c = @cImport({
//     @cInclude("stdlib.h");
// });
const ConfigFile = @import("config_file.zig").ConfigFile;
const isEqual = @import("is_equal.zig").isEqual;
const print = @import("print.zig");

pub fn main() !void {
    // _ = c.system("git status");
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();

    const argv = try process.argsAlloc(arena.allocator());
    // defer process.argsFree(arena.allocator(), argv); // No need to call argsFree because using arena allocator

    const args = argv[1..];
    if (args.len < 1) {
        print.help();
        return;
    }

    const cmd = args[0];

    if (isEqual(cmd, "-h") or isEqual(cmd, "--help") or isEqual(cmd, "help")) {
        print.help();
        return;
    }

    const settings = ConfigFile.init(arena.allocator());

    if (isEqual(cmd, "show")) {
        print.show(settings);
        return;
    }

    if (cmd.len > 0) {
        print.commandNotFound();
        return;
    }
}
