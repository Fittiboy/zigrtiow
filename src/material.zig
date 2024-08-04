const std = @import("std");

const root = @import("root.zig");
const E = root.E;
const Ray = root.Ray;
const Collision = root.Collision;
const Color = root.Color;
const Vec3 = root.Vec3;

pub const Lambertian = @import("materials/lambertian.zig");
pub const Metal = @import("materials/metal.zig");

pub const ScatteredRay = struct {
    ray: Ray,
    attenuation: Vec3,
};

pub const Material = union(enum) {
    const Self = @This();
    lambertian: Lambertian,
    metal: Metal,

    pub fn lambertian(albedo: Vec3) Self {
        return .{ .lambertian = .{ .albedo = albedo } };
    }

    pub fn metal(albedo: Vec3, fuzz: E) Self {
        return .{ .metal = .{ .albedo = albedo, .fuzz = fuzz } };
    }

    pub fn scatter(
        self: Self,
        rand: std.Random,
        ray_in: Ray,
        collision: Collision,
    ) ?ScatteredRay {
        switch (self) {
            inline else => |mat| return mat.scatter(
                rand,
                ray_in,
                collision,
            ),
        }
    }

    pub fn default() Self {
        return .{ .lambertian = .{ .albedo = Vec3.init(0, 0, 0) } };
    }
};
