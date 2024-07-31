const std = @import("std");
const rt = @import("root.zig");
const testing = std.testing;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try rt.imagePPM(stdout);
}
