const std = @import("std");
const rt = @import("root.zig");
const testing = std.testing;

pub fn main() !void {
    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    try rt.Images.imagePPM(buffered.writer(), true);
    try buffered.flush();
}
