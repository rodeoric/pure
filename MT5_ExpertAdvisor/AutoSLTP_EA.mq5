//+------------------------------------------------------------------+
//|                                                  AutoSLTP_EA.mq5 |
//|                                      Automatic SL/TP Management  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Auto SL/TP Management EA"
#property link      ""
#property version   "1.00"
#property description "Automatically manages Stop Loss and Take Profit"
#property description "Sets SL 10 pips below entry and TP 20 pips above entry"
#property description "Trails SL by 5 pips based on 5-minute candle analysis"

#include <Trade\Trade.mqh>

//--- Input parameters
input group "=== Stop Loss & Take Profit Settings (Forex & Metals) ==="
input double   StopLossPips = 50.0;          // Stop Loss in pips (Forex & Metals)
input double   TakeProfitPips = 100.0;       // Take Profit in pips (Forex & Metals)

input group "=== Stop Loss & Take Profit Settings (Cryptocurrencies) ==="
input double   CryptoStopLossPips = 100.0;   // Stop Loss in pips (Crypto) - 1000 points
input double   CryptoTakeProfitPips = 250.0; // Take Profit in pips (Crypto) - 2500 points

input group "=== Stop Loss & Take Profit Settings (BTCUSD Only) ==="
input double   BTCStopLossPips = 5000.0;     // Stop Loss in pips (BTCUSD) - 50000 points
input double   BTCTakeProfitPips = 10000.0;  // Take Profit in pips (BTCUSD) - 100000 points

input group "=== Trailing Settings ==="
input double   TrailStepPips = 5.0;          // Trailing step in pips
input double   CandleThresholdPercent = 20.0; // Candle size threshold (%)
input ENUM_TIMEFRAMES TrailTimeframe = PERIOD_M5; // Timeframe for trailing analysis

input group "=== Trading Pairs ==="
input string   TradingSymbols = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY,XAUUSD,XAGUSD,EURHUF,BTCUSD,ETHUSD,BNBUSD,XRPUSD,ADAUSD,SOLUSD,DOGEUSD,TRXUSD,MATICUSD,DOTUSD,LTCUSD,AVAXUSD,LINKUSD,UNIUSD,ATOMUSD,XLMUSD,TONUSD,BCHUSD,APTUSD,FILUSD,NEARUSD"; // Comma-separated list of symbols

input group "=== General Settings ==="
input int      MagicNumber = 123456;         // Magic number for identification
input int      TimerIntervalSeconds = 1;     // Timer check interval in seconds (1-60)

//--- Global variables
CTrade trade;
string symbolArray[];
int symbolCount = 0;
double candleThresholdMultiplier = 0.0;

//--- Structure to store position information
struct PositionInfo
{
   ulong    ticket;
   double   initialSL;
   double   initialTP;
   bool     manuallyModified;
   datetime lastCandleTime;
   double   lastCandleSize;
};

PositionInfo positionData[];

//--- Function declarations
bool IsCryptoSymbol(string symbol);

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Set magic number for the trade object
   trade.SetExpertMagicNumber(MagicNumber);
   
   //--- Parse trading symbols
   ParseTradingSymbols();
   
   //--- Initialize position data array
   ArrayResize(positionData, 0);
   
   //--- Pre-calculate candle threshold multiplier
   candleThresholdMultiplier = CandleThresholdPercent / 100.0;
   
   //--- Set timer for position checks and cleanup
   //--- Limit timer interval to reasonable range (1-60 seconds)
   int timerInterval = TimerIntervalSeconds;
   if(timerInterval < 1) timerInterval = 1;
   if(timerInterval > 60) timerInterval = 60;
   EventSetTimer(timerInterval);
   
   //--- Print initialization message
   Print("AutoSLTP EA initialized successfully");
   Print("Monitoring ", symbolCount, " symbols: ", TradingSymbols);
   Print("Forex & Metals Settings - SL: ", StopLossPips, " pips (", StopLossPips * 10, " points), TP: ", TakeProfitPips, " pips (", TakeProfitPips * 10, " points)");
   Print("Cryptocurrency Settings - SL: ", CryptoStopLossPips, " pips (", CryptoStopLossPips * 10, " points), TP: ", CryptoTakeProfitPips, " pips (", CryptoTakeProfitPips * 10, " points)");
   Print("BTCUSD Specific Settings - SL: ", BTCStopLossPips, " pips (", BTCStopLossPips * 10, " points), TP: ", BTCTakeProfitPips, " pips (", BTCTakeProfitPips * 10, " points)");
   Print("Trailing: ", TrailStepPips, " pips on ", EnumToString(TrailTimeframe));
   Print("Timer check interval: ", timerInterval, " seconds");
   Print("Symbol matching: Exact match + prefix matching for broker suffixes");
   Print("BTCUSD has dedicated settings - Will use BTCUSD-specific SL/TP values");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Kill timer
   EventKillTimer();
   
   Print("AutoSLTP EA stopped. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check all open positions
   CheckAndManagePositions();
}

