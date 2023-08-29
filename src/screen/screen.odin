package screen

import "core:fmt"

Screen :: struct {
    buf: [32][8]u8,
    init: proc(rawptr) -> bool,
    deinit: proc(rawptr),
    clear: proc(rawptr),
    draw: proc(rawptr),
    present: proc(rawptr),
    poll: proc(rawptr) -> (u8, bool),
}

clear :: proc(s: ^Screen) {
    for _, i in s.buf {
        for _, j in s.buf[i] {
            s.buf[i][j] = 0
        }
    }
    s->clear()
    s->present()
}

draw_sprite :: proc(s: ^Screen, sprite: []u8, xp, yp: u8) -> (unset: bool) {
    x := xp % 64
    y := yp % 32
    if x % 8 == 0 {
        xp := x / 8
        for row, i in sprite {
            if (y+u8(i) >= 32) do break
            curr := &s.buf[y+u8(i)][xp]
            unset |= curr^ & row != 0
            curr^ ~= row
        }
    } else {
        xl := x / 8
        xr := xl + 1
        sh := x % 8
        for row, i in sprite {
            if (y+u8(i) >= 32) do break
            curr_l := &s.buf[y+u8(i)][xl]
            row_l := row >> sh
            unset |= curr_l^ & row_l != 0
            curr_l^ ~= row_l
            if (xr >= 8) do continue
            curr_r := &s.buf[y+u8(i)][xr]
            row_r := row << (8 - sh)
            unset |= curr_r^ & row_r != 0
            curr_r^ ~= row_r
        }
    }
    s->draw()
    s->present()
    return
}
