const std = @import("std");

pub fn isEqual(s: []const u8, s2: []const u8) bool {
    return std.mem.eql(u8, s, s2);
}
