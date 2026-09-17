# Test 03 — Priority Inversion / Bounded Blocking

## Cosa testa
Tre task (chiamate per priorita'):
- Low
- Medium
- High
Low tiene una risorsa condivisa con ceiling protocol, Medium e High diventano pronti nello stesso istante. Verifica che il ceiling impedisca a Medium di passare avanti a High, e misura quanto High resta bloccato. 

## Requisiti

- [Alire](https://alire.ada.dev/)
- Rust + Cargo, target `thumbv7em-none-eabihf`
- Renode 1.16.1

## Come eseguire

```bash
# Ada
cd ada && alr build
renode --disable-xwt --console -e 's @measure_inversion.resc' -e quit | grep -o -E '(MEDIUM_DELAY|HIGH_BLOCKING)=[0-9]*'

# Rust
cd ../rust && cargo build --release
renode --disable-xwt --console -e 's @measure_inversion.resc' -e quit | grep -o -E '(MEDIUM_DELAY|HIGH_BLOCKING)=[0-9]*'
```

Campioni grezzi in `results/ada_raw.txt` e `results/rust_raw.txt`.

## Risultati

| | Ada (n=10) | Rust (n=10) |
|---|---|---|
| HIGH_BLOCKING (min/media/max) | 72725/72725.0/72725 | 117432/117432.5/117433 |
| MEDIUM_DELAY (min/media/max) | 73205/73205.7/73212 | 117808/117808.0/117808 |

Il ceiling protocol funziona in entrambi: `MEDIUM_DELAY` non è mai minore di `HIGH_BLOCKING`, nessuna inversione illimitata. Su questo carico di calcolo puro, **Ada è ~1.61× più veloce di Rust** 
