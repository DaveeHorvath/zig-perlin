const std = @import("std");

const Vec2 = struct { x: f32, y: f32 };

pub fn main() !void {
    const chars = [_]*const [3:0]u8{
        "000",
        "032",
        "064",
        "096",
        "128",
        "160",
        "192",
        "224",
        "255",
    };
    const size: i32 = 50;
    const step: f32 = 0.01;
    var offsetX: f32 = 0;
    var offsetY: f32 = 0;

    while (true) {
        std.debug.print("\x1B[2J\x1B[H", .{});
        offsetX += step * 2;
        offsetY += step;
        var y: f32 = 0;
        while (y < size * step) {
            var x: f32 = 0;
            while (x < size * step) {
                std.debug.print("\x1B[38;2;{0s};0;{0s}m■ ", .{chars[@as(u32, @intFromFloat(perlin(x + offsetX, y + offsetY) * chars.len))]});
                x += step;
            }
            std.debug.print("\n", .{});
            y += step;
        }
        std.time.sleep(2e8);
    }
}

pub fn getGridVector(x: i32, y: i32, _seed: u64) Vec2 {
    var prng = std.Random.DefaultPrng.init(blk: {
        // xor should make it unique, since the second components is
        // maybe another function would be better as neighbouring values have very similar values
        const seed: u64 = _seed ^ @as(u64, @bitCast(@as(i64, x) | @as(i64, y) << 32));
        break :blk seed;
    });
    const rand = prng.random();
    const angle = rand.float(f32);
    return Vec2{ .x = @cos(angle), .y = @sin(angle) };
}

pub fn getDotFromVector(vec: Vec2, dx: f32, dy: f32) f32 {
    return (vec.x * dx + vec.y * dy);
}

// coefficients 6t^5 - 15t^4 + 10t^3 based on
// https://mrl.cs.nyu.edu/~perlin/paper445.pdf
pub fn interploate(a0: f32, a1: f32, w: f32) f32 {
    return (a1 - a0) * ((6 * w - 15) * w + 10) * w * w * w + a0;
}

pub fn perlin(x: f32, y: f32) f32 {
    // grippoints where our x,y lies inbetween
    const x0: i32 = @as(i32, @intFromFloat(@floor(x)));
    const y0: i32 = @as(i32, @intFromFloat(@floor(y)));
    const seed: u64 = 0; // this should actually be random or assigned on creation

    // coefficients per axis
    const dx: f32 = x - @as(f32, @floatFromInt(x0));
    const dy: f32 = y - @as(f32, @floatFromInt(y0));

    // x direction interpolations
    const ix0: f32 = interploate(getDotFromVector(getGridVector(x0, y0, seed), dx, dy), getDotFromVector(getGridVector(x0 + 1, y0, seed), 1 - dx, dy), dx);
    const ix1: f32 = interploate(getDotFromVector(getGridVector(x0, y0 + 1, seed), dx, 1 - dy), getDotFromVector(getGridVector(x0 + 1, y0 + 1, seed), 1 - dx, 1 - dy), dx);

    // y direction interpolation
    return interploate(ix0, ix1, dy);
}
