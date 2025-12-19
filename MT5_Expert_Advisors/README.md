# Pure Wick Trading Expert Advisor for MetaTrader 5

## Übersicht

Dieser Expert Advisor (EA) implementiert eine automatische Trading-Strategie für MetaTrader 5, die auf Kerzendocht-Mustern (Candlestick Wicks) im 1-Minuten-Timeframe basiert.

## Features

### Hauptstrategie: Pin Bar Reversal
- **Erkennung von Hammer und Shooting Star Patterns**
- **Symbol-Filter** nur für ausgewählte 21 Währungspaare und Instrumente
- **Automatische Entry-Logik** basierend auf Docht-zu-Körper Verhältnis
- **Sehr enge SL/TP** innerhalb der Kerze (Tight Stops Modus)
- **Dynamische Stop Loss und Take Profit** Berechnung
- **Risikomanagement** mit prozentbasierter Position-Sizing
- **Trailing Stop** für Gewinnmaximierung
- **Session-Filter** für optimale Trading-Zeiten
- **Spread-Filter** zum Schutz vor hohen Kosten
- **Trend-Filter** (optional) für Trades in Trendrichtung

## Erlaubte Trading-Symbole

Der EA handelt **nur** mit den folgenden 21 Symbolen:

```
AUDCAD, AUDCHF, AUDJPY, AUDNZD, AUDUSD
CADCHF, CADJPY, CHFJPY, EURAUD, EURCAD
USDJPY, GBPUSD, USDCHF, EURUSD, XAUUSD
EURHUF, BTCUSD, XRPUSD, USDCAD, USDSEK
NZDUSD
```

⚠️ **Wichtig**: Wenn Sie den EA auf einem anderen Symbol starten, wird die Initialisierung fehlschlagen.

## Installation

1. **Download**: Laden Sie die Datei `PureWickTradingEA.mq5` herunter
2. **Kopieren**: Speichern Sie die Datei in Ihrem MT5-Datenordner:
   ```
   C:\Users\[IhrBenutzername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\
   ```
   Oder nutzen Sie im MT5: Datei → Datenordner öffnen → MQL5 → Experts

3. **Kompilieren**: 
   - Öffnen Sie MetaEditor (F4 in MT5)
   - Öffnen Sie die `.mq5` Datei
   - Drücken Sie F7 zum Kompilieren
   - Stellen Sie sicher, dass keine Fehler auftreten

4. **Aktivieren**:
   - Öffnen Sie einen M1 (1-Minute) Chart Ihres gewünschten Symbols
   - Ziehen Sie den EA aus dem Navigator-Fenster auf den Chart
   - Aktivieren Sie "Algo-Trading" (Strg+E oder Button in der Toolbar)

## Konfiguration

### Risk Management Parameter

| Parameter | Standard | Beschreibung |
|-----------|----------|--------------|
| RiskPercent | 1.0 | Risiko pro Trade in Prozent des Kontos |
| MinLotSize | 0.01 | Minimale Lot-Größe für Trades |
| MaxLotSize | 10.0 | Maximale Lot-Größe für Trades |

### Strategie Parameter

| Parameter | Standard | Beschreibung |
|-----------|----------|--------------|
| WickToBodyRatio | 2.0 | Minimales Verhältnis von Docht zu Körper |
| OppositeWickMaxPercent | 30.0 | Maximaler Gegendocht in % des Hauptdochts |
| MinWickPips | 5 | Minimale Dochtlänge in Pips |
| **UseTightStops** | **true** | **Aktiviert sehr enge SL/TP innerhalb der Kerze** |
| **TightSLPercent** | **30.0** | **SL bei % der Kerzenhöhe (wenn UseTightStops=true)** |
| **TightTPPercent** | **40.0** | **TP bei % der Kerzenhöhe (wenn UseTightStops=true)** |
| TakeProfitMultiplier | 1.5 | Take Profit als Vielfaches der Dochtlänge (wenn UseTightStops=false) |
| StopLossBuffer | 3 | Zusätzliche Pips für Stop Loss (wenn UseTightStops=false) |

**Hinweis zu Tight Stops**: Wenn `UseTightStops=true`, werden SL und TP basierend auf der Kerzenhöhe berechnet und liegen innerhalb oder sehr nah an der Kerze. Dies führt zu sehr engen Stops, ideal für schnelle Scalping-Trades.

### Trading Einstellungen

| Parameter | Standard | Beschreibung |
|-----------|----------|--------------|
| MagicNumber | 123456 | Eindeutige ID für EA-Orders |
| TradeOnlyTrend | false | Nur in Trendrichtung handeln |
| TrendPeriod | 20 | MA-Periode für Trend-Erkennung |
| MaxOpenTrades | 1 | Maximum gleichzeitige offene Trades |
| UseTrailingStop | true | Trailing Stop aktivieren |
| TrailingStopPercent | 50.0 | Start Trailing bei % des TP |

