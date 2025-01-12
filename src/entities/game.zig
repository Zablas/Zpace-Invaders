const rl = @import("raylib");
const Spaceship = @import("spaceship.zig").Spaceship;

pub const Game = struct {
    spaceship: Spaceship,

    pub fn init() !Game {
        return Game{
            .spaceship = try Spaceship.init(),
        };
    }

    pub fn deinit(self: *Game) void {
        self.spaceship.deinit();
    }

    pub fn draw(self: Game) void {
        self.spaceship.draw();
    }

    pub fn handleInput(self: *Game) void {
        if (rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right)) {
            self.spaceship.moveRight();
        } else if (rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left)) {
            self.spaceship.moveLeft();
        }
    }
};
