const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants");
const entities = @import("entities");

const colors = constants.colors;
const ui = constants.ui;

pub fn main() !void {
    rl.initWindow(750 + ui.offset, 700 + 2 * ui.offset, "Zpace invaders");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    const font = try rl.loadFontEx("assets/fonts/monogram.ttf", 64, null);
    defer rl.unloadFont(font);

    rl.setTargetFPS(60);
    rl.setExitKey(rl.KeyboardKey.null);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var game = try entities.Game.init(allocator);
    defer game.deinit();

    rl.playMusicStream(game.music);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.updateMusicStream(game.music);

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

        rl.drawTextEx(font, "SCORE", rl.Vector2.init(50, 15), 34, 2, colors.yellow);
        const score = try formatScoreWithLeadingZeros(allocator, game.score, 5);
        defer allocator.free(score);
        rl.drawTextEx(font, score, rl.Vector2.init(50, 40), 34, 2, colors.yellow);

        rl.drawTextEx(font, "HIGH-SCORE", rl.Vector2.init(570, 15), 34, 2, colors.yellow);
        const high_score = try formatScoreWithLeadingZeros(allocator, game.high_score, 5);
        defer allocator.free(high_score);
        rl.drawTextEx(font, high_score, rl.Vector2.init(650, 40), 34, 2, colors.yellow);

        game.draw();
        try game.update();
    }
}

fn formatScoreWithLeadingZeros(allocator: std.mem.Allocator, number: i32, width: usize) ![:0]u8 {
    const score = rl.textFormat("%d", .{number});
    const leading_zeros = width - std.mem.len(score);

    const zero_text = try allocator.alloc(u8, width);
    defer allocator.free(zero_text);

    @memset(zero_text, '0');
    std.mem.copyForwards(u8, zero_text[leading_zeros..], std.mem.span(score));

    const final_text = try allocator.dupeZ(u8, zero_text);
    return final_text;
}
