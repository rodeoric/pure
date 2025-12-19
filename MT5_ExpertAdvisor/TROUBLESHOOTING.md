# Troubleshooting Guide - AutoSLTP EA

## Problemlösungen für häufige Fehler

---

## 1. EA startet nicht

### Symptom:
- Kein Smiley-Symbol im Chart
- Keine Meldungen im Experten-Tab
- EA erscheint nicht im Navigator

### Lösungen:

#### Lösung 1: Auto Trading aktivieren
1. Toolbar prüfen
2. Grüner Button "Auto Trading" muss aktiv sein
3. Falls rot/grau: Einmal klicken zum Aktivieren

#### Lösung 2: EA-Einstellungen prüfen
1. Rechtsklick auf Chart
2. Expert Advisors → Eigenschaften
3. Tab "Allgemein"
4. ✓ "DLL-Imports zulassen" aktivieren
5. ✓ "Live-Trading zulassen" aktivieren

#### Lösung 3: Neu kompilieren
1. MetaEditor öffnen (F4)
2. AutoSLTP_EA.mq5 öffnen
3. Kompilieren (F7)
4. Auf Fehler prüfen
5. MT5 neu starten

---

## 2. SL/TP wird nicht gesetzt

### Symptom:
- Trade wird eröffnet
- Aber SL und TP bleiben bei 0
- Keine Fehlermeldung

### Lösungen:

#### Lösung 1: Symbol in Liste prüfen
```
TradingSymbols = "EURUSD,GBPUSD,USDJPY"
```
- Ist Ihr gehandeltes Symbol in der Liste?
- Schreibweise exakt wie in Market Watch?
- Keine Leerzeichen vor/nach Kommas?

**Beispiel:**
```
❌ Falsch: "EURUSD, GBPUSD"  (Leerzeichen!)
✓ Richtig: "EURUSD,GBPUSD"
```

#### Lösung 2: Broker-Mindestabstände prüfen
```mql5
// Im MetaEditor ausführen:
double minDistance = SymbolInfoInteger("EURUSD", SYMBOL_TRADE_STOPS_LEVEL);
Print("Mindestabstand: ", minDistance, " Points");
```

**Wenn Mindestabstand > 10 Pips:**
```
StopLossPips = 15.0   // oder höher
```

#### Lösung 3: Position wurde außerhalb EA eröffnet
- EA verwaltet nur Positionen, die nach EA-Start eröffnet wurden
- Oder Positionen ohne SL/TP
- Prüfen Sie, ob Position bereits SL/TP hat

---

## 3. Trailing funktioniert nicht

### Symptom:
- Position ist im Gewinn
- SL wird nicht nachgezogen
- Keine Trailing-Meldungen im Log

### Lösungen:

#### Lösung 1: Position muss im Gewinn sein
```
Buy @ 1.1000
Current Price: 1.0995  ❌ Noch nicht im Gewinn
Current Price: 1.1005  ✓ Im Gewinn, Trailing möglich
```

#### Lösung 2: Neue Kerze muss entstehen
- Warten Sie auf neue 5-Minuten-Kerze
- Trailing erfolgt nur bei neuer Kerze
- Nicht bei jeder Preisbewegung

#### Lösung 3: Kerzen-Schwellenwert prüfen
```
CandleThresholdPercent = 20.0
```

**Beispiel:**
```
Vorherige Kerze: 5 Pips groß
Aktuelle Kerze muss: 6 Pips groß sein (20% mehr)
Aktuelle Kerze ist: 5.5 Pips  ❌ Zu klein
Aktuelle Kerze ist: 6.2 Pips  ✓ Groß genug
```

**Lösung bei zu seltenem Trailing:**
```
CandleThresholdPercent = 15.0  // Senken für häufigeres Trailing
```

#### Lösung 4: Manuelle Änderung prüfen
- Haben Sie SL/TP manuell geändert?
- Dann stoppt EA automatische Verwaltung
- Log-Meldung prüfen: "Manual modification detected"
- Lösung: Neue Position eröffnen ohne manuelle Änderung

---

## 4. "Trade context is busy" Fehler

### Symptom:
```
Failed to set SL/TP for position #12345
Error: 10041 - Trade context is busy
```

### Ursache:
- MetaTrader ist mit anderem Trade-Vorgang beschäftigt
- Kann nicht zwei Operationen gleichzeitig

### Lösung:
- **Nichts tun!**
- EA versucht automatisch erneut
- Wenn persistent: MT5 neu starten

---

## 5. "Invalid stops" Fehler

### Symptom:
```
Failed to modify position #12345
Error: 10015 - Invalid stops
```

### Ursachen und Lösungen:

