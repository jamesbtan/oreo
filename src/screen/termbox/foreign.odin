package termbox

import "core:c"

foreign import termbox "../../../dep/termbox2/libtermbox2.a"

Event :: struct {
    type: c.uint8_t,
    mod: c.uint8_t,
    key: c.uint16_t,
    ch: c.uint32_t,
    w, h, x, y: c.uint32_t,
}

DEFAULT :: 0x0000
BLACK :: 0x0001
RED :: 0x0002
GREEN :: 0x0003
YELLOW :: 0x0004
BLUE :: 0x0005
MAGENTA :: 0x0006
CYAN :: 0x0007
WHITE :: 0x0008

@(link_prefix="tb_")
foreign termbox {
    init :: proc() -> c.int ---
    shutdown :: proc() -> c.int ---

    set_cell :: proc(c.int, c.int, c.uint32_t, c.uint16_t, c.uint16_t) -> c.int ---
    print :: proc(c.int, c.int, c.uint16_t, c.uint16_t, cstring) -> c.int ---

    clear :: proc() -> c.int ---
    present :: proc() -> c.int ---

    hide_cursor :: proc() -> c.int ---

    poll_event :: proc(^Event) -> c.int ---
/*
    width
    height


    set_cursor


    peek_event

    printf
*/
}
