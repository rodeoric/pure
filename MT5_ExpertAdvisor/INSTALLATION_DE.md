# Installationsanleitung - AutoSLTP EA für MetaTrader 5

## Schritt-für-Schritt Installation

### 1. Dateien vorbereiten
- Laden Sie die Datei `AutoSLTP_EA.mq5` herunter
- Stellen Sie sicher, dass Sie MetaTrader 5 installiert haben (nicht MT4!)

### 2. EA installieren

#### Methode A: Über MetaTrader 5
1. Öffnen Sie MetaTrader 5
2. Klicken Sie auf **Datei** → **Datenordner öffnen**
3. Navigieren Sie zum Ordner **MQL5** → **Experts**
4. Kopieren Sie die Datei `AutoSLTP_EA.mq5` in diesen Ordner
5. Schließen Sie den Ordner

#### Methode B: Manuell
1. Navigieren Sie zu:
   ```
   C:\Users\[IhrBenutzername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\
   ```
2. Kopieren Sie `AutoSLTP_EA.mq5` hierhin

### 3. EA kompilieren
1. Öffnen Sie den **MetaEditor** (F4 in MT5 oder über Menü: Extras → MetaQuotes Language Editor)
2. Öffnen Sie die Datei `AutoSLTP_EA.mq5` im MetaEditor
3. Klicken Sie auf **Kompilieren** (F7) oder auf das Kompilieren-Symbol
4. Prüfen Sie auf Fehler im "Errors" Tab
5. Bei erfolgreichem Kompilieren sehen Sie "0 error(s), 0 warning(s)"

### 4. EA aktivieren
1. Gehen Sie zurück zu MetaTrader 5
2. Klicken Sie auf **Ansicht** → **Navigator** (oder drücken Sie Strg+N)
3. Erweitern Sie den Abschnitt **Expert Advisors**
4. Sie sollten nun **AutoSLTP_EA** in der Liste sehen

### 5. EA auf Chart anwenden

#### Vorbereitung:
1. Öffnen Sie ein Chart mit einem Währungspaar (z.B. EURUSD)
2. Stellen Sie sicher, dass **Auto Trading** aktiviert ist (grüner Button in der Toolbar)

#### EA auf Chart ziehen:
1. Ziehen Sie **AutoSLTP_EA** aus dem Navigator auf das Chart
2. Ein Einstellungs-Dialog öffnet sich

### 6. Einstellungen konfigurieren

#### Wichtige Einstellungen:

**Stop Loss & Take Profit:**
```
StopLossPips = 10.0     ← SL Abstand in Pips
TakeProfitPips = 20.0   ← TP Abstand in Pips
```

**Trailing:**
```
TrailStepPips = 5.0              ← Trailing-Schrittweite
CandleThresholdPercent = 20.0   ← Kerzen-Schwellenwert
TrailTimeframe = PERIOD_M5       ← 5-Minuten-Chart
```

**Trading Paare:**
```
TradingSymbols = "EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,NZDUSD"
```
**Wichtig:** Keine Leerzeichen nach Kommas!

**Beispiele für eigene Paare:**
```
Nur EUR-Paare: "EURUSD,EURJPY,EURGBP,EURAUD"
Nur Major-Paare: "EURUSD,GBPUSD,USDJPY,USDCHF"
Nur ein Paar: "EURUSD"
```

**Magic Number:**
```
MagicNumber = 123456    ← Eindeutige Identifikation
```

### 7. Bestätigen und starten
1. Prüfen Sie die Einstellungen
2. Aktivieren Sie **DLL-Imports zulassen** (falls angezeigt)
3. Aktivieren Sie **Live-Trading zulassen**
4. Klicken Sie auf **OK**

### 8. Überprüfung

#### Smiley-Symbol im Chart:
- 😊 (Lächeln) = EA läuft erfolgreich
- 😟 (Traurig) = EA hat einen Fehler oder ist deaktiviert

#### Im Experten-Tab:
1. Öffnen Sie das **Terminal-Fenster** (Strg+T)
2. Gehen Sie zum Tab **Experten**
3. Sie sollten sehen:
   ```
   AutoSLTP EA initialized successfully
   Monitoring symbols: EURUSD,GBPUSD,USDJPY,AUDUSD,USDCAD,NZDUSD
   SL: 10.0 pips, TP: 20.0 pips
   Trailing: 5.0 pips on PERIOD_M5
   ```

## Erste Schritte nach der Installation

### Test 1: Trade eröffnen und SL/TP prüfen
1. Öffnen Sie eine Position manuell (oder durch ein anderes System)
2. Der EA sollte automatisch SL und TP setzen
3. Prüfen Sie im **Experten**-Tab die Meldung:
   ```
   SL/TP set for position #12345 on EURUSD
   SL: 1.09900 TP: 1.10200
   ```

### Test 2: Manuelle Änderung
1. Ändern Sie den SL oder TP manuell
2. Der EA sollte erkennen:
   ```
   Manual modification detected for position #12345. Stopping automated management.
   ```
3. Der EA wird diese Position nicht mehr automatisch verwalten

### Test 3: Trailing beobachten
1. Warten Sie, bis die Position im Gewinn ist
2. Beobachten Sie die 5-Minuten-Kerzen
3. Wenn eine Kerze 20% größer ist, wird getrailed:
   ```
   SL trailed for position #12345 on EURUSD. New SL: 1.09950
   ```

