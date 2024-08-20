const std = @import("std");
const isEqual = @import("is_equal.zig").isEqual;
const expect = std.testing.expect;

test "returns true when the strings are equal" {
    try expect(isEqual("foo", "foo"));
}

test "returns false when the strings are equal" {
    try expect(!isEqual("foo", "bar"));
}
