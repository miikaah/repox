const std = @import("std");

/// NOTE: I don't know if this works properly with utf-8
///       https://www.reddit.com/r/Zig/comments/17zxypc/just_an_example_of_string_sorting_because_i/
pub fn compareAsciiStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}
