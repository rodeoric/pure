//+------------------------------------------------------------------+
//|                                          PureWickTradingEA.mq5   |
//|                                 Pure Cryptocurrency Project       |
//|                                 https://github.com/rodeoric/pure |
//+------------------------------------------------------------------+
#property copyright "Pure Cryptocurrency Project"
#property link      "https://github.com/rodeoric/pure"
#property version   "1.00"
#property description "Expert Advisor für Kerzendocht-Trading im M1 Chart"
#property description "Implementiert Pin Bar Reversal Strategie"

//--- Input Parameters
input group "=== Risk Management ==="
input double   RiskPercent = 1.0;              // Risiko pro Trade in %
input double   MinLotSize = 0.01;              // Minimale Lot-Größe
input double   MaxLotSize = 10.0;              // Maximale Lot-Größe

input group "=== Strategy Parameters ==="
input double   WickToBodyRatio = 2.0;          // Mindest Docht-zu-Körper Verhältnis
input double   OppositeWickMaxPercent = 30.0; // Max Gegendocht in % des Hauptdochts
input int      MinWickPips = 5;                // Minimale Dochtlänge in Pips
input double   TakeProfitMultiplier = 1.5;    // TP als Vielfaches der Dochtlänge
input double   StopLossBuffer = 3;             // SL Buffer in Pips über/unter Docht

input group "=== Trading Settings ==="
input int      MagicNumber = 123456;           // Magic Number für Orders
input bool     TradeOnlyTrend = false;         // Nur in Trendrichtung handeln
input int      TrendPeriod = 20;               // MA Periode für Trend-Filter
input int      MaxOpenTrades = 1;              // Maximale gleichzeitige Trades
input bool     UseTrailingStop = true;         // Trailing Stop aktivieren
input double   TrailingStopPercent = 50.0;    // Trailing Start bei % des TP

input group "=== Session Filter ==="
input bool     UseSessionFilter = true;        // Session-Filter aktivieren
input int      SessionStartHour = 8;           // Start-Stunde (Server-Zeit)
input int      SessionEndHour = 20;            // End-Stunde (Server-Zeit)
input double   MaxSpreadPips = 3.0;            // Maximaler Spread in Pips

//--- Global Variables
int            trendMA_handle;
double         trendMA_buffer[];
datetime       lastBarTime = 0;
double         tickSize;
double         tickValue;
int            digits;

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Initialize indicator
   trendMA_handle = iMA(_Symbol, PERIOD_M1, TrendPeriod, 0, MODE_SMA, PRICE_CLOSE);
   if(trendMA_handle == INVALID_HANDLE)
   {
      Print("Fehler beim Erstellen des MA Indikators!");
      return(INIT_FAILED);
   }
   
   ArraySetAsSeries(trendMA_buffer, true);
   
   //--- Get symbol properties
   digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   
   //--- Success
   Print("PureWickTradingEA initialisiert für ", _Symbol, " M1 Chart");
   Print("Risk per Trade: ", RiskPercent, "%");
   Print("Wick-to-Body Ratio: ", WickToBodyRatio);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(trendMA_handle != INVALID_HANDLE)
      IndicatorRelease(trendMA_handle);
   
   Print("PureWickTradingEA gestoppt. Grund: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check if new bar
   datetime currentBarTime = iTime(_Symbol, PERIOD_M1, 0);
   if(currentBarTime == lastBarTime)
      return;
   
   lastBarTime = currentBarTime;
   
   //--- Session filter
   if(UseSessionFilter && !IsInTradingSession())
      return;
   
   //--- Spread filter
   if(!CheckSpread())
      return;
   
   //--- Check if we can open new trade
   if(CountOpenPositions() >= MaxOpenTrades)
   {
      ManageOpenPositions();
      return;
   }
   
   //--- Update MA buffer
   if(CopyBuffer(trendMA_handle, 0, 0, 3, trendMA_buffer) < 3)
      return;
   
   //--- Analyze candlestick (previous closed candle)
   int signal = AnalyzePinBar(1);
   
   if(signal == 1) // Bullish Pin Bar
   {
      if(!TradeOnlyTrend || IsBullishTrend())
         OpenPosition(ORDER_TYPE_BUY);
   }
   else if(signal == -1) // Bearish Pin Bar
   {
      if(!TradeOnlyTrend || IsBearishTrend())
         OpenPosition(ORDER_TYPE_SELL);
   }
   
   //--- Manage existing positions
   ManageOpenPositions();
}

