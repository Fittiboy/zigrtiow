const std = @import("std");
const root = @import("root.zig");
const Vec3 = root.Vec3;
const Camera = root.Camera;
const Hittable = root.Hittable;
const HittableList = root.HittableList;
const Color = root.Color;
const RefCounted = root.RefCounted;
const Material = root.Material;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var world = try HittableList.init(allocator);
    defer world.deinit();

    const materials = [_]Material{
        Material.lambertian(Vec3.init(0.8, 0.8, 0.0)), // ground
        Material.lambertian(Vec3.init(0.1, 0.2, 0.5)), // center
        Material.dielectric(1.0 / 1.33), // left outer
        Material.dielectric(1.0 / 1.5), // left inner
        Material.metal(Vec3.init(0.8, 0.6, 0.2), 1.0), // right
    };
    const MatCount = RefCounted(Material);
    const mat_refs = try allocator.alloc(MatCount, 4);
    defer MatCount.free(mat_refs, allocator);
    for (materials, 0..mat_refs.len) |material, i| {
        const mat = try MatCount.create(allocator);
        mat.data.value = material;
        mat_refs[i] = mat;
    }

    const ground = Hittable.initSphere(.{ 0.0, -100.5, -1.0 }, 100, mat_refs[0]);
    defer ground.deinit();
    const center = Hittable.initSphere(.{ 0.0, 0, -1.2 }, 0.5, mat_refs[1]);
    defer center.deinit();
    const left_outer = Hittable.initSphere(.{ -1.0, 0, -1.0 }, 0.5, mat_refs[2]);
    defer left_outer.deinit();
    // const left_inner = Hittable.initSphere(.{ -1.0, 0, -1.0 }, 0.45, mat_refs[3]);
    // defer left_inner.deinit();
    const right = Hittable.initSphere(.{ 1.0, 0, -1.0 }, 0.5, mat_refs[4]);
    defer right.deinit();
    try world.add(ground);
    try world.add(center);
    try world.add(left_outer);
    // try world.add(left_inner);
    try world.add(right);

    const width = 400;
    const aspect = 16.0 / 9.0;
    const camera = blk: {
        var camera = Camera.init(aspect, width, 100, 50);
        camera.logging = true;
        break :blk camera;
    };

    var stdout = std.io.getStdOut();
    var buffered = std.io.bufferedWriter(stdout.writer());
    try camera.render(world, buffered.writer());
    try buffered.flush();
}
