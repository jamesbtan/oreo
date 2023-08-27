package oreo

import "core:os"
import "core:fmt"
import "screen/termbox"

main :: proc() {
    error: u16
    {
        m := Machine{screen=termbox.get_screen()}
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
        error = run(&m)
    }
    fmt.printf("%04x\n", error)
}