#### Ursache 1: Stops zu eng
```
// Broker erlaubt min. 15 Pips
StopLossPips = 10.0  ❌ Zu eng

// Lösung:
StopLossPips = 15.0  ✓ Oder höher
```

#### Ursache 2: SL auf falscher Seite
- Nur relevant bei manueller Modifikation
- EA berechnet korrekt, aber überprüfen Sie Log

#### Ursache 3: Freeze Level
```
// Preis zu nah am aktuellen Markt
// EA berücksichtigt dies automatisch
// Falls Fehler: Größeren TrailStepPips verwenden
TrailStepPips = 7.0  // statt 5.0
```

---

## 6. EA hört auf zu arbeiten

### Symptom:
- EA lief anfangs
- Plötzlich keine Reaktion mehr
- Smiley noch sichtbar

### Lösungen:

#### Lösung 1: Chart neu starten
1. EA vom Chart entfernen
2. MT5 neu starten
3. EA wieder auf Chart ziehen

#### Lösung 2: Logs prüfen
1. Terminal-Fenster öffnen (Strg+T)
2. Tab "Experten"
3. Nach Fehlermeldungen suchen
4. Fehlercodes googeln

#### Lösung 3: Memory-Problem
- Zu viele Positionen getrackt?
- MT5 neu starten
- Weniger Symbole überwachen

---

## 7. Falsche Pip-Berechnung

### Symptom:
- SL/TP scheinen falsch berechnet
- Z.B. zu viel oder zu wenig Abstand

### Ursache:
- Seltene Instrumente mit ungewöhnlicher Quotierung

### Lösung:
Der EA verwendet die Standard-Definition: **1 Pip = 10 Punkte** für alle Instrumente.

Dies funktioniert korrekt für:
- Forex-Paare (2-, 3-, 4-, 5-stellig)
- Gold/Silber (XAUUSD, XAGUSD)
- Indizes und andere CFDs

**Beispiele:**
- EURUSD (1.12345): 10 Pips = 100 Punkte = 0.00100
- XAUUSD (1850.50): 10 Pips = 100 Punkte = 1.00
- USDJPY (123.456): 10 Pips = 100 Punkte = 0.100

Falls ein Instrument abweichende Pip-Definitionen benötigt, passen Sie die Parameter `StopLossPips` und `TakeProfitPips` entsprechend an.

---

## 8. Position wird sofort geschlossen

### Symptom:
- Position eröffnet
- SL/TP gesetzt
- Position schließt sofort

### Ursachen:

#### Ursache 1: TP zu eng
```
// Bei hoher Volatilität
TakeProfitPips = 10.0  ❌ Zu eng, schnell erreicht

// Lösung:
TakeProfitPips = 30.0  ✓ Größerer Spielraum
```

#### Ursache 2: Spread zu hoch
```
// EURUSD Spread: 5 Pips (sehr hoch!)
StopLossPips = 10.0
Effektiver SL = 5 Pips  ❌ Zu eng

// Lösung:
- Warten auf niedrigeren Spread
- Größeren SL verwenden
- Anderen Broker erwägen
```

---

## 9. Inkonsistente Performance

### Symptom:
- Manchmal funktioniert EA perfekt
- Manchmal gar nicht
- Unvorhersehbares Verhalten

### Lösungen:

#### Lösung 1: Internet-Verbindung
- Stabile Verbindung erforderlich
- VPN kann Probleme verursachen
- VPS empfohlen für stabilen Betrieb

#### Lösung 2: Marktbedingungen
- Bei News-Events kann EA langsamer reagieren
- Normale Reaktion auf hohe Volatilität
- Überprüfen Sie Wirtschaftskalender

#### Lösung 3: Broker-Server
- Broker-Server überlastet?
- Re-Quotes häufig?
- Ggf. anderen Broker testen

---

## 10. Magic Number Konflikte

### Symptom:
- Mehrere EAs interferieren
- Falsche Positionen werden verwaltet

### Lösung:
```
// Jeder EA braucht eigene Magic Number:
EA #1: MagicNumber = 123456
EA #2: MagicNumber = 234567
EA #3: MagicNumber = 345678
```

---

## 11. Zu viele Modifikationen

### Symptom:
- SL wird zu oft nachgezogen
- Position wird zu früh geschlossen

### Lösung:
```
// Konservativere Einstellungen:
CandleThresholdPercent = 30.0  // Höherer Schwellenwert
TrailTimeframe = PERIOD_M15     // Längere Timeframe
```

---

## 12. Zu wenige Modifikationen

### Symptom:
- SL wird nie nachgezogen
- Obwohl Position lange im Gewinn

### Lösung:
```
// Aggressivere Einstellungen:
CandleThresholdPercent = 15.0  // Niedrigerer Schwellenwert
TrailTimeframe = PERIOD_M5      // Kürzere Timeframe (oder M1)
```

