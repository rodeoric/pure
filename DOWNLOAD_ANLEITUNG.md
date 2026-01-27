# DOWNLOAD-ANLEITUNG FÜR XAUUSD_WickScalp_Intrabar.mq5

## ⚠️ WICHTIG: Häufigster Fehler

**Sie kopieren die Datei FALSCH!**

Die Fehler entstehen, weil Sie:
- Von GitHub's Webseite kopieren/einfügen
- Aus dem README oder PR-Beschreibung kopieren
- Markdown-Formatierung mitkopiern (`, **, ##, etc.)

## ✅ RICHTIGE Download-Methode

### Methode 1: RAW Button (EMPFOHLEN)

1. Gehen Sie zu: https://github.com/rodeoric/pure/blob/copilot/add-wicktrading-ea/XAUUSD_WickScalp_Intrabar.mq5

2. Klicken Sie auf "Raw" Button (oben rechts über dem Code)
   - Der Button sieht aus wie: [< > Raw Blame]

3. Die Seite zeigt jetzt NUR den reinen Code ohne Formatierung

4. Rechtsklick → "Speichern unter..." oder Strg+S
   - Speichern Sie als: XAUUSD_WickScalp_Intrabar.mq5
   - NICHT als .txt Datei!

5. Kopieren Sie die Datei in Ihren MT5 Experts Ordner:
   ```
   C:\Users\IhrName\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\
   ```

6. Öffnen Sie die Datei in MetaEditor und kompilieren Sie (F7)

### Methode 2: Git Clone

```bash
git clone https://github.com/rodeoric/pure.git
cd pure
```

Die Datei ist dann unter: `pure/XAUUSD_WickScalp_Intrabar.mq5`

### Methode 3: Direct Download Link

Verwenden Sie diesen direkten Link:
```
https://raw.githubusercontent.com/rodeoric/pure/copilot/add-wicktrading-ea/XAUUSD_WickScalp_Intrabar.mq5
```

Rechtsklick → "Ziel speichern unter..."

## ❌ WAS SIE NICHT TUN SOLLTEN

- ❌ NICHT von der GitHub Webseite kopieren/einfügen
- ❌ NICHT aus dem README kopieren
- ❌ NICHT aus der PR-Beschreibung kopieren
- ❌ NICHT als .txt speichern und umbenennen
- ❌ NICHT die Datei mit Notepad öffnen und kopieren

## ✅ Überprüfung ob die Datei korrekt ist

Öffnen Sie die Datei in MetaEditor. Die ersten Zeilen sollten so aussehen:

```
//+------------------------------------------------------------------+
//| XAUUSD_WickScalp_Intrabar.mq5                                     |
//| Intrabar wick-rejection scalper with auto SL/TP + timeout         |
//| Optimized for quick scalping trades on M1/M5 timeframes          |
//+------------------------------------------------------------------+
#property copyright "Wicktrading EA"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;
```

Wenn Sie ` (Backticks), ## oder ** am Anfang der Zeilen sehen, haben Sie die Datei FALSCH kopiert!

## Kompilierung

1. Öffnen Sie MetaEditor (F4 in MT5)
2. Datei → Öffnen → XAUUSD_WickScalp_Intrabar.mq5
3. Drücken Sie F7 zum Kompilieren
4. Es sollte "0 error(s), 0 warning(s)" anzeigen

Wenn Sie Fehler sehen, haben Sie die Datei falsch heruntergeladen!

## Support

Wenn Sie immer noch Probleme haben:
1. Laden Sie die Datei mit Methode 1 (RAW Button) herunter
2. Überprüfen Sie, dass keine Backticks (`) im Code sind
3. Stellen Sie sicher, die Datei hat die .mq5 Endung
