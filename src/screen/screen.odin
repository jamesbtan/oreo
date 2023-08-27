package screen

import "core:fmt"

Screen :: struct {
    buf: [32][8]u8,
    init: proc(rawptr),
    deinit: proc(rawptr),
    clear: proc(rawptr),
    draw: proc(rawptr),
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
    } else {
        xl := x / 8
        xr := xl + 1
        sh := x % 8
        for row, i in sprite {
            if (y+u8(i) >= 32) { break }
            curr_l := &s.buf[y+u8(i)][xl]
            row_l := row >> sh
            swap |= curr_l^ ~ row_l != 0
            curr_l^ ~= row_l
            if (xr >= 8) { continue }
            curr_r := &s.buf[y+u8(i)][xr]
            row_r := row << (8 - sh)
            swap |= curr_r^ ~ row_r != 0
            curr_r^ ~= row_r
        }
    }
    if (swap) { s->draw() }
    return
}
