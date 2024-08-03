const std = @import("std");
const Camera = @import("root.zig").Camera;
const testing = std.testing;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const width = 400;
    const aspect = 16.0 / 9.0;

    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    try Camera.render(allocator, buffered.writer(), width, aspect, true);
    try buffered.flush();
}