//+------------------------------------------------------------------+
//| Analyze candlestick for Pin Bar pattern                          |
//+------------------------------------------------------------------+
int AnalyzePinBar(int barIndex)
{
   double open = iOpen(_Symbol, PERIOD_M1, barIndex);
   double high = iHigh(_Symbol, PERIOD_M1, barIndex);
   double low = iLow(_Symbol, PERIOD_M1, barIndex);
   double close = iClose(_Symbol, PERIOD_M1, barIndex);
   
   double bodySize = MathAbs(close - open);
   double upperWick = high - MathMax(open, close);
   double lowerWick = MathMin(open, close) - low;
   double totalRange = high - low;
   
   //--- Convert to pips
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double lowerWickPips = lowerWick / point / 10.0;
   double upperWickPips = upperWick / point / 10.0;
   
   //--- Check for Bullish Pin Bar (Hammer)
   if(lowerWickPips >= MinWickPips && bodySize > 0)
   {
      double wickToBodyRatio = lowerWick / bodySize;
      double oppositeWickRatio = (upperWick / lowerWick) * 100.0;
      
      if(wickToBodyRatio >= WickToBodyRatio && 
         oppositeWickRatio <= OppositeWickMaxPercent &&
         close > (low + totalRange * 0.6)) // Close in upper 40%
      {
         return 1; // Bullish signal
      }
   }
   
   //--- Check for Bearish Pin Bar (Shooting Star)
   if(upperWickPips >= MinWickPips && bodySize > 0)
   {
      double wickToBodyRatio = upperWick / bodySize;
      double oppositeWickRatio = (lowerWick / upperWick) * 100.0;
      
      if(wickToBodyRatio >= WickToBodyRatio && 
         oppositeWickRatio <= OppositeWickMaxPercent &&
         close < (high - totalRange * 0.6)) // Close in lower 40%
      {
         return -1; // Bearish signal
      }
   }
   
   return 0; // No signal
}

