//+------------------------------------------------------------------+
//|                                             PrevBarBreakSide.mq5 |
//|                            Copyright 2024, Diamond Systems Corp. |
//|                                        https://algotrading.today |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Diamond Systems Corp."
#property link "https://algotrading.today"
#property version "1.00"
#property script_show_inputs

//--- ENUMs
enum PBBS_TREND
{
   PBBS_TREND_ERROR = -1,
   PBBS_TREND_NONE,
   PBBS_TREND_UP,
   PBBS_TREND_DOWN,
};

//--- inputs
input int i_Bar = 5; // Bar

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=====================");

   datetime time = iTime(_Symbol, PERIOD_CURRENT, i_Bar);
   double high = iHigh(_Symbol, PERIOD_CURRENT, i_Bar);
   double low = iLow(_Symbol, PERIOD_CURRENT, i_Bar);
   double open = iOpen(_Symbol, PERIOD_CURRENT, i_Bar);
   double close = iClose(_Symbol, PERIOD_CURRENT, i_Bar);

   switch (PrevBarBreakSide(time, high, low))
   {
      case PBBS_TREND_NONE:
         Print("TREND NONE");
         break;
      case PBBS_TREND_UP:
         Print("TREND UP");
         break;
      case PBBS_TREND_DOWN:
         Print("TREND DOWN");
         break;
      default:
         Print("LIKELY TREND: ", (open > close ? "DOWN" : "UP"));
         Print("You should not hope for this calculation, since it considers open and close prices.");
   }
}

//+------------------------------------------------------------------+
//| The breakdown side of the previous bar                           |
//+------------------------------------------------------------------+
int PrevBarBreakSide(const datetime time, const double prevBarHigh, const double prevBarLow)
{
   long timeMs = time * 1000;

   // search in M1
   if (Period() != PERIOD_M1)
   {
      MqlRates rates[];
      int ratesCnt = CopyRates(_Symbol, PERIOD_M1, time, time + PeriodSeconds() - 1, rates);
      if (ratesCnt > 0)
      {
         int i = 0;
         for (; i < ratesCnt; i++)
         {
            if (prevBarHigh < rates[i].high)
            {
               if (prevBarLow > rates[i].low)
               {
                  timeMs = rates[i].time * 1000;
                  break;  // search in ticks
               }
               else
                  return PBBS_TREND_UP;
            }
            else if (prevBarLow > rates[i].low)
               return PBBS_TREND_DOWN;
         }
         if (i >= ratesCnt)
            return PBBS_TREND_NONE;
      }
      else
         return PBBS_TREND_ERROR;
   }

   // search in ticks
   MqlTick ticks[];
   int ticksCnt = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL, timeMs, timeMs + 60000);
   if (ticksCnt < 1)
      return PBBS_TREND_ERROR;
   
   for (int i = 0; i < ticksCnt; i++)
   {
      if (ticks[i].flags != TICK_FLAG_BID || ticks[i].bid < _Point)
         continue;
      if (prevBarHigh < ticks[i].bid)
         return PBBS_TREND_UP;
      else if (prevBarLow > ticks[i].bid)
         return PBBS_TREND_DOWN;
   }
   
   return PBBS_TREND_NONE;
}

//+------------------------------------------------------------------+
