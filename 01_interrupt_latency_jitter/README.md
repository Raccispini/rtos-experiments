# Test 01 — Latenza Interrupt & Jitter


## Cosa testa

Cicli di clock tra un interrupt esterno e la prima istruzione del suo handler, con CPU sempre occupata da un carico di fondo. Verifica se la latenza è limitata e predicibile.

## Requisiti

- [Alire](https://alire.ada.dev/)
- Rust + Cargo, target `thumbv7em-none-eabihf`
- Renode 1.16.1

## Come eseguire

```bash
# Ada
cd ada && alr build
renode --disable-xwt --console -e 's @measure_jitter.resc' -e quit | grep -o 'CYCLES=[0-9]*'

# Rust
cd ../rust && cargo build --release
renode --disable-xwt --console -e 's @measure_jitter.resc' -e quit | grep -o 'CYCLES=[0-9]*'
```

Campioni grezzi in `results/ada_samples.txt` e `results/rust_samples.txt`.

## Risultati

| | Ada | Rust |
|---|---|---|
| campioni | 30 | 30 |
| min/max | 93/93 | 5/5 |
| media | 93.00 | 5.00 |
| dev. standard | 0.00 | 0.00 |

Ada impiega **~18.6×** i cicli di Rust.
