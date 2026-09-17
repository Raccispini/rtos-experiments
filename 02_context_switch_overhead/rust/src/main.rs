#![no_std]
#![no_main]

use panic_halt as _;

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

    #[shared]
    struct Shared {}

    #[local]
    struct Local {
        uart_tx: Uarte<UARTE0>,
        tick_count: u32,
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
        syst.set_clock_source(cortex_m::peripheral::syst::SystClkSource::Core);
        syst.set_reload(14_008_888);
        syst.clear_current();
        syst.enable_counter();
        syst.enable_interrupt();

        (
            Shared {},
            Local {
                uart_tx,
                tick_count: 0,
            },
            init::Monotonics(),
        )
    }

    #[task(binds = SysTick, priority = 2, local = [tick_count])]
    fn signaler(cx: signaler::Context) {
        *cx.local.tick_count += 1;
        if *cx.local.tick_count >= 3 {
            *cx.local.tick_count = 0;
            let before = DWT::cycle_count();
            dispatch_target::spawn(before).ok();
        }
    }

    #[task(priority = 5, local = [uart_tx])]
    fn dispatch_target(cx: dispatch_target::Context, before: u32) {
        let now = DWT::cycle_count();
        let delta = now.wrapping_sub(before);
        let mut buf: String<32> = String::new();
        let _ = writeln!(buf, "CYCLES={}", delta);
        cx.local.uart_tx.write(buf.as_bytes()).ok();
    }
}
