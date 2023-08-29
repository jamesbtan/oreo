package termbox

import "core:c"

foreign import termbox "../../../dep/termbox2/libtermbox2.a"

Event :: struct {
    type: c.uint8_t,
    mod: c.uint8_t,
    key: c.uint16_t,
    ch: c.uint32_t,
    w: c.int32_t,
    h: c.int32_t,
    x: c.int32_t,
    y: c.int32_t,
}

DEFAULT :: 0x0000
BLACK   :: 0x0001
RED     :: 0x0002
GREEN   :: 0x0003
YELLOW  :: 0x0004
BLUE    :: 0x0005
MAGENTA :: 0x0006
CYAN    :: 0x0007
WHITE   :: 0x0008

TB_EVENT_KEY    :: 1
TB_EVENT_RESIZE :: 2
TB_EVENT_MOUSE  :: 3

TB_OK                   :: 0
TB_ERR                  :: -1
TB_ERR_NEED_MORE        :: -2
TB_ERR_INIT_ALREADY     :: -3
TB_ERR_INIT_OPEN        :: -4
TB_ERR_MEM              :: -5
TB_ERR_NO_EVENT         :: -6
TB_ERR_NO_TERM          :: -7
TB_ERR_NOT_INIT         :: -8
TB_ERR_OUT_OF_BOUNDS    :: -9
TB_ERR_READ             :: -10
TB_ERR_RESIZE_IOCTL     :: -11
TB_ERR_RESIZE_PIPE      :: -12
TB_ERR_RESIZE_SIGACTION :: -13
TB_ERR_POLL             :: -14
TB_ERR_TCGETATTR        :: -15
TB_ERR_TCSETATTR        :: -16
TB_ERR_UNSUPPORTED_TERM :: -17
TB_ERR_RESIZE_WRITE     :: -18
TB_ERR_RESIZE_POLL      :: -19
TB_ERR_RESIZE_READ      :: -20
TB_ERR_RESIZE_SSCANF    :: -21
TB_ERR_CAP_COLLISION    :: -22

@(link_prefix="tb_")
foreign termbox {
    init :: proc() -> c.int ---
    shutdown :: proc() -> c.int ---

    set_cell :: proc(c.int, c.int, c.uint32_t, c.uint16_t, c.uint16_t) -> c.int ---
    print :: proc(c.int, c.int, c.uint16_t, c.uint16_t, cstring) -> c.int ---
    
    peek_event :: proc(^Event, c.int) -> c.int ---

    clear :: proc() -> c.int ---
    present :: proc() -> c.int ---

    hide_cursor :: proc() -> c.int ---
}
