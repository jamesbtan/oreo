package oreo

import "screen"

Machine :: struct {
    screen: ^screen.Screen,
    index: u16,
    registers: [16]u8,
    // timers count down at 60Hz til 0
    delay_timer: u8,
    sound_timer: u8,
    // [0x00,0x50) -- font sprites
    // [0x50,0x70] -- stack
    // [0x200,0xe90) -- program memory
    // [0xe90,..) -- reserved end
    memory: [4096]u8,
}
