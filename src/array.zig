const std = @import("std");
const isEqual = @import("is_equal.zig").isEqual;

/// Caller is responsible for freeing the result array
pub fn copyStringArrayListItemsToOwnedSlice(
    allocator: std.mem.Allocator,
    array_list: std.ArrayList([]u8),
) [][]u8 {
    var new_array = allocator.alloc([]u8, array_list.items.len) catch |err| {
        std.log.err("Failed to allocate memory for copy of array of strings: {}", .{err});
        std.process.exit(1);
    };

    for (array_list.items, 0..) |item, i| {
        new_array[i] = item;
    }

    return new_array;
}

pub fn stringArrayListContains(
    array_list: *std.ArrayList([]u8),
    value: []u8,
) bool {
    for (array_list.items) |item| {
        if (isEqual(item, value)) {
            return true;
        }
    }

    return false;
}

/// Removes the item in the array list in place
pub fn removeOneByValue(
    array_list: *std.ArrayList([]u8),
    value: []u8,
) void {
    for (array_list.items, 0..) |item, index| {
        if (isEqual(item, value)) {
            _ = array_list.orderedRemove(index);
            break;
        }
    }
}
