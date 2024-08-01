const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vectors.Vec3;
const P3 = root.Vectors.P3;
const Colors = root.Colors;
const Color = Colors.Color;
const Ray = root.Rays.Ray;

pub fn rayColor(ray: Ray) Color {
    _ = ray;
    return Color.init(0, 0, 0);
}

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

    // Camera

    // The image's actual aspect ratio might not match ideal aspect ratio,
    // so we use the actual values for the viewport aspect ratio.
    const viewport_height: f64 = 2.0;
    const viewport_width: f64 = viewport_height * (width_f / height_f);
    const focal_length = 1.0;
    const camera_center = P3.init(0, 0, 0);

    // Horizontal (left->right) and vertical (top->bottom) viewport edges
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    const pixel_delta_u = viewport_u.divScalar(width_f);
    const pixel_delta_v = viewport_v.divScalar(height_f);

    const viewport_upper_left = camera_center
        .sub(Vec3.init(0, 0, focal_length))
        .sub(viewport_u.divScalar(2))
        .sub(viewport_v.divScalar(2));
    const pixel00_loc = viewport_upper_left
        .add(pixel_delta_u.add(pixel_delta_v).mulScalar(0.5));

    // Render image

    // We render the image in the
    // [PPM](https://en.wikipedia.org/wiki/Netpbm#PPM_example) format.
    try writer.print("P3\n{d} {d}\n{d}\n", .{ width, height, max_color });

    for (0..height) |j| {
        if (log) print("\rScanlines remaining: {d: >5}", .{height - j});
        for (0..width) |i| {
            // const color = Color.init(
            //     @as(f64, @floatFromInt(i)) / (width_f - 0.999),
            //     @as(f64, @floatFromInt(j)) / (height_f - 0.999),
            //     0.0,
            // );
            const pixel_center = pixel00_loc
                .add(pixel_delta_u.mulScalar(@floatFromInt(i)))
                .add(pixel_delta_v.mulScalar(@floatFromInt(j)));
            const ray_direction = pixel_center.sub(camera_center);
            const ray = Ray{ .orig = camera_center, .dir = ray_direction };
            const color = rayColor(ray);

            try Colors.writeColor(writer, color);
            try writer.writeAll(if (i + 1 < width) "\t" else "\n");
        }
    }
    if (log) print("\r{s: <26}\n", .{"Done!"});
}

// test imagePPM {
//     {
//         var buf: [59]u8 = undefined;
//         var stream = std.io.fixedBufferStream(&buf);
//         const writer = stream.writer();
//         try imagePPM(writer, 2, 1.0, false);

//         var exp_buf: [59]u8 = undefined;
//         var exp_stream = std.io.fixedBufferStream(&exp_buf);
//         const exp_writer = exp_stream.writer();
//         try exp_writer.print("{s}{s}{s}{s}{s}", .{
//             "P3\n",
//             "2 2\n",
//             "255\n",
//             "  0   0   0\t255   0   0\n",
//             "  0 255   0\t255 255   0\n",
//         });

//         try testing.expectEqualDeep(exp_buf[0..exp_stream.pos], buf[0..stream.pos]);
//     }

//     {
//         var buf: [35]u8 = undefined;
//         var stream = std.io.fixedBufferStream(&buf);
//         const writer = stream.writer();
//         try imagePPM(writer, 2, 16.0 / 9.0, false);

//         var exp_buf: [35]u8 = undefined;
//         var exp_stream = std.io.fixedBufferStream(&exp_buf);
//         const exp_writer = exp_stream.writer();
//         try exp_writer.print("{s}{s}{s}{s}", .{
//             "P3\n",
//             "2 1\n",
//             "255\n",
//             "  0   0   0\t255   0   0\n",
//         });

//         try testing.expectEqualDeep(exp_buf[0..exp_stream.pos], buf[0..stream.pos]);
//     }
// }
