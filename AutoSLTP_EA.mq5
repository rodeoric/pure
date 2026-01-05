//+------------------------------------------------------------------+
//|                                                  AutoSLTP_EA.mq5 |
//|                                      Automatic SL/TP Management  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Auto SL/TP Management EA"
#property link      ""
#property version   "1.00"
#property description "Automatically manages Stop Loss and Take Profit"
#property description "Sets configurable SL/TP for all positions"
#property description "Auto-closes positions at profit target"

#include <Trade\Trade.mqh>

//--- Input parameters
input group "=== Stop Loss & Take Profit Settings ==="
input double   StopLossPoints = 1000.0;      // Stop Loss in points (100 pips = 1000 points)
input double   TakeProfitPoints = 2000.0;    // Take Profit in points (200 pips = 2000 points)

input group "=== Auto-Close Profit Target ==="
input double   AutoClosePoints = 300.0;      // Auto-close when profit reaches this (points)

input group "=== Trading Pairs ==="
input string   TradingSymbols = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY,XAUUSD,XAGUSD,EURHUF,BTCUSD,ETHUSD,BNBUSD,XRPUSD,ADAUSD,SOLUSD,DOGEUSD,TRXUSD,MATICUSD,DOTUSD,LTCUSD,AVAXUSD,LINKUSD,UNIUSD,ATOMUSD,XLMUSD,TONUSD,BCHUSD,APTUSD,FILUSD,NEARUSD"; // Comma-separated list of symbols

input group "=== General Settings ==="
input int      MagicNumber = 123456;         // Magic number for identification
input int      TimerIntervalSeconds = 1;     // Timer check interval in seconds (1-60)

//--- Global variables
CTrade trade;
string symbolArray[];
int symbolCount = 0;

//--- Structure to store position information
struct PositionInfo
{
   ulong    ticket;
   double   initialSL;
   double   initialTP;
   bool     manuallyModified;
};

PositionInfo positionData[];

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
   
   //--- Set timer for position checks and cleanup
   //--- Limit timer interval to reasonable range (1-60 seconds)
   int timerInterval = TimerIntervalSeconds;
   if(timerInterval < 1) timerInterval = 1;
   if(timerInterval > 60) timerInterval = 60;
   EventSetTimer(timerInterval);
   
   //--- Print initialization message
   Print("AutoSLTP EA initialized successfully");
   Print("Monitoring ", symbolCount, " symbols: ", TradingSymbols);
   Print("Settings - SL: ", StopLossPoints, " points, TP: ", TakeProfitPoints, " points");
   Print("Auto-close at: ", AutoClosePoints, " points profit");
   Print("Timer check interval: ", timerInterval, " seconds");
   Print("Symbol matching: Exact match + prefix matching for broker suffixes");
   
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
         return true;
      }
   }
   
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
      
      //--- Skip if not our symbol
      if(!IsMonitoredSymbol(symbol))
         continue;
      
      //--- Skip if not our magic number
      //--- If MagicNumber = 0, EA manages all positions
      //--- If position magic = 0 OR matches EA magic, manage it
      if(MagicNumber != 0 && magic != 0 && magic != MagicNumber)
         continue;
      
      //--- Check if position needs SL/TP
      CheckAndSetSLTP(ticket, symbol);
      
      //--- Check if position should be auto-closed
      CheckAutoClose(ticket, symbol);
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
      
      if(MathAbs(currentSL) < epsilon || MathAbs(currentTP) < epsilon)
      {
         //--- Calculate SL and TP
         double sl = 0, tp = 0;
         CalculateSLTP(symbol, openPrice, posType, sl, tp);
         
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
         }
      }
      else
      {
         //--- Position already has SL/TP, add to tracking
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
//| Calculate SL and TP based on position type                        |
//+------------------------------------------------------------------+
void CalculateSLTP(string symbol, double openPrice, long posType, double &sl, double &tp)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   
   //--- Calculate distances in points
   double slDistance = StopLossPoints * point;
   double tpDistance = TakeProfitPoints * point;
   
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
//| Check if position should be auto-closed at profit target         |
//+------------------------------------------------------------------+
void CheckAutoClose(ulong ticket, string symbol)
{
   if(!PositionSelectByTicket(ticket))
      return;
   
   int posIndex = FindPositionIndex(ticket);
   if(posIndex < 0)
      return;
   
   //--- Note: Auto-close works regardless of manual modifications
   //--- This ensures profit target is always respected
   
   double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   long posType = PositionGetInteger(POSITION_TYPE);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   //--- Calculate profit in points
   double profitPoints = 0;
   if(posType == POSITION_TYPE_BUY)
      profitPoints = (currentPrice - openPrice) / point;
   else if(posType == POSITION_TYPE_SELL)
      profitPoints = (openPrice - currentPrice) / point;
   
   //--- Check if profit target reached
   if(profitPoints >= AutoClosePoints)
   {
      //--- Close the position
      if(trade.PositionClose(ticket))
      {
         Print("AUTO-CLOSED: Position #", ticket, " on ", symbol, " at ", profitPoints, " points profit");
         //--- Position will be removed from tracking in cleanup
      }
      else
      {
         int errorCode = GetLastError();
         Print("FAILED to auto-close position #", ticket, ". Error: ", errorCode);
      }
   }
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
