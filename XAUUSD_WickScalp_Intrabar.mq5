//+------------------------------------------------------------------+
//| XAUUSD_WickScalp_Intrabar.mq5                                     |
//| Intrabar wick-rejection scalper with auto SL/TP + timeout         |
//| Optimized for quick scalping trades on M1/M5 timeframes          |
//+------------------------------------------------------------------+
#property copyright "Wicktrading EA"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;

// -------------------- Inputs --------------------
input string InpSymbol              = "XAUUSD";
input ENUM_TIMEFRAMES InpTF         = PERIOD_M1;

input long   InpMagic               = 26012701;
input double InpLots                = 0.01;           // Lot size (configurable)

input int    InpMaxSpreadPoints     = 60;             // points (for XAUUSD broker-dependent)
input int    InpMinWickPoints       = 80;             // minimum wick length (points) to qualify
input double InpWickToBodyRatio     = 1.5;            // wick must be >= body * ratio
input int    InpRetraceTriggerPts   = 40;             // after making extreme, price must retrace this many points to trigger entry
input int    InpSLBufferPoints      = 20;             // buffer beyond extreme for SL

// TP mode
input bool   InpUseFixedTP          = true;           // true: fixed TP points, false: RR-based TP
input int    InpFixedTPPoints       = 60;             // points
input double InpRR                  = 0.7;            // TP = SL_distance * RR (if fixed TP disabled)
input int    InpMaxTPPointsCap      = 120;            // cap for RR TP points (avoid too large TP)

// Time exit
input int    InpMaxHoldSeconds      = 90;             // close after this many seconds
input int    InpCooldownSeconds     = 20;             // pause after a trade closes (avoid spam)

// Safety
input bool   InpOneTradeAtATime     = true;           // only one position for this EA

// Commission (EUR/USD per lot)
input double InpCommissionPerLot    = 7.0;            // Commission per lot in EUR/USD
input double InpMinProfitMultiplier = 1.5;            // Minimum profit must be this times commission

// -------------------- Constants --------------------
#define INVALID_SPREAD 999999

// -------------------- State --------------------
datetime g_bar_time = 0;
double   g_open     = 0.0;
double   g_high     = 0.0;
double   g_low      = 0.0;

datetime g_last_trade_time = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Validate timeframe
   if(InpTF != PERIOD_M1 && InpTF != PERIOD_M5)
   {
      Print("ERROR: EA only works on M1 or M5 timeframes!");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(20);     // slippage allowance (adjust if needed)
   EventSetTimer(1);                   // manage timeout each second
   
   Print("Wicktrading EA initialized for ", InpSymbol, " on ", EnumToString(InpTF));
   Print("Lot size: ", InpLots, " | Commission per lot: ", InpCommissionPerLot, " EUR/USD");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check spread
   if(SpreadPoints() > InpMaxSpreadPoints)
      return;

   // One trade at a time?
   if(InpOneTradeAtATime && IsOurPositionOpen())
      return;

   // Cooldown
   if(!CooldownOk())
      return;

   UpdateBarState();

   // Try sell signal
   double sl=0, tp=0;
   if(TrySellSignal(sl, tp))
   {
      if(trade.Sell(InpLots, InpSymbol, 0, sl, tp, "WickSell"))
      {
         g_last_trade_time = TimeCurrent();
         Print("SELL order placed at ", SymbolInfoDouble(InpSymbol, SYMBOL_BID), " SL:", sl, " TP:", tp);
      }
      return;
   }

   // Try buy signal
   if(TryBuySignal(sl, tp))
   {
      if(trade.Buy(InpLots, InpSymbol, 0, sl, tp, "WickBuy"))
      {
         g_last_trade_time = TimeCurrent();
         Print("BUY order placed at ", SymbolInfoDouble(InpSymbol, SYMBOL_ASK), " SL:", sl, " TP:", tp);
      }
      return;
   }
}

//+------------------------------------------------------------------+
//| Timer function                                                    |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Check if we should close position due to timeout
   ulong ticket=0;
   datetime open_time=0;
   
   if(GetOurPositionInfo(ticket, open_time))
   {
      int hold_time = (int)(TimeCurrent() - open_time);
      if(hold_time >= InpMaxHoldSeconds)
      {
         if(trade.PositionClose(ticket))
         {
            Print("Position closed due to timeout (", hold_time, " seconds)");
            g_last_trade_time = TimeCurrent();
         }
      }
   }
}

