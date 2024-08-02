const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

pub const E = f64;

pub const Images = @import("images.zig");

pub const Vec3 = @import("vector.zig");
pub const P3 = Vec3;

pub const Color = @import("color.zig");

pub const Ray = @import("ray.zig");

pub const Hittable = @import("hittable.zig").Hittable;
pub const Collision = Hittable.Collision;

pub const HittableList = @import("hittable_list.zig");

pub const Sphere = @import("sphere.zig");

pub const inf: E = std.math.inf(E);
pub const pi: E = std.math.pi;

pub fn degToRad(degrees: E) E {
    return degrees * pi / 180.0;
}

test {
    testing.refAllDecls(@import("images.zig"));
    testing.refAllDecls(@import("vector.zig"));
    testing.refAllDecls(@import("color.zig"));
    testing.refAllDecls(@import("ray.zig"));
    testing.refAllDecls(@import("hittable.zig"));
    testing.refAllDecls(@import("hittable_list.zig"));
    testing.refAllDecls(@import("sphere.zig"));
}
