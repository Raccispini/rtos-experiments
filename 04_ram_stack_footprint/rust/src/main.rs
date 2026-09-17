#![no_std]
#![no_main]

use panic_halt as _;

#[rtic::app(device = nrf52840_hal::pac, peripherals = true, dispatchers = [SWI0_EGU0, SWI1_EGU1, SWI2_EGU2])]
mod app {
    use nrf52840_hal::{
        gpio::{p0::Parts as P0Parts, Level},
        pac::UARTE0,
        uarte::{Baudrate, Parity, Pins, Uarte},
    };
    use heapless::String;
    use core::fmt::Write;

    const STACK_PAINT_VALUE: u32 = 0xCCCC_CCCC;

    #[shared]
    struct Shared {}

    #[local]
    struct Local {
        uart_tx: Uarte<UARTE0>,
    }

    fn measure_stack_hwm() -> (u32, u32) {
        extern "C" {
            static _stack_start: u32;
        }
        let sheap = cortex_m_rt::heap_start() as u32;
        let stack_top = &raw const _stack_start as u32;

        let mut addr = sheap;
        while addr < stack_top {
            let word = unsafe { core::ptr::read_volatile(addr as *const u32) };
            if word != STACK_PAINT_VALUE {
                break;
            }
            addr += 4;
        }
        (stack_top - sheap, stack_top - addr)
    }

    #[init]
    fn init(cx: init::Context) -> (Shared, Local, init::Monotonics) {
        let mut syst = cx.core.SYST;
        let reload = 64_000_000u32 - 1;
        syst.set_clock_source(cortex_m::peripheral::syst::SystClkSource::Core);
        syst.set_reload(reload);
        syst.clear_current();
        syst.enable_counter();
        syst.enable_interrupt();

        let p0 = P0Parts::new(cx.device.P0);
        let mut uart_tx = Uarte::new(
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

        let (region_bytes, _) = measure_stack_hwm();
        let mut buf: String<48> = String::new();
        let _ = writeln!(buf, "STACK_REGION_BYTES={}", region_bytes);
        uart_tx.write(buf.as_bytes()).ok();

        (Shared {}, Local { uart_tx }, init::Monotonics())
    }

    #[task(binds = SysTick, priority = 1)]
    fn task_a(_cx: task_a::Context) {
        task_b::spawn().ok();
    }

    #[task(priority = 2)]
    fn task_b(_cx: task_b::Context) {
        task_c::spawn().ok();
    }

    #[task(priority = 3)]
    fn task_c(_cx: task_c::Context) {
        task_d::spawn().ok();
    }

    #[task(priority = 4, local = [uart_tx])]
    fn task_d(cx: task_d::Context) {
        let (_, used_bytes) = measure_stack_hwm();
        let mut buf: String<48> = String::new();
        let _ = writeln!(buf, "STACK_HWM_BYTES={}", used_bytes);
        cx.local.uart_tx.write(buf.as_bytes()).ok();
    }
}
