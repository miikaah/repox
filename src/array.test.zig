const std = @import("std");
const array = @import("array.zig");
const expectEqualStringArrays = @import("testing.zig").expectEqualStringArrays;

test "copyStringArrayListItemsToOwnedSlice - returns a slice copied from array list items" {
    const allocator = std.testing.allocator;
    const expected_slice = &[_][]u8{ @constCast("foo"), @constCast("bar") };

    var repolist = std.ArrayList([]u8).init(allocator);
    defer repolist.deinit();

    try repolist.appendSlice(expected_slice);

    const slice = array.copyStringArrayListItemsToOwnedSlice(allocator, repolist);
    defer allocator.free(slice);

    try expectEqualStringArrays(expected_slice, slice);
}
