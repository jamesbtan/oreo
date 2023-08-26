package oreo

import "core:io"
import "core:fmt"

load :: proc(m: ^Machine, rom: io.Stream) {
    for i := 0x200; i <= 0xe8f; i += 1 {
        n_read: int
        b, err := io.read_byte(rom, &n_read)
        if err != .None || n_read == 0 { break }
        m.memory[i] = b
    }
}

run :: proc(m: ^Machine) {
    ip: u16 = 0x200
    loop: for {
        inst := u16(m.memory[ip]) << 8 | u16(m.memory[ip+1])
        fnib := inst & 0xf000
        lnib := inst & 0x000f
        fmt.eprintf("[%03x]%04x:\t", ip, inst)
        switch {
        case inst == 0x00e0:
            fmt.eprintln("clear screen")
        case fnib == 0x6000:
            reg := (inst & 0x0f00) >> 8
            m.registers[reg] = u8(inst & 0x00ff)
            fmt.eprintf("set V%x to %02x\n", reg, m.registers[reg])
        case fnib == 0xa000:
            m.index = inst & 0x0fff
            fmt.eprintf("set I to: %04x\n", m.index)
        case fnib == 0xd000:
            fmt.eprintln("draw sprite")
        case fnib == 0x1000:
            fmt.eprintln("jumping")
            ip = inst & 0x0fff
            continue loop
        case:
            break loop
        }
        ip += 2
    }

}
