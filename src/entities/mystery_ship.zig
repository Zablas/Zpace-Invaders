const rl = @import("raylib");
const constants = @import("constants");

const ui = constants.ui;

pub const MysteryShip = struct {
    image: rl.Texture2D,
    position: rl.Vector2,
    speed: f32 = 0,
    is_alive: bool = false,

    pub fn init() !MysteryShip {
        return MysteryShip{
            .image = try rl.loadTexture("assets/textures/mystery.png"),
            .position = rl.Vector2.zero(),
        };
    }

    pub fn deinit(self: *MysteryShip) void {
        rl.unloadTexture(self.image);
    }

    pub fn spawn(self: *MysteryShip) void {
        self.position.y = 90;
        const side = rl.getRandomValue(0, 1);

        if (side == 0) {
            self.position.x = @divFloor(ui.offset, 2);
            self.speed = 3;
        } else {
            self.position.x = @floatFromInt(rl.getScreenWidth() - self.image.width - @divFloor(ui.offset, 2));
            self.speed = -3;
        }

        self.is_alive = true;
    }

    pub fn update(self: *MysteryShip) void {
        if (!self.is_alive) {
            return;
        }

        self.position.x += self.speed;
        const offset = @divFloor(ui.offset, 2);

        if (self.position.x > @as(f32, @floatFromInt(rl.getScreenWidth() - self.image.width - offset)) or self.position.x < offset) {
            self.is_alive = false;
        }
    }

    pub fn draw(self: MysteryShip) void {
        if (!self.is_alive) {
            return;
        }

        rl.drawTextureV(self.image, self.position, rl.Color.white);
    }

    pub fn getRect(self: MysteryShip) rl.Rectangle {
        return rl.Rectangle.init(
            self.position.x,
            self.position.y,
            if (self.is_alive) @floatFromInt(self.image.width) else 0,
            if (self.is_alive) @floatFromInt(self.image.height) else 0,
        );
    }
};
