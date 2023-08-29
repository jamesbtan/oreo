package sdl

import ".."

Screen :: struct {
    using screen: screen.Screen,
    window: rawptr,
    renderer: rawptr,
}

get_screen :: proc() -> Screen {
    return {
        init=sdl_init,
        deinit=sdl_deinit,
        clear=sdl_clear,
        draw=sdl_draw,
        present=sdl_present,
        poll=sdl_poll,
    }
}

handle_error :: proc() -> bool {
    return false
}

// add error handling
sdl_init :: proc(sr: rawptr) -> bool {
    s := (^Screen)(sr)
    err: i32
    if Init(SDL_INIT_EVERYTHING) != 0 do return handle_error()
    s.window = CreateWindow("oreo", 0, 0, 1280, 640, 0)
    if s.window == nil do return handle_error()
    s.renderer = CreateRenderer(s.window, -1, 0)
    if s.renderer == nil do return handle_error()
    return true
}

sdl_deinit :: proc(sr: rawptr) {
    s := (^Screen)(sr)
    if s.renderer != nil do DestroyRenderer(s.renderer)
    if s.window != nil do DestroyWindow(s.window)
    Quit()
}

sdl_clear :: proc(sr: rawptr) {
    s := (^Screen)(sr)
    RenderClear(s.renderer)
}

sdl_draw :: proc(sr: rawptr) {
    s := (^Screen)(sr)
    for y: u8 = 0; y < 32; y += 1 {
        for x: u8 = 0; x < 8; x += 1 {
            byte := s.buf[y][x]
            for xb: u8 = 7; xb <= 7; xb -= 1 {
                xi := x*8 + xb
                value := u8(byte & 1 != 0 ? 0xff : 0x00)
                SetRenderDrawColor(s.renderer, value, value, value, 0xff)
                r: Rect = { i32(xi) * 20, i32(y) * 20, i32(20), i32(20) }
                RenderFillRect(s.renderer, &r)
                byte >>= 1
            }
        }
    }
}

sdl_present :: proc(sr: rawptr) {
    s := (^Screen)(sr)
    RenderPresent(s.renderer)
}

sdl_poll :: proc(sr: rawptr) -> (u8, bool) {
    s := (^Screen)(sr)
    return 0x0, false
}
