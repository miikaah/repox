const std = @import("std");
const array = @import("array.zig");
const expectEqualSlices = std.testing.expectEqualSlices;

test "return a slice copied from array list items" {
    const allocator = std.testing.allocator;
    var expected_slice = try allocator.alloc([]const u8, 2);
    defer allocator.free(expected_slice);

    expected_slice[0] = "foo";
    expected_slice[1] = "bar";

    var repolist = std.ArrayList([]u8).init(allocator);
    defer repolist.deinit();

    try repolist.append(@constCast("foo"));
    try repolist.append(@constCast("bar"));

    const slice = array.copyStringArrayListItemsToOwnedSlice(allocator, repolist);
    defer allocator.free(slice);

    for (slice, 0..) |item, index| {
        try expectEqualSlices(u8, expected_slice[index], item);
    }
}
