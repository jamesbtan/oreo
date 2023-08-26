package oreo

import "core:fmt"
import "core:os"

main :: proc() {
    m: Machine
    {
        f, ferr := os.open(os.args[1])
        if (ferr != 0) {
            return
        }
        defer os.close(f)
        r := os.stream_from_handle(f)
        load(&m, r)
    }
    run(&m)
}
