# MetaTrader 5 Expert Advisor - Kerzendocht (Candlestick Wick) Strategien

## Übersicht (Overview)

Dieses Dokument beschreibt automatische Trading-Strategien für MetaTrader 5, die auf Kerzendochten (Candlestick Wicks) im 1-Minuten-Chart basieren.

## Strategie-Vorschläge für 1-Minuten Kerzendocht Trading

### 1. **Pin Bar Reversal Strategie**

**Konzept:** Erkennt Pin Bars (Hammer/Shooting Star) mit langen Dochten, die potenzielle Trendumkehrungen signalisieren.

**Entry-Bedingungen:**
- **Long Entry:** 
  - Unterer Docht ist mindestens 2x so lang wie der Kerzenkörper
  - Oberer Docht ist kleiner als 30% des unteren Dochts
  - Schlusskurs im oberen Drittel der Kerze
  - Optional: Bestätigung durch vorherigen Abwärtstrend
  
- **Short Entry:**
  - Oberer Docht ist mindestens 2x so lang wie der Kerzenkörper
  - Unterer Docht ist kleiner als 30% des oberen Dochts
  - Schlusskurs im unteren Drittel der Kerze
  - Optional: Bestätigung durch vorherigen Aufwärtstrend

**Exit-Bedingungen:**
- Take Profit: 1.5-2x des durchschnittlichen Docht-Länge
- Stop Loss: Unterhalb/oberhalb des Docht-Extrems + Spread
- Trailing Stop: 50% des initialen Stop Loss

**Parameter:**
- Timeframe: M1 (1-Minute)
- Wick-to-Body Ratio: 2.0 minimum
- Risk per Trade: 1-2% des Kapitals

---

### 2. **Docht Rejection Strategie**

**Konzept:** Handelt Ablehnungen an wichtigen Preisniveaus, erkennbar durch lange Dochte.

**Entry-Bedingungen:**
- Identifiziere Support/Resistance Levels (H1/H4 Pivots)
- Warte auf Kerze mit langem Docht, der das Level testet
- **Long:** Unterer Docht durchstößt Support, schließt aber darüber
- **Short:** Oberer Docht durchstößt Resistance, schließt aber darunter
- Docht muss mindestens 60% der gesamten Kerzenhöhe ausmachen

**Exit-Bedingungen:**
- Take Profit: Nächstes signifikantes Level
- Stop Loss: 5-10 Pips hinter dem Docht-Extrem
- Zeitbasierter Exit: Nach 5-10 Kerzen, wenn kein TP erreicht

**Parameter:**
- Minimum Wick Percentage: 60%
- Level Touch Tolerance: 2-3 Pips
- Max Open Trades: 1 pro Richtung

---

### 3. **Doppel-Docht Bestätigung Strategie**

**Konzept:** Wartet auf zwei aufeinanderfolgende Kerzen mit Dochten in die gleiche Richtung für stärkere Bestätigung.

**Entry-Bedingungen:**
- **Long Entry:**
  - Kerze 1: Langer unterer Docht (>50% der Kerzenhöhe)
  - Kerze 2: Ebenfalls langer unterer Docht auf ähnlichem Preisniveau
  - Kerze 2 schließt höher als Kerze 1
  - Einstieg beim Close von Kerze 2
  
- **Short Entry:**
  - Kerze 1: Langer oberer Docht (>50% der Kerzenhöhe)
  - Kerze 2: Ebenfalls langer oberer Docht auf ähnlichem Preisniveau
  - Kerze 2 schließt tiefer als Kerze 1
  - Einstieg beim Close von Kerze 2

**Exit-Bedingungen:**
- Take Profit: 2x der kombinierten Docht-Länge
- Stop Loss: Unterhalb/oberhalb beider Docht-Extreme
- Break-Even: Bei 50% des TP

**Parameter:**
- Minimum Wick Size: 5 Pips
- Maximum Candle Gap: 3 Pips
- Position Size: Basierend auf Stop Loss Distanz

