const std = @import("std");
const fs = std.fs;
const heap = std.heap;
const io = std.io;
const mem = std.mem;
const process = std.process;
// const c = @cImport({
//     @cInclude("stdlib.h");
// });
const array = @import("array.zig");
const ConfigFile = @import("config_file.zig").ConfigFile;
const dirExists = @import("fs.zig").dirExists;
const isEqual = @import("is_equal.zig").isEqual;
const joinPath = @import("path.zig").joinPath;
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

    const config_file = ConfigFile.init(arena.allocator());
    var config = config_file.read();

    if (isEqual(cmd, "show")) {
        print.show(config);
        return;
    }

    if (isEqual(cmd, "add")) {
        const add_args = args[1..];
        if (add_args.len < 1) {
            std.log.err("Missing argument for adding a new directory", .{});
            return;
        }

        const new_dir = add_args[0];
        dirExists(config.repodir);

        const new_dirpath = joinPath(arena.allocator(), config.repodir, new_dir);
        dirExists(new_dirpath);

        // TODO: append multiple

        try config.repolist.append(new_dir);

        config_file.write(.{
            .repodir = config.repodir,
            .repolist = config.repolist,
        });
        return;
    }

    if (isEqual(cmd, "remove")) {
        const remove_args = args[1..];
        if (remove_args.len < 1) {
            std.log.err("Missing argument for removing a directory", .{});
            return;
        }

        // TODO: remove multiple

        const dir_to_remove = remove_args[0];
        array.removeByValue(&config.repolist, dir_to_remove);

        config_file.write(.{
            .repodir = config.repodir,
            .repolist = config.repolist,
        });
        return;
    }

    if (cmd.len > 0) {
        print.commandNotFound();
        return;
    }
}
