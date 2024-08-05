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
const Material = root.Material;

const Self = @This();
aspect_ratio: E,
width: usize,
samples_per_pixel: usize,
max_depth: usize,
pixel_sample_scale: E,
height: usize,
center: P3,
pixel00_loc: P3,
pixel_delta_u: Vec3,
pixel_delta_v: Vec3,

pub const CameraConfig = struct {
    aspect_ratio: E = 1.0,
    width: usize = 100,
    samples_per_pixel: usize = 10,
    max_depth: usize = 10,
    vfov: E = 90,
};

pub fn init(
    config: CameraConfig,
) Self {
    const width_f: f64 = @floatFromInt(config.width);
    const height = @max(@as(usize, @intFromFloat(width_f / config.aspect_ratio)), 1);
    const height_f: f64 = @floatFromInt(height);

    const camera_center = P3.fromArray(.{ 0, 0, 0 });

    // Viewport dimensions based on vertical FOV
    const focal_length = 1.0;
    const theta = root.degToRad(config.vfov);
    const h = std.math.tan(theta / 2);
    const viewport_height: f64 = 2.0 * h * focal_length;
    const viewport_width: f64 = viewport_height * (width_f / height_f);

    // Horizontal (left->right) and vertical (top->bottom) viewport edges
    const viewport_u = Vec3.fromArray(.{ viewport_width, 0, 0 });
    const viewport_v = Vec3.fromArray(.{ 0, -viewport_height, 0 });

    const pixel_delta_u = viewport_u.divScalar(width_f);
    const pixel_delta_v = viewport_v.divScalar(height_f);

    const viewport_upper_left = camera_center
        .sub(Vec3.fromArray(.{ 0, 0, focal_length }))
        .sub(viewport_u.divScalar(2))
        .sub(viewport_v.divScalar(2));
    const pixel00_loc = viewport_upper_left
        .add(pixel_delta_u.add(pixel_delta_v).mulScalar(0.5));

    return Self{
        .aspect_ratio = config.aspect_ratio,
        .width = config.width,
        .samples_per_pixel = config.samples_per_pixel,
        .pixel_sample_scale = 1.0 / @as(E, @floatFromInt(config.samples_per_pixel)),
        .max_depth = config.max_depth,
        .height = height,
        .center = camera_center,
        .pixel00_loc = pixel00_loc,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
    };
}

fn rayColorValue(rand: std.Random, ray: Ray, world: HittableList, depth: usize) Vec3 {
    if (depth == 0) return Vec3.init(0, 0, 0);

    if (world.hit(Interval.init(0.001, root.inf), ray)) |c| {
        if (c.matRef().scatter(rand, ray, c)) |s| {
            return rayColorValue(rand, s.ray, world, depth - 1).mul(s.attenuation);
        }
        return Vec3.init(0, 0, 0);
    }

    const a = 0.5 * (ray.dir.normed().y() + 1.0);
    const white = Vec3.fromArray(.{ 1.0, 1.0, 1.0 });
    const blue = Vec3.fromArray(.{ 0.5, 0.7, 1.0 });
    return white.lerp(blue, a);
}

pub fn render(self: Self, world: HittableList, writer: anytype, logging: bool) !void {
    var prng = try root.rng();
    const rand = prng.random();
    // We render the image in the
    // [PPM](https://en.wikipedia.org/wiki/Netpbm#PPM_example) format.
    const max_color = 255;
    try writer.print("P3\n{d} {d}\n{d}\n", .{ self.width, self.height, max_color });

    for (0..self.height) |j| {
        if (logging) print("\rScanlines remaining: {d: >5}", .{self.height - j});
        for (0..self.width) |i| {
            var color_value = Vec3.fromArray(.{ 0, 0, 0 });
            for (0..self.samples_per_pixel) |_| {
                const ray = self.getRay(i, j, rand);
                color_value = color_value.add(rayColorValue(rand, ray, world, self.max_depth));
            }
            const averaged = color_value.mulScalar(self.pixel_sample_scale);
            const color = Color.fromVec3(averaged);
            try color.writeTo(writer);
            try writer.writeAll(if (i + 1 < self.width) "\t" else "\n");
        }
    }
    if (logging) print("\r{s: <26}\n", .{"Done!"});
}

fn getRay(self: Self, i: usize, j: usize, rand: std.Random) Ray {
    const offset = sampleSquare(rand);
    const sample = self.pixel00_loc
        .add(self.pixel_delta_u.mulScalar(@as(E, @floatFromInt(i)) + offset.x()))
        .add(self.pixel_delta_v.mulScalar(@as(E, @floatFromInt(j)) + offset.y()));
    return Ray.fromVecs(self.center, self.center.to(sample));
}

fn sampleSquare(rand: std.Random) Vec3 {
    return Vec3.fromArray(.{ rand.float(E) - 0.5, rand.float(E) - 0.5, 0 });
}
