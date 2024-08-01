const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

const Colors = @import("root.zig").Colors;
const Color = Colors.Color;

pub fn imagePPM(
    writer: anytype,
    width: usize,
    aspect_ratio: f64,
    comptime log: bool,
) !void {
    // Image constants
    const width_f: f64 = @floatFromInt(width);
    const max_color = 255;

    const height: usize = blk: {
        const h: usize = @intFromFloat(width_f / aspect_ratio);
        break :blk if (h >= 1) h else 1;
    };
    const height_f: f64 = @floatFromInt(height);

    const viewport_height: f64 = 2.0;
    // The image's real aspect ratio might not match ideal aspect ratio,
    // so we use the real value for the viewport aspect ratio.
    const viewport_width: f64 = viewport_height * (width_f / height_f);
    _ = viewport_width;

    // Render image

    // We render the image in the
    // [PPM](https://en.wikipedia.org/wiki/Netpbm#PPM_example) format.
    try writer.print("P3\n{d} {d}\n{d}\n", .{ width, height, max_color });

    for (0..height) |j| {
        if (log) print("\rScanlines remaining: {d: >5}", .{height - j});
        for (0..width) |i| {
            const color = Color.init(
                @as(f64, @floatFromInt(i)) / (width_f - 0.999),
                @as(f64, @floatFromInt(j)) / (height_f - 0.999),
                0.0,
            );

            try Colors.writeColor(writer, color);
            try writer.writeAll(if (i + 1 < width) "\t" else "\n");
        }
    }
    if (log) print("\r{s: <26}\n", .{"Done!"});
}

test imagePPM {
    {
        var buf: [59]u8 = undefined;
        var stream = std.io.fixedBufferStream(&buf);
        const writer = stream.writer();
        try imagePPM(writer, 2, 1.0, false);

        var exp_buf: [59]u8 = undefined;
        var exp_stream = std.io.fixedBufferStream(&exp_buf);
        const exp_writer = exp_stream.writer();
        try exp_writer.print("{s}{s}{s}{s}{s}", .{
            "P3\n",
            "2 2\n",
            "255\n",
            "  0   0   0\t255   0   0\n",
            "  0 255   0\t255 255   0\n",
        });

        try testing.expectEqualDeep(exp_buf[0..exp_stream.pos], buf[0..stream.pos]);
    }

    {
        var buf: [35]u8 = undefined;
        var stream = std.io.fixedBufferStream(&buf);
        const writer = stream.writer();
        try imagePPM(writer, 2, 16.0 / 9.0, false);

        var exp_buf: [35]u8 = undefined;
        var exp_stream = std.io.fixedBufferStream(&exp_buf);
        const exp_writer = exp_stream.writer();
        try exp_writer.print("{s}{s}{s}{s}", .{
            "P3\n",
            "2 1\n",
            "255\n",
            "  0   0   0\t255   0   0\n",
        });

        try testing.expectEqualDeep(exp_buf[0..exp_stream.pos], buf[0..stream.pos]);
    }
}
