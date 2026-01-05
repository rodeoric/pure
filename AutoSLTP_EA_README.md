# AutoSLTP EA - Automatic Stop Loss and Take Profit Expert Advisor

## Overview

AutoSLTP EA is a MetaTrader 5 Expert Advisor that automatically manages Stop Loss (SL) and Take Profit (TP) levels for open positions. It also includes an auto-close feature to secure profits at a configurable target.

## Features

- **Automatic SL/TP Setting**: Automatically sets Stop Loss and Take Profit for positions that don't have them
- **Auto-Close at Profit Target**: Automatically closes positions when they reach a specified profit level
- **Multi-Symbol Support**: Monitors multiple trading pairs simultaneously
- **Manual Override Protection**: Stops managing positions if SL/TP is manually modified
- **Broker Suffix Support**: Works with broker-specific symbol suffixes (e.g., EURUSD.a, XAUUSD.pro)

## Configuration Parameters

### Stop Loss & Take Profit Settings
- **StopLossPoints**: Stop Loss distance in points (Default: 1000 points = 100 pips)
- **TakeProfitPoints**: Take Profit distance in points (Default: 2000 points = 200 pips)

### Auto-Close Profit Target
- **AutoClosePoints**: Automatically close position when profit reaches this value in points (Default: 300 points)

### Trading Pairs
- **TradingSymbols**: Comma-separated list of symbols to monitor (Default includes Forex, Metals, and Crypto pairs)
  - Forex: AUDCAD, AUDCHF, AUDJPY, AUDNZD, AUDUSD, CADCHF, CADJPY, CHFJPY, EURAUD, EURCAD, EURCHF, EURGBP, EURJPY, EURUSD, GBPAUD, GBPCAD, GBPCHF, GBPJPY, GBPNZD, GBPUSD, NZDCAD, NZDCHF, NZDJPY, NZDUSD, USDCAD, USDCHF, USDJPY, EURHUF
  - Metals: XAUUSD, XAGUSD
  - Crypto: BTCUSD, ETHUSD, BNBUSD, XRPUSD, ADAUSD, SOLUSD, DOGEUSD, TRXUSD, MATICUSD, DOTUSD, LTCUSD, AVAXUSD, LINKUSD, UNIUSD, ATOMUSD, XLMUSD, TONUSD, BCHUSD, APTUSD, FILUSD, NEARUSD

### General Settings
- **MagicNumber**: Magic number for position identification (Default: 123456)
- **TimerIntervalSeconds**: How often to check positions in seconds (Default: 1, Range: 1-60)

## How It Works

1. **Position Monitoring**: The EA monitors all open positions on the specified symbols
2. **SL/TP Assignment**: If a position doesn't have SL/TP, the EA automatically sets them based on the configured distances
3. **Profit Monitoring**: Continuously monitors position profit in points
4. **Auto-Close**: When profit reaches the AutoClosePoints threshold, the position is automatically closed
5. **Manual Override**: If you manually modify SL/TP, the EA stops managing that position

## Installation

