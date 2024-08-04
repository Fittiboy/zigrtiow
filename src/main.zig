const std = @import("std");
const root = @import("root.zig");
const Vec3 = root.Vec3;
const Camera = root.Camera;
const Hittable = root.Hittable;
const HittableList = root.HittableList;
const testing = std.testing;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var world = try HittableList.init(allocator);
    defer world.deinit();
    try world.add(Hittable.initSphere(.{ 0, 0, -1 }, 0.5));
    try world.add(Hittable.initSphere(.{ 0, -100.5, -1 }, 100));

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
