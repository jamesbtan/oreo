package oreo

import "core:io"
import "core:mem"
import "core:time"
import "screen"

init :: proc(m: ^Machine) {
    // can i make this const?
    sprites := [?]u8{
        0xf0, 0x90, 0x90, 0x90, 0xf0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xf0, 0x10, 0xf0, 0x80, 0xf0, // 2
        0xf0, 0x10, 0xf0, 0x10, 0xf0, // 3
        0x90, 0x90, 0xf0, 0x10, 0x10, // 4
        0xf0, 0x80, 0xf0, 0x10, 0x10, // 5
        0xf0, 0x80, 0xf0, 0x90, 0xf0, // 6
        0xf0, 0x10, 0x20, 0x40, 0x40, // 7
        0xf0, 0x90, 0xf0, 0x90, 0xf0, // 8
        0xf0, 0x90, 0xf0, 0x10, 0xf0, // 9
        0xf0, 0x90, 0xf0, 0x90, 0x90, // A
        0xe0, 0x90, 0xe0, 0x90, 0xe0, // B
        0xf0, 0x80, 0x80, 0x80, 0xf0, // C
        0xe0, 0x90, 0x90, 0x90, 0xe0, // D
        0xf0, 0x80, 0xf0, 0x80, 0xf0, // E
        0xf0, 0x80, 0xf0, 0x80, 0x80, // F
    }
    mem.copy_non_overlapping(&m.memory[0], &sprites[0], len(sprites))
    m.screen->init()
}

deinit :: proc(m: ^Machine) {
    m.screen->deinit()
}

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
        // fmt.eprintf("[%03x]%04x:\t", ip, inst)
        switch {
        case inst == 0x00e0:
            // fmt.eprintln("clear screen")
            m.screen->clear()
        case fnib == 0x6000:
            reg := (inst & 0x0f00) >> 8
            m.registers[reg] = u8(inst & 0x00ff)
            // fmt.eprintf("set V%x to %02x\n", reg, m.registers[reg])
        case fnib == 0xa000:
            m.index = inst & 0x0fff
            // fmt.eprintf("set I to: %04x\n", m.index)
        case fnib == 0xd000:
            // fmt.eprintln("draw sprite")
            x := m.registers[inst & 0x0f00 >> 8]
            y := m.registers[inst & 0x00f0 >> 4]
            n := inst & 0x000f
            m.registers[0xf] = u8(screen.draw_sprite(&m.screen, m.memory[m.index:][:n], x, y))
        case fnib == 0x1000:
            // fmt.eprintln("jumping")
            ip = inst & 0x0fff
            continue loop
        case:
            break loop
        }
        time.sleep(time.Duration(time.duration_nanoseconds(16666)))
        ip += 2
    }

}
