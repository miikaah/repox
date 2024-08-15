const std = @import("std");

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
