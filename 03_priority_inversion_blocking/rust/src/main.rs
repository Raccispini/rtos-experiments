#![no_std]
#![no_main]

use panic_halt as _;
mod workload;

#[rtic::app(device = nrf52840_hal::pac, peripherals = true, dispatchers = [SWI0_EGU0, SWI1_EGU1])]
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
    use crate::workload::small_whetstone;

    #[shared]
    struct Shared {
        shared_resource: (),
        uart_tx: Uarte<UARTE0>,
    }

    #[local]
    struct Local {
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
        syst.set_reload(16_164_102);
        syst.clear_current();
        syst.enable_counter();
        syst.enable_interrupt();

        (
            Shared {
                shared_resource: (),
                uart_tx,
            },
            Local { tick_count: 0 },
            init::Monotonics(),
        )
    }

    #[task(binds = SysTick, priority = 1, shared = [shared_resource], local = [tick_count])]
    fn low_task(mut cx: low_task::Context) {
        *cx.local.tick_count += 1;
        if *cx.local.tick_count < 13 {
            return;
        }
        *cx.local.tick_count = 0;

        cx.shared.shared_resource.lock(|_r| {
            let t_ready = DWT::cycle_count();
            medium_task::spawn(t_ready).ok();
            high_task::spawn(t_ready).ok();
            small_whetstone(50);
        });
    }

    #[task(priority = 2, shared = [uart_tx])]
    fn medium_task(mut cx: medium_task::Context, t_ready: u32) {
        let now = DWT::cycle_count();
        let delay = now.wrapping_sub(t_ready);
        cx.shared.uart_tx.lock(|u| {
            let mut buf: String<32> = String::new();
            let _ = writeln!(buf, "MEDIUM_DELAY={}", delay);
            u.write(buf.as_bytes()).ok();
        });
    }

    #[task(priority = 3, shared = [shared_resource, uart_tx])]
    fn high_task(mut cx: high_task::Context, t_ready: u32) {
        cx.shared.shared_resource.lock(|_r| {});
        let now = DWT::cycle_count();
        let delay = now.wrapping_sub(t_ready);
        cx.shared.uart_tx.lock(|u| {
            let mut buf: String<32> = String::new();
            let _ = writeln!(buf, "HIGH_BLOCKING={}", delay);
            u.write(buf.as_bytes()).ok();
        });
    }
}
