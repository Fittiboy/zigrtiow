const root = @import("root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const Ray = root.Ray;
const Sphere = root.Sphere;

pub const Hittable = union(enum) {
    const Self = @This();
    sphere: Sphere,

    pub const Collision = struct {
        t: E,
        normal: Vec3,
    };

    pub fn collisionAt(self: Self, t_min: E, t_max: E, ray: Ray) ?Collision {
        switch (self) {
            inline else => |hittable| hittable.collisionAt(t_min, t_max, ray),
        }
    }
};
