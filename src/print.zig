const std = @import("std");
const ConfigFile = @import("config_file.zig").ConfigFile;
const Config = ConfigFile.Config;

const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const END = "\x1b[0m";

const Color = enum {
    green,
    yellow,
};

/// You can't get stdin/out/err during comptime on Windows so this can't be a global
/// https://github.com/ziglang/zig/issues/17186
fn getStdOut() std.fs.File.Writer {
    return std.io.getStdOut().writer();
}

pub fn help() void {
    const help_text =
        \\Repox commands:
        \\  help  -h, --help      Print this help
        \\  dir                   Set repository directory
        \\  show                  Print current config
        \\  add                   Add repositories
        \\  remove                Remove repositories
        \\  empty                 Remove all repositories
        \\
        \\  fetch                 Run git fetch in all repositories
        \\  fs                    Run git fetch && git status in all repositories
        \\  status                Run git status in all repositories
        \\  clean                 Remove node_modules directory in all repositories
        \\  install  i            Run npm i in all repositories
        \\  pull                  Run git pull --rebase in all repositories
        \\  pi                    Run git pull --rebase && npm i in all repositories
        \\
    ;
    info("\n{s}\n", help_text);
}

pub fn show(config: Config) void {
    info("{s}\n", config.buffer);
}

pub fn commandNotFound() void {
    infoo("Command not found\n");
}

pub fn info(comptime format: []const u8, args: anytype) void {
    getStdOut().print(format, .{args}) catch |err| {
        std.log.err("Failed to info: {}", .{err});
        std.process.exit(1);
    };
}

pub fn infoo(comptime format: []const u8) void {
    getStdOut().print(format, .{}) catch |err| {
        std.log.err("Failed to infoo: {}", .{err});
        std.process.exit(1);
    };
}

pub fn warn(comptime format: []const u8, args: anytype) void {
    formatPrint(Color.yellow, format, args);
}

pub fn success(comptime format: []const u8, args: anytype) void {
    formatPrint(Color.green, format, args);
}

fn formatPrint(
    color: Color,
    comptime format: []const u8,
    args: anytype,
) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const text = std.fmt.allocPrint(allocator, format, .{args}) catch |err| {
        std.log.err("Failed to format: {}", .{err});
        std.process.exit(1);
    };
    defer allocator.free(text);

    switch (color) {
        Color.yellow => yellow(text),
        Color.green => green(text),
    }
}

pub fn yellow(text: []const u8) void {
    getStdOut().print("{s}{s}{s}", .{ YELLOW, text, END }) catch |err| {
        std.log.err("Failed to print warn: {}", .{err});
        std.process.exit(1);
    };
}

pub fn green(text: []const u8) void {
    getStdOut().print("{s}{s}{s}", .{ GREEN, text, END }) catch |err| {
        std.log.err("Failed to print success: {}", .{err});
        std.process.exit(1);
    };
}

pub fn ok() void {
    green("OK\n");
}

pub fn header(repo: []const u8) void {
    const header_text =
        \\
        \\---------------------------------------------
        \\Repository: {s}
        \\
    ;
    info(header_text, repo);
}

pub fn footer() void {
    const footer_text =
        \\---------------------------------------------
        \\
    ;
    infoo(footer_text);
}
