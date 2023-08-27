package oreo

import "screen"

Machine :: struct {
    index: u16,
    registers: [16]u8,
    // prog memory starts at 0x200-0xe8f
    // reserved end starts at 0xe90
    memory: [4096]u8,
    screen: screen.Screen,
    // enough stack for 12 subroutine calls
    // timers count down at 60Hz til 0
}
