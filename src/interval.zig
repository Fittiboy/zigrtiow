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