### Session Filter

| Parameter | Standard | Beschreibung |
|-----------|----------|--------------|
| UseSessionFilter | true | Session-Filter aktivieren |
| SessionStartHour | 8 | Handelsstart (Server-Zeit) |
| SessionEndHour | 20 | Handelsende (Server-Zeit) |
| MaxSpreadPips | 3.0 | Maximaler erlaubter Spread in Pips |

## Empfohlene Einstellungen

### Für Tight Stops (Standard - Sehr enge SL/TP innerhalb der Kerze)
```
UseTightStops = true
TightSLPercent = 30.0
TightTPPercent = 40.0
RiskPercent = 1.0
MinWickPips = 5
MaxOpenTrades = 1
```

### Für Anfänger (Konservativ)
```
UseTightStops = false
RiskPercent = 0.5
MinWickPips = 8
TakeProfitMultiplier = 2.0
MaxOpenTrades = 1
TradeOnlyTrend = true
```

### Für Fortgeschrittene (Moderat)
```
UseTightStops = false
RiskPercent = 1.0
MinWickPips = 5
TakeProfitMultiplier = 1.5
MaxOpenTrades = 2
TradeOnlyTrend = false
UseTrailingStop = true
```

### Für Erfahrene (Aggressiv mit Tight Stops)
```
UseTightStops = true
TightSLPercent = 25.0
TightTPPercent = 35.0
RiskPercent = 2.0
MinWickPips = 3
MaxOpenTrades = 3
WickToBodyRatio = 1.5
```

## Trading-Logik

### Long Entry (Kaufen)
Ein Long-Trade wird eröffnet, wenn:
1. ✅ Eine bullische Pin Bar (Hammer) erkannt wird
2. ✅ Unterer Docht ist mindestens 2x so lang wie der Körper
3. ✅ Oberer Docht ist kleiner als 30% des unteren Dochts
4. ✅ Schlusskurs liegt im oberen 40% der Kerze
5. ✅ Docht ist mindestens 5 Pips lang
6. ✅ Spread ist unter dem Maximum
7. ✅ (Optional) Preis ist über dem Trend-MA

**Stop Loss & Take Profit (Tight Stops Modus - Standard)**:
- **SL**: 30% der Kerzenhöhe vom Entry-Preis entfernt (innerhalb der Kerze)
- **TP**: 40% der Kerzenhöhe vom Entry-Preis entfernt (knapp innerhalb/außerhalb der Kerze)
- Sehr enge Stops für schnelle Scalping-Trades

**Stop Loss & Take Profit (Standard Modus - UseTightStops=false)**:
- **SL**: Unter dem Docht-Tief + Buffer
- **TP**: 1.5x der Dochtlänge

### Short Entry (Verkaufen)
Ein Short-Trade wird eröffnet, wenn:
1. ✅ Eine bearische Pin Bar (Shooting Star) erkannt wird
2. ✅ Oberer Docht ist mindestens 2x so lang wie der Körper
3. ✅ Unterer Docht ist kleiner als 30% des oberen Dochts
4. ✅ Schlusskurs liegt im unteren 40% der Kerze
5. ✅ Docht ist mindestens 5 Pips lang
6. ✅ Spread ist unter dem Maximum
7. ✅ (Optional) Preis ist unter dem Trend-MA

**Stop Loss & Take Profit (Tight Stops Modus - Standard)**:
- **SL**: 30% der Kerzenhöhe vom Entry-Preis entfernt (innerhalb der Kerze)
- **TP**: 40% der Kerzenhöhe vom Entry-Preis entfernt (knapp innerhalb/außerhalb der Kerze)
- Sehr enge Stops für schnelle Scalping-Trades

**Stop Loss & Take Profit (Standard Modus - UseTightStops=false)**:
- **SL**: Über dem Docht-Hoch + Buffer
- **TP**: 1.5x der Dochtlänge

### Trailing Stop
- Aktiviert sich bei 50% des Take Profit
- Bewegt den SL kontinuierlich mit dem Gewinn
- Schützt bereits erzielte Gewinne

## Beste Währungspaare

**Alle 21 erlaubten Symbole** (siehe oben) können gehandelt werden. Der EA ist optimiert für:
- **Forex-Paare**: EUR/USD, GBP/USD, USD/JPY, AUD/USD, etc.
- **Krypto**: BTC/USD, XRP/USD
- **Edelmetalle**: XAU/USD (Gold)
- **Exotische Paare**: EUR/HUF

⚠️ **Wichtig**: Nur die 21 aufgelisteten Symbole werden vom EA akzeptiert!