//+------------------------------------------------------------------+
// Helper functions
//+------------------------------------------------------------------+
bool IsOurPositionOpen()
{
   for(int pos_index=PositionsTotal()-1; pos_index>=0; pos_index--)
   {
      if(PositionSelectByIndex(pos_index))
      {
         string sym = PositionGetString(POSITION_SYMBOL);
         long   mg  = (long)PositionGetInteger(POSITION_MAGIC);
         if(sym == InpSymbol && mg == InpMagic)
            return true;
      }
   }
   return false;
}

bool GetOurPositionInfo(ulong &ticket, datetime &open_time)
{
   for(int pos_index=PositionsTotal()-1; pos_index>=0; pos_index--)
   {
      if(PositionSelectByIndex(pos_index))
      {
         string sym = PositionGetString(POSITION_SYMBOL);
         long   mg  = (long)PositionGetInteger(POSITION_MAGIC);
         if(sym == InpSymbol && mg == InpMagic)
         {
            ticket    = (ulong)PositionGetInteger(POSITION_TICKET);
            open_time = (datetime)PositionGetInteger(POSITION_TIME);
            return true;
         }
      }
   }
   return false;
}

int SpreadPoints()
{
   double ask=0, bid=0;
   if(!SymbolInfoDouble(InpSymbol, SYMBOL_ASK, ask)) return INVALID_SPREAD;
   if(!SymbolInfoDouble(InpSymbol, SYMBOL_BID, bid)) return INVALID_SPREAD;
   double pt = SymbolInfoDouble(InpSymbol, SYMBOL_POINT);
   if(pt <= 0)
   {
      Print("ERROR: Invalid SYMBOL_POINT: ", pt);
      return INVALID_SPREAD;
   }
   return (int)MathRound((ask-bid)/pt);
}

bool CooldownOk()
{
   if(g_last_trade_time == 0) return true;
   return ((TimeCurrent() - g_last_trade_time) >= InpCooldownSeconds);
}

double PointsToPrice(int pts)
{
   double pt = SymbolInfoDouble(InpSymbol, SYMBOL_POINT);
   if(pt <= 0)
   {
      Print("ERROR: Invalid SYMBOL_POINT in PointsToPrice: ", pt);
      return 0.0;
   }
   return pts * pt;
}

double NormalizePrice(double price)
{
   int digits = (int)SymbolInfoInteger(InpSymbol, SYMBOL_DIGITS);
   return NormalizeDouble(price, digits);
}

