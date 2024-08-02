const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

const root = @import("root.zig");
const Vec3 = root.Vec3;
const P3 = root.P3;
const Color = root.Color;
const Ray = root.Ray;
const Sphere = root.Sphere;

pub fn rayColor(ray: Ray) Color {
    const sphere = Sphere.init(
        Vec3.init(0, 0, -1),
        0.5,
    );
    const collision = sphere.collisionAt(ray);
    switch (collision) {
        .hit => |t| {
            const point = ray.at(t);
            const normal = sphere.center.to(point).normed();
            // const color_vec = normal.abs();
            // const color_vec = normal.add(Vec3.init(1, 1, 1)).divScalar(2);
            const color_vec = normal.add(Vec3.init(1, 1, 1)).normed();
            return Color.fromVec3(color_vec);
        },
        else => {
            const unit_dir = ray.dir.normed();
            const a = 0.5 * (unit_dir.y() + 1.0);
            const white = Vec3.init(1.0, 1.0, 1.0);
            const blue = Vec3.init(0.5, 0.7, 1.0);
            return Color.fromVec3(white.lerp(blue, a));
        },
    }
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
            const pixel_center = pixel00_loc
                .add(pixel_delta_u.mulScalar(@floatFromInt(i)))
                .add(pixel_delta_v.mulScalar(@floatFromInt(j)));
            const ray_direction = camera_center.directionTo(pixel_center);
            const ray = Ray.init(camera_center, ray_direction);
            const color = rayColor(ray);

            try color.writeTo(writer);
            try writer.writeAll(if (i + 1 < width) "\t" else "\n");
        }
    }
    if (log) print("\r{s: <26}\n", .{"Done!"});
}
