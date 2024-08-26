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
input uint i_Bar = 0; // Bar index (0=BarOnDropped)

//--- global variables
datetime g_barTime;
double   g_barHigh;
double   g_barLow;
double   g_barOpen;
double   g_barClose;
string   g_printStr = "";
ulong    g_startMsecCount;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   AddPrint("=====================");

   g_startMsecCount = GetMicrosecondCount();
   
   int bar = 0;
   if (i_Bar == 0)
   {
      datetime timeOnDropped = ChartTimeOnDropped();
      if (timeOnDropped > 0)
      {
         bar = iBarShift(NULL, 0, timeOnDropped, true);
         if (bar > 0)
            bar--;
         else
            bar = 0;
      }
   }
   else
      bar = (int)i_Bar;

   g_barTime = iTime(NULL, 0, bar);
   g_barHigh = iHigh(NULL, 0, bar);
   g_barLow = iLow(NULL, 0, bar);
   g_barOpen = iOpen(NULL, 0, bar);
   g_barClose = iClose(NULL, 0, bar);
   
   double prevBarHigh = iHigh(NULL, 0, bar + 1);
   double prevBarLow = iLow(NULL, 0, bar + 1);
   
   AddPrint("Bar time: " + TimeToString(g_barTime));
   AddPrint("Bar index: " + IntegerToString(bar));

   // checking at the bar level
   if (prevBarHigh < g_barHigh)
   {
      if (prevBarLow < g_barLow)
      {
         PrintResult(PBBS_TREND_UP);
         return;
      }
   }
   else if (prevBarLow > g_barLow)
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
   switch (PrevBarBreakSide(g_barTime, prevBarHigh, prevBarLow))
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

/**
 * Saves the line for further printing
 * @param  addStr: Print string
 */
void AddPrint(string addStr)
{
   g_printStr += addStr + "\n";
}

//+------------------------------------------------------------------+
//| The breakdown side of the previous bar                           |
//+------------------------------------------------------------------+
PBBS_TREND PrevBarBreakSide(const datetime time, const double prevBarHigh, const double prevBarLow)
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
         for (; i < ratesCnt && ! IsStopped(); i++)
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

   for (int i = 0; i < ticksCnt && ! IsStopped(); i++)
   {
      if ((ticks[i].flags & TICK_FLAG_BID) != TICK_FLAG_BID || ticks[i].bid < _Point)
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
 * @param  trend: PBBS_TREND type
 */
void PrintResult(PBBS_TREND trend)
{
   AddPrint("Calc msec: " + IntegerToString(GetMicrosecondCount() - g_startMsecCount));

   long chartId = ChartID();
   string arrowName = "PBBS_Trend";
   double arrowPrice = g_barHigh + (_Point * 10);

   ObjectDelete(chartId, arrowName);

   switch (trend)
   {
      case PBBS_TREND_NONE:
      {
         AddPrint("Trend: NONE");
         ObjectCreate(chartId, arrowName, OBJ_ARROW, 0, g_barTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_ARROWCODE, 220);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrOrange);
         break;
      }
      case PBBS_TREND_UP:
      {
         AddPrint("Trend: UP");
         ObjectCreate(chartId, arrowName, OBJ_ARROW_UP, 0, g_barTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrGreen);
         break;
      }
      case PBBS_TREND_DOWN:
      {
         AddPrint("Trend: DOWN");
         ObjectCreate(chartId, arrowName, OBJ_ARROW_DOWN, 0, g_barTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrRed);
         break;
      }
      default:
      {
         AddPrint("LIKELY TREND: "+ (g_barOpen > g_barClose ? "DOWN" : "UP"));
         AddPrint("You should not hope for this calculation, since it considers open and close prices.");

         ObjectCreate(chartId, arrowName, OBJ_ARROW_STOP, 0, g_barTime, arrowPrice);
         ObjectSetInteger(chartId, arrowName, OBJPROP_COLOR, clrRed);
         break;
      }
   }

   Print(g_printStr);
   Comment(g_printStr);

   ObjectSetInteger(chartId, arrowName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   ChartRedraw(chartId);
}

//+------------------------------------------------------------------+
