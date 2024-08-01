const std = @import("std");
const print = std.debug.print;

const Colors = @import("root.zig").Colors;
const Color = Colors.Color;

pub fn imagePPM(writer: anytype, comptime log: bool) !void {
    // Image constants
    const width = 256;
    const height = 256;
    const max_color = 255;

    // Render image

    // We render the image in the [PPM](https://en.wikipedia.org/wiki/Netpbm#PPM_example) format
    try writer.print("P3\n{d} {d}\n{d}\n", .{ width, height, max_color });

    for (0..height) |j| {
        if (log) print("\rScanlines remaining: {d: >5}", .{height - j});
        for (0..width) |i| {
            const color = Color.init(
                @as(f64, @floatFromInt(i)) / (width - 1),
                @as(f64, @floatFromInt(j)) / (height - 1),
                0.0,
            );

            try Colors.writeColor(writer, color);
            try writer.writeAll(if (i + 1 < width) "\t" else "\n");
        }
    }
    if (log) print("\r{s: <26}\n", .{"Done!"});
}