//+------------------------------------------------------------------+
//| Parse trading symbols from input string                          |
//+------------------------------------------------------------------+
void ParseTradingSymbols()
{
   string symbols = TradingSymbols;
   symbolCount = StringSplit(symbols, ',', symbolArray);
   
   //--- Trim whitespace from symbol names
   for(int i = 0; i < symbolCount; i++)
   {
      StringTrimLeft(symbolArray[i]);
      StringTrimRight(symbolArray[i]);
   }
}

//+------------------------------------------------------------------+
//| Check if symbol is in monitored list                             |
//+------------------------------------------------------------------+
bool IsMonitoredSymbol(string symbol)
{
   //--- First try exact match
   for(int i = 0; i < symbolCount; i++)
   {
      if(symbolArray[i] == symbol)
      {
         if(StringFind(symbol, "XRP") >= 0 || StringFind(symbol, "XAUUSD") >= 0)
            Print("Symbol ", symbol, " matched exactly with ", symbolArray[i]);
         return true;
      }
   }
   
   //--- If no exact match, try partial match (for broker suffixes like XAUUSD.a)
   //--- Check if any monitored symbol is contained at the start of the position symbol
   for(int i = 0; i < symbolCount; i++)
   {
      int len = StringLen(symbolArray[i]);
      if(StringSubstr(symbol, 0, len) == symbolArray[i])
      {
         if(StringFind(symbol, "XRP") >= 0 || StringFind(symbol, "XAUUSD") >= 0)
            Print("Symbol ", symbol, " matched by prefix with ", symbolArray[i]);
         return true;
      }
   }
   
   if(StringFind(symbol, "XRP") >= 0 || StringFind(symbol, "XAUUSD") >= 0)
      Print("Symbol ", symbol, " NOT FOUND in monitored list");
   
   return false;
}

//+------------------------------------------------------------------+
//| Check and manage all positions                                    |
//+------------------------------------------------------------------+
void CheckAndManagePositions()
{
   int totalPositions = PositionsTotal();
   if(totalPositions == 0)
      return;  // No positions to check
   
   //--- Loop through all open positions
   for(int i = totalPositions - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0) continue;
      
      //--- Get position properties
      string symbol = PositionGetString(POSITION_SYMBOL);
      long magic = PositionGetInteger(POSITION_MAGIC);
      
      //--- Log every BTCUSD position found for explicit diagnostics
      if(StringFind(symbol, "BTC") >= 0)
      {
         Print("Found position: Ticket #", ticket, ", Symbol: ", symbol, ", Magic: ", magic);
      }
      
      //--- Skip if not our symbol
      if(!IsMonitoredSymbol(symbol))
      {
         if(StringFind(symbol, "BTC") >= 0)
            Print("  Symbol ", symbol, " not in monitored list - SKIPPING");
         continue;
      }
      else
      {
         //--- Log successful symbol matching for BTCUSD
         if(StringFind(symbol, "BTC") >= 0)
            Print("  Symbol ", symbol, " MATCHED in monitored list");
      }
      
      //--- Skip if not our magic number (unless it's 0, meaning position has no magic)
      if(magic != 0 && magic != MagicNumber)
      {
         if(StringFind(symbol, "BTC") >= 0)
            Print("  Magic number mismatch (Position: ", magic, ", EA: ", MagicNumber, ") - SKIPPING");
         continue;
      }
      
      //--- Check if position needs SL/TP
      CheckAndSetSLTP(ticket, symbol);
      
      //--- Check if position needs trailing
      CheckAndTrailStop(ticket, symbol);
   }
}

