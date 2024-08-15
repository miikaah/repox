const std = @import("std");

pub fn dirExists(dirpath: []const u8) void {
    var dir = std.fs.openDirAbsolute(dirpath, .{}) catch {
        std.log.err("Directory not found: {s}", .{dirpath});
        std.process.exit(1);
    };
    defer dir.close();
}
