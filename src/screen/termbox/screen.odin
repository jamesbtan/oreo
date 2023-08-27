package termbox

import "../"
import "core:fmt"

Screen :: struct {
    using screen: screen.Screen,
}

get_screen :: proc() -> Screen {
    return {
        init=termbox_init,
        deinit=termbox_deinit,
        clear=termbox_clear,
        draw=termbox_draw,
    }
}

termbox_init :: proc(^screen.Screen) {
    init()
    hide_cursor()
}

termbox_deinit :: proc(^screen.Screen) {
    shutdown()
}

termbox_clear :: proc(^screen.Screen) {
    clear()
}

termbox_draw :: proc(s: ^screen.Screen) {
    for y: u8 = 0; y < 32; y += 1 {
        for x: u8 = 63; x <= 63; x -= 1 {
            xc: u8 = x / 8
            xb: u8 = 7 - (x % 8)
            set_cell(i32(x), i32(y), s.buf[y][xc] & (1 << xb) != 0 ? '█' : ' ', DEFAULT, DEFAULT)
            //print(i32(x)*2, i32(y), DEFAULT, DEFAULT, s.buf[y][xc] & (1 << xb) != 0 ? "██" : "  ")
        }
    }
    present()
}
