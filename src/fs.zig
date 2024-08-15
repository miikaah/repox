const std = @import("std");
const fs = std.fs;
const process = std.process;

pub fn dirExists(dirpath: []const u8) void {
    var dir = fs.openDirAbsolute(dirpath, .{}) catch {
        std.log.err("Directory not found: {s}", .{dirpath});
        process.exit(1);
    };
    defer dir.close();
}
