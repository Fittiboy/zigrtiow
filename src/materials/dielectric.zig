const std = @import("std");

const root = @import("../root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Collision = root.Collision;
const ScatteredRay = root.ScatteredRay;

const Self = @This();
ref_index: E,

pub fn scatter(
    self: Self,
    rand: std.Random,
    r_in: Ray,
    collision: Collision,
) ?ScatteredRay {
    const idx = if (collision.face == .front) 1.0 / self.ref_index else self.ref_index;

    const dir_in = r_in.dir.normed();
    const normal = collision.normal;
    const cos = -dir_in.dot(normal);
    const sin = @sqrt(1 - cos * cos);
    const dir = if (idx * sin > 1.0 or reflectance(cos, idx) > rand.float(E)) blk: {
        break :blk dir_in.reflected(normal);
    } else dir_in.refract(normal, idx);

    return .{ .ray = Ray.fromVecs(collision.p, dir), .attenuation = Vec3.init(1, 1, 1) };
}

fn reflectance(cos: E, index: E) E {
    // Schlick's approximation
    const r0 = blk: {
        const r0 = (1 - index) / (1 + index);
        break :blk r0 * r0;
    };
    return r0 + (1 - r0) * std.math.pow(E, (1 - cos), 5);
}
