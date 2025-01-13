const rl = @import("raylib");

pub const AlienType = enum {
    Type1,
    Type2,
    Type3,
};

pub const Alien = struct {
    image: rl.Texture2D,
    alien_type: AlienType,
    position: rl.Vector2,

    pub fn init(alien_type: AlienType, position: rl.Vector2) !Alien {
        const image = switch (alien_type) {
            .Type1 => try rl.loadTexture("assets/textures/alien_1.png"),
            .Type2 => try rl.loadTexture("assets/textures/alien_2.png"),
            .Type3 => try rl.loadTexture("assets/textures/alien_3.png"),
        };

        return Alien{
            .alien_type = alien_type,
            .position = position,
            .image = image,
        };
    }

    pub fn deinit(self: *Alien) void {
        rl.unloadTexture(self.image);
    }

    pub fn draw(self: Alien) void {
        rl.drawTextureV(self.image, self.position, rl.Color.white);
    }
};
