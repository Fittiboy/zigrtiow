const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const root = @import("root.zig");
const E = root.E;
const Ray = root.Ray;
const Hittable = root.Hittable;
const Collision = root.Collision;
const Interval = root.Interval;

const Self = @This();
objects: std.ArrayList(Hittable),

pub fn init(alloc: Allocator) !Self {
    return .{ .objects = std.ArrayList(Hittable).init(alloc) };
}

pub fn deinit(self: Self) void {
    self.objects.deinit();
}

pub fn add(self: *Self, object: Hittable) !void {
    try self.objects.append(object);
}

pub fn clear(self: *Self) !void {
    self.objects.clearRetainingCapacity();
}

pub fn hit(self: Self, interval: Interval, ray: Ray) ?Collision {
    var collision: ?Collision = null;
    var closest = interval;

    for (self.objects.items) |object| {
        if (object.collisionAt(closest, ray)) |coll| {
            closest.max = coll.t;
            collision = coll;
        }
    }

    return collision;
}

test add {
    var list = try Self.init(testing.allocator);
    defer list.deinit();
    try testing.expectEqual(0, list.objects.items.len);
    try list.add(Hittable.initSphere(
        .{ 0, 0, 0 },
        1,
    ));

    try testing.expectEqual(1, list.objects.items.len);
}

test clear {
    const alloc = std.testing.allocator;
    var objects = std.ArrayList(Hittable).init(alloc);
    defer objects.deinit();
    try objects.append(Hittable.initSphere(
        .{ 0, 0, 0 },
        1,
    ));
    var list = Self{ .objects = objects };
    try list.clear();

    try testing.expectEqual(0, list.objects.items.len);
}
