#![no_std]
#![no_main]

use panic_halt as _;

static mut SHARED_COUNTER: u32 = 0;

const N_LOW: u32 = 300_000;
const N_HIGH: u32 = 50;

#[rtic::app(device = nrf52840_hal::pac, peripherals = true)]
mod app {
    use core::fmt::Write;
    use heapless::String;
    use nrf52840_hal::{
        clocks::Clocks,
        gpio::{p0::Parts as P0Parts, Level},
        pac::UARTE0,
        uarte::{Baudrate, Parity, Pins, Uarte},
    };

    use crate::{N_HIGH, N_LOW, SHARED_COUNTER};

    #[shared]
    struct Shared {}

    #[local]
    struct Local {
        uart_tx: Uarte<UARTE0>,
        remaining: u32,
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
        syst.set_reload(reload / 50);
        syst.clear_current();
        syst.enable_counter();
        syst.enable_interrupt();

        (
            Shared {},
            Local {
                uart_tx,
                remaining: N_HIGH,
            },
            init::Monotonics(),
        )
    }

    #[idle]
    fn idle(_cx: idle::Context) -> ! {
        for _ in 0..N_LOW {
            unsafe {
                SHARED_COUNTER += 1;
            }
        }
        loop {
            cortex_m::asm::nop();
        }
    }

    #[task(binds = SysTick, local = [uart_tx, remaining], priority = 5)]
    fn racer_high(cx: racer_high::Context) {
        unsafe {
            SHARED_COUNTER += 1;
        }
        *cx.local.remaining -= 1;
        if *cx.local.remaining == 0 {
            let final_value = unsafe { SHARED_COUNTER };
            let mut buf: String<64> = String::new();
            let _ = writeln!(
                buf,
                "SHARED_COUNTER_FINAL={} EXPECTED={}",
                final_value,
                N_LOW + N_HIGH
            );
            cx.local.uart_tx.write(buf.as_bytes()).ok();
        }
    }
}

#[allow(dead_code)]
const SELECTED_SCENARIO: u8 = 0;

#[allow(dead_code)]
fn run_out_of_range_demo() {
    let mut buf: [i32; 5] = [0; 5];
    let bad_index: usize = core::hint::black_box(5);
    buf[bad_index] = 42;
}

#[allow(dead_code)]
fn run_overflow_demo() {
    let x: i8 = core::hint::black_box(i8::MAX);
    let _y = x + 1;
}
