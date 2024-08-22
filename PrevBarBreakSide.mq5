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

//--- global variables
datetime g_BarTime;
double   g_BarHigh;
double   g_BarLow;
double   g_BarOpen;
double   g_BarClose;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=====================");

   g_BarTime = iTime(_Symbol, PERIOD_CURRENT, i_Bar);
   g_BarHigh = iHigh(_Symbol, PERIOD_CURRENT, i_Bar);
   g_BarLow = iLow(_Symbol, PERIOD_CURRENT, i_Bar);
   g_BarOpen = iOpen(_Symbol, PERIOD_CURRENT, i_Bar);
   g_BarClose = iClose(_Symbol, PERIOD_CURRENT, i_Bar);
   //---
   double prevBarHigh = iHigh(_Symbol, PERIOD_CURRENT, i_Bar + 1);
   double prevBarLow = iLow(_Symbol, PERIOD_CURRENT, i_Bar + 1);

   // checking at the bar level
   if (prevBarHigh < g_BarHigh)
   {
      if (prevBarLow < g_BarLow)
      {
         PrintResult(PBBS_TREND_UP);
         return;
      }
   }
   else if (prevBarLow > g_BarLow)
   {
      PrintResult(PBBS_TREND_DOWN);
      return;
   }
   else
   {
      PrintResult(PBBS_TREND_NONE);
      return;
   }

   // if there is a breakout on both sides, we look for which side broke first
   switch (PrevBarBreakSide(g_BarTime, prevBarHigh, prevBarLow))
   {
      case PBBS_TREND_NONE:
         PrintResult(PBBS_TREND_NONE);
         break;
      case PBBS_TREND_UP:
         PrintResult(PBBS_TREND_UP);
         break;
      case PBBS_TREND_DOWN:
         PrintResult(PBBS_TREND_DOWN);
         break;
      default:
         PrintResult(PBBS_TREND_ERROR);
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

/**
 * Print the result
 * 
 * @param  trend: Argument 1
 */
void PrintResult(PBBS_TREND trend)
{
   long chartId = ChartID();
   string arrowName = "PBBS_Trend";
   double arrowPrice = g_BarHigh + (_Point * 10);

   ObjectDelete(chartId, arrowName);

   switch (trend)
   {
      case PBBS_TREND_NONE:
      {
         Print("TREND NONE");
         ObjectCreate(chartId, arrowName, OBJ_ARROW, 0, g_BarTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_ARROWCODE, 220);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrOrange);
         break;
      }
      case PBBS_TREND_UP:
      {
         Print("TREND UP");
         ObjectCreate(chartId, arrowName, OBJ_ARROW_UP, 0, g_BarTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrGreen);
         break;
      }
      case PBBS_TREND_DOWN:
      {
         Print("TREND DOWN");
         ObjectCreate(chartId, arrowName, OBJ_ARROW_DOWN, 0, g_BarTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrRed);
         break;
      }
      default:
      {
         Print("LIKELY TREND: ", (g_BarOpen > g_BarClose ? "DOWN" : "UP"));
         Print("You should not hope for this calculation, since it considers open and close prices.");

         ObjectCreate(chartId, arrowName, OBJ_ARROW_STOP, 0, g_BarTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrRed);
         break;
      }
   }

   ObjectSetInteger(chartId, arrowName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   ChartRedraw(chartId);
}

//+------------------------------------------------------------------+
