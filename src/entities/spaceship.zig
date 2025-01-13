const std = @import("std");
const rl = @import("raylib");
const laser = @import("laser.zig");

pub const Spaceship = struct {
    image: rl.Texture2D,
    position: rl.Vector2,
    lasers: std.ArrayList(laser.Laser),
    last_fire_time: f64,

    pub fn init(allocator: std.mem.Allocator) !Spaceship {
        const image = try rl.loadTexture("assets/textures/spaceship.png");
        const position_x = @divFloor(rl.getScreenWidth() - image.width, 2);
        const position_y = rl.getScreenHeight() - image.height;

        return Spaceship{
            .image = image,
            .position = rl.Vector2{ .x = @floatFromInt(position_x), .y = @floatFromInt(position_y) },
            .lasers = std.ArrayList(laser.Laser).init(allocator),
            .last_fire_time = rl.getTime(),
        };
    }

    pub fn deinit(self: *Spaceship) void {
        rl.unloadTexture(self.image);
        self.lasers.deinit();
    }

    pub fn draw(self: Spaceship) void {
        rl.drawTextureV(self.image, self.position, rl.Color.white);
    }

    pub fn moveLeft(self: *Spaceship) void {
        self.position.x -= 7;

        if (self.position.x < 0) {
            self.position.x = 0;
        }
    }

    pub fn moveRight(self: *Spaceship) void {
        self.position.x += 7;

        const right_boundary: f32 = @floatFromInt(rl.getScreenWidth() - self.image.width);
        if (self.position.x > right_boundary) {
            self.position.x = right_boundary;
        }
    }

    pub fn fireLaser(self: *Spaceship) !void {
        const curr_time = rl.getTime();
        if (curr_time - self.last_fire_time < 0.35) {
            return;
        }
        self.last_fire_time = curr_time;

        const position = rl.Vector2{
            .x = self.position.x + @as(f32, @floatFromInt(@divFloor(self.image.width, 2))) - 2,
            .y = self.position.y,
        };
        try self.lasers.append(laser.Laser.init(position, -6));
    }
};
