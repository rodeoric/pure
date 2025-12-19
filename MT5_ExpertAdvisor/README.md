# AutoSLTP EA - Automatic Stop Loss & Take Profit Management

## Übersicht (Overview)

Dieser Expert Advisor (EA) für MetaTrader 5 automatisiert das Management von Stop Loss (SL) und Take Profit (TP) für Ihre Trades.

This Expert Advisor (EA) for MetaTrader 5 automates the management of Stop Loss (SL) and Take Profit (TP) for your trades.

## Hauptfunktionen (Main Features)

### 1. Automatisches SL/TP beim Trade-Eröffnung
- **Stop Loss**: Automatisch 10 Pips unter dem Einstiegspreis (für Long-Positionen)
- **Take Profit**: Automatisch 20 Pips über dem Einstiegspreis (für Long-Positionen)
- Bei Short-Positionen werden die Werte entsprechend umgekehrt

### 2. Erkennung manueller Änderungen
- Wenn Sie den SL oder TP manuell ändern, stoppt der EA die automatische Verwaltung für diese Position
- Dies gibt Ihnen die volle Kontrolle, falls Sie eine Position manuell steuern möchten

### 3. Automatisches Trailing des Stop Loss
- Der EA überwacht profitable Positionen
- Verwendet 5-Minuten-Kerzen zur Analyse
- Trailing-Bedingung: Wenn die aktuelle Kerze 20% größer als die vorherige ist, wird der SL um 5 Pips nachgezogen
- Dies schützt Ihre Gewinne, während Trendfortsetzungen möglich bleiben

## Installation

1. **Kopieren Sie die Datei** `AutoSLTP_EA.mq5` in Ihren MetaTrader 5 Datenordner:
   ```
   C:\Users\[IhrName]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\
   ```

2. **Kompilieren Sie den EA** im MetaEditor oder MetaTrader 5 wird ihn automatisch kompilieren

3. **Ziehen Sie den EA** aus dem Navigator-Fenster auf ein Chart

## Konfiguration (Configuration)

### Stop Loss & Take Profit Einstellungen
- **StopLossPips** (Standard: 10.0): Stop Loss Abstand in Pips
- **TakeProfitPips** (Standard: 20.0): Take Profit Abstand in Pips

### Trailing Einstellungen
- **TrailStepPips** (Standard: 5.0): Schrittweite für das Trailing in Pips
- **CandleThresholdPercent** (Standard: 20.0): Schwellenwert für Kerzengröße in Prozent
- **TrailTimeframe** (Standard: PERIOD_M5): Zeitrahmen für Kerzenanalyse

### Trading Pairs
- **TradingSymbols** (Standard: "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,USDJPY,GBPUSD,USDCHF,EURUSD,XAUUSD,EURHUF,BTCUSD"): 
  Kommagetrennte Liste der zu überwachenden Währungspaare
  
  Sie können diese Liste anpassen, z.B.:
  - "EURUSD,GBPUSD" - nur zwei Paare
  - "EURUSD,GBPUSD,USDJPY,EURJPY,GBPJPY" - mehrere Paare
  - Wichtig: Keine Leerzeichen nach den Kommas!

### Allgemeine Einstellungen
- **MagicNumber** (Standard: 123456): Identifikationsnummer für vom EA verwaltete Positionen

## Funktionsweise

### 1. Trade-Eröffnung
Wenn Sie einen neuen Trade eröffnen:
1. Der EA erkennt die neue Position
2. Falls kein SL/TP gesetzt ist, werden diese automatisch hinzugefügt
3. SL: 10 Pips vom Einstieg entfernt
4. TP: 20 Pips vom Einstieg entfernt

### 2. Manuelle Anpassung
Wenn Sie SL oder TP manuell ändern:
1. Der EA erkennt die Änderung
2. Die automatische Verwaltung für diese Position wird gestoppt
3. Sie haben volle Kontrolle über die Position

### 3. Trailing Stop Loss
Wenn die Position im Gewinn ist:
1. Der EA überwacht 5-Minuten-Kerzen
2. Bei Breakeven passiert bei normalen Kerzen nichts
3. Wenn eine Kerze 20% größer als die vorherige ist:
   - Der SL wird um 5 Pips in Gewinnrichtung nachgezogen
   - Dies schützt bereits erzielte Gewinne

## Beispiel-Szenario

### Long-Position (Kauf):
1. **Trade-Eröffnung bei 1.1000**
   - Automatischer SL: 1.0990 (10 Pips darunter)
   - Automatischer TP: 1.1020 (20 Pips darüber)