---

### 4. **Volatilitäts-Breakout mit Docht-Filter**

**Konzept:** Nutzt Dochte, um falsche Breakouts zu filtern.

**Entry-Bedingungen:**
- Identifiziere Konsolidierungsbereich (Bollinger Bands Squeeze)
- Warte auf Breakout-Kerze
- **Gültiger Breakout (Long):**
  - Schließt über dem High der Range
  - Oberer Docht kleiner als 20% der Kerzenhöhe
  - Unterer Docht zeigt Kaufdruck
  
- **Falscher Breakout (vermeiden):**
  - Langer oberer Docht (>40% der Höhe) = Verkaufsdruck
  - Nicht einsteigen

**Exit-Bedingungen:**
- Take Profit: Höhe der Konsolidierung projiziert
- Stop Loss: Mitte der vorherigen Range
- Trail nach 1:1 R/R

**Parameter:**
- Consolidation Period: Min 10 Kerzen
- Wick Filter: Max 20% auf Breakout-Seite
- ADR Filter: Nur traden in ersten 50% des Average Daily Range

---

### 5. **Scalping mit Mikro-Dochten**

**Konzept:** Sehr kurze Trades basierend auf kleinen Docht-Formationen.

**Entry-Bedingungen:**
- Verwende nur in liquiden Märkten (EUR/USD, GBP/USD)
- **Long:** Serie von Kerzen mit kleinen oberen Dochten + größere untere Dochte = Kaufdruck
- **Short:** Serie von Kerzen mit kleinen unteren Dochten + größere obere Dochte = Verkaufsdruck
- Minimum 3 Kerzen in Folge mit gleicher Docht-Charakteristik

**Exit-Bedingungen:**
- Take Profit: 3-5 Pips
- Stop Loss: 5-8 Pips
- Maximale Haltedauer: 3-5 Minuten

**Parameter:**
- Spread: Max 1.5 Pips
- Trading Hours: London/New York Session
- Max Daily Trades: 10-15
- Daily Loss Limit: 2% des Kapitals

---

## Installation und Verwendung

### Installation in MetaTrader 5:

1. Speichern Sie die `.mq5` Datei im Ordner: `MQL5/Experts/`
2. Kompilieren Sie die Datei im MetaEditor (F7)
3. Starten Sie MT5 neu oder aktualisieren Sie den Navigator
4. Ziehen Sie den EA auf einen M1-Chart

### Allgemeine Empfehlungen:

- **Backtesting:** Testen Sie jede Strategie mindestens 3 Monate auf historischen Daten
- **Demo-Trading:** Mindestens 1 Monat auf Demo-Konto
- **Risk Management:** Nie mehr als 1-2% pro Trade riskieren
- **Trading Sessions:** Am besten London/New York Session (höchste Liquidität)
- **Währungspaare:** EUR/USD, GBP/USD, USD/JPY (niedrige Spreads)
- **VPS empfohlen:** Für 24/7 Trading ohne Unterbrechungen

### Wichtige Parameter zum Optimieren:

- Lot Size / Risk Percentage
- Wick-to-Body Ratio
- Minimum Wick Size (in Pips)
- Take Profit / Stop Loss Ratio
- Trading Hours (Session Filter)
- Maximum Spread
- Maximum Open Trades

---

## Risiko-Hinweis

**ACHTUNG:** Trading mit Expert Advisors birgt erhebliche Risiken. Diese Strategien sind Vorschläge und keine Garantie für Profitabilität. Immer:
- Umfangreiche Tests durchführen
- Kleines Kapital verwenden
- Stop Loss verwenden
- Risikomanagement befolgen
- Nie mehr riskieren, als Sie verlieren können

---

## Implementierung

Die Beispiel-Implementierung `PureWickTradingEA.mq5` zeigt die **Pin Bar Reversal Strategie** (Strategie #1) als Referenz. Sie können diese anpassen oder als Basis für die anderen Strategien verwenden.
