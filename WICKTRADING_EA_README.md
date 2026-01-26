# Wicktrading EA - XAUUSD Scalper

## Overview
This Expert Advisor (EA) is designed for quick scalping trades on XAUUSD (Gold) using wick rejection strategy.

## Features
- **Symbol**: XAUUSD only
- **Timeframes**: M1 (1-minute) or M5 (5-minute) charts only
- **Strategy**: Intrabar wick rejection scalping
- **Trade Duration**: Seconds to minutes (max 90 seconds by default)
- **Commission Aware**: Factors in 7 EUR/USD commission per lot

## Installation
1. Copy `XAUUSD_WickScalp_Intrabar.mq5` to your MetaTrader 5 `Experts` folder
2. Compile in MetaEditor (F7)
3. Attach to XAUUSD M1 or M5 chart
4. Configure settings in EA inputs

## Key Settings

### Trade Settings
- **InpLots** (default: 0.01): Lot size - **CONFIGURABLE IN EA SETTINGS**
- **InpCommissionPerLot** (default: 7.0): Commission per lot in EUR/USD

### Timeframe Settings
- **InpTF** (default: PERIOD_M1): Choose M1 or M5 only

### Risk Management
- **InpMaxHoldSeconds** (default: 90): Maximum hold time in seconds
- **InpSLBufferPoints** (default: 20): Stop loss buffer
- **InpFixedTPPoints** (default: 60): Fixed take profit in points

### Entry Conditions
- **InpMinWickPoints** (default: 80): Minimum wick size for signal
- **InpRetraceTriggerPts** (default: 40): Retrace points to trigger entry
- **InpMaxSpreadPoints** (default: 60): Maximum spread allowed

### Safety
- **InpOneTradeAtATime** (default: true): Only one position at a time
- **InpCooldownSeconds** (default: 20): Pause between trades

## Strategy Logic
1. EA monitors price action on M1/M5 charts
2. Detects significant wicks (rejection patterns)
3. Waits for price to retrace from extreme
4. Enters trade with tight SL/TP
5. Automatically closes after max hold time
6. Considers commission costs before entering

## Performance Tips
- Use on low-spread brokers
- Test on demo account first
- Adjust lot size based on your account size
- Monitor during liquid trading hours (London/NY session)
- Consider reducing InpMaxHoldSeconds for faster scalping

## Commission Consideration
The EA calculates whether a trade is worth taking based on the commission cost.
It requires potential profit to be at least 1.5x the commission to enter a trade.

## Disclaimer
Trading involves risk. This EA is provided as-is without any guarantees.
Always test on a demo account before using real money.
