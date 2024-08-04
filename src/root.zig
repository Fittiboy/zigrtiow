const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

pub const E = f64;

pub const Camera = @import("camera.zig");

pub const Vec3 = @import("vector.zig");
pub const P3 = Vec3;

pub const Color = @import("color.zig");

pub const Ray = @import("ray.zig");

pub const Hittable = @import("hittable.zig").Hittable;
pub const Collision = Hittable.Collision;

pub const HittableList = @import("hittable_list.zig");

pub const Sphere = @import("sphere.zig");

pub const Interval = @import("interval.zig");

pub const RefCounter = @import("ref_counted.zig");

pub const Material = @import("material.zig").Material;

pub const inf: E = std.math.inf(E);
pub const pi: E = std.math.pi;

pub inline fn degToRad(degrees: E) E {
    return degrees * pi / 180.0;
}

pub fn rng() !std.Random.Xoshiro256 {
    return std.Random.DefaultPrng.init(blk: {
        var seed: usize = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
}

pub fn randomRange(rand: std.Random, min: E, max: E) E {
    std.debug.assert(max - min >= 0);
    return min + (max - min) * rand.float(E);
}

test {
    testing.refAllDecls(@import("camera.zig"));
    testing.refAllDecls(@import("vector.zig"));
    testing.refAllDecls(@import("color.zig"));
    testing.refAllDecls(@import("ray.zig"));
    testing.refAllDecls(@import("hittable.zig"));
    testing.refAllDecls(@import("hittable_list.zig"));
    testing.refAllDecls(@import("sphere.zig"));
    testing.refAllDecls(@import("interval.zig"));
    testing.refAllDecls(@import("ref_counted.zig"));
    testing.refAllDecls(@import("material.zig"));
}
