const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

pub const Images = @import("images.zig");

pub const Vectors = @import("vectors.zig");
const Vec3 = Vectors.Vec3;
const P3 = Vectors.P3;

pub const Colors = @import("colors.zig");
const Color = Colors.Color;

pub const Rays = @import("rays.zig");
const Ray = Rays.Ray;

test {
    testing.refAllDecls(@import("vectors.zig"));
    testing.refAllDecls(@import("colors.zig"));
    testing.refAllDecls(@import("rays.zig"));
}