//+------------------------------------------------------------------+
//| Check and set SL/TP if not already set                           |
//+------------------------------------------------------------------+
void CheckAndSetSLTP(ulong ticket, string symbol)
{
   if(!PositionSelectByTicket(ticket))
      return;
   
   double currentSL = PositionGetDouble(POSITION_SL);
   double currentTP = PositionGetDouble(POSITION_TP);
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   long posType = PositionGetInteger(POSITION_TYPE);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   //--- Check if position already has SL/TP set
   int posIndex = FindPositionIndex(ticket);
   
   if(posIndex < 0)
   {
      //--- New position, check if we need to set SL/TP
      double epsilon = point * 0.5;
      
      //--- Debug logging for troubleshooting
      Print("Checking position #", ticket, " on ", symbol);
      Print("  Current SL: ", currentSL, ", Current TP: ", currentTP);
      Print("  Open Price: ", openPrice, ", Point: ", point, ", Epsilon: ", epsilon);
      
      if(MathAbs(currentSL) < epsilon || MathAbs(currentTP) < epsilon)
      {
         //--- Calculate SL and TP
         double sl = 0, tp = 0;
         CalculateSLTP(symbol, openPrice, posType, sl, tp);
         
         Print("  Calculated SL: ", sl, ", TP: ", tp);
         
         //--- Modify position
         if(trade.PositionModify(ticket, sl, tp))
         {
            Print("SUCCESS: SL/TP set for position #", ticket, " on ", symbol);
            Print("  SL: ", sl, " TP: ", tp);
            
            //--- Add to tracking
            AddPositionToTracking(ticket, sl, tp);
         }
         else
         {
            int errorCode = GetLastError();
            Print("FAILED: Could not set SL/TP for position #", ticket, " on ", symbol);
            Print("  Error code: ", errorCode);
            Print("  Attempted SL: ", sl, ", TP: ", tp);
            
            //--- Explicit BTCUSD failure logging
            if(StringFind(symbol, "BTC") >= 0)
            {
               Print("BTCUSD FAILED - This requires investigation");
               Print("  Check broker symbol name in Market Watch");
               Print("  Verify broker allows SL/TP modification for BTCUSD");
               Print("  Try increasing StopLossPips and TakeProfitPips if error 10013");
            }
         }
      }
      else
      {
         //--- Position already has SL/TP, add to tracking
         Print("Position #", ticket, " on ", symbol, " already has SL/TP set");
         AddPositionToTracking(ticket, currentSL, currentTP);
      }
   }
   else
   {
      //--- Check if SL/TP was manually modified
      if(!positionData[posIndex].manuallyModified)
      {
         double tolerance = point * 2.0;  // Allow 2 points tolerance for broker adjustments
         if(MathAbs(currentSL - positionData[posIndex].initialSL) > tolerance ||
            MathAbs(currentTP - positionData[posIndex].initialTP) > tolerance)
         {
            //--- SL or TP was manually modified
            positionData[posIndex].manuallyModified = true;
            Print("Manual modification detected for position #", ticket, ". Stopping automated management.");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if symbol is a cryptocurrency (excluding BTCUSD)            |
//+------------------------------------------------------------------+
bool IsCryptoSymbol(string symbol)
{
   //--- BTCUSD has its own dedicated settings, so exclude it from general crypto detection
   if(StringFind(symbol, "BTC") >= 0)
      return false;
   
   //--- List of crypto identifiers (symbol usually contains these)
   string cryptoIdentifiers[] = {"ETH", "BNB", "XRP", "ADA", "SOL", "DOGE", "TRX", 
                                  "MATIC", "DOT", "LTC", "AVAX", "LINK", "UNI", "ATOM", 
                                  "XLM", "TON", "BCH", "APT", "FIL", "NEAR"};
   
   //--- Check if symbol contains any crypto identifier
   for(int i = 0; i < ArraySize(cryptoIdentifiers); i++)
   {
      if(StringFind(symbol, cryptoIdentifiers[i]) >= 0)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate SL and TP based on position type                        |
//+------------------------------------------------------------------+
void CalculateSLTP(string symbol, double openPrice, long posType, double &sl, double &tp)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   
   //--- Check if this is BTCUSD (highest priority)
   bool isBTCUSD = (StringFind(symbol, "BTC") >= 0);
   
   //--- Determine if this is a crypto symbol (excluding BTCUSD)
   bool isCrypto = IsCryptoSymbol(symbol);
   
   //--- Calculate pip value
   //--- For most forex pairs and instruments: 1 pip = 10 points
   //--- This works for: 5-digit (0.00010), 3-digit (0.010), 2-digit (0.10) quotes
   double pipValue = point * 10;
   
   //--- Select appropriate SL/TP distances based on symbol type
   double slPips, tpPips;
   
   if(isBTCUSD)
   {
      //--- Use BTCUSD-specific distances
      slPips = BTCStopLossPips;
      tpPips = BTCTakeProfitPips;
      Print("BTCUSD POSITION DETECTED - Using BTCUSD-specific settings");
      Print("  Using ", slPips, " pips for SL (", slPips * 10, " points), ", tpPips, " pips for TP (", tpPips * 10, " points)");
   }
   else if(isCrypto)
   {
      //--- Use general crypto distances
      slPips = CryptoStopLossPips;
      tpPips = CryptoTakeProfitPips;
      Print("CRYPTO detected: ", symbol, " - Using SL: ", slPips, " pips (", slPips * 10, " points), TP: ", tpPips, " pips (", tpPips * 10, " points)");
   }
   else
   {
      //--- Use forex/metals distances
      slPips = StopLossPips;
      tpPips = TakeProfitPips;
   }
   
   double slDistance = slPips * pipValue;
   double tpDistance = tpPips * pipValue;
   
   if(posType == POSITION_TYPE_BUY)
   {
      sl = NormalizeDouble(openPrice - slDistance, digits);
      tp = NormalizeDouble(openPrice + tpDistance, digits);
   }
   else if(posType == POSITION_TYPE_SELL)
   {
      sl = NormalizeDouble(openPrice + slDistance, digits);
      tp = NormalizeDouble(openPrice - tpDistance, digits);
   }
}

//+------------------------------------------------------------------+
//| Check and trail stop loss                                         |
//+------------------------------------------------------------------+
void CheckAndTrailStop(ulong ticket, string symbol)
{
   if(!PositionSelectByTicket(ticket))
      return;
   
   int posIndex = FindPositionIndex(ticket);
   if(posIndex < 0)
      return;
   
   //--- Don't trail if manually modified
   if(positionData[posIndex].manuallyModified)
      return;
   
   double currentSL = PositionGetDouble(POSITION_SL);
   double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   long posType = PositionGetInteger(POSITION_TYPE);
   double currentTP = PositionGetDouble(POSITION_TP);
   
   //--- Check if position is at breakeven or in profit
   bool inProfit = false;
   if(posType == POSITION_TYPE_BUY)
      inProfit = (currentPrice > openPrice);
   else if(posType == POSITION_TYPE_SELL)
      inProfit = (currentPrice < openPrice);
   
   if(!inProfit)
   {
      return;
   }
   
   //--- Position is in profit, check candle conditions
   if(ShouldTrailStop(symbol, posType, posIndex))
   {
      //--- Calculate new SL
      double newSL = CalculateTrailedSL(symbol, currentPrice, currentSL, posType);
      
      //--- Trail only if new SL is better than current
      bool shouldModify = false;
      if(posType == POSITION_TYPE_BUY && newSL > currentSL)
         shouldModify = true;
      else if(posType == POSITION_TYPE_SELL && newSL < currentSL)
         shouldModify = true;
      
      if(shouldModify)
      {
         if(trade.PositionModify(ticket, newSL, currentTP))
         {
            Print("SL trailed for position #", ticket, " on ", symbol, ". New SL: ", newSL);
            positionData[posIndex].initialSL = newSL;
         }
         else
         {
            Print("Failed to trail SL for position #", ticket, ". Error: ", GetLastError());
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if stop should be trailed based on candle analysis         |
//+------------------------------------------------------------------+
bool ShouldTrailStop(string symbol, long posType, int posIndex)
{
   //--- Get current candle on trailing timeframe
   datetime currentCandleTime = iTime(symbol, TrailTimeframe, 0);
   
   //--- Check if we have a new candle
   if(currentCandleTime == positionData[posIndex].lastCandleTime)
      return false; // Same candle, no action
   
   //--- Get completed previous candle data (index 1 = last completed candle)
   //--- Using completed candles ensures reliable trading decisions
   double prevHigh = iHigh(symbol, TrailTimeframe, 1);
   double prevLow = iLow(symbol, TrailTimeframe, 1);
   double prevCandleSize = prevHigh - prevLow;
   
   //--- Store candle info on first check
   if(positionData[posIndex].lastCandleTime == 0)
   {
      //--- First check, just store data and wait for next candle
      positionData[posIndex].lastCandleTime = currentCandleTime;
      positionData[posIndex].lastCandleSize = prevCandleSize;
      return false;
   }
   
   //--- Check if candle is X% larger than the stored previous candle (configurable threshold)
   //--- Protect against division by zero or very small candles
   double minCandleSize = SymbolInfoDouble(symbol, SYMBOL_POINT) * 10;  // Minimum 10 points
   if(positionData[posIndex].lastCandleSize < minCandleSize)
   {
      //--- Previous candle too small, update and wait
      positionData[posIndex].lastCandleTime = currentCandleTime;
      positionData[posIndex].lastCandleSize = prevCandleSize;
      return false;
   }
   
   //--- Formula: current > previous * (1 + threshold%), simplified for performance
   bool thresholdMet = false;
   if(prevCandleSize > positionData[posIndex].lastCandleSize * (1.0 + candleThresholdMultiplier))
      thresholdMet = true;
   
   //--- Update tracking with completed candle data
   positionData[posIndex].lastCandleTime = currentCandleTime;
   positionData[posIndex].lastCandleSize = prevCandleSize;
   
   return thresholdMet;
}

//+------------------------------------------------------------------+
//| Calculate trailed stop loss                                       |
//+------------------------------------------------------------------+
double CalculateTrailedSL(string symbol, double currentPrice, double currentSL, long posType)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   
   //--- Calculate pip value
   //--- For most forex pairs and instruments: 1 pip = 10 points
   //--- This works for: 5-digit (0.00010), 3-digit (0.010), 2-digit (0.10) quotes
   double pipValue = point * 10;
   
   double trailDistance = TrailStepPips * pipValue;
   double newSL = 0;
   
   //--- Get broker's minimum stop distance
   long stopsLevel = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double minDistance = stopsLevel * point;
   
   if(posType == POSITION_TYPE_BUY)
   {
      newSL = NormalizeDouble(currentSL + trailDistance, digits);
      //--- Ensure new SL is not too close to current price
      double minAllowedSL = currentPrice - minDistance;
      if(newSL > minAllowedSL)
         newSL = minAllowedSL;
   }
   else if(posType == POSITION_TYPE_SELL)
   {
      newSL = NormalizeDouble(currentSL - trailDistance, digits);
      //--- Ensure new SL is not too close to current price
      double maxAllowedSL = currentPrice + minDistance;
      if(newSL < maxAllowedSL)
         newSL = maxAllowedSL;
   }
   
   return newSL;
}

//+------------------------------------------------------------------+
//| Find position index in tracking array                             |
//+------------------------------------------------------------------+
int FindPositionIndex(ulong ticket)
{
   for(int i = 0; i < ArraySize(positionData); i++)
   {
      if(positionData[i].ticket == ticket)
         return i;
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Add position to tracking array                                    |
//+------------------------------------------------------------------+
void AddPositionToTracking(ulong ticket, double sl, double tp)
{
   int size = ArraySize(positionData);
   ArrayResize(positionData, size + 1);
   
   positionData[size].ticket = ticket;
   positionData[size].initialSL = sl;
   positionData[size].initialTP = tp;
   positionData[size].manuallyModified = false;
   positionData[size].lastCandleTime = 0;
   positionData[size].lastCandleSize = 0;
}

//+------------------------------------------------------------------+
//| Remove closed positions from tracking                             |
//+------------------------------------------------------------------+
void CleanupClosedPositions()
{
   for(int i = ArraySize(positionData) - 1; i >= 0; i--)
   {
      if(!PositionSelectByTicket(positionData[i].ticket))
      {
         //--- Position is closed, remove from tracking
         ArrayRemove(positionData, i, 1);
      }
   }
}

//+------------------------------------------------------------------+
//| Timer function - periodic position checks and cleanup            |
//+------------------------------------------------------------------+
void OnTimer()
{
   //--- Check all open positions (ensures positions are checked even if ticks are slow)
   CheckAndManagePositions();
   
   //--- Cleanup closed positions from tracking array
   CleanupClosedPositions();
}
//+------------------------------------------------------------------+
