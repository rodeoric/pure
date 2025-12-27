//+------------------------------------------------------------------+
//| Microtrade Pattern EA für M5 Chart mit Risk/Reward, flexible Pinbar, Kommission-Check |
//+------------------------------------------------------------------+
#property strict

input string SymbolsToTrade    = "EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,NZDUSD";
input ENUM_TIMEFRAMES InpTF    = PERIOD_M30;          // 5-Minuten Chart
input double RiskPercent       = 1.0;                // % Risiko pro Trade
input double MaxLots           = 0.25;               // Maximale Lots pro Trade
input double MinProfitUSD      = 8.0;                // Mindestgewinn pro Trade
input ulong  Magic             = 62843109;           // Neue Magic Number (zufällig)
input double PinbarBodyMaxFrac = 0.50;               // Pinbar: max. Body/Rang
input double PinbarWickMult    = 2.2;                // Pinbar: Wick-Multiplikator
input int    MinStopPtsFX      = 300;                // Mindestabstand SL in Punkten
input bool   DebugLogs         = true;

#include <Trade\Trade.mqh>
CTrade trade;

string Symbols[];
datetime LastBarTime[];

// ==== Kerzenmuster-Logik ====
enum ESignal { ES_NONE, ES_SELL };

ESignal GetCandleSignal(string sym) {
   double O1[1], H1[1], L1[1], C1[1], O2[1], H2[1], L2[1], C2[1];
   datetime T1[1], T2[1];

   // vorletzte Bar
   if(CopyTime(sym, InpTF, 1, 1, T1)!=1) return ES_NONE;
   if(CopyOpen(sym, InpTF, 1, 1, O1)!=1) return ES_NONE;
   if(CopyHigh(sym, InpTF, 1, 1, H1)!=1) return ES_NONE;
   if(CopyLow(sym, InpTF, 1, 1, L1)!=1) return ES_NONE;
   if(CopyClose(sym, InpTF, 1, 1, C1)!=1) return ES_NONE;
   double o1=O1[0], h1=H1[0], l1=L1[0], c1=C1[0];

   // zweitletzte Bar
   if(CopyTime(sym, InpTF, 2, 1, T2)!=1) return ES_NONE;
   if(CopyOpen(sym, InpTF, 2, 1, O2)!=1) return ES_NONE;
   if(CopyHigh(sym, InpTF, 2, 1, H2)!=1) return ES_NONE;
   if(CopyLow(sym, InpTF, 2, 1, L2)!=1) return ES_NONE;
   if(CopyClose(sym, InpTF, 2, 1, C2)!=1) return ES_NONE;
   double o2=O2[0], h2=H2[0], l2=L2[0], c2=C2[0];

   // Bearish Engulfing
   bool bear = (c2 > o2) && (c1 < o1) && (c1 < o2) && (o1 > c2);
   if(bear) return ES_SELL;

   // Pinbar
   double body = MathAbs(c1 - o1);
   double rng  = h1 - l1;
   if(rng <= 0) return ES_NONE;
   if(body / rng <= PinbarBodyMaxFrac) {
      double upper = h1 - MathMax(o1, c1);
      if(upper > PinbarWickMult * body) return ES_SELL;
   }
   return ES_NONE;
}

// ==== Risk/Reward Lot-Berechnung ====
double CalcLots(string sym, double stopPts)
{
   double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   double point     = SymbolInfoDouble(sym, SYMBOL_POINT);
   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney = balance * RiskPercent / 100.0;
   double slDist    = stopPts * point;
   double lotStep   = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);

   if(tickValue<=0 || tickSize<=0 || slDist<=0) return lotStep;

   double lots = riskMoney / (slDist / tickSize * tickValue);
   lots = MathMax(lots, lotStep);
   lots = MathMin(lots, MaxLots);
   lots = MathFloor(lots / lotStep) * lotStep; // runden auf LotStep
   return lots;
}

// ==== Einstieg & Exit ====
void OnTick()
{
   int n = StringSplit(SymbolsToTrade, ',', Symbols);
   if(ArraySize(LastBarTime)!=n) ArrayResize(LastBarTime, n);

   for(int i=0; i<n; i++)
   {
      string sym = Symbols[i]; if(sym=="") continue;
      SymbolSelect(sym, true);

      // Kerzenbeginn erkennen
      datetime T[1];
      if(CopyTime(sym, InpTF, 0, 1, T)==1)
      {
         if(LastBarTime[i]!=T[0])
         {
            LastBarTime[i]=T[0];

            // Kerzenmuster-Check: mehrere Trades pro Bar erlaubt!
            ESignal sig = GetCandleSignal(sym);
            if(sig == ES_NONE) continue;

            double point = SymbolInfoDouble(sym, SYMBOL_POINT);
            double stopPts = MinStopPtsFX; // Kannst du nach Muster anpassen!
            double entryPrice = SymbolInfoDouble(sym, SYMBOL_BID);

            double sl, tp;
            sl = entryPrice + stopPts * point;
            tp = entryPrice - (stopPts * 2.0) * point;

            double lots = CalcLots(sym, stopPts);

            trade.SetExpertMagicNumber(Magic);
            bool ok = trade.Sell(lots, sym, entryPrice, sl, tp, NULL);

            if(DebugLogs) Print("[",sym,"] SELL gestartet mit ",DoubleToString(lots,2)," lots @ ",entryPrice," SL:",sl," TP:",tp);
         }
      }

      // Exit: Schließe Trade nur, wenn Gewinnziel erreicht (mind. 3x Kommission oder MinProfitUSD)
      if(PositionSelect(sym))
      {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         double profit = PositionGetDouble(POSITION_PROFIT);
         double commission = PositionGetDouble(POSITION_COMMISSION);
         double minProfit = MathMax(MinProfitUSD, 3.0 * MathAbs(commission));

         if(profit >= minProfit)
         {
            trade.PositionClose(ticket);
            if(DebugLogs) Print("[",sym,"] Trade geschlossen mit Gewinn: ",profit," (Komm.:",commission,")");
         }
      }
   }
}
