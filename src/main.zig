const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants");
const entities = @import("entities");

const colors = constants.colors;
const ui = constants.ui;

pub fn main() !void {
    rl.initWindow(750 + ui.offset, 700 + 2 * ui.offset, "Zpace invaders");
    defer rl.closeWindow();

    const font = try rl.loadFontEx("assets/fonts/monogram.ttf", 64, null);
    defer rl.unloadFont(font);

    rl.setTargetFPS(60);
    rl.setExitKey(rl.KeyboardKey.null);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var game = try entities.Game.init(allocator);
    defer game.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        try game.handleInput();

        rl.clearBackground(colors.grey);
        rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(10, 10, 780, 780), 0.18, 20, 2, colors.yellow);
        rl.drawLineEx(rl.Vector2.init(25, 730), rl.Vector2.init(775, 730), 3, colors.yellow);

        if (game.is_running) {
            rl.drawTextEx(font, "LEVEL 01", rl.Vector2.init(570, 740), 34, 2, colors.yellow);
        } else {
            rl.drawTextEx(font, "GAME OVER", rl.Vector2.init(570, 740), 34, 2, colors.yellow);
        }

        var life_icon_offset: f32 = 50;
        for (0..game.lives) |_| {
            rl.drawTextureV(game.spaceship.image, rl.Vector2.init(life_icon_offset, 745), rl.Color.white);
            life_icon_offset += 50;
        }

        game.draw();
        try game.update();
    }
}
