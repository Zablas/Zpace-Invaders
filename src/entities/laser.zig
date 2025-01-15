const rl = @import("raylib");
const colors = @import("constants").colors;

pub const Laser = struct {
    position: rl.Vector2,
    speed: i32,
    is_active: bool = true,

    pub fn init(position: rl.Vector2, speed: i32) Laser {
        return Laser{
            .position = position,
            .speed = speed,
        };
    }

    pub fn draw(self: Laser) void {
        if (!self.is_active) {
            return;
        }

        rl.drawRectangle(
            @intFromFloat(self.position.x),
            @intFromFloat(self.position.y),
            4,
            15,
            colors.yellow,
        );
    }

    pub fn update(self: *Laser) void {
        if (!self.is_active) {
            return;
        }

        self.position.y += @floatFromInt(self.speed);
        if (self.position.y < 0 or self.position.y > @as(f32, @floatFromInt(rl.getScreenHeight()))) {
            self.is_active = false;
        }
    }

    pub fn getRect(self: Laser) rl.Rectangle {
        return rl.Rectangle.init(self.position.x, self.position.y, 8, 15);
    }
};
