const std = @import("std");
const expect = std.testing.expect;

pub fn isEqual(s: []const u8, s2: []const u8) bool {
    return std.mem.eql(u8, s, s2);
}

test "returns true when the strings are equal" {
    try expect(isEqual("foo", "foo"));
}

test "returns false when the strings are equal" {
    try expect(!isEqual("foo", "bar"));
}
