const std = @import("std");
const array = @import("array.zig");
const expectEqualStringArrays = @import("testing.zig").expectEqualStringArrays;
const expect = std.testing.expect;

test "copyStringArrayListItemsToOwnedSlice - returns a slice copied from array list items" {
    const allocator = std.testing.allocator;
    const expected_slice = &[_][]u8{ @constCast("foo"), @constCast("bar") };

    var array_list = std.ArrayList([]u8).init(allocator);
    defer array_list.deinit();

    try array_list.appendSlice(expected_slice);

    const slice = array.copyStringArrayListItemsToOwnedSlice(allocator, array_list);
    defer allocator.free(slice);

    try expectEqualStringArrays(expected_slice, slice);
}

test "stringArrayListContains - returns true when array list constains string" {
    var array_list = std.ArrayList([]u8).init(std.testing.allocator);
    defer array_list.deinit();

    try array_list.appendSlice(&[_][]u8{ @constCast("foo"), @constCast("bar") });

    try expect(array.stringArrayListContains(&array_list, @constCast("foo")));
}

test "stringArrayListContains - returns false when array list not constains string" {
    var array_list = std.ArrayList([]u8).init(std.testing.allocator);
    defer array_list.deinit();

    try array_list.appendSlice(&[_][]u8{ @constCast("foo"), @constCast("bar") });

    try expect(!array.stringArrayListContains(&array_list, @constCast("zoo")));
}
