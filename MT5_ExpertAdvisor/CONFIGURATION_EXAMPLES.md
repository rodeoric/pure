# Konfigurationsbeispiele für AutoSLTP EA

## Inhaltsverzeichnis
1. [Konservative Einstellungen](#konservative-einstellungen)
2. [Aggressive Einstellungen](#aggressive-einstellungen)
3. [Scalping Setup](#scalping-setup)
4. [Swing Trading Setup](#swing-trading-setup)
5. [Symbol-spezifische Konfigurationen](#symbol-spezifische-konfigurationen)

---

## Konservative Einstellungen

### Profil: Sicherheitsorientiert
**Zielgruppe:** Anfänger, risikoaverse Trader

```
=== Stop Loss & Take Profit Settings ===
StopLossPips = 15.0
TakeProfitPips = 30.0

=== Trailing Settings ===
TrailStepPips = 7.0
CandleThresholdPercent = 25.0
TrailTimeframe = PERIOD_M15

=== Trading Pairs ===
TradingSymbols = "EURUSD,GBPUSD"

=== General Settings ===
MagicNumber = 123456
```

**Charakteristik:**
- Größere Stops = mehr Spielraum gegen normale Volatilität
- Höheres Risk/Reward Ratio (1:2)
- Konservativerer Trailing-Ansatz
- Längere Timeframe (15 Minuten)
- Nur die liquidesten Paare

**Einsatz:**
- Bei volatilen Marktbedingungen
- Für größere Positionen
- Wenn Sie nicht ständig überwachen können

---

## Aggressive Einstellungen

### Profil: Renditeorientiert
**Zielgruppe:** Erfahrene Trader, höhere Risikotoleranz

```
=== Stop Loss & Take Profit Settings ===
StopLossPips = 8.0
TakeProfitPips = 16.0

=== Trailing Settings ===
TrailStepPips = 3.0
CandleThresholdPercent = 15.0
TrailTimeframe = PERIOD_M1

=== Trading Pairs ===
TradingSymbols = "EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,NZDUSD,EURJPY,GBPJPY"

=== General Settings ===
MagicNumber = 123456
```

**Charakteristik:**
- Engere Stops = schnellere Ein- und Ausstiege
- Risk/Reward Ratio (1:2) beibehalten
- Aggressiveres Trailing
- Kürzere Timeframe (1 Minute)
- Mehr Handelsmöglichkeiten durch mehr Paare

**Einsatz:**
- In Trendphasen
- Bei niedrigem Spread
- Mit aktiver Überwachung

---

## Scalping Setup

### Profil: Kurzfristig, viele Trades
**Zielgruppe:** Aktive Day-Trader

```
=== Stop Loss & Take Profit Settings ===
StopLossPips = 5.0
TakeProfitPips = 10.0

=== Trailing Settings ===
TrailStepPips = 2.0
CandleThresholdPercent = 10.0
TrailTimeframe = PERIOD_M1

=== Trading Pairs ===
TradingSymbols = "EURUSD,GBPUSD,USDJPY"

=== General Settings ===
MagicNumber = 123456
```

**Wichtige Hinweise:**
- ⚠️ **Nur für ECN/STP-Konten** mit sehr niedrigen Spreads
- ⚠️ Mindestens 0.5 Pips Spread empfohlen
- Erfordert sehr schnelle Ausführung
- Hohe Anzahl an Trades

**Broker-Anforderungen:**
- Spread < 1 Pip für Majors
- Market Execution
- Keine Re-Quotes
- Geringe Slippage

**Einsatz:**
- Nur während Haupthandelszeiten (London/New York Overlap)
- Bei hoher Liquidität
- Kontinuierliche Überwachung erforderlich

---

## Swing Trading Setup

### Profil: Mittelfristig, weniger Trades
**Zielgruppe:** Berufstätige, Nebenzeit-Trader

```
=== Stop Loss & Take Profit Settings ===
StopLossPips = 25.0
TakeProfitPips = 50.0

=== Trailing Settings ===
TrailStepPips = 10.0
CandleThresholdPercent = 30.0
TrailTimeframe = PERIOD_H1

=== Trading Pairs ===
TradingSymbols = "EURUSD,GBPUSD,AUDUSD,NZDUSD"

=== General Settings ===
MagicNumber = 123456
```

**Charakteristik:**
- Große Stops = Spielraum für mehrtägige Swings
- Höheres Risk/Reward (1:2)
- Langsames Trailing
- Stunden-Chart für Trailing
- Fokus auf trendstarke Paare

**Einsatz:**
- Bei klaren Trends
- Position über mehrere Tage halten
- Weniger Zeit für Monitoring erforderlich

---

## Symbol-spezifische Konfigurationen

### Setup für verschiedene Paare

#### Für Major Paare (EURUSD, GBPUSD, USDJPY)
**Niedriger Spread, hohe Liquidität**

```
StopLossPips = 10.0
TakeProfitPips = 20.0
TrailStepPips = 5.0
CandleThresholdPercent = 20.0
TrailTimeframe = PERIOD_M5
TradingSymbols = "EURUSD,GBPUSD,USDJPY"
```

#### Für Minor Paare (EURJPY, GBPJPY, EURGBP)
**Mittlerer Spread, gute Liquidität**

```
StopLossPips = 15.0
TakeProfitPips = 30.0
TrailStepPips = 7.0
CandleThresholdPercent = 25.0
TrailTimeframe = PERIOD_M15
TradingSymbols = "EURJPY,GBPJPY,EURGBP"
```

#### Für Exotic Paare (USDTRY, USDZAR, USDMXN)
**Hoher Spread, niedrigere Liquidität**

```
StopLossPips = 30.0
TakeProfitPips = 60.0
TrailStepPips = 15.0
CandleThresholdPercent = 35.0
TrailTimeframe = PERIOD_H1
TradingSymbols = "USDTRY,USDZAR"
```

⚠️ **Achtung:** Exotic Paare haben oft hohe Spreads und Swaps!

---

## Marktbedingungen-spezifische Setups

### Setup für Range-Märkte
**Seitwärtsbewegung, keine klaren Trends**

```
StopLossPips = 12.0
TakeProfitPips = 18.0      ← Kleineres R:R
TrailStepPips = 4.0
CandleThresholdPercent = 15.0
TrailTimeframe = PERIOD_M5
```

**Strategie:**
- Kleineres Risk/Reward da oft schnelle Umkehrungen
- Engeres Trailing um Gewinne zu sichern
- Häufigere Trails

### Setup für Trend-Märkte
**Starke, anhaltende Trends**

```
StopLossPips = 15.0
TakeProfitPips = 45.0      ← Größeres R:R
TrailStepPips = 10.0
CandleThresholdPercent = 30.0
TrailTimeframe = PERIOD_M15
```

**Strategie:**
- Größeres Risk/Reward um Trends auszureizen
- Konservativeres Trailing (weniger häufig)
- Trendfortsetzung ermöglichen

### Setup für Volatile Märkte
**Hohe Volatilität, News-Events**

```
StopLossPips = 20.0        ← Größerer Stop
TakeProfitPips = 40.0
TrailStepPips = 8.0
CandleThresholdPercent = 35.0  ← Höherer Schwellenwert
TrailTimeframe = PERIOD_M15
```

**Strategie:**
- Größere Stops gegen Ausreißer
- Höherer Schwellenwert um falsche Signale zu filtern
- Mittlere Timeframe

---

## Zeitzonen-optimierte Setups

### Asiatische Session (Tokyo)
**Geringere Volatilität**

```
StopLossPips = 8.0
TakeProfitPips = 16.0
TrailStepPips = 4.0
CandleThresholdPercent = 15.0
TrailTimeframe = PERIOD_M5
TradingSymbols = "USDJPY,AUDJPY,NZDJPY"
```

### Europäische Session (London)
**Mittlere bis hohe Volatilität**

```
StopLossPips = 12.0
TakeProfitPips = 24.0
TrailStepPips = 6.0
CandleThresholdPercent = 20.0
TrailTimeframe = PERIOD_M5
TradingSymbols = "EURUSD,GBPUSD,EURGBP"
```

### Amerikanische Session (New York)
**Hohe Volatilität**

```
StopLossPips = 15.0
TakeProfitPips = 30.0
TrailStepPips = 7.0
CandleThresholdPercent = 25.0
TrailTimeframe = PERIOD_M5
TradingSymbols = "EURUSD,GBPUSD,USDJPY,USDCAD"
```

### Overlap (London + New York)
**Höchste Volatilität und Liquidität**

```
StopLossPips = 18.0
TakeProfitPips = 36.0
TrailStepPips = 8.0
CandleThresholdPercent = 30.0
TrailTimeframe = PERIOD_M5
TradingSymbols = "EURUSD,GBPUSD,USDJPY"
```

---

## Account-Size spezifische Empfehlungen

### Micro Account (< $1,000)
```
TradingSymbols = "EURUSD"     ← Nur ein Paar
StopLossPips = 15.0           ← Konservativ
TakeProfitPips = 30.0
```
**Fokus:** Kapitalerhalt, Lernen

### Mini Account ($1,000 - $5,000)
```
TradingSymbols = "EURUSD,GBPUSD"   ← Zwei Paare
StopLossPips = 12.0
TakeProfitPips = 24.0
```
**Fokus:** Ausgeglichene Strategie

### Standard Account (> $5,000)
```
TradingSymbols = "EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,NZDUSD"
StopLossPips = 10.0
TakeProfitPips = 20.0
```
**Fokus:** Diversifikation, Rendite

---

## Testen Ihrer Konfiguration

### Backtesting Checklist:
1. **Strategy Tester öffnen** (Strg+R)
2. **EA auswählen:** AutoSLTP_EA
3. **Symbol wählen:** z.B. EURUSD
4. **Zeitraum:** Minimum 3 Monate
5. **Modus:** "Every tick" für beste Genauigkeit
6. **Einstellungen:** Ihre Konfiguration laden
7. **Start** klicken

### Optimierung:
- **Nicht** alle Parameter gleichzeitig optimieren
- Fokus auf 1-2 Parameter:
  - Beginnen Sie mit StopLossPips
  - Dann TakeProfitPips
  - Dann TrailStepPips

### Demo-Testing:
- **Mindestens 2 Wochen** auf Demo
- **Verschiedene Marktbedingungen** testen
- **Log-Dateien** regelmäßig prüfen

---

## Wartung und Anpassung

### Wöchentliche Überprüfung:
```
- Performance-Statistiken prüfen
- Gewinn/Verlust-Verhältnis analysieren
- Bei schlechter Performance: Einstellungen anpassen
```

### Monatliche Optimierung:
```
- Marktbedingungen evaluieren
- Setups ggf. anpassen (Range vs. Trend)
- Neue Paare testen
```

### Nach großen Verlusten:
```
1. EA pausieren
2. Marktanalyse durchführen
3. Einstellungen überdenken
4. Auf Demo neu testen
```

---

## Beispiel-Szenarien

### Szenario 1: Anfänger, $2000 Konto
```
StopLossPips = 15.0
TakeProfitPips = 30.0
TrailStepPips = 7.0
CandleThresholdPercent = 25.0
TrailTimeframe = PERIOD_M15
TradingSymbols = "EURUSD"
```

### Szenario 2: Erfahrener Trader, $10,000 Konto
```
StopLossPips = 10.0
TakeProfitPips = 20.0
TrailStepPips = 5.0
CandleThresholdPercent = 20.0
TrailTimeframe = PERIOD_M5
TradingSymbols = "EURUSD,GBPUSD,USDJPY,AUDUSD"
```

### Szenario 3: Professional, $50,000+ Konto
```
StopLossPips = 8.0
TakeProfitPips = 16.0
TrailStepPips = 3.0
CandleThresholdPercent = 15.0
TrailTimeframe = PERIOD_M1
TradingSymbols = "EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,NZDUSD,EURJPY,GBPJPY"
```

---

## Wichtige Erinnerungen

1. **Keine universelle Einstellung** - Was für andere funktioniert, muss nicht für Sie funktionieren
2. **Testen Sie immer** neue Einstellungen auf Demo
3. **Passen Sie an** Ihre Risikotoleranz an
4. **Dokumentieren Sie** welche Einstellungen wann funktionieren
5. **Seien Sie geduldig** - Gute Einstellungen brauchen Zeit zum Optimieren

---

## Empfohlene Starter-Konfiguration

Wenn Sie unsicher sind, beginnen Sie mit:

```
=== Stop Loss & Take Profit Settings ===
StopLossPips = 12.0
TakeProfitPips = 24.0

=== Trailing Settings ===
TrailStepPips = 6.0
CandleThresholdPercent = 20.0
TrailTimeframe = PERIOD_M5

=== Trading Pairs ===
TradingSymbols = "EURUSD,GBPUSD"

=== General Settings ===
MagicNumber = 123456
```

Diese Einstellung bietet:
✓ Ausgeglichenes Risiko
✓ Standard Risk/Reward (1:2)
✓ Bewährte Timeframe
✓ Liquideste Paare
✓ Guter Startpunkt für Optimierung
