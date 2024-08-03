const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const testing = std.testing;

const root = @import("root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const P3 = root.P3;
const Color = root.Color;
const Ray = root.Ray;
const Hittable = root.Hittable;
const HittableList = root.HittableList;
const Sphere = root.Sphere;
const Interval = root.Interval;

const Self = @This();
aspect_ratio: E = 1.0,
width: usize = 100,
height: usize,
center: P3,
pixel00_loc: P3,
pixel_delta_u: Vec3,
pixel_delta_v: Vec3,
logging: bool = false,

pub fn init(aspect_ratio: ?E, image_width: ?usize) Self {
    const ratio = aspect_ratio orelse 1.0;
    const width = image_width orelse 100;

    const width_f: f64 = @floatFromInt(width);
    const height: usize = blk: {
        const h: usize = @intFromFloat(width_f / ratio);
        break :blk if (h >= 1) h else 1;
    };
    const height_f: f64 = @floatFromInt(height);

    const camera_center = P3.init(.{ 0, 0, 0 });
    const focal_length = 1.0;

    // The image's actual aspect ratio might not match chosen aspect ratio,
    // so we use the actual values for the viewport aspect ratio.
    const viewport_height: f64 = 2.0;
    const viewport_width: f64 = viewport_height * (width_f / height_f);

    // Horizontal (left->right) and vertical (top->bottom) viewport edges
    const viewport_u = Vec3.init(.{ viewport_width, 0, 0 });
    const viewport_v = Vec3.init(.{ 0, -viewport_height, 0 });

    const pixel_delta_u = viewport_u.divScalar(width_f);
    const pixel_delta_v = viewport_v.divScalar(height_f);

    const viewport_upper_left = camera_center
        .sub(Vec3.init(.{ 0, 0, focal_length }))
        .sub(viewport_u.divScalar(2))
        .sub(viewport_v.divScalar(2));
    const pixel00_loc = viewport_upper_left
        .add(pixel_delta_u.add(pixel_delta_v).mulScalar(0.5));

    return Self{
        .aspect_ratio = ratio,
        .width = width,
        .height = height,
        .center = camera_center,
        .pixel00_loc = pixel00_loc,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
    };
}

fn rayColor(ray: Ray, world: HittableList) Color {
    if (world.hit(Interval.init(0, root.inf), ray)) |c| {
        return Color.fromVec3(c.normal.addScalar(1).divScalar(2));
    } else {
        const a = 0.5 * (ray.dir.normed().y() + 1.0);
        const white = Vec3.init(.{ 1.0, 1.0, 1.0 });
        const blue = Vec3.init(.{ 0.5, 0.7, 1.0 });
        return Color.fromVec3(white.lerp(blue, a));
    }
}

pub fn render(self: Self, world: HittableList, writer: anytype) !void {
    // We render the image in the
    // [PPM](https://en.wikipedia.org/wiki/Netpbm#PPM_example) format.
    const max_color = 255;
    try writer.print("P3\n{d} {d}\n{d}\n", .{ self.width, self.height, max_color });

    for (0..self.height) |j| {
        if (self.log) print("\rScanlines remaining: {d: >5}", .{self.height - j});
        for (0..self.width) |i| {
            const pixel_center = self.pixel00_loc
                .add(self.pixel_delta_u.mulScalar(@floatFromInt(i)))
                .add(self.pixel_delta_v.mulScalar(@floatFromInt(j)));
            const ray_direction = self.center.to(pixel_center);
            const ray = Ray.init(self.center, ray_direction);
            const color = rayColor(ray, world);

            try color.writeTo(writer);
            try writer.writeAll(if (i + 1 < self.width) "\t" else "\n");
        }
    }
    if (self.log) print("\r{s: <26}\n", .{"Done!"});
}
