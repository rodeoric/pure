# Quick Reference - AutoSLTP EA

## Schnellübersicht (Quick Overview)

### Was macht dieser EA? (What does this EA do?)

✓ Setzt automatisch SL 10 Pips unter Einstieg  
✓ Setzt automatisch TP 20 Pips über Einstieg  
✓ Erkennt manuelle Änderungen und stoppt dann  
✓ Zieht SL nach bei profitablen Trades (5 Pips)  
✓ Nutzt 5-Minuten-Kerzenanalyse für Trailing  

---

## Installation in 3 Schritten

1. **Datei kopieren**
   ```
   AutoSLTP_EA.mq5 → MetaTrader 5\MQL5\Experts\
   ```

2. **Kompilieren** (F7 im MetaEditor)

3. **Auf Chart ziehen** und Einstellungen anpassen

---

## Standard-Einstellungen

```
StopLossPips = 10.0
TakeProfitPips = 20.0
TrailStepPips = 5.0
CandleThresholdPercent = 20.0
TrailTimeframe = PERIOD_M5
TradingSymbols = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,USDJPY,GBPUSD,USDCHF,EURUSD,XAUUSD,EURHUF,BTCUSD"
MagicNumber = 123456
TimerIntervalSeconds = 1
```

---

## Wichtige Hinweise

### ✓ DO's
- Auf Demo-Konto testen
- Auto Trading aktivieren
- Niedrige Spreads bevorzugen
- Einstellungen an Handelsstil anpassen
- Regelmäßig Logs prüfen

### ✗ DON'Ts
- Nicht ohne Test auf Live-Konto
- Nicht mit zu engen Stops (< 5 Pips)
- Nicht bei hohen Spreads verwenden
- Nicht während News-Events unüberwacht
- Nicht Magic Number doppelt verwenden

---

## Häufige Probleme - Schnelllösung

### Problem: EA setzt kein SL/TP
**Lösung:** 
- Symbol zur TradingSymbols-Liste hinzufügen
- TimerIntervalSeconds auf 1 setzen für häufigere Prüfung (Standard)

### Problem: Trailing funktioniert nicht
**Lösung:** Position muss im Gewinn sein + neue 5-Min-Kerze abwarten

### Problem: "Trade context busy"
**Lösung:** Normal - EA versucht automatisch erneut

### Problem: EA zeigt 😟 im Chart
**Lösung:** Auto Trading aktivieren (grüner Button)

---

## Beispiel-Trade-Ablauf

### 1. Trade eröffnen
```
Kaufe EURUSD bei 1.1000
→ EA setzt: SL 1.0990, TP 1.1020
```

### 2. Position im Gewinn
```
Preis steigt auf 1.1010
→ EA überwacht 5-Min-Kerzen
```

### 3. Trailing aktiviert
```
Neue Kerze ist 20% größer
→ EA zieht SL nach: 1.0990 → 1.0995
```

### 4. Weitere Trails
```
Nächste große Kerze
→ EA zieht SL nach: 1.0995 → 1.1000
→ Position nun auf Breakeven
```

---

## Anpassung der Symbole

### Nur Major Paare:
```
TradingSymbols = "EURUSD,GBPUSD,USDJPY"
```

### Nur EUR Paare:
```
TradingSymbols = "EURUSD,EURJPY,EURGBP,EURAUD"
```

### Nur ein Paar:
```
TradingSymbols = "EURUSD"
```

**Wichtig:** Keine Leerzeichen nach Kommas!

---

## Wichtigste Einstellungen zum Anpassen

### Für engere Stops:
```
StopLossPips = 8.0
TakeProfitPips = 16.0
```

### Für weitere Stops:
```
StopLossPips = 15.0
TakeProfitPips = 30.0
```

### Für aggressiveres Trailing:
```
TrailStepPips = 3.0
CandleThresholdPercent = 15.0
```

### Für konservativeres Trailing:
```
TrailStepPips = 7.0
CandleThresholdPercent = 25.0
```

---

## Empfohlene Broker-Eigenschaften

| Eigenschaft | Empfehlung |
|-------------|------------|
| Spread | < 2 Pips für Majors |
| Ausführung | Market Execution |
| Kontoart | Standard/ECN/STP |
| Plattform | MetaTrader 5 |

---

## Log-Meldungen erklärt

