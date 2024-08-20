const std = @import("std");
const expectEqualSlices = std.testing.expectEqualSlices;

pub fn expectEqualStringArrays(expected_slice: []const []const u8, slice: [][]u8) !void {
    for (slice, 0..) |item, index| {
        try expectEqualSlices(u8, expected_slice[index], item);
    }
}