---

## Fehlercode-Referenz

### Häufigste Fehlercodes:

| Code | Bedeutung | Lösung |
|------|-----------|--------|
| 10004 | Requote | Normal, EA versucht erneut |
| 10006 | Request rejected | Broker lehnt ab, Einstellungen prüfen |
| 10015 | Invalid stops | SL/TP Abstand zu eng |
| 10016 | Old price | Alte Preisdaten, warten |
| 10019 | Not enough money | Nicht genug Margin |
| 10027 | Auto trading disabled | Auto Trading aktivieren |
| 10036 | Order locked | Position gesperrt, warten |
| 10041 | Trade context busy | Warten, EA versucht erneut |

### Fehlercodes nachschlagen:
```
https://www.mql5.com/en/docs/constants/errorswarnings/enum_trade_return_codes
```

---

## Debugging-Schritte

### Schritt 1: Logs sammeln
1. Öffnen Sie Terminal (Strg+T)
2. Tab "Experten"
3. Alle Meldungen kopieren
4. In Textdatei speichern

### Schritt 2: Systematisch testen
```
Test 1: EA auf Demo-Konto
Test 2: Nur ein Symbol verwenden
Test 3: Standard-Einstellungen verwenden
Test 4: Nach jedem Test Logs prüfen
```

### Schritt 3: Isolieren
- Funktioniert es auf Symbol A aber nicht B?
- Funktioniert es morgens aber nicht abends?
- Funktioniert es auf Demo aber nicht Live?

### Schritt 4: Dokumentieren
```
Problem: ___________________
Wann: _____________________
Symptome: _________________
Einstellungen: _____________
Fehlermeldungen: __________
```

---

## Präventive Maßnahmen

### Tägliche Routine:
- [ ] Logs auf Fehler prüfen
- [ ] Smiley-Status im Chart prüfen
- [ ] Offene Positionen überprüfen
- [ ] Spread-Bedingungen prüfen

### Wöchentliche Wartung:
- [ ] Performance analysieren
- [ ] Einstellungen optimieren
- [ ] Logs archivieren
- [ ] MT5 auf Updates prüfen

### Monatliche Überprüfung:
- [ ] Broker-Konditionen prüfen
- [ ] EA-Updates suchen
- [ ] Backup erstellen
- [ ] Alternative Einstellungen testen

---

## Notfall-Checkliste

Wenn gar nichts mehr geht:

1. **EA stoppen**
   - EA vom Chart entfernen
   - Alle Positionen manuell schließen

2. **System überprüfen**
   - MT5 neu starten
   - Computer neu starten
   - Internet-Verbindung prüfen

3. **Neu starten**
   - EA neu kompilieren
   - Mit Standard-Einstellungen starten
   - Auf Demo testen

4. **Falls weiterhin Probleme**
   - Broker kontaktieren
   - MQL5 Community fragen
   - Logs zur Analyse bereitstellen

---

## Kontakt für Support

### Selbsthilfe:
1. Diese Dokumentation durchlesen
2. MQL5.com Forum durchsuchen
3. Broker-Support kontaktieren

### Community:
- MQL5.com Forum
- Trading-Foren
- Broker-Community

### Logs bereitstellen:
Wenn Sie um Hilfe bitten, fügen Sie hinzu:
- MT5 Version und Build
- Broker-Name
- EA-Einstellungen
- Komplette Fehlermeldungen
- Schritte zur Reproduktion

---

## Erweiterte Diagnose

### Script zum Testen der Broker-Limits:

```mql5
//+------------------------------------------------------------------+
//|                                                 BrokerInfo.mq5   |
//|                                     Broker Information Script    |
//+------------------------------------------------------------------+
#property copyright "Broker Info Script"
#property version   "1.00"
#property script_show_inputs

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   string symbol = Symbol();
   
   Print("=== Broker Limits für ", symbol, " ===");
   Print("Point: ", SymbolInfoDouble(symbol, SYMBOL_POINT));
   Print("Digits: ", SymbolInfoInteger(symbol, SYMBOL_DIGITS));
   Print("Stops Level: ", SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL));
   Print("Freeze Level: ", SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL));
   Print("Min Volume: ", SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN));
   Print("Max Volume: ", SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX));
   Print("Spread: ", SymbolInfoInteger(symbol, SYMBOL_SPREAD));
}
```

Speichern als "BrokerInfo.mq5" und ausführen!

---

**Bei Fragen oder Problemen:**
- Erst Dokumentation lesen
- Dann Demo-Konto testen
- Logs sammeln
- Systematisch debuggen

**Viel Erfolg! 🔧**
