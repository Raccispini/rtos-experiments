# Test 07 — Robustezza a Input Malformati / Buffer Overflow

## Cosa testa

Cosa succede quando un pacchetto dichiara una lunghezza maggiore del buffer di destinazione, con la copia più diretta in ciascun linguaggio. Variante naive (nessun controllo) vs validata (lunghezza clampata), per misurare anche il costo della validazione.

## Requisiti

- [Alire](https://alire.ada.dev/)
- Rust + Cargo, target `thumbv7em-none-eabihf`
- Renode 1.16.1

## Come eseguire

```bash
# Ada
cd ada && alr build
renode --disable-xwt --console -e 's @measure_robustness.resc' -e quit

# Rust
cd ../rust && cargo build --release
renode --disable-xwt --console -e 's @measure_robustness.resc' -e quit
```

Variante naive di default (`Use_Validation`/`USE_VALIDATION = false`); per la validata impostare `True`/`true` su entrambi i lati e ricompilare.

## Risultati

100 pacchetti, 1 ogni 5 malformato (`Len=12` contro `Cap=8`), periodo 200ms.

### Variante naive

| | Pacchetti validi | Pacchetto malformato |
|---|---|---|
| Ada | `cost=39` cicli | `Constraint_Error` non gestita → `_exit` → **reset dell'intera CPU** (`AIRCR.SYSRESETREQ`, confermato via disassembly). Il firmware riparte da zero ogni ~1s. |
| Rust | `cost=2` cicli | Panic → `panic-halt`: **CPU bloccata per sempre**, nessun reset, nessun messaggio. |

un'eccezione Ada non gestita non termina solo il task, in questo runtime/BSP **resetta tutta la CPU**. Due esiti diversi (restart-loop Ada vs freeze permanente Rust), nessuno "contiene il danno" meglio dell'altro.

### Variante validata

| | Pacchetti validi | Malformati clampati |
|---|---|---|
| Ada | 40-41 cicli | 52-53 cicli |
| Rust | 0 (100/100) | 0 (100/100) |

Tutti i 100 pacchetti processati senza crash in entrambi. Overhead di validazione: Ada ~+1-2 cicli (~3-5%); per Rust i valori (2 e 0) sono sotto la risoluzione del simulatore, non misurabile in modo affidabile.
