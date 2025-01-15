const rl = @import("raylib");

pub const AlienType = enum {
    Type1,
    Type2,
    Type3,
};

pub var alien_images = [3]?rl.Texture2D{ null, null, null };

pub const Alien = struct {
    alien_type: AlienType,
    position: rl.Vector2,

    pub fn init(alien_type: AlienType, position: rl.Vector2) !Alien {
        const id: usize = @intFromEnum(alien_type);

        if (alien_images[id] == null) {
            alien_images[id] = switch (alien_type) {
                .Type1 => try rl.loadTexture("assets/textures/alien_1.png"),
                .Type2 => try rl.loadTexture("assets/textures/alien_2.png"),
                .Type3 => try rl.loadTexture("assets/textures/alien_3.png"),
            };
        }

        return Alien{
            .alien_type = alien_type,
            .position = position,
        };
    }

    pub fn deinit(_: *Alien) void {}

    pub fn draw(self: Alien) void {
        const id: usize = @intFromEnum(self.alien_type);
        rl.drawTextureV(alien_images[id].?, self.position, rl.Color.white);
    }

    pub fn update(self: *Alien, direction: f32) void {
        self.position.x += direction;
    }

    pub fn unloadIamges() void {
        for (&alien_images) |*image| {
            if (image.* != null) {
                rl.unloadTexture(image.*.?);
            }
        }
    }

    pub fn getRect(self: Alien) rl.Rectangle {
        const id: usize = @intFromEnum(self.alien_type);
        const image = alien_images[id];

        return rl.Rectangle.init(
            self.position.x,
            self.position.y,
            if (image != null) @floatFromInt(image.?.width) else 0,
            if (image != null) @floatFromInt(image.?.height) else 0,
        );
    }
};
