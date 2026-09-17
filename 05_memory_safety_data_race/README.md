# Test 05 — Sicurezza della Memoria & Data Race


## Cosa testa

A che stadio (compile-time, runtime, o mai) Ada e Rust intercettano 5 classi di errore comuni in ambito embedded: data race, accesso fuori range, overflow aritmetico, riferimento dangling, e quanta superficie "unsafe" serve per toccare i registri hardware. Test categorico, non di velocità.

## Requisiti

- [Alire](https://alire.ada.dev/)
- Rust + Cargo, target `thumbv7em-none-eabihf`
- Renode 1.16.1

## Come eseguire

```bash
# Ada
cd ada && alr build
renode --disable-xwt --console -e 's @measure_safety.resc' -e quit

# Rust — di default esegue lo scenario 1. Per 2/3, impostare
# SELECTED_SCENARIO in main.rs e ricompilare separatamente.
cd ../rust && cargo build --release
renode --disable-xwt --console -e 's @measure_safety.resc' -e quit
```

Lo scenario 4 (dangling) è verificato compilando isolatamente con `gprbuild`/`rustc`. Lo scenario 5 è una ricerca testuale nei sorgenti dei Test 01-04.

## Risultati

| Scenario | Ada | Rust |
|---|---|---|
| 1 — data race | Compila senza costrutti speciali; `SHARED_COUNTER_FINAL=300050=EXPECTED` in 3/3 run | Compila ma richiede `unsafe`; stesso esito in 3/3 run |
| 2 — fuori range | `CONSTRAINT_ERROR` catturato, prosegue | Panic, `panic-halt` blocca la CPU per sempre, nessun messaggio |
| 3 — overflow | `CONSTRAINT_ERROR` catturato, prosegue | Nessun panic in release: wrap silenzioso a `-128` |
| 4 — dangling | Rifiutato a compile-time | Rifiutato a compile-time (`E0515`) |
| 5 — superficie unsafe (Test 01-04) | 0 occorrenze | 1 blocco `unsafe` reale (lettura stack per l'high-water-mark del Test 04) |

