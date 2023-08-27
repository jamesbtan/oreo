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
        switch {
        case inst == 0x00e0:
            screen.clear(&m.screen)
        case inst == 0x00ee:
            m.memory[0x70] -= 1
            ind := 0x50 + 2*m.memory[0x70]
            ip = (u16(m.memory[ind]) << 8) | u16(m.memory[ind+1])
            continue loop
        case fnib == 0x1000:
            ip = inst & 0x0fff
            continue loop
        case fnib == 0x2000:
            ind := 0x50 + 2*m.memory[0x70]
            m.memory[ind] = u8((ip + 2) >> 8)
            m.memory[ind+1] = u8((ip + 2) & 0x00ff)
            m.memory[0x70] += 1
            ip = inst & 0x0fff
            continue loop
        case fnib == 0x3000:
            if (m.registers[(inst & 0x0f00) >> 8] == u8(inst & 0x00ff)) {
                ip += 2
            }
        case fnib == 0x4000:
            if (m.registers[(inst & 0x0f00) >> 8] != u8(inst & 0x00ff)) {
                ip += 2
            }
        case fnib == 0x5000:
            reg1 := m.registers[(inst & 0x0f00) >> 8]
            reg2 := m.registers[(inst & 0x00f0) >> 4]
            if (reg1 == reg2) {
                ip += 2
            }
        case fnib == 0x6000:
            reg := (inst & 0x0f00) >> 8
            m.registers[reg] = u8(inst & 0x00ff)
        case fnib == 0x7000:
            reg := (inst & 0x0f00) >> 8
            m.registers[reg] += u8(inst & 0x00ff)
        case fnib == 0x8000:
            regX := &m.registers[(inst & 0x0f00) >> 8]
            regY := &m.registers[(inst & 0x00f0) >> 4]
            switch lnib {
            case 0x0:
                regX^ = regY^
            case 0x1:
                regX^ |= regY^
            case 0x2:
                regX^ &= regY^
            case 0x3:
                regX^ ~= regY^
            case 0x4:
                sum := regX^ + regY^
                flag := u8(sum < regX^)
                regX^ = sum
                m.registers[0xf] = flag
            case 0x5:
                flag := u8(regX^ > regY^)
                regX^ -= regY^
                m.registers[0xf] = flag
            case 0x7:
                flag := u8(regY^ > regX^)
                regX^ = regY^ - regX^
                m.registers[0xf] = flag
            case 0x6:
                flag := regY^ & 1
                regX^ = regY^ >> 1
                m.registers[0xf] = flag
            case 0xe:
                flag := regY^ >> 7
                regX^ = regY^ << 1
                m.registers[0xf] = flag
            }
        case fnib == 0x9000:
            reg1 := m.registers[(inst & 0x0f00) >> 8]
            reg2 := m.registers[(inst & 0x00f0) >> 4]
            if (reg1 != reg2) {
                ip += 2
            }
        case fnib == 0xa000:
            m.index = inst & 0x0fff
        case fnib == 0xb000:
            ip = inst & 0x0fff + u16(m.registers[0x0]);
        case fnib == 0xc000:
            // TODO random
        case fnib == 0xd000:
            x := m.registers[inst & 0x0f00 >> 8]
            y := m.registers[inst & 0x00f0 >> 4]
            n := inst & 0x000f
            m.registers[0xf] = u8(screen.draw_sprite(&m.screen, m.memory[m.index:][:n], x, y))
        case fnib == 0xe000:
            // TODO keypresses
        case fnib == 0xf000:
            switch inst & 0x00ff {
            case 0x07:
                // TODO delay timer
            case 0x0a:
                // TODO keypresses
            case 0x15:
                // TODO delay timer
            case 0x18:
                // TODO sound timer
            case 0x1e:
                m.index += u16(m.registers[(inst & 0x0f00) >> 8])
            case 0x29:
                dig := (inst & 0x0f00) >> 8;
                m.index = dig * 5;
            case 0x33:
                val := m.registers[(inst & 0x0f00) >> 8]
                m.memory[m.index+2] = val % 10
                val /= 10
                m.memory[m.index+1] = val % 10
                val /= 10
                m.memory[m.index] = val % 10
            case 0x55:
                for i: u8 = 0; i <= u8((inst & 0x0f00) >> 8); i += 1 {
                    m.memory[m.index] = m.registers[i]
                    m.index += 1
                }
            case 0x65:
                for i: u8 = 0; i <= u8((inst & 0x0f00) >> 8); i += 1 {
                    m.registers[i] = m.memory[m.index]
                    m.index += 1
                }
            }
        case:
            break loop
        }
        time.sleep(time.Duration(time.duration_nanoseconds(16666)))
        ip += 2
    }

}
