#![no_std]
#![no_main]

use panic_halt as _;

const USE_VALIDATION: bool = false;

const CAP: usize = 8;

#[derive(Clone, Copy)]
pub struct Packet {
    pub len: usize,
    pub data: [u8; CAP],
}

#[rtic::app(device = nrf52840_hal::pac, peripherals = true, dispatchers = [SWI0_EGU0])]
mod app {
    use core::fmt::Write;
    use cortex_m::peripheral::DWT;
    use heapless::String;
    use nrf52840_hal::{
        clocks::Clocks,
        gpio::{p0::Parts as P0Parts, Level},
        pac::UARTE0,
        uarte::{Baudrate, Parity, Pins, Uarte},
    };

    use crate::{Packet, CAP, USE_VALIDATION};

    #[shared]
    struct Shared {}

    #[local]
    struct Local {
        uart_tx: Uarte<UARTE0>,
        packet_count: u32,
    }

    #[init]
    fn init(mut cx: init::Context) -> (Shared, Local, init::Monotonics) {
        cx.core.DCB.enable_trace();
        cx.core.DWT.enable_cycle_counter();

        let _clocks = Clocks::new(cx.device.CLOCK).enable_ext_hfosc();
        let p0 = P0Parts::new(cx.device.P0);

        let uart_tx = Uarte::new(
            cx.device.UARTE0,
            Pins {
                txd: p0.p0_06.into_push_pull_output(Level::High).degrade(),
                rxd: p0.p0_08.into_floating_input().degrade(),
                cts: None,
                rts: None,
            },
            Parity::EXCLUDED,
            Baudrate::BAUD115200,
        );

        let mut syst = cx.core.SYST;
        let reload = 64_000_000u32 - 1;
        syst.set_clock_source(cortex_m::peripheral::syst::SystClkSource::Core);
        syst.set_reload(reload / 5);
        syst.clear_current();
        syst.enable_counter();
        syst.enable_interrupt();

        (
            Shared {},
            Local {
                uart_tx,
                packet_count: 0,
            },
            init::Monotonics(),
        )
    }

    #[task(binds = SysTick, local = [packet_count], priority = 2)]
    fn source(cx: source::Context) {
        const N_PACKETS: u32 = 100;
        if *cx.local.packet_count >= N_PACKETS {
            return;
        }
        *cx.local.packet_count += 1;
        let i = *cx.local.packet_count;

        let data = [(i % 256) as u8; CAP];
        let len = if i % 5 == 0 {
            CAP + 4
        } else {
            CAP - 2
        };

        consumer::spawn(Packet { len, data }).ok();
    }

    #[task(priority = 5, local = [uart_tx])]
    fn consumer(cx: consumer::Context, p: Packet) {
        let t0 = DWT::cycle_count();

        let mut local_buf = [0u8; CAP];
        let effective_len = if USE_VALIDATION {
            core::cmp::min(p.len, CAP)
        } else {
            p.len
        };

        for i in 0..effective_len {
            local_buf[i] = p.data[i];
        }

        let t1 = DWT::cycle_count();
        let cost = t1.wrapping_sub(t0);
        let mut buf: String<32> = String::new();
        let _ = writeln!(buf, "PACKET_OK cost={}", cost);
        cx.local.uart_tx.write(buf.as_bytes()).ok();
    }
}
