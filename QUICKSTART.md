# AutoSLTP EA - Quick Reference Guide

## What Does This EA Do?

The AutoSLTP EA is a "set and forget" position manager that:

1. **Automatically sets Stop Loss and Take Profit** on positions that don't have them
2. **Automatically closes positions** when they reach a profit target
3. **Works on multiple symbols** simultaneously
4. **Respects manual changes** - stops managing if you manually modify SL/TP

## Visual Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                     New Position Opened                      │
│                    (Any monitored symbol)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Does it have SL/TP already?                     │
└──────────────┬───────────────────────┬──────────────────────┘
               │ NO                    │ YES
               ▼                       ▼
┌────────────────────────┐   ┌───────────────────────────────┐
│   EA Sets SL/TP        │   │  EA Tracks Position           │
│   SL: Entry ± 1000pts  │   │  (No changes needed)          │
│   TP: Entry ± 2000pts  │   │                               │
└──────────┬─────────────┘   └──────────┬────────────────────┘
           │                             │
           └──────────────┬──────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              Continuous Profit Monitoring                    │
│                  (Every tick/timer)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Profit >= 300 points?                           │
└──────────┬────────────────────────┬─────────────────────────┘
           │ NO                     │ YES
           ▼                        ▼
┌────────────────────┐   ┌──────────────────────────────────┐
│  Keep Monitoring   │   │   AUTO-CLOSE POSITION            │
│  Wait for:         │   │   Lock in profits!               │
│  - TP hit          │   │                                  │
│  - SL hit          │   │   Position closed automatically  │
│  - Profit target   │   │                                  │
└────────────────────┘   └──────────────────────────────────┘
```

## Example Scenario (EURUSD)

**Initial Setup:**
- StopLossPoints = 1000 (100 pips)
- TakeProfitPoints = 2000 (200 pips)
- AutoClosePoints = 300 (30 pips)

**Trade Execution:**

```
Time   Action                           Price      Status
────────────────────────────────────────────────────────────
00:00  Buy EURUSD opened               1.1000     Position open
00:01  EA detects position             1.1000     
00:01  EA sets SL                      1.0900     SL = Entry - 100 pips
00:01  EA sets TP                      1.1200     TP = Entry + 200 pips
00:30  Price moves up                  1.1031     Profit = 31 pips (310 points)
00:30  EA AUTO-CLOSES                  1.1031     ✓ Position closed with 31 pips profit (target was 30+)
```

## Configuration Examples

### Default Settings (Moderate Risk)
```
StopLossPoints = 1000      (100 pips)
TakeProfitPoints = 2000    (200 pips)
AutoClosePoints = 300      (30 pips)
```
**Risk/Reward:** 1:2 ratio, early exit at 30% of TP

### Conservative (Lower Risk)
```
StopLossPoints = 2000      (200 pips)
TakeProfitPoints = 4000    (400 pips)
AutoClosePoints = 500      (50 pips)
```
**Risk/Reward:** 1:2 ratio, early exit at 25% of TP

### Aggressive (Higher Risk)
```
StopLossPoints = 500       (50 pips)
TakeProfitPoints = 1000    (100 pips)
AutoClosePoints = 150      (15 pips)
```
**Risk/Reward:** 1:2 ratio, early exit at 30% of TP

### Scalping (Very Tight)
```
StopLossPoints = 200       (20 pips)
TakeProfitPoints = 400     (40 pips)
AutoClosePoints = 100      (10 pips)
```
**Risk/Reward:** 1:2 ratio, early exit at 50% of TP

## Points vs Pips Cheatsheet

For most forex pairs (5-digit quotes):

| Pips | Points | Example (EURUSD @ 1.10000) |
|------|--------|----------------------------|
| 1    | 10     | 1.10010                   |
| 10   | 100    | 1.10100                   |
| 50   | 500    | 1.10500                   |
| 100  | 1000   | 1.11000                   |
| 200  | 2000   | 1.12000                   |

## Key Features

✅ **Automatic SL/TP** - Sets automatically if missing
✅ **Auto-Close at Profit** - Secures profits early
✅ **Multi-Symbol** - Monitors 50+ pairs simultaneously  
✅ **Manual Override** - Respects your changes
✅ **Broker Suffix Support** - Works with EURUSD, EURUSD.a, EURUSD.pro, etc.
✅ **Low CPU Usage** - Efficient timer-based checking
✅ **Detailed Logging** - All actions logged to Expert Journal

❌ **No Trailing Stop** - SL stays fixed
❌ **No Break-Even** - SL doesn't move to entry
❌ **No Partial Close** - Closes entire position

## Important Safety Notes

⚠️ **Always test on demo account first**
⚠️ **Check broker's minimum stop distance** - Some brokers require larger distances
⚠️ **Verify symbol names** - Ensure symbols match your broker's naming
⚠️ **Monitor first trades** - Check Expert Journal logs
⚠️ **Adjust for instrument** - Gold, crypto may need different values

## Quick Start Checklist

1. ☐ Copy `AutoSLTP_EA.mq5` to MT5 Experts folder
2. ☐ Compile in MetaEditor (F7)
3. ☐ Restart MT5 or refresh Navigator
4. ☐ Open any chart (symbol doesn't matter)
5. ☐ Drag EA onto chart
6. ☐ Configure input parameters
7. ☐ Enable "Allow Algo Trading" button
8. ☐ Click OK
9. ☐ Check Expert Journal for initialization message
10. ☐ Open a test position (small size)
11. ☐ Verify SL/TP are set correctly
12. ☐ Test auto-close by watching a profitable position

## Troubleshooting Quick Guide

**Problem:** EA doesn't set SL/TP
- **Check:** Symbol in TradingSymbols list?
- **Check:** Magic number matches (or set to 0)?
- **Check:** Expert Journal for error messages

**Problem:** Auto-close doesn't work
- **Check:** Position has enough profit?
- **Check:** Expert Journal for close attempts
- **Check:** Broker allows position closing

**Problem:** EA sets wrong SL/TP distance
- **Solution:** Adjust StopLossPoints and TakeProfitPoints
- **Note:** Remember 1 pip = 10 points for most pairs

## Support

For detailed information, see:
- `AutoSLTP_EA_README.md` - Complete user manual
- `CHANGES.md` - Detailed change log from original template
- Expert Journal in MT5 - Real-time EA logs

## Version

**v1.00** - Initial simplified release
- Automatic SL/TP management
- Auto-close at profit target
- No trailing, no break-even
- Universal settings for all symbols
