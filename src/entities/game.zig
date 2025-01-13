const std = @import("std");
const rl = @import("raylib");
const Spaceship = @import("spaceship.zig").Spaceship;
const obstacle = @import("obstacle.zig");

pub const Game = struct {
    spaceship: Spaceship,
    obstacles: [4]obstacle.Obstacle = undefined,

    pub fn init(allocator: std.mem.Allocator) !Game {
        var game = Game{
            .spaceship = try Spaceship.init(allocator),
        };
        game.obstacles = try createObstacles(allocator);

        return game;
    }

    pub fn deinit(self: *Game) void {
        self.spaceship.deinit();

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
};
