const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

fn RefCounted(comptime T: type) type {
    return struct {
        const Self = @This();

        const Data = struct {
            value: T,
            ref_count: usize,
            allocator: Allocator,
        };

        data: *Data,

        pub fn create(allocator: Allocator) !Self {
            const data = try allocator.create(Data);
            data.* = Data{
                .value = undefined,
                .ref_count = 1,
                .allocator = allocator,
            };
            return Self{ .data = data };
        }

        pub fn deinit(self: Self) void {
            self.data.ref_count -= 1;
            if (self.data.ref_count == 0) {
                const allocator = self.data.allocator;
                allocator.destroy(self.data);
            }
        }

        pub fn strongRef(self: Self) Self {
            self.data.ref_count += 1;
            return Self{ .data = self.data };
        }

        pub fn weakRef(self: Self) *T {
            return &self.data.value;
        }
    };
}

test "create" {
    var fourty_two = try RefCounted(u32).create(testing.allocator);
    defer fourty_two.deinit();
    fourty_two.data.value = 42;
    try testing.expectEqual(42, fourty_two.data.value);
    try testing.expectEqual(1, fourty_two.data.ref_count);
}

test "strongRef" {
    const rc = try RefCounted(u32).create(testing.allocator);
    defer rc.deinit();
    const second_ref = rc.strongRef();
    defer second_ref.deinit();

    try testing.expectEqual(2, rc.data.ref_count);
}

test "weakRef" {
    var fourty_two = try RefCounted(u32).create(testing.allocator);
    defer fourty_two.deinit();
    fourty_two.data.value = 42;
    const weak_ref = fourty_two.weakRef();
    const expected: u32 = 42;

    try testing.expectEqual(expected, weak_ref.*);
}
