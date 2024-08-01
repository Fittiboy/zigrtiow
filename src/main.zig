const std = @import("std");
const rt = @import("root.zig");
const testing = std.testing;

pub fn main() !void {
    const width = 400;
    const aspect = 16.0 / 9.0;

    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    try rt.Images.imagePPM(buffered.writer(), width, aspect, true);
    try buffered.flush();
}
