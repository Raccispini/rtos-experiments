# Test 02 — Overhead di Context Switch
\

## Cosa testa

Costo, in cicli di clock, di un dispatch tra task puramente software (nessun hardware coinvolto): un task periodico segnala un task a priorità più alta e si misura il ritardo. Context-switch reale (Ravenscar) vs interrupt software(RTIC).

## Requisiti

- [Alire](https://alire.ada.dev/)
- Rust + Cargo, target `thumbv7em-none-eabihf`
- Renode 1.16.1

## Come eseguire

```bash
# Ada
cd ada && alr build
renode --disable-xwt --console -e 's @measure_dispatch.resc' -e quit | grep -o 'CYCLES=[0-9]*'

# Rust
cd ../rust && cargo build --release
renode --disable-xwt --console -e 's @measure_dispatch.resc' -e quit | grep -o 'CYCLES=[0-9]*'
```

Campioni grezzi in `results/ada_samples.txt` e `results/rust_samples.txt`.

## Risultati

| | Ada | Rust |
|---|---|---|
| campioni | 42 | 41 |
| min/max | 241/242 | 63/64 |
| media | 241.93 | 63.37 |
| dev. standard | 0.26 | 0.48 |

Ada impiega **~3.8×** i cicli di Rust.
