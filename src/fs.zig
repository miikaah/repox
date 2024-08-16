const std = @import("std");

pub fn assertDirExists(dirpath: []const u8) void {
    if (!std.fs.path.isAbsolute(dirpath)) {
        std.log.err("Directory path is not absolute: {s}", .{dirpath});
        std.process.exit(1);
    }
    var dir = std.fs.openDirAbsolute(dirpath, .{}) catch {
        std.log.err("Directory not found: {s}", .{dirpath});
        std.process.exit(1);
    };
    defer dir.close();
}

pub fn dirExists(dirpath: []const u8) bool {
    var exists = true;
    _ = std.fs.openDirAbsolute(dirpath, .{}) catch {
        exists = false;
    };

    return exists;
}
