package sdl

import "core:c"

foreign import sdl "system:SDL2"

Rect :: struct {
    x: c.int,
    y: c.int,
    w: c.int,
    h: c.int,
}

SDL_INIT_TIMER          :: 0x00000001
SDL_INIT_AUDIO          :: 0x00000010
SDL_INIT_VIDEO          :: 0x00000020  /**< SDL_INIT_VIDEO implies SDL_INIT_EVENTS */
SDL_INIT_JOYSTICK       :: 0x00000200  /**< SDL_INIT_JOYSTICK implies SDL_INIT_EVENTS */
SDL_INIT_HAPTIC         :: 0x00001000
SDL_INIT_GAMECONTROLLER :: 0x00002000  /**< SDL_INIT_GAMECONTROLLER implies SDL_INIT_JOYSTICK */
SDL_INIT_EVENTS         :: 0x00004000
SDL_INIT_SENSOR         :: 0x00008000
SDL_INIT_NOPARACHUTE    :: 0x00100000  /**< compatibility; this flag is ignored. */
SDL_INIT_EVERYTHING :: (
                SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS |
                SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC | SDL_INIT_GAMECONTROLLER | SDL_INIT_SENSOR
            )

@(link_prefix="SDL_")
foreign sdl {
    Init :: proc(c.uint32_t) -> c.int ---
    Quit :: proc() ---
    
    GetError :: proc() -> cstring ---
    CreateWindow :: proc(title: cstring, x, y, w, h: c.int, flags: c.uint32_t) -> rawptr ---
    DestroyWindow :: proc(window: rawptr) ---
    CreateRenderer :: proc(window: rawptr, index: c.int, flags: c.uint32_t) -> rawptr ---
    DestroyRenderer :: proc(renderer: rawptr) ---
    SetRenderDrawColor :: proc(renderer: rawptr, r, g, b, a: c.uint8_t) -> c.int ---
    RenderFillRect :: proc(renderer: rawptr, rect: ^Rect) -> c.int ---
    RenderClear :: proc(renderer: rawptr) -> c.int ---
    RenderPresent :: proc(renderer: rawptr) ---
}
