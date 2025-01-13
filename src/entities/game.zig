const std = @import("std");
const rl = @import("raylib");
const obstacle = @import("obstacle.zig");
const alien = @import("alien.zig");
const Spaceship = @import("spaceship.zig").Spaceship;

pub const Game = struct {
    spaceship: Spaceship,
    aliens: std.ArrayList(alien.Alien),
    obstacles: [4]obstacle.Obstacle,

    pub fn init(allocator: std.mem.Allocator) !Game {
        return Game{
            .spaceship = try Spaceship.init(allocator),
            .obstacles = try createObstacles(allocator),
            .aliens = try createAliens(allocator),
        };
    }

    pub fn deinit(self: *Game) void {
        self.spaceship.deinit();

        for (self.aliens.items) |*a| {
            a.deinit();
        }
        self.aliens.deinit();

        for (&self.obstacles) |*o| {
            o.deinit();
        }
    }

    pub fn draw(self: Game) void {
        self.spaceship.draw();

        for (self.spaceship.lasers.items) |laser| {
            laser.draw();
        }

        for (self.obstacles) |o| {
            o.draw();
        }

        for (self.aliens.items) |a| {
            a.draw();
        }
    }

    pub fn update(self: *Game) void {
        for (self.spaceship.lasers.items) |*laser| {
            laser.update();
        }

        self.deleteInactiveLasers();
    }

    pub fn handleInput(self: *Game) !void {
        if (rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right)) {
            self.spaceship.moveRight();
        } else if (rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left)) {
            self.spaceship.moveLeft();
        }

        if (rl.isKeyDown(rl.KeyboardKey.space)) {
            try self.spaceship.fireLaser();
        }
    }

    fn deleteInactiveLasers(self: *Game) void {
        var i: usize = 0;
        while (i < self.spaceship.lasers.items.len) {
            if (!self.spaceship.lasers.items[i].is_active) {
                _ = self.spaceship.lasers.swapRemove(i);
            } else {
                i += 1;
            }
        }
    }

    fn createObstacles(allocator: std.mem.Allocator) ![4]obstacle.Obstacle {
        const obstacle_width = obstacle.grid[0].len * 3;
        const gap = (@as(f32, @floatFromInt(rl.getScreenWidth())) - @as(f32, @floatFromInt(4 * obstacle_width))) / 5;

        var obstacles: [4]obstacle.Obstacle = [_]obstacle.Obstacle{undefined} ** 4;
        for (0..4) |i| {
            const offset_x = @as(f32, @floatFromInt(i + 1)) * gap + @as(f32, @floatFromInt(i * obstacle_width));
            obstacles[i] = try obstacle.Obstacle.init(
                allocator,
                rl.Vector2{ .x = offset_x, .y = @floatFromInt(rl.getScreenHeight() - 100) },
            );
        }

        return obstacles;
    }

    fn createAliens(allocator: std.mem.Allocator) !std.ArrayList(alien.Alien) {
        var aliens = std.ArrayList(alien.Alien).init(allocator);

        for (0..5) |row| {
            for (0..11) |column| {
                const x: f32 = @floatFromInt(column * 55 + 75);
                const y: f32 = @floatFromInt(row * 55 + 110);
                const alien_type: alien.AlienType = switch (row) {
                    0 => .Type3,
                    1, 2 => .Type2,
                    else => .Type1,
                };
                try aliens.append(try alien.Alien.init(alien_type, rl.Vector2{ .x = x, .y = y }));
            }
        }

        return aliens;
    }
};
