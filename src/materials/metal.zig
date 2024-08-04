const std = @import("std");

const root = @import("../root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Collision = root.Collision;
const ScatteredRay = root.ScatteredRay;

const Self = @This();
albedo: Vec3,
fuzz: E = 0.0,

pub fn scatter(
    self: Self,
    rand: std.Random,
    ray_in: Ray,
    collision: Collision,
) ?ScatteredRay {
    const reflected = ray_in.dir.reflected(collision.normal).normed()
        .add(Vec3.randomUnit(rand).mulScalar(self.fuzz));

    return if (reflected.dot(collision.normal) <= 0) null else ScatteredRay{
        .ray = Ray.fromVecs(collision.p, reflected),
        .attenuation = self.albedo,
    };
}
