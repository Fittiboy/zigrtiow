const std = @import("std");
const testing = std.testing;

pub fn imagePPM(writer: anytype) !void {
    // Image constants
    const width = 256;
    const height = 256;
    const color_depth = 255;

    // Render image

    // We render the image in the [PPM](https://en.wikipedia.org/wiki/Netpbm#PPM_example) format
    try writer.print("P3\n{d} {d}\n{d}\n", .{ width, height, color_depth });

    for (0..height) |j| {
        for (0..width) |i| {
            const r: f32 = @as(f32, @floatFromInt(i)) / (width - 1);
            const g: f32 = @as(f32, @floatFromInt(j)) / (height - 1);
            const b: f32 = 0.0;

            const ir: u32 = @intFromFloat(255.999 * r);
            const ig: u32 = @intFromFloat(255.999 * g);
            const ib: u32 = @intFromFloat(255.999 * b);

            try writer.print("{d: >3} {d: >3} {d: >3}", .{ ir, ig, ib });
            try writer.writeAll(if (i + 1 < width) "\t" else "\n");
        }
    }
}
