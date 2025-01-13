const std = @import("std");
const rl = @import("raylib");
const Spaceship = @import("spaceship.zig").Spaceship;

pub const Game = struct {
    spaceship: Spaceship,

    pub fn init(allocator: std.mem.Allocator) !Game {
        return Game{
            .spaceship = try Spaceship.init(allocator),
        };
    }

    pub fn deinit(self: *Game) void {
        self.spaceship.deinit();
    }

    pub fn draw(self: Game) void {
        self.spaceship.draw();

        for (self.spaceship.lasers.items) |*laser| {
            laser.draw();
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
};
