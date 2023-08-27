package screen

import "core:fmt"

Screen :: struct {
    buf: [32][8]u8,
    init: proc(^Screen),
    deinit: proc(^Screen),
    clear: proc(^Screen),
    draw: proc(^Screen),
}

clear :: proc(s: ^Screen) {
    for _, i in s.buf {
        for _, j in s.buf[i] {
            s.buf[i][j] = 0
        }
    }
    s->clear()
}

draw_sprite :: proc(s: ^Screen, sprite: []u8, x, y: u8) -> (swap: bool) {
    if x % 8 == 0 {
        xp := x / 8
        for row, i in sprite {
            curr := &s.buf[y+u8(i)][xp]
            swap |= curr^ ~ row != 0
            curr^ ~= row
        }
    }
    if (swap) { s->draw() }
    return
}
