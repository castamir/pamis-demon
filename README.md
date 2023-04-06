# ISO demon

## Spuštění

Windows příkazová řádka.
```
C:\cesta\k\pamis_demon\demon.bat
```

## Konfigurace úlohy
Soubor `examples\job.ini`

Podporované parametry:

- `typ` - Povinný argument, výčtový typ, podporované hodnoty `ares` (časem `excel` a `word`).

### Konfigurace úlohy ares
- `ico` - Povinný argument

Příklad správné konfigurace:

```
[uloha]
typ=ares

[parametry]
ico=07318219
```
Výstup úlohy ares je v souboru dst\ares.ini.
