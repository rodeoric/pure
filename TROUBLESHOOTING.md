# TROUBLESHOOTING - Kompilierungsfehler beheben

## Problem: "undeclared identifier" oder "'i' - some operator expected"

### Ursache
Sie verwenden eine **umbenannte oder modifizierte** Datei. Der EA funktioniert NUR mit dem Original-Dateinamen!

### Lösung

#### ✅ RICHTIG:
- Dateiname: **XAUUSD_WickScalp_Intrabar.mq5**
- Größe: ~12 KB
- Zeilen: 392

#### ❌ FALSCH:
- wicktrading_test_27.01.2026.mq5 ❌
- XAUUSD_WickScalp_Intrabar_copy.mq5 ❌
- XAUUSD_WickScalp_Intrabar (1).mq5 ❌
- Jeder andere Name außer dem Original ❌

## Schritt-für-Schritt Fehlerbehebung

### Schritt 1: Alte Dateien löschen
Löschen Sie ALLE Versionen mit falschem Namen:
- wicktrading_test_27.01.2026.mq5
- Alle Kopien oder umbenannte Versionen

### Schritt 2: Frischer Download
1. Gehen Sie zu: https://raw.githubusercontent.com/rodeoric/pure/copilot/add-wicktrading-ea/XAUUSD_WickScalp_Intrabar.mq5
2. Drücken Sie **Strg+S** (Windows) oder **Cmd+S** (Mac)
3. Im "Speichern unter" Dialog:
   - Überprüfen Sie: Name ist **XAUUSD_WickScalp_Intrabar.mq5**
   - Speicherort: `C:\Users\[IhrName]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\`

### Schritt 3: In MetaEditor öffnen
1. MetaEditor öffnen (F4 in MT5)
2. Navigator → Experts → **XAUUSD_WickScalp_Intrabar**
3. Doppelklick zum Öffnen

### Schritt 4: Überprüfung vor Kompilierung
Im MetaEditor-Fenster oben sollte stehen:
```
XAUUSD_WickScalp_Intrabar.mq5
```
**NICHT** "wicktrading_test_27.01.2026.mq5"!

Erste Zeilen sollten sein:
```mql5
//+------------------------------------------------------------------+
//| XAUUSD_WickScalp_Intrabar.mq5                                     |
//| Intrabar wick-rejection scalper with auto SL/TP + timeout         |
```

### Schritt 5: Kompilieren
Drücken Sie **F7**

Erwartetes Ergebnis:
```
0 error(s), 0 warning(s)
Compilation successful
```

## Häufige Fehler

### Fehler 1: "undeclared identifier" bei Zeile 156/171
**Ursache:** Umbenannte Datei oder beschädigter Download
**Lösung:** Schritte 1-5 oben befolgen

### Fehler 2: "unknown symbol '`'"
**Ursache:** Copy/Paste mit Markdown-Formatierung
**Lösung:** RAW-Download verwenden (siehe Schritt 2)

### Fehler 3: "invalid preprocessor command"
**Ursache:** Copy/Paste aus PR-Beschreibung oder README
**Lösung:** RAW-Download verwenden (siehe Schritt 2)

## Wichtige Regeln

1. ✅ **Dateinamen NIEMALS ändern**
2. ✅ **IMMER von raw.githubusercontent.com herunterladen**
3. ✅ **NIEMALS copy/paste verwenden**
4. ✅ **Original-Datei direkt kompilieren**

## Wenn es immer noch nicht funktioniert

1. Zeigen Sie einen Screenshot vom MetaEditor-Fenster (mit Dateiname oben sichtbar)
2. Zeigen Sie die Dateigröße (Rechtsklick → Eigenschaften)
3. Zeigen Sie die Anzahl der Zeilen (unten rechts in MetaEditor)

Die Datei **MUSS**:
- Name: **XAUUSD_WickScalp_Intrabar.mq5**
- Größe: ~12 KB
- Zeilen: 392
- Keine Backticks (`) im Code

## Direkter Download-Link (Copy/Paste NICHT erlaubt!)

```
https://raw.githubusercontent.com/rodeoric/pure/copilot/add-wicktrading-ea/XAUUSD_WickScalp_Intrabar.mq5
```

Rechtsklick auf Link → "Ziel speichern unter..." → Als .mq5 speichern
