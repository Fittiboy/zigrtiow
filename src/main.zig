const std = @import("std");

const root = @import("root.zig");
const E = root.E;
const Vec3 = root.Vec3;
const P3 = root.P3;
const Camera = root.Camera;
const Hittable = root.Hittable;
const HittableList = root.HittableList;
const Color = root.Color;
const RefCounted = root.RefCounted;
const Material = root.Material;

const pi = root.pi;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var world = try HittableList.init(allocator);
    defer world.deinit();

    const ground_mat = try Material.lambertian(Vec3.init(0.5, 0.5, 0.5)).counted(allocator);
    defer ground_mat.deinit();
    try world.add(Hittable.initSphere(.{ 0, -1000, 0 }, 1000, ground_mat));

    var prng = try root.rng();
    const rand = prng.random();
    for (0..22) |a_pos| for (0..22) |b_pos| {
        const a: f64 = @as(f64, @floatFromInt(a_pos)) - 11;
        const b: f64 = @as(f64, @floatFromInt(b_pos)) - 11;
        const choose_mat = rand.float(E);
        const center = [_]E{ a + 0.9 * rand.float(E), 0.2, b + 0.9 * rand.float(E) };

        if (P3.init(4, 0.2, 0).to(P3.fromArray(center)).length() > 0.9) {
            const mat = try RefCounted(Material).create(allocator);
            defer mat.deinit();

            if (choose_mat < 0.8) {
                const albedo = Vec3.random(rand).mul(Vec3.random(rand));
                mat.data.value = Material.lambertian(albedo);
            } else if (choose_mat < 0.95) {
                const albedo = Vec3.randomRange(rand, 0.5, 1);
                const fuzz = root.randomRange(rand, 0, 0.5);
                mat.data.value = Material.metal(albedo, fuzz);
            } else {
                mat.data.value = Material.dielectric(1.5);
            }
            try world.add(Hittable.initSphere(center, 0.2, mat));
        }
    };

    const mat1 = try Material.dielectric(1.5).counted(allocator);
    defer mat1.deinit();
    try world.add(Hittable.initSphere(.{ 0, 1, 0 }, 1.0, mat1));

    const mat2 = try Material.lambertian(Vec3.init(0.4, 0.2, 0.1)).counted(allocator);
    defer mat2.deinit();
    try world.add(Hittable.initSphere(.{ -4, 1, 0 }, 1.0, mat2));

    const mat3 = try Material.metal(Vec3.init(0.7, 0.6, 0.5), 0.0).counted(allocator);
    defer mat3.deinit();
    try world.add(Hittable.initSphere(.{ 4, 1, 0 }, 1.0, mat3));

    const camera = Camera.init(.{
        .aspect_ratio = 16.0 / 9.0,
        .width = 1200,
        .samples_per_pixel = 500,
        .max_depth = 50,
        .vfov = 20,
        .defocus_angle = 0.6,
        .focus_dist = 10.0,
        .position = .{
            .look_from = P3.init(13, 2, 3),
            .look_at = P3.init(0, 0, 0),
            .v_up = Vec3.init(0, 1, 0),
        },
    });

    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    try camera.render(world, buffered.writer(), true);
    try buffered.flush();
}
