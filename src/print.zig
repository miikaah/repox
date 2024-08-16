const std = @import("std");
const ConfigFile = @import("config_file.zig").ConfigFile;
const Config = ConfigFile.Config;

export const RED = "\x1b[31m";
export const GREEN = "\x1b[32m";
export const YELLOW = "\x1b[33m";
export const END = "\x1b[0m";

const stdout = std.io.getStdOut().writer();

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

pub fn help() void {
    stdout.print("\n{s}\n", .{help_text}) catch |err| {
        std.log.err("Failed to print help: {}", .{err});
        std.process.exit(1);
    };
}

pub fn show(config: Config) void {
    stdout.print("{s}\n", .{config.buffer}) catch |err| {
        std.log.err("Failed to print show: {}", .{err});
        std.process.exit(1);
    };
}

pub fn commandNotFound() void {
    stdout.print("Command not found\n", .{}) catch |err| {
        std.log.err("Failed to print command not found: {}", .{err});
        std.process.exit(1);
    };
}

pub fn info(comptime format: []const u8, args: anytype) void {
    stdout.print(format, .{args}) catch |err| {
        std.log.err("Failed to print: {}", .{err});
        std.process.exit(1);
    };
}

pub fn warn(comptime format: []const u8, args: anytype) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const text = std.fmt.allocPrint(allocator, format, .{args}) catch |err| {
        std.log.err("Failed to format warn: {}", .{err});
        std.process.exit(1);
    };
    defer allocator.free(text);

    stdout.print("{s}{s}{s}", .{ YELLOW, text, END }) catch |err| {
        std.log.err("Failed to print warn: {}", .{err});
        std.process.exit(1);
    };
}

pub fn success(comptime format: []const u8, args: anytype) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const text = std.fmt.allocPrint(allocator, format, .{args}) catch |err| {
        std.log.err("Failed to format success: {}", .{err});
        std.process.exit(1);
    };
    defer allocator.free(text);

    stdout.print("{s}{s}{s}", .{ GREEN, text, END }) catch |err| {
        std.log.err("Failed to print success: {}", .{err});
        std.process.exit(1);
    };
}