2. **Preis steigt auf 1.1010** (Breakeven + 10 Pips)
   - 5-Minuten-Kerze 1: Größe 5 Pips
   - 5-Minuten-Kerze 2: Größe 4 Pips → Keine Aktion (nicht 20% größer)
   - 5-Minuten-Kerze 3: Größe 6 Pips → Trailing aktiviert! (20% größer als Kerze 1)
   - Neuer SL: 1.0995 (5 Pips nachgezogen)

3. **Preis steigt weiter auf 1.1015**
   - Weiteres Trailing nach gleicher Logik
   - SL wird kontinuierlich nachgezogen

### Short-Position (Verkauf):
Funktioniert analog, nur in umgekehrter Richtung.

## Unterstützte Währungspaare

Standard-Konfiguration:
- AUDCAD (Australian Dollar / Canadian Dollar)
- AUDCHF (Australian Dollar / Swiss Franc)
- AUDJPY (Australian Dollar / Japanese Yen)
- AUDNZD (Australian Dollar / New Zealand Dollar)
- AUDUSD (Australian Dollar / US Dollar)
- CADCHF (Canadian Dollar / Swiss Franc)
- CADJPY (Canadian Dollar / Japanese Yen)
- CHFJPY (Swiss Franc / Japanese Yen)
- EURAUD (Euro / Australian Dollar)
- EURCAD (Euro / Canadian Dollar)
- USDJPY (US Dollar / Japanese Yen)
- GBPUSD (British Pound / US Dollar)
- USDCHF (US Dollar / Swiss Franc)
- EURUSD (Euro / US Dollar)
- XAUUSD (Gold / US Dollar)
- EURHUF (Euro / Hungarian Forint)
- BTCUSD (Bitcoin / US Dollar)

Sie können beliebige andere Forex-Paare oder Symbole hinzufügen, indem Sie die **TradingSymbols** Eingabe anpassen.

## Wichtige Hinweise

### Pip-Berechnung
Der EA berechnet Pips korrekt für alle Instrumente:
- 1 Pip = 10 Punkte für alle Standard-Forex-Paare und Instrumente
- Funktioniert mit 2-, 3-, 4- und 5-stelligen Broker-Quotes
- Beispiele: EURUSD (5-stellig): 10 Pips = 100 Punkte, XAUUSD (2-stellig): 10 Pips = 100 Punkte

### Spread-Berücksichtigung
- Der EA setzt SL/TP basierend auf dem Eröffnungspreis
- Beachten Sie, dass der Spread Ihre effektiven Kosten beeinflusst

### Backtesting
- Der EA kann im Strategy Tester getestet werden
- Verwenden Sie "Every tick" Modus für beste Ergebnisse
- Beachten Sie, dass manuelle Modifikationen im Tester nicht simuliert werden können

### Risiko-Management
- Passen Sie StopLossPips an Ihre Risikotoleranz an
- Verwenden Sie angemessene Positionsgrößen
- Der EA ersetzt keine eigene Marktanalyse

## Fehlerbehebung

### EA funktioniert nicht
1. Prüfen Sie, ob "Auto Trading" aktiviert ist (Toolbar-Button)
2. Prüfen Sie, ob DLL-Imports erlaubt sind (falls erforderlich)
3. Prüfen Sie das "Experts" Tab für Fehlermeldungen

### SL/TP wird nicht gesetzt
1. Prüfen Sie, ob das Symbol in der TradingSymbols Liste ist
2. Prüfen Sie die Broker-Mindestabstände (SYMBOL_TRADE_STOPS_LEVEL)
3. Prüfen Sie das Journal für Fehlermeldungen

### Trailing funktioniert nicht
1. Position muss im Gewinn sein
2. Es muss eine neue 5-Minuten-Kerze gebildet werden
3. Kerze muss 20% größer sein als die vorherige
4. SL/TP dürfen nicht manuell geändert worden sein

## Lizenz und Haftungsausschluss

Dieses Programm wird "wie es ist" bereitgestellt. Der Handel mit Devisen birgt hohe Risiken und ist nicht für alle Anleger geeignet. Verwenden Sie diesen EA auf eigenes Risiko.

## Support

Bei Fragen oder Problemen:
1. Prüfen Sie die Dokumentation
2. Prüfen Sie das MetaTrader Journal für Fehlermeldungen
3. Testen Sie den EA zuerst auf einem Demo-Konto

## Version History

**Version 1.00**
- Initiale Veröffentlichung
- Automatisches SL/TP Management
- Erkennung manueller Änderungen
- Candle-basiertes Trailing System
- Unterstützung mehrerer Währungspaare