bool IsProfitWorthCommission(double profit_price)
{
   // Calculate if profit is worth the commission cost
   double commission_cost = InpCommissionPerLot * InpLots;
   double tick_value = SymbolInfoDouble(InpSymbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(InpSymbol, SYMBOL_TRADE_TICK_SIZE);
   
   // Validate tick_value to prevent division by zero
   if(tick_value <= 0)
   {
      Print("ERROR: Invalid tick_value: ", tick_value);
      return false;
   }
   
   // Validate tick_size
   if(tick_size <= 0)
   {
      Print("ERROR: Invalid tick_size: ", tick_size);
      return false;
   }
   
   // Convert commission to price units
   double min_profit_price = (commission_cost / tick_value) * tick_size;
   
   return (profit_price >= min_profit_price * InpMinProfitMultiplier);
}

//+------------------------------------------------------------------+
// Entry logic (intrabar wick rejection)
//+------------------------------------------------------------------+
void UpdateBarState()
{
   datetime t = (datetime)iTime(InpSymbol, InpTF, 0);
   if(t != g_bar_time)
   {
      // new bar
      g_bar_time = t;
      g_open     = iOpen(InpSymbol, InpTF, 0);
      
      // Validate price data
      if(g_open <= 0)
      {
         Print("ERROR: Invalid open price: ", g_open);
         return;
      }
      
      g_high     = g_open;
      g_low      = g_open;
   }
}

bool TrySellSignal(double &sl, double &tp)
{
   // We want: new high happened, upper wick big, then retrace down by InpRetraceTriggerPts from the high
   double bid=0, ask=0;
   if(!SymbolInfoDouble(InpSymbol, SYMBOL_BID, bid)) return false;
   if(!SymbolInfoDouble(InpSymbol, SYMBOL_ASK, ask)) return false;

   // update intrabar extremes with current prices
   if(ask > g_high) g_high = ask;
   if(bid < g_low)  g_low  = bid;

   // current "body" size so far: distance from open to current close proxy (bid)
   double body = MathAbs(bid - g_open);
   double upper_wick = g_high - MathMax(g_open, bid);
   double pt = SymbolInfoDouble(InpSymbol, SYMBOL_POINT);
   if(pt <= 0)
   {
      Print("ERROR: Invalid SYMBOL_POINT in TrySellSignal: ", pt);
      return false;
   }

   int upper_wick_pts = (int)MathRound(upper_wick / pt);

   if(upper_wick_pts < InpMinWickPoints) return false;
   if(body > 0.0)
   {
      if(upper_wick < body * InpWickToBodyRatio) return false;
   }

   // retrace check: price moved down from the high by trigger points
   double retrace = g_high - bid;
   int retrace_pts = (int)MathRound(retrace / pt);
   if(retrace_pts < InpRetraceTriggerPts) return false;

   // build SL / TP
   sl = NormalizePrice(g_high + PointsToPrice(InpSLBufferPoints));

   double sl_dist = sl - bid; // in price
   int sl_pts = (int)MathRound(sl_dist / pt);
   if(sl_pts <= 0) return false;

   if(InpUseFixedTP)
   {
      tp = NormalizePrice(bid - PointsToPrice(InpFixedTPPoints));
   }
   else
   {
      int tp_pts = (int)(sl_pts * InpRR);
      if(tp_pts > InpMaxTPPointsCap) tp_pts = InpMaxTPPointsCap;
      tp = NormalizePrice(bid - PointsToPrice(tp_pts));
   }

   // Factor in commission: check if TP is worth it
   double tp_profit = bid - tp; // profit in price
   if(!IsProfitWorthCommission(tp_profit))
      return false;

   return true;
}

bool TryBuySignal(double &sl, double &tp)
{
   // We want: new low happened, lower wick big, then retrace up by InpRetraceTriggerPts from the low
   double bid=0, ask=0;
   if(!SymbolInfoDouble(InpSymbol, SYMBOL_BID, bid)) return false;
   if(!SymbolInfoDouble(InpSymbol, SYMBOL_ASK, ask)) return false;

   // update intrabar extremes
   if(ask > g_high) g_high = ask;
   if(bid < g_low)  g_low  = bid;

   double body = MathAbs(ask - g_open);
   double lower_wick = MathMin(g_open, ask) - g_low;
   double pt = SymbolInfoDouble(InpSymbol, SYMBOL_POINT);
   if(pt <= 0)
   {
      Print("ERROR: Invalid SYMBOL_POINT in TryBuySignal: ", pt);
      return false;
   }

   int lower_wick_pts = (int)MathRound(lower_wick / pt);

   if(lower_wick_pts < InpMinWickPoints) return false;
   if(body > 0.0)
   {
      if(lower_wick < body * InpWickToBodyRatio) return false;
   }

   // retrace check: price moved up from the low
   double retrace = ask - g_low;
   int retrace_pts = (int)MathRound(retrace / pt);
   if(retrace_pts < InpRetraceTriggerPts) return false;

   // build SL / TP
   sl = NormalizePrice(g_low - PointsToPrice(InpSLBufferPoints));

   double sl_dist = ask - sl;
   int sl_pts = (int)MathRound(sl_dist / pt);
   if(sl_pts <= 0) return false;

   if(InpUseFixedTP)
   {
      tp = NormalizePrice(ask + PointsToPrice(InpFixedTPPoints));
   }
   else
   {
      int tp_pts = (int)(sl_pts * InpRR);
      if(tp_pts > InpMaxTPPointsCap) tp_pts = InpMaxTPPointsCap;
      tp = NormalizePrice(ask + PointsToPrice(tp_pts));
   }

   // Factor in commission: check if TP is worth it
   double tp_profit = tp - ask; // profit in price
   if(!IsProfitWorthCommission(tp_profit))
      return false;

   return true;
}
//+------------------------------------------------------------------+
