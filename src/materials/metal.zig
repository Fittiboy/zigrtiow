const std = @import("std");

const root = @import("../root.zig");
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Collision = root.Collision;
const ScatteredRay = root.ScatteredRay;

const Self = @This();
albedo: Vec3,

pub fn scatter(
    self: Self,
    _: std.Random,
    ray_in: Ray,
    collision: Collision,
) ?ScatteredRay {
    const reflected = ray_in.dir.reflected(collision.normal);

    return ScatteredRay{
        .ray = Ray.fromVecs(collision.p, reflected),
        .attenuation = self.albedo,
    };
}
