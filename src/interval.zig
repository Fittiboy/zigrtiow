const std = @import("std");
const testing = std.testing;

const root = @import("root.zig");
const inf = root.inf;
const E = root.E;

pub const empty = Self.init(inf, -inf);
pub const universe = Self.init(-inf, inf);

const Self = @This();
min: E,
max: E,

pub fn init(min: E, max: E) Self {
    return .{
        .min = min,
        .max = max,
    };
}

pub fn size(self: Self) E {
    return self.max - self.min;
}

pub fn contains(self: Self, x: E) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: Self, x: E) bool {
    return self.min < x and x < self.max;
}

pub fn clamp(self: Self, x: E) E {
    return @min(self.max, @max(self.min, x));
}

test size {
    const int = Self.init(0, 100);

    try testing.expectEqual(100, int.size());
}

test contains {
    const int = Self.init(0, 100);

    try testing.expect(int.contains(100));
}

test surrounds {
    const int = Self.init(0, 100);

    try testing.expect(!int.surrounds(100));
}

test clamp {
    const int = Self.init(0, 100);

    try testing.expectEqual(0, int.clamp(-200));
    try testing.expectEqual(100, int.clamp(200));
}
