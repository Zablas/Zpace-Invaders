const std = @import("std");
const rl = @import("raylib");
const obstacle = @import("obstacle.zig");
const alien = @import("alien.zig");
const Spaceship = @import("spaceship.zig").Spaceship;
const Laser = @import("laser.zig").Laser;
const MysteryShip = @import("mystery_ship.zig").MysteryShip;

pub const Game = struct {
    spaceship: Spaceship,
    aliens: std.ArrayList(alien.Alien),
    alien_lasers: std.ArrayList(Laser),
    obstacles: [4]obstacle.Obstacle,
    mystery_ship: MysteryShip,
    time_last_alien_fired: f64,
    aliens_direction: f32 = 1,
    alien_laser_interval: f64 = 0.35,
    mystery_ship_spawn_interval: f64,
    time_last_spawn: f64,
    lives: i32 = 3,
    is_running: bool = true,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Game {
        const curr_time = rl.getTime();

        return Game{
            .spaceship = try Spaceship.init(allocator),
            .obstacles = try createObstacles(allocator),
            .aliens = try createAliens(allocator),
            .alien_lasers = std.ArrayList(Laser).init(allocator),
            .time_last_alien_fired = curr_time,
            .mystery_ship = try MysteryShip.init(),
            .time_last_spawn = curr_time,
            .mystery_ship_spawn_interval = @floatFromInt(rl.getRandomValue(10, 20)),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Game) void {
        alien.Alien.unloadIamges();
        self.deinitNonMedia();
    }

    pub fn deinitNonMedia(self: *Game) void {
        self.spaceship.deinit();
        self.mystery_ship.deinit();

        self.aliens.deinit();
        self.alien_lasers.deinit();

        for (&self.obstacles) |*o| {
            o.deinit();
        }
    }

    pub fn draw(self: Game) void {
        self.spaceship.draw();

        for (self.spaceship.lasers.items) |laser| {
            laser.draw();
        }

        for (self.alien_lasers.items) |laser| {
            laser.draw();
        }

        for (self.obstacles) |o| {
            o.draw();
        }

        for (self.aliens.items) |a| {
            a.draw();
        }

        self.mystery_ship.draw();
    }

    pub fn update(self: *Game) !void {
        if (!self.is_running) {
            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                try self.reset();
            }
            return;
        }

        const curr_time = rl.getTime();
        if (curr_time - self.time_last_spawn > self.mystery_ship_spawn_interval) {
            self.mystery_ship.spawn();
            self.time_last_spawn = curr_time;
            self.mystery_ship_spawn_interval = @floatFromInt(rl.getRandomValue(10, 20));
        }

        for (self.spaceship.lasers.items) |*laser| {
            laser.update();
        }

        self.moveAliens();

        try self.alienShootLaser();
        for (self.alien_lasers.items) |*laser| {
            laser.update();
        }
        self.mystery_ship.update();

        self.checkForCollisions();
        self.deleteInactiveLasers();
    }

    pub fn handleInput(self: *Game) !void {
        if (!self.is_running) {
            return;
        }

        if (rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right)) {
            self.spaceship.moveRight();
        } else if (rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left)) {
            self.spaceship.moveLeft();
        }

        if (rl.isKeyDown(rl.KeyboardKey.space)) {
            try self.spaceship.fireLaser();
        }
    }

    pub fn moveAliens(self: *Game) void {
        for (self.aliens.items) |*a| {
            const id: usize = @intFromEnum(a.alien_type);
            if (alien.alien_images[id] != null and @as(c_int, @intFromFloat(a.position.x)) + alien.alien_images[id].?.width > rl.getScreenWidth()) {
                self.aliens_direction = -1;
                self.moveDownAliens(4);
            } else if (a.position.x < 0) {
                self.aliens_direction = 1;
                self.moveDownAliens(4);
            }

            a.update(self.aliens_direction);
        }
    }

    fn moveDownAliens(self: *Game, distance: f32) void {
        for (self.aliens.items) |*a| {
            a.position.y += distance;
        }
    }

    fn alienShootLaser(self: *Game) !void {
        const curr_time = rl.getTime();
        if (curr_time - self.time_last_alien_fired < self.alien_laser_interval or self.aliens.items.len == 0) {
            return;
        }
        self.time_last_alien_fired = curr_time;

        const index: usize = @intCast(rl.getRandomValue(0, @intCast(self.aliens.items.len - 1)));
        const al = self.aliens.items[index];
        const id: usize = @intFromEnum(al.alien_type);
        const image = alien.alien_images[id];
        if (image == null) {
            return;
        }

        const position = rl.Vector2{
            .x = al.position.x + @as(f32, @floatFromInt(image.?.width)) / 2,
            .y = al.position.y + @as(f32, @floatFromInt(image.?.height)),
        };
        const laser = Laser.init(position, 6);

        try self.alien_lasers.append(laser);
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

        i = 0;
        while (i < self.alien_lasers.items.len) {
            if (!self.alien_lasers.items[i].is_active) {
                _ = self.alien_lasers.swapRemove(i);
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

    fn checkForCollisions(self: *Game) void {
        // Spaceship lasers
        outer: for (self.spaceship.lasers.items) |*laser| {
            const laser_rect = laser.getRect();

            var i: usize = 0;
            while (i < self.aliens.items.len) {
                if (rl.checkCollisionRecs(laser_rect, self.aliens.items[i].getRect())) {
                    _ = self.aliens.swapRemove(i);
                    laser.is_active = false;
                    break :outer;
                } else {
                    i += 1;
                }
            }

            for (&self.obstacles) |*o| {
                var j: usize = 0;
                while (j < o.blocks.items.len) {
                    if (rl.checkCollisionRecs(laser_rect, o.blocks.items[j].getRect())) {
                        _ = o.blocks.swapRemove(j);
                        laser.is_active = false;
                    } else {
                        j += 1;
                    }
                }
            }

            if (rl.checkCollisionRecs(laser_rect, self.mystery_ship.getRect())) {
                self.mystery_ship.is_alive = false;
                laser.is_active = false;
                break;
            }
        }

        // Alien lasers
        const spaceship_rect = self.spaceship.getRect();
        for (self.alien_lasers.items) |*laser| {
            const laser_rect = laser.getRect();

            if (rl.checkCollisionRecs(laser_rect, spaceship_rect)) {
                laser.is_active = false;
                self.lives -= 1;
                if (self.lives == 0) {
                    self.endGame();
                }
                break;
            }

            for (&self.obstacles) |*o| {
                var j: usize = 0;
                while (j < o.blocks.items.len) {
                    if (rl.checkCollisionRecs(laser_rect, o.blocks.items[j].getRect())) {
                        _ = o.blocks.swapRemove(j);
                        laser.is_active = false;
                    } else {
                        j += 1;
                    }
                }
            }
        }

        // Alien collision with an obstacle
        for (self.aliens.items) |a| {
            const alien_rect = a.getRect();

            for (&self.obstacles) |*o| {
                var i: usize = 0;
                while (i < o.blocks.items.len) {
                    if (rl.checkCollisionRecs(alien_rect, o.blocks.items[i].getRect())) {
                        _ = o.blocks.swapRemove(i);
                    } else {
                        i += 1;
                    }
                }
            }

            if (rl.checkCollisionRecs(alien_rect, spaceship_rect)) {
                self.endGame();
            }
        }
    }

    fn endGame(self: *Game) void {
        self.is_running = false;
    }

    fn reset(self: *Game) !void {
        self.deinitNonMedia();
        try self.reinit();
    }

    fn reinit(self: *Game) !void {
        const curr_time = rl.getTime();

        self.spaceship = try Spaceship.init(self.allocator);
        self.aliens = try createAliens(self.allocator);
        self.alien_lasers = std.ArrayList(Laser).init(self.allocator);
        self.obstacles = try createObstacles(self.allocator);
        self.mystery_ship = try MysteryShip.init();
        self.time_last_alien_fired = curr_time;
        self.aliens_direction = 1;
        self.alien_laser_interval = 0.35;
        self.mystery_ship_spawn_interval = @floatFromInt(rl.getRandomValue(10, 20));
        self.time_last_spawn = curr_time;
        self.lives = 3;
        self.is_running = true;
    }
};
