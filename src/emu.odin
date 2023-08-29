package oreo

import "core:io"
import "core:mem"
import "core:time"
import "screen"

init :: proc(m: ^Machine) -> bool {
    sprites :: [?]u8{
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
    for byte, i in sprites do m.memory[i] = byte
    return m.screen->init()
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
    loop: for i := 0; ; i = (i + 1) % 10 {
        if (i == 0) {
            if m.delay_timer > 0 do m.delay_timer -= 1
            if m.sound_timer > 0 do m.sound_timer -= 1
        }
        // if (m.sound_timer > 0) do screen->sound()
        // how will i turn sound on and off?
        inst := u16(m.memory[ip]) << 8 | u16(m.memory[ip+1])
        nibs: [4]u8 = {
            u8(inst >> 12 & 0x000f),
            u8(inst >> 8  & 0x000f),
            u8(inst >> 4  & 0x000f),
            u8(inst >> 0  & 0x000f),
        }
        ip += 2
        switch {
        case inst == 0x00e0:
            screen.clear(m.screen)
        case inst == 0x00ee:
            m.memory[0x70] -= 1
            ind := 0x50 + 2*m.memory[0x70]
            ip = (u16(m.memory[ind]) << 8) | u16(m.memory[ind+1])
        case nibs[0] == 0x1:
            ip = inst & 0x0fff
        case nibs[0] == 0x2:
            ind := 0x50 + 2*m.memory[0x70]
            m.memory[ind] = u8(ip >> 8)
            m.memory[ind+1] = u8(ip & 0x00ff)
            m.memory[0x70] += 1
            ip = inst & 0x0fff
        case nibs[0] == 0x3:
            if (m.registers[nibs[1]] == u8(inst & 0x00ff)) {
                ip += 2
            }
        case nibs[0] == 0x4:
            if (m.registers[nibs[1]] != u8(inst & 0x00ff)) {
                ip += 2
            }
        case nibs[0] == 0x5 && nibs[3] == 0x0:
            reg1 := m.registers[nibs[1]]
            reg2 := m.registers[nibs[2]]
            if (reg1 == reg2) {
                ip += 2
            }
        case nibs[0] == 0x6:
            m.registers[nibs[1]] = u8(inst & 0x00ff)
        case nibs[0] == 0x7:
            m.registers[nibs[1]] += u8(inst & 0x00ff)
        case nibs[0] == 0x8:
            regX := &m.registers[nibs[1]]
            regY := &m.registers[nibs[2]]
            switch nibs[3] {
            case 0x0:
                regX^ = regY^
            case 0x1:
                regX^ |= regY^
                m.registers[0xf] = 0x0
            case 0x2:
                regX^ &= regY^
                m.registers[0xf] = 0x0
            case 0x3:
                regX^ ~= regY^
                m.registers[0xf] = 0x0
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
        case nibs[0] == 0x9:
            reg1 := m.registers[nibs[1]]
            reg2 := m.registers[nibs[2]]
            if (reg1 != reg2) {
                ip += 2
            }
        case nibs[0] == 0xa:
            m.index = inst & 0x0fff
        case nibs[0] == 0xb:
            ip = inst & 0x0fff + u16(m.registers[0x0]);
        case nibs[0] == 0xc:
            // TODO random
        case nibs[0] == 0xd:
            x := m.registers[nibs[1]]
            y := m.registers[nibs[2]]
            n := nibs[3]
            m.registers[0xf] = u8(screen.draw_sprite(m.screen, m.memory[m.index:][:n], x, y))
        case nibs[0] == 0xe:
            key, ok := m.screen->poll()
            switch inst & 0x00ff {
            case 0x9e:
                if ok && m.registers[nibs[1]] == key do ip += 2
            case 0xa1:
                if !ok || m.registers[nibs[1]] != key do ip += 2
            }
        case nibs[0] == 0xf:
            switch inst & 0x00ff {
            case 0x07:
                m.registers[nibs[1]] = m.delay_timer
            case 0x0a:
                key, ok := m.screen->poll()
                if !ok {
                    ip -= 2
                } else {
                    m.registers[nibs[1]] = key
                }
            case 0x15:
                m.delay_timer = m.registers[nibs[1]]
            case 0x18:
                m.sound_timer = m.registers[nibs[1]]
            case 0x1e:
                m.index += u16(m.registers[nibs[1]])
            case 0x29:
                m.index = u16(nibs[1] * 5);
            case 0x33:
                val := m.registers[nibs[1]]
                m.memory[m.index+2] = val % 10
                val /= 10
                m.memory[m.index+1] = val % 10
                val /= 10
                m.memory[m.index] = val % 10
            case 0x55:
                for i: u8 = 0; i <= nibs[1]; i += 1 {
                    m.memory[m.index] = m.registers[i]
                    m.index += 1
                }
            case 0x65:
                for i: u8 = 0; i <= nibs[1]; i += 1 {
                    m.registers[i] = m.memory[m.index]
                    m.index += 1
                }
            }
        case:
            break loop
            //ip -= 2
        }
        time.sleep(time.Duration(time.duration_nanoseconds(1666)))
    }

}
