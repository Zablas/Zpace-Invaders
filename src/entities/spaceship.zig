const rl = @import("raylib");

pub const Spaceship = struct {
    image: rl.Texture2D,
    position: rl.Vector2,

    pub fn init() !Spaceship {
        const image = try rl.loadTexture("assets/textures/spaceship.png");
        const position_x = @divFloor(rl.getScreenWidth() - image.width, 2);
        const position_y = rl.getScreenHeight() - image.height;

        return Spaceship{
            .image = image,
            .position = rl.Vector2{ .x = @floatFromInt(position_x), .y = @floatFromInt(position_y) },
        };
    }

    pub fn deinit(self: *Spaceship) void {
        rl.unloadTexture(self.image);
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
};
