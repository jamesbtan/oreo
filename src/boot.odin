package oreo

import "core:os"
import "core:fmt"
import "core:c"
import "screen/termbox"

/*
main :: proc() {
    err : c.int
    err = termbox.init()
    if err != 0 {
        fmt.println("failed init")
        return
    }
    defer termbox.shutdown()
    
    err = termbox.hide_cursor()
    if err != 0 {
        fmt.println("failed hide cursor")
        return
    }
    err = termbox.set_cell(0, 0, 'A', termbox.DEFAULT, termbox.DEFAULT)
    err = termbox.set_cell(0, 1, 'B', termbox.DEFAULT, termbox.DEFAULT)
    if err != 0 {
        fmt.println("failed set cell")
        return
    }
    err = termbox.present()
    if err != 0 {
        fmt.println("failed present")
        return
    }
    
    ev: termbox.Event
    err = termbox.poll_event(&ev)
    if err != 0 {
        fmt.println("failed poll")
        return
    }
}
*/

main :: proc() {
    m: Machine
    m.screen = termbox.get_screen()
    init(&m)
    defer deinit(&m)
    {
        f, ferr := os.open(os.args[1])
        if (ferr != 0) {
            return
        }
        defer os.close(f)
        rom := os.stream_from_handle(f)
        load(&m, rom)
    }
    run(&m)
}
