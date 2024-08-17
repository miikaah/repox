const std = @import("std");
const array = @import("array.zig");
const command = @import("cmd.zig");
const ConfigFile = @import("config_file.zig").ConfigFile;
const fs = @import("fs.zig");
const isEqual = @import("is_equal.zig").isEqual;
const joinPath = @import("path.zig").joinPath;
const print = @import("print.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const argv = try std.process.argsAlloc(arena.allocator());
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

        const new_repodirpath = dir_args[0];
        fs.assertDirExists(new_repodirpath);
        fs.assertAllReposExist(arena.allocator(), config);

        config_file.write(.{
            .repodir = new_repodirpath,
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
        fs.assertAllReposExist(arena.allocator(), config);

        for (add_args) |new_dir| {
            fs.assertDirExists(joinPath(arena.allocator(), config.repodir, new_dir));

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

    if (isEqual(cmd, "fetch")) {
        command.runInAllRepos(arena.allocator(), config, command.gitFetch);
        return;
    }

    if (isEqual(cmd, "fs")) {
        command.runInAllRepos(arena.allocator(), config, command.gitFetchStatus);
        return;
    }

    if (isEqual(cmd, "status")) {
        command.runInAllRepos(arena.allocator(), config, command.gitStatus);
        return;
    }

    if (cmd.len > 0) {
        print.commandNotFound();
        return;
    }
}
