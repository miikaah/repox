const std = @import("std");
// const c = @cImport({
//     @cInclude("stdlib.h");
// });
const array = @import("array.zig");
const ConfigFile = @import("config_file.zig").ConfigFile;
const fs = @import("fs.zig");
const isEqual = @import("is_equal.zig").isEqual;
const joinPath = @import("path.zig").joinPath;
const print = @import("print.zig");

pub fn main() !void {
    // _ = c.system("git status");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const argv = try std.process.argsAlloc(arena.allocator());
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

    if (isEqual(cmd, "dir")) {
        const dir_args = args[1..];
        if (dir_args.len < 1) {
            std.log.err("Missing argument for adding a new directory", .{});
            return;
        }

        const new_dirpath = dir_args[0];
        fs.assertDirExists(new_dirpath);

        config_file.write(.{
            .repodir = new_dirpath,
            .repolist = config.repolist,
        });
        return;
    }

    if (isEqual(cmd, "add")) {
        const add_args = args[1..];
        if (add_args.len < 1) {
            std.log.err("Missing argument for adding a new directory", .{});
            return;
        }

        fs.assertDirExists(config.repodir);

        for (add_args) |new_dir| {
            const new_dirpath = joinPath(arena.allocator(), config.repodir, new_dir);
            fs.assertDirExists(new_dirpath);

            if (!array.stringArrayListContains(&config.repolist, new_dir)) {
                try config.repolist.append(new_dir);
            }
        }

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

        for (remove_args) |dir_to_remove| {
            if (array.stringArrayListContains(&config.repolist, dir_to_remove)) {
                array.removeOneByValue(&config.repolist, dir_to_remove);
            }
        }

        config_file.write(.{
            .repodir = config.repodir,
            .repolist = config.repolist,
        });
        return;
    }

    if (isEqual(cmd, "empty")) {
        config.repolist.clearAndFree();

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
