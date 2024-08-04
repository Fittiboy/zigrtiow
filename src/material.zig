const root = @import("root.zig");
const Ray = root.Ray;
const Collision = root.Collision;
const Color = root.Color;

pub const Material = union(enum) {
    const Self = @This();

    pub fn scatter(
        self: Self,
        ray_in: Ray,
        collision: Collision,
        attenuation: Color,
        scattered: Ray,
    ) bool {
        switch (self) {
            inline else => |mat| return mat.scatter(ray_in, collision, attenuation, scattered),
        }
    }
};