//+------------------------------------------------------------------+
//| Open new position                                                 |
//+------------------------------------------------------------------+
void OpenPosition(ENUM_ORDER_TYPE orderType)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double price = (orderType == ORDER_TYPE_BUY) ? ask : bid;
   
   //--- Get previous candle data for SL/TP calculation
   double high = iHigh(_Symbol, PERIOD_M1, 1);
   double low = iLow(_Symbol, PERIOD_M1, 1);
   double close = iClose(_Symbol, PERIOD_M1, 1);
   double open = iOpen(_Symbol, PERIOD_M1, 1);
   
   double wickLength = (orderType == ORDER_TYPE_BUY) ? 
                       (MathMin(open, close) - low) : 
                       (high - MathMax(open, close));
   
   //--- Calculate SL and TP
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double slDistance, tpDistance;
   double sl, tp;
   
   if(orderType == ORDER_TYPE_BUY)
   {
      slDistance = (price - low) + (StopLossBuffer * 10 * point);
      tpDistance = wickLength * TakeProfitMultiplier;
      sl = NormalizeDouble(price - slDistance, digits);
      tp = NormalizeDouble(price + tpDistance, digits);
   }
   else
   {
      slDistance = (high - price) + (StopLossBuffer * 10 * point);
      tpDistance = wickLength * TakeProfitMultiplier;
      sl = NormalizeDouble(price + slDistance, digits);
      tp = NormalizeDouble(price - tpDistance, digits);
   }
   
   //--- Calculate lot size based on risk
   double lotSize = CalculateLotSize(slDistance);
   
   //--- Prepare trade request
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lotSize;
   request.type = orderType;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = MagicNumber;
   request.comment = "PureWick_" + (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL");
   request.type_filling = ORDER_FILLING_FOK;
   
   //--- Send order
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
      {
         Print("Order erfolgreich eröffnet: ", result.order, 
               " | Typ: ", EnumToString(orderType),
               " | Lots: ", lotSize,
               " | SL: ", sl,
               " | TP: ", tp);
      }
      else
      {
         Print("Order fehlgeschlagen. RetCode: ", result.retcode, 
               " | ", result.comment);
      }
   }
   else
   {
      Print("OrderSend Fehler: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk percentage                      |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistance)
{
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = accountBalance * (RiskPercent / 100.0);
   
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   double moneyPerLot = (slDistance / tickSize) * tickValue;
   double lotSize = riskAmount / moneyPerLot;
   
   //--- Normalize lot size
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   lotSize = MathMax(MinLotSize, MathMin(MaxLotSize, lotSize));
   
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                 |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Manage open positions (Trailing Stop)                            |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   if(!UseTrailingStop)
      return;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;
      
      if(PositionGetString(POSITION_SYMBOL) != _Symbol ||
         PositionGetInteger(POSITION_MAGIC) != MagicNumber)
         continue;
      
      double positionOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double positionSL = PositionGetDouble(POSITION_SL);
      double positionTP = PositionGetDouble(POSITION_TP);
      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      double currentPrice = (positionType == POSITION_TYPE_BUY) ? 
                            SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                            SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      double profit = (positionType == POSITION_TYPE_BUY) ? 
                      (currentPrice - positionOpenPrice) : 
                      (positionOpenPrice - currentPrice);
      
      double tpDistance = MathAbs(positionTP - positionOpenPrice);
      double profitPercent = (profit / tpDistance) * 100.0;
      
      //--- Apply trailing stop if profit reached threshold
      if(profitPercent >= TrailingStopPercent)
      {
         double newSL;
         double trailDistance = tpDistance * (TrailingStopPercent / 100.0);
         
         if(positionType == POSITION_TYPE_BUY)
         {
            newSL = currentPrice - trailDistance;
            if(newSL > positionSL && newSL < currentPrice)
            {
               ModifyPosition(ticket, newSL, positionTP);
            }
         }
         else
         {
            newSL = currentPrice + trailDistance;
            if(newSL < positionSL && newSL > currentPrice)
            {
               ModifyPosition(ticket, newSL, positionTP);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Modify position SL/TP                                             |
//+------------------------------------------------------------------+
void ModifyPosition(ulong ticket, double newSL, double newTP)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_SLTP;
   request.position = ticket;
   request.sl = NormalizeDouble(newSL, digits);
   request.tp = NormalizeDouble(newTP, digits);
   
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
      {
         Print("Position ", ticket, " modifiziert. Neuer SL: ", newSL);
      }
   }
}

//+------------------------------------------------------------------+
//| Check if in trading session                                       |
//+------------------------------------------------------------------+
bool IsInTradingSession()
{
   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   
   if(time.hour >= SessionStartHour && time.hour < SessionEndHour)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Check spread                                                      |
//+------------------------------------------------------------------+
bool CheckSpread()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = ask - bid;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double spreadPips = spread / point / 10.0;
   
   return (spreadPips <= MaxSpreadPips);
}

//+------------------------------------------------------------------+
//| Check for bullish trend                                           |
//+------------------------------------------------------------------+
bool IsBullishTrend()
{
   double currentPrice = iClose(_Symbol, PERIOD_M1, 1);
   return (currentPrice > trendMA_buffer[1]);
}

//+------------------------------------------------------------------+
//| Check for bearish trend                                           |
//+------------------------------------------------------------------+
bool IsBearishTrend()
{
   double currentPrice = iClose(_Symbol, PERIOD_M1, 1);
   return (currentPrice < trendMA_buffer[1]);
}
//+------------------------------------------------------------------+
