# Test 06 — Parità Dimensione Binario

## Cosa testa

Dimensione statica del binario (`.text`/`.data`/`.bss`) a parità di funzionalità applicativa reale (producer periodico con carico matematico, consumer, interrupt da bottone).

## Requisiti

- [Alire](https://alire.ada.dev/)
- Rust + Cargo, target `thumbv7em-none-eabihf`
- `size`/`nm` (nessun Renode, solo analisi statica)

## Come eseguire

```bash
# Ada
cd ada && alr build
size obj/ada_renode_rtos
nm --print-size --size-sort obj/ada_renode_rtos | grep -i -E 'stack|periodic_producer__|periodic_consumer__|button_monitor__'

# Rust
cd ../rust && cargo build --release
size target/thumbv7em-none-eabihf/release/rust_renode_rtos
nm --print-size --size-sort target/thumbv7em-none-eabihf/release/rust_renode_rtos | grep -E ' [bBdD] '
```

Output completo in `results/ada_static_analysis.txt` e `results/rust_static_analysis.txt`.

## Risultati

| | Ada | Rust |
|---|---|---|
| .text/.data/.bss/totale | 91264/2808/21800/**115872** | 20152/0/36/**20188** |
| Δ `.text` vs baseline Test 04 | +22508 | +13644 |

Stesse chiamate matematiche (`Sin`/`Cos`/`Sqrt`/`Exp`/`Log`) in entrambi: la libreria matematica pesa **854 byte lato Ada/newlib contro 9996 lato Rust/`libm`** (~11-12× più grande) — `libm` implementa la riduzione d'argomento IEEE 754 completa, newlib è molto più compatta (`sqrtf` = 6 byte).
