package oreo

import "core:os"
import "core:fmt"
import "screen/sdl"

main :: proc() {
    s := sdl.get_screen()
    m := Machine{screen=&s}
    ok := init(&m)
    defer deinit(&m)
    if !ok do return
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
