#![no_std]
#![no_main]

use panic_halt as _;
mod workload;

#[rtic::app(device = nrf52840_hal::pac, peripherals = true, dispatchers = [SWI0_EGU0])]
mod app {
    use core::fmt::Write;
    use cortex_m::peripheral::DWT;
    use heapless::String;
    use nrf52840_hal::{
        clocks::Clocks,
        gpio::{p0::Parts as P0Parts, Level},
        gpiote::Gpiote,
        pac::UARTE0,
        uarte::{Baudrate, Parity, Pins, Uarte},
    };

    use crate::workload::small_whetstone;

    #[shared]
    struct Shared {
        last_cost: u32,
        uart_tx: Uarte<UARTE0>,
    }

    #[local]
    struct Local {
        gpiote: Gpiote,
        activation_count: u32,
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

        let mut syst = cx.core.SYST;
        let reload = 64_000_000u32 - 1;
        syst.set_clock_source(cortex_m::peripheral::syst::SystClkSource::Core);
        syst.set_reload(reload);
        syst.clear_current();
        syst.enable_counter();
        syst.enable_interrupt();

        (
            Shared {
                last_cost: 0,
                uart_tx,
            },
            Local {
                gpiote,
                activation_count: 0,
            },
            init::Monotonics(),
        )
    }

    #[task(binds = SysTick, local = [activation_count], shared = [last_cost, uart_tx], priority = 2)]
    fn producer(mut cx: producer::Context) {
        let t0 = DWT::cycle_count();
        small_whetstone(50);
        let t1 = DWT::cycle_count();
        let cost = t1.wrapping_sub(t0);

        cx.shared.last_cost.lock(|v| *v = cost);
        cx.shared.uart_tx.lock(|u| {
            let mut buf: String<32> = String::new();
            let _ = writeln!(buf, "PRODUCER_COST={}", cost);
            u.write(buf.as_bytes()).ok();
        });

        *cx.local.activation_count += 1;
        if *cx.local.activation_count == 3 {
            *cx.local.activation_count = 0;
            consumer::spawn().ok();
        }
    }

    #[task(priority = 3, shared = [last_cost, uart_tx])]
    fn consumer(mut cx: consumer::Context) {
        let value = cx.shared.last_cost.lock(|v| *v);
        cx.shared.uart_tx.lock(|u| {
            let mut buf: String<32> = String::new();
            let _ = writeln!(buf, "CONSUMER_READ={}", value);
            u.write(buf.as_bytes()).ok();
        });
    }

    #[task(binds = GPIOTE, local = [gpiote], shared = [uart_tx], priority = 4)]
    fn button_pressed(mut cx: button_pressed::Context) {
        cx.local.gpiote.channel0().reset_events();
        cx.shared.uart_tx.lock(|u| {
            u.write(b"BUTTON_EVENT\r\n").ok();
        });
    }
}
