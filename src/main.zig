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

    if (eql(u8, cmd, "-h") or eql(u8, cmd, "--help") or eql(u8, cmd, "help")) {
        print.help();
        return;
    }

    const settings = ConfigFile.init(arena.allocator());

    if (eql(u8, cmd, "show")) {
        print.show(settings);
        return;
    }

    if (cmd.len > 0) {
        print.commandNotFound();
        return;
    }
}