1. Copy `AutoSLTP_EA.mq5` to your MetaTrader 5 `Experts` folder:
   - `C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\`

2. Open MetaTrader 5

3. Open MetaEditor (F4) and compile the EA:
   - File → Open → Select `AutoSLTP_EA.mq5`
   - Click Compile (F7)

4. Restart MetaTrader 5 or refresh the Navigator (Ctrl+N)

## Usage

### Attaching to Chart

1. In MetaTrader 5, open any chart (the symbol doesn't matter as the EA monitors all specified symbols)

2. Drag `AutoSLTP_EA` from the Navigator onto the chart

3. Configure the input parameters as desired:
   - Set StopLossPoints (e.g., 1000 for 100 pips)
   - Set TakeProfitPoints (e.g., 2000 for 200 pips)
   - Set AutoClosePoints (e.g., 300 for 30 pips profit)
   - Adjust TradingSymbols if needed

4. Enable "Allow Algo Trading" button in the toolbar

5. Click OK

### Understanding Points vs Pips

For most forex pairs with 5-digit quotes (e.g., EURUSD = 1.12345):
- **1 pip = 10 points**
- 1000 points = 100 pips
- 2000 points = 200 pips
- 300 points = 30 pips

Example:
- EURUSD: 1 point = 0.00001, 1 pip = 0.0001
- If you want 50 pips SL, set StopLossPoints = 500

For JPY pairs with 3-digit quotes (e.g., USDJPY = 110.123):
- **1 pip = 10 points**
- Same calculation applies

For metals like XAUUSD (Gold):
- Depends on broker quote format
- Typically: 1 point = 0.01
- Adjust values accordingly

## Adjusting for Different Instruments

### Forex Pairs (5-digit quotes)
- SL 50 pips → StopLossPoints = 500
- TP 100 pips → TakeProfitPoints = 1000
- Auto-close at 30 pips → AutoClosePoints = 300

### Gold (XAUUSD)
- Check your broker's point value
- If 1 point = 0.01, then:
  - SL $10 → StopLossPoints = 1000
  - TP $20 → TakeProfitPoints = 2000

### Cryptocurrencies (e.g., BTCUSD)
- Highly depends on broker
- Test with small values first
- Monitor the Expert Journal for actual SL/TP prices

## Monitoring

The EA logs all actions to the MetaTrader 5 Expert Journal:
- Initialization details
- SL/TP setting success/failure
- Auto-close actions
- Manual modification detection

To view logs:
1. Open the Toolbox window (Ctrl+T)
2. Click the "Journal" tab
3. Look for messages from AutoSLTP_EA

## Important Notes

### Position Management
- **New Positions**: EA sets SL/TP immediately when detected
- **Existing Positions**: If already have SL/TP, EA tracks them
- **Manual Changes**: If you manually modify SL/TP, EA stops managing that position
- **Auto-Close**: Closes position at profit target regardless of manual modifications

### Magic Number
- Set MagicNumber = 0 to manage all positions regardless of magic number
- Set specific MagicNumber to only manage positions opened by specific EAs

### Symbol Matching
- Supports exact match: "EURUSD" matches "EURUSD"
- Supports prefix match: "EURUSD" matches "EURUSD.a" or "EURUSD.pro" (broker suffixes)

### Performance
- TimerIntervalSeconds = 1 provides near real-time management
- Increase to 5-10 seconds for less frequent checks (saves CPU)

## Troubleshooting

### EA Not Setting SL/TP

**Check Symbol List**
- Ensure the position symbol is in TradingSymbols parameter
- Check for broker suffixes (add them manually if needed)

**Check Magic Number**
- If position has a magic number, ensure it matches the EA's MagicNumber
- Or set EA's MagicNumber = 0 to manage all positions

**Check Broker Restrictions**
- Some brokers have minimum stop distances
- Check error code in Expert Journal
- Error 10013 = Invalid stops (too close to current price)

### Auto-Close Not Working

**Check Profit Calculation**
- Verify position is actually in profit
- Check Expert Journal for profit point calculations
- Ensure AutoClosePoints is not set too high

**Check Manual Modification Flag**
- If SL/TP was manually changed, verify manuallyModified flag
- Auto-close should still work even if manual modifications were made

### Position Not Monitored

**Verify Symbol Name**
- Check exact symbol name in Market Watch
- Add to TradingSymbols with correct spelling
- Include broker suffix if present

## Example Configurations

### Conservative Trading (Wider Stops)
```
StopLossPoints = 2000 (200 pips)
TakeProfitPoints = 4000 (400 pips)
AutoClosePoints = 500 (50 pips)
```

### Aggressive Trading (Tighter Stops)
```
StopLossPoints = 500 (50 pips)
TakeProfitPoints = 1000 (100 pips)
AutoClosePoints = 150 (15 pips)
```

### Scalping (Very Tight)
```
StopLossPoints = 200 (20 pips)
TakeProfitPoints = 300 (30 pips)
AutoClosePoints = 100 (10 pips)
```

## Support and Customization

This EA can be customized further based on your trading strategy. The source code is provided as-is for educational and trading purposes.

## Version History

**v1.00** - Initial Release
- Automatic SL/TP management
- Auto-close at profit target
- Multi-symbol support
- Manual override protection

## License

This EA is provided as-is without warranty. Use at your own risk. Always test on a demo account before using on a live account.
