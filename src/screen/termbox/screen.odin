package termbox

import ".."

Screen :: struct {
    using screen: screen.Screen,
}

get_screen :: proc() -> Screen {
    return {
        init=termbox_init,
        deinit=termbox_deinit,
        clear=termbox_clear,
        draw=termbox_draw,
        present=termbox_present,
        poll=termbox_poll,
    }
}

termbox_init :: proc(rawptr) -> bool {
    init()
    hide_cursor()
    return true
}

termbox_deinit :: proc(rawptr) {
    shutdown()
}

termbox_present :: proc(rawptr) {
    present()
}

termbox_clear :: proc(rawptr) {
    clear()
}

termbox_draw :: proc(sr: rawptr) {
    s := (^Screen)(sr)
    for y: u8 = 0; y < 32; y += 1 {
        for x: u8 = 63; x <= 63; x -= 1 {
            xc: u8 = x / 8
            xb: u8 = 7 - (x % 8)
            //set_cell(i32(x), i32(y), s.buf[y][xc] & (1 << xb) != 0 ? '█' : ' ', DEFAULT, DEFAULT)
            print(i32(x)*2, i32(y), DEFAULT, DEFAULT, s.buf[y][xc] & (1 << xb) != 0 ? "██" : "  ")
        }
    }
}

// keyboard events are broken.
termbox_poll :: proc(rawptr) -> (u8, bool) {
    ev: Event
    if peek_event(&ev, 16) == TB_ERR_NO_EVENT do return 0x0, false
    if ev.type != TB_EVENT_KEY do return 0x0, false
    switch ev.ch {
    case '1': return 0x1, true
    case '2': return 0x2, true
    case '3': return 0x3, true
    case 'q': return 0x4, true
    case 'w': return 0x5, true
    case 'e': return 0x6, true
    case 'a': return 0x7, true
    case 's': return 0x8, true
    case 'd': return 0x9, true
    case 'x': return 0x0, true
    case 'z': return 0xa, true
    case 'c': return 0xb, true
    case '4': return 0xc, true
    case 'r': return 0xd, true
    case 'f': return 0xe, true
    case 'v': return 0xf, true
    }
    return 0x0, false
}
