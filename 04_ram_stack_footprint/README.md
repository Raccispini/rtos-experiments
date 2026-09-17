# Test 04 — Impronta RAM/Stack


## Cosa fa

Costo statico in RAM, in byte, dello stack dedicato per-task di Ravenscar vs lo stack unico condiviso ("stackless") di RTIC, su 4 task/handler banali equivalenti. Analisi statica (`size`/`nm`), più un'estensione che misura l'uso reale (high-water-mark) dello stack RTIC.

## Requisiti

- [Alire](https://alire.ada.dev/) (fornisce `arm-eabi-size`/`arm-eabi-nm`)
- Rust + Cargo, target `thumbv7em-none-eabihf`
- Renode 1.16.1 (solo per l'estensione high-water-mark)

## Come eseguire

```bash
# Ada
cd ada && alr build
arm-eabi-size obj/ada_renode_rtos
arm-eabi-nm --print-size --size-sort obj/ada_renode_rtos | grep -i -E 'stack|footprint_tasks__task_[abcd]$'

# Rust
cd ../rust && cargo build --release
arm-eabi-size target/thumbv7em-none-eabihf/release/rust_renode_rtos
arm-eabi-nm --print-size --size-sort target/thumbv7em-none-eabihf/release/rust_renode_rtos | grep -E ' [bBdD] '

# Estensione high-water-mark (Rust)
renode --disable-xwt --console -e 's @measure_stack_hwm.resc' -e quit | grep -E 'STACK_(REGION|HWM)_BYTES'
```

Output completo in `results/ada_static_analysis.txt`, `results/rust_static_analysis.txt`, `results/rust_stack_hwm.txt`.
### NOTE
Per per lanciare `arm-eabi-size` e `arm-eabi-nm` potrebbe essere necessario dichiararli esplicitamente nel path, siccome sono scaricati in automatico dalla toolchain.
## Risultati

| | Ada | Rust |
|---|---|---|
| .text | 68756 | 6508 |
| .data | 2128 | 0 |
| .bss | 23184 | 76 |
| **RAM statica (.data+.bss)** | **25312** | **76** |

I 4 task Ada (Storage_Size 512/1024/2048/4096B) allocano realmente 1144/1656/2680/4728B: **+632B fissi per task**, indipendenti dalla dimensione. Il runtime Ravenscar riserva già ~9808B prima di ogni task applicativo (idle stack, interrupt stack, secondary stack, ecc.) — costo che RTIC non ha.

Rust non ha simboli di stack statici. Misurando l'uso reale (stack painting): **512B usati su 262068 disponibili (~0.2%)**.

Ada usa **~333×** più RAM statica per questo scheletro — ma il costo per-task in Ada è esplicito e verificabile a link-time, mentre in RTIC va misurato a runtime.
