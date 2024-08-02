const root = @import("root.zig");
const Ray = root.Ray;
const Sphere = root.Sphere;
const E = root.E;
const Vec3 = root.Vec3;

pub const Hittable = union(enum) {
    const Self = @This();
    sphere: Sphere,

    pub const Collision = union(enum) {
        hit: struct {
            t: E,
            normal: Vec3,
        },
        inside: E,
        miss,
    };

    pub fn collisionAt(self: Self, ray: Ray) Collision {
        switch (self) {
            inline else => |hittable| hittable.collisionAt(ray),
        }
    }

    pub fn hitBy(self: Self, ray: Ray) Collision {
        switch (self) {
            inline else => |hittable| hittable.hitBy(ray),
        }
    }
};
