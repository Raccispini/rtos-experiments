#![no_std]
#![no_main]

use panic_halt as _;
mod workload;

#[rtic::app(device = nrf52840_hal::pac, peripherals = true)]
mod app {
    use nrf52840_hal::{
        gpio::{p0::Parts as P0Parts, Level},
        gpiote::Gpiote,
        pac::UARTE0,
        uarte::{Baudrate, Parity, Pins, Uarte},
        clocks::Clocks,
    };
    use heapless::String;
    use core::fmt::Write;
    use cortex_m::peripheral::DWT;
    use crate::workload::small_whetstone;

    #[shared]
    struct Shared {}

    #[local]
    struct Local {
        gpiote: Gpiote,
        uart_tx: Uarte<UARTE0>,
    }

    #[init]
    fn init(mut cx: init::Context) -> (Shared, Local, init::Monotonics) {
        cx.core.DCB.enable_trace();
        cx.core.DWT.enable_cycle_counter();

        let _clocks = Clocks::new(cx.device.CLOCK).enable_ext_hfosc();
        let p0 = P0Parts::new(cx.device.P0);

        let button_pin = p0.p0_11.into_pullup_input().degrade();
        let gpiote = Gpiote::new(cx.device.GPIOTE);
        gpiote
            .channel0()
            .input_pin(&button_pin)
            .hi_to_lo()
            .enable_interrupt();

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

        (Shared {}, Local { gpiote, uart_tx }, init::Monotonics())
    }

    const DUTY_PERCENT: u32 = 100;
    const CYCLES_PER_MS: u32 = 64_000;
    const PERIOD_MS: u32 = 100;

    #[idle]
    fn idle(_cx: idle::Context) -> ! {
        if DUTY_PERCENT >= 100 {
            loop {
                small_whetstone(1000);
            }
        } else {
            let period_cycles = PERIOD_MS * CYCLES_PER_MS;
            let busy_cycles = period_cycles / 100 * DUTY_PERCENT;
            loop {
                let period_start = DWT::cycle_count();
                if DUTY_PERCENT > 0 {
                    while DWT::cycle_count().wrapping_sub(period_start) < busy_cycles {
                        small_whetstone(50);
                    }
                }
                while DWT::cycle_count().wrapping_sub(period_start) < period_cycles {
                    for _ in 0..256u32 {
                        cortex_m::asm::nop();
                    }
                }
            }
        }
    }

    #[task(binds = GPIOTE, local = [gpiote, uart_tx], priority = 4)]
    fn button_pressed(cx: button_pressed::Context) {
        let cycles = DWT::cycle_count();
        cx.local.gpiote.channel0().reset_events();

        let mut buf: String<32> = String::new();
        let _ = writeln!(buf, "CYCLES={}", cycles);
        cx.local.uart_tx.write(buf.as_bytes()).ok();
    }
}