### Erfolgreiche Initialisierung:
```
AutoSLTP EA initialized successfully
Monitoring symbols: EURUSD,GBPUSD,...
SL: 10.0 pips, TP: 20.0 pips
```
✓ EA läuft korrekt

### SL/TP gesetzt:
```
SL/TP set for position #12345 on EURUSD
SL: 1.09900 TP: 1.10200
```
✓ Automatische Einstellung erfolgreich

### Manuelle Änderung erkannt:
```
Manual modification detected for position #12345
Stopping automated management
```
✓ Sie haben die Kontrolle übernommen

### Trailing durchgeführt:
```
SL trailed for position #12345 on EURUSD
New SL: 1.09950
```
✓ SL wurde nachgezogen

### Fehler beim Setzen:
```
Failed to set SL/TP for position #12345
Error: 10036
```
✗ Prüfen Sie Broker-Mindestabstände

---

## Performance-Überwachung

### Täglich prüfen:
- [ ] Anzahl offener Positionen
- [ ] Gesamtgewinn/-verlust
- [ ] Log auf Fehler prüfen

### Wöchentlich analysieren:
- [ ] Win-Rate berechnen
- [ ] Durchschnittlicher Gewinn/Verlust
- [ ] Best/Worst Performing Symbole

### Monatlich optimieren:
- [ ] Einstellungen basierend auf Performance anpassen
- [ ] Neue Symbole testen
- [ ] Unrentable Symbole entfernen

---

## Risiko-Management

### Position Sizing:
```
Risiko pro Trade = 1-2% des Kontos
Bei 10 Pips SL und $10,000 Konto:
Max. Loss = $100-200
Position Size = $10-20 pro Pip
```

### Maximum offene Positionen:
- Anfänger: 1-2 gleichzeitig
- Fortgeschritten: 3-4 gleichzeitig
- Experte: 5-6 gleichzeitig

### Täglicher Max-Loss:
```
Setzen Sie ein Tageslimit, z.B.:
- Micro: $50
- Mini: $100
- Standard: $500
```

---

## Backup und Sicherheit

### Vor Live-Nutzung:
1. Einstellungen speichern (.set Datei)
2. EA-Datei sichern
3. Broker-Zugangsdaten dokumentieren

### Regelmäßig:
1. Trading-Performance exportieren
2. Chart-Screenshots erstellen
3. Einstellungen anpassen und dokumentieren

---

## Support-Informationen

### Bei Problemen:
1. **Logs prüfen:** Experten-Tab in MT5
2. **Dateiordner:** Datei → Datenordner öffnen → MQL5 → Logs
3. **Fehlercodes:** Suchen Sie nach Error-Nummern im Journal

### Häufigste Fehlercodes:
- **10004** - Server beschäftigt, Retry
- **10006** - Anfrage abgelehnt
- **10015** - Ungültige Stops
- **10016** - Alte Preis-Daten
- **10036** - Order-Modifikation fehlgeschlagen

### Hilfreiche Links:
- MQL5.com - Community und Dokumentation
- Broker-Support - Für kontospezifische Fragen

---

## Checkliste vor Live-Trading

- [ ] Mind. 2 Wochen auf Demo getestet
- [ ] Alle Funktionen verstanden
- [ ] SL/TP-Funktion verifiziert
- [ ] Trailing-Funktion verifiziert
- [ ] Manual-Override-Funktion getestet
- [ ] Log-Meldungen verstanden
- [ ] Risikomanagement definiert
- [ ] Position Sizing berechnet
- [ ] Broker-Eigenschaften geprüft
- [ ] Backup-Plan erstellt

---

## Kontakt und Updates

- **Version:** 1.00
- **Letzte Änderung:** Dezember 2025
- **Kompatibilität:** MetaTrader 5 Build 3000+

---

## Lizenz und Disclaimer

⚠️ **Wichtig:**
- Kein Gewinn garantiert
- Trading birgt Verlustrisiken
- Nur mit Risikokapital handeln
- Immer zuerst auf Demo testen
- Keine Haftung für Verluste

✓ **Open Source:**
- Frei verwendbar
- Anpassungen erlaubt
- Weitergabe erlaubt
- Kommerzielle Nutzung auf eigenes Risiko

---

**Viel Erfolg beim Trading! 📈**

*Denken Sie daran: Die beste Strategie ist eine gut getestete Strategie!*
