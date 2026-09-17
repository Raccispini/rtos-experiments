#![no_std]

use core::hint::black_box;
use libm::{cosf, expf, fabsf, logf, sinf, sqrtf};

pub fn small_whetstone(kilo_whets: u32) {
    if kilo_whets == 0 {
        return;
    }

    const T: f32 = 0.499975;
    const T1: f32 = 0.50025;
    const T2: f32 = 2.0;
    const N8: i32 = 10;
    const N9: usize = 7;
    const VALUE: f32 = 0.941377;
    const TOLERANCE: f32 = 0.00001;

    let mut ij: i32 = 1;
    let mut ik: i32 = 2;
    let mut il: i32 = 3;
    let y: f32 = 1.0;
    let mut z: f32 = 0.0;
    let mut sum: f32 = 0.0;

    let mut e1: [f32; 8] = [0.0; 8];

    for _ in 0..kilo_whets {
        e1.fill(0.0);

        ij = (ik - ij) * (il - ik);
        ik = il - (ik - ij);
        il = (il - ik) * (ik + il);

        if (ik - 1) < 1 || (il - 1) < 1 {
            ik = 2;
            il = 2;
        } else if (ik - 1) > N9 as i32 || (il - 1) > N9 as i32 {
            ik = N9 as i32 + 1;
            il = N9 as i32 + 1;
        }
        e1[(il - 1) as usize] = (ij + ik + il) as f32;
        e1[(ik - 1) as usize] = sinf(il as f32);

        z = e1[4];
        for inner_loop_var in 1..=N8 {
            let x = y * (inner_loop_var as f32);
            let y_param = y + z;

            let x_temp = T * (z + x);
            let y_temp = T * (x_temp + y_param);
            z = (x_temp + y_temp) / T2;
        }

        ij = il - (il - 3) * ik;
        il = (il - ik) * (ik - ij);
        ik = (il - ik) * ik;

        if (il - 1) < 1 {
            il = 2;
        } else if (il - 1) > N9 as i32 {
            il = N9 as i32 + 1;
        }
        e1[(il - 1) as usize] = (ij + ik + il) as f32;

        if (ik + 1) > N9 as i32 {
            ik = N9 as i32 - 1;
        } else if (ik + 1) < 1 {
            ik = 0;
        }
        e1[(ik + 1) as usize] = fabsf(cosf(z));

        if ij < 1 || ik < 1 || il < 1 {
            ij = 1;
            ik = 1;
            il = 1;
        } else if ij > N9 as i32 || ik > N9 as i32 || il > N9 as i32 {
            ij = N9 as i32;
            ik = N9 as i32;
            il = N9 as i32;
        }
        for i in 1..=N9 {
            e1[ij as usize] = e1[ik as usize];
            e1[ik as usize] = e1[il as usize];
            e1[i] = e1[ij as usize];
        }

        z = sqrtf(expf(logf(e1[N9]) / T1));
        sum += z;

        if fabsf(z - VALUE) > TOLERANCE {
            sum *= 2.0;
            ij += 1;
        }

        black_box(ij);
        black_box(ik);
        black_box(il);
        black_box(z);
        black_box(sum);
        black_box(&e1);
    }
}