## Häufige Probleme und Lösungen

### Problem 1: EA erscheint nicht im Navigator
**Lösung:**
- Prüfen Sie, ob die Datei im richtigen Ordner ist
- Kompilieren Sie die Datei neu im MetaEditor
- Starten Sie MetaTrader 5 neu

### Problem 2: "EA is not allowed for current account"
**Lösung:**
- Ihr Broker erlaubt keine EAs
- Kontaktieren Sie Ihren Broker
- Wechseln Sie ggf. zu einem Broker, der EAs unterstützt

### Problem 3: SL/TP wird nicht gesetzt
**Mögliche Ursachen:**
1. **Symbol nicht in Liste:** Fügen Sie das Symbol zu TradingSymbols hinzu
2. **Zu enger Stop:** Broker erlaubt keinen so engen SL
   - Erhöhen Sie StopLossPips (z.B. auf 15 oder 20)
3. **Broker-Einschränkungen:** Prüfen Sie SYMBOL_TRADE_STOPS_LEVEL

**Lösung prüfen:**
```
Öffnen Sie MetaEditor → Service → MQL5 Community
Erstellen Sie ein einfaches Script:
Print("Min Distance: ", SymbolInfoInteger("EURUSD", SYMBOL_TRADE_STOPS_LEVEL));
```

### Problem 4: Trailing funktioniert nicht
**Prüfen Sie:**
1. Position muss im GEWINN sein
2. Auf 5-Minuten-Chart warten
3. Neue Kerze muss entstehen
4. Kerze muss 20% größer sein
5. Keine manuelle Änderung vorgenommen

### Problem 5: "Trade context is busy"
**Lösung:**
- Warten Sie einen Moment
- MetaTrader ist gerade beschäftigt
- EA wird automatisch erneut versuchen

## Empfohlene Broker-Einstellungen

### Spread:
- Niedriger Spread bevorzugt (< 2 Pips für Majors)
- EA funktioniert mit allen Spreads, aber niedrigerer ist besser

### Ausführung:
- Market Execution bevorzugt
- Instant Execution funktioniert auch

### Kontoart:
- Standard-, ECN- oder STP-Konten unterstützt
- Nicht für Cent-Konten optimiert (aber verwendbar)

## Multi-Chart Setup

### Einen EA auf mehreren Charts:
**Nicht empfohlen!** Der EA überwacht bereits alle konfigurierten Symbole.

### Empfohlenes Setup:
1. **Ein Chart, ein EA** mit allen Symbolen in der Liste
2. Der EA funktioniert global für alle konfigurierten Paare
3. Sie müssen den EA nur einmal auf einem beliebigen Chart starten

### Alternative:
- Wenn Sie verschiedene Einstellungen für verschiedene Paare möchten:
  - EA auf mehreren Charts mit unterschiedlichen Einstellungen
  - Verwenden Sie unterschiedliche Magic Numbers!

## Aktualisierung des EA

### Neue Version installieren:
1. **Schließen Sie alle Charts** mit dem EA
2. Ersetzen Sie die alte .mq5 Datei mit der neuen
3. **Kompilieren** Sie die neue Version
4. **Fügen Sie den EA erneut** zu Ihren Charts hinzu

### Einstellungen übernehmen:
- Notieren Sie Ihre Einstellungen vorher
- Oder erstellen Sie ein "Set-File":
  1. Im Einstellungs-Dialog: **Speichern** klicken
  2. Dateiname wählen (z.B. "meine_einstellungen.set")
  3. Bei neuer Version: **Laden** klicken

## Support und Weiterführende Hilfe

### Log-Dateien finden:
```
Datei → Datenordner öffnen → MQL5 → Logs
```

### Debugging aktivieren:
1. Rechtsklick auf EA im Chart
2. Expert Advisors → Eigenschaften
3. Tab "Eingaben"
4. Prüfen Sie die Einstellungen

### Gemeinde und Forum:
- MQL5.com Forum
- MT5 Community
- Broker-spezifische Foren

## Rechtliche Hinweise

**Disclaimer:**
- Automatisierter Handel birgt Risiken
- Testen Sie immer zuerst auf einem Demo-Konto
- Keine Gewinngarantie
- Verwenden Sie nur Kapital, das Sie verlieren können
- Haftung ausgeschlossen

**Empfehlung:**
- Mindestens 2 Wochen Demo-Test
- Mit kleinen Positionsgrößen starten
- Kontinuierliche Überwachung
- Regelmäßige Überprüfung der Einstellungen

---

## Kontrolliste vor dem Live-Einsatz

- [ ] EA erfolgreich installiert
- [ ] EA erfolgreich kompiliert
- [ ] EA im Navigator sichtbar
- [ ] Auto Trading aktiviert
- [ ] Einstellungen konfiguriert
- [ ] TradingSymbols angepasst
- [ ] Auf Demo-Konto getestet
- [ ] SL/TP-Funktion geprüft
- [ ] Trailing-Funktion geprüft
- [ ] Manuelle-Änderungs-Erkennung geprüft
- [ ] Ausreichendes Kapital auf Konto
- [ ] Risikomanagement verstanden
- [ ] Log-Meldungen verstanden

**Erst nach Abhaken aller Punkte live gehen!**