## Optimale Trading-Zeiten

| Session | Uhrzeit (GMT) | Empfehlung |
|---------|---------------|------------|
| Tokyo | 00:00 - 09:00 | Moderat |
| London | 08:00 - 17:00 | ⭐ Sehr gut |
| New York | 13:00 - 22:00 | ⭐ Sehr gut |
| London + NY Overlap | 13:00 - 17:00 | ⭐⭐⭐ Optimal |

## Backtesting

### Schritte zum Backtesting:
1. Öffnen Sie den Strategy Tester (Strg+R)
2. Wählen Sie den EA: `PureWickTradingEA`
3. Symbol: EUR/USD (oder anderes Paar)
4. Periode: M1
5. Datum: Mindestens 3 Monate historische Daten
6. Modus: "Alle Ticks" für beste Genauigkeit
7. Klicken Sie auf "Start"

### Was zu überprüfen ist:
- Profit Factor > 1.5
- Drawdown < 20%
- Win Rate > 45%
- Anzahl der Trades ausreichend (min. 100)

## Monitoring

### Im Chart:
Der EA zeigt keine visuellen Elemente, aber Sie sehen:
- Orders im Terminal-Fenster
- SL/TP Linien bei offenen Positionen
- Trading-Historie

### Im Journal/Logs:
```
"PureWickTradingEA initialisiert für EURUSD M1 Chart"
"Order erfolgreich eröffnet: 12345 | Typ: ORDER_TYPE_BUY | Lots: 0.10"
"Position 12345 modifiziert. Neuer SL: 1.08456"
```

## Tipps und Best Practices

### ✅ DO's:
- Immer zuerst auf Demo-Konto testen (min. 1 Monat)
- Umfangreiches Backtesting durchführen
- VPS verwenden für 24/7 Trading
- Regelmäßig Performance überprüfen
- Risk Management Parameter konservativ einstellen
- Nur ein Chart pro Symbol verwenden

### ❌ DON'Ts:
- Nicht auf Live-Konto ohne ausreichende Tests
- Nicht mehrere EAs auf dem gleichen Symbol
- Nicht während wichtiger News-Events
- Nicht mit zu hohem Risiko (>2% pro Trade)
- Nicht ohne Stop Loss handeln
- Nicht manuell in EA-Trades eingreifen

## Fehlerbehebung

### EA öffnet keine Trades
- ✔️ Prüfen Sie, ob Algo-Trading aktiviert ist
- ✔️ Prüfen Sie die Session-Filter Einstellungen
- ✔️ Reduzieren Sie MinWickPips
- ✔️ Deaktivieren Sie TradeOnlyTrend
- ✔️ Prüfen Sie den Spread

### Zu viele Verlust-Trades
- ✔️ Erhöhen Sie MinWickPips
- ✔️ Erhöhen Sie WickToBodyRatio
- ✔️ Aktivieren Sie TradeOnlyTrend
- ✔️ Reduzieren Sie TakeProfitMultiplier
- ✔️ Nutzen Sie Session-Filter

### Zu wenige Trades
- ✔️ Reduzieren Sie MinWickPips
- ✔️ Reduzieren Sie WickToBodyRatio
- ✔️ Erweitern Sie die Trading-Session
- ✔️ Erhöhen Sie MaxSpreadPips (vorsichtig!)

## Weitere Strategien

Siehe `EXPERT_ADVISOR_STRATEGY.md` für 4 weitere Trading-Strategien:
1. ✅ Pin Bar Reversal (implementiert)
2. Docht Rejection Strategie
3. Doppel-Docht Bestätigung
4. Volatilitäts-Breakout mit Docht-Filter
5. Scalping mit Mikro-Dochten

## Support und Updates

- GitHub: https://github.com/rodeoric/pure
- Dokumentation: Siehe `EXPERT_ADVISOR_STRATEGY.md`

## Risiko-Hinweis

⚠️ **WICHTIGER HINWEIS**: Trading mit Expert Advisors birgt erhebliche Risiken. Es gibt keine Garantie für Profitabilität. Vergangene Performance ist keine Garantie für zukünftige Ergebnisse.

**Handeln Sie nur mit Kapital, dessen Verlust Sie sich leisten können.**

- Führen Sie immer umfangreiche Tests durch
- Starten Sie mit kleinem Kapital
- Nutzen Sie strenge Risikomanagement-Regeln
- Überwachen Sie den EA regelmäßig
- Passen Sie Parameter an Marktbedingungen an

## Lizenz

Dieses Projekt ist Teil des Pure Cryptocurrency Projekts.
Copyright © Pure Cryptocurrency Project

---

**Version**: 1.00
**Letztes Update**: Dezember 2025
**Kompatibilität**: MetaTrader 5 Build 3000+
