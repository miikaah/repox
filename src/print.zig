const std = @import("std");
const ConfigFile = @import("config_file.zig").ConfigFile;
const Config = ConfigFile.Config;

export const RED = "\x1b[31m";
export const GREEN = "\x1b[32m";
export const YELLOW = "\x1b[33m";
export const END = "\x1b[0m";

const stdout = std.io.getStdOut().writer();

pub fn help() void {
    const help_text =
        \\Repox commands:
        \\help  -h, --help      Print this help
        \\dir                   Set repository directory
        \\show                  Print current config
        \\add                   Add repositories
        \\remove                Remove repositories
        \\empty                 Remove all repositories
        \\
        \\fetch                 Run git fetch in all repositories
        \\fs                    Run git fetch && git status in all repositories
        \\status                Run git status in all repositories
        \\clean                 Remove node_modules directory in all repos
        \\install               Run npm i in all repos
        \\pull                  Run git pull --rebase in all repos
        \\pi                    Run git pull --rebase && npm i in all repos
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
    stdout.print(format, .{args}) catch |err| {
        std.log.err("Failed to info: {}", .{err});
        std.process.exit(1);
    };
}

pub fn infoo(comptime format: []const u8) void {
    stdout.print(format, .{}) catch |err| {
        std.log.err("Failed to infoo: {}", .{err});
        std.process.exit(1);
    };
}

pub fn warn(comptime format: []const u8, args: anytype) void {
    yellow(formatText(format, args));
}

pub fn success(comptime format: []const u8, args: anytype) void {
    green(formatText(format, args));
}

fn formatText(comptime format: []const u8, args: anytype) []u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const text = std.fmt.allocPrint(allocator, format, .{args}) catch |err| {
        std.log.err("Failed to format: {}", .{err});
        std.process.exit(1);
    };
    defer allocator.free(text);

    return text;
}

pub fn yellow(text: []const u8) void {
    stdout.print("{s}{s}{s}", .{ YELLOW, text, END }) catch |err| {
        std.log.err("Failed to print warn: {}", .{err});
        std.process.exit(1);
    };
}

pub fn green(text: []const u8) void {
    stdout.print("{s}{s}{s}", .{ GREEN, text, END }) catch |err| {
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
