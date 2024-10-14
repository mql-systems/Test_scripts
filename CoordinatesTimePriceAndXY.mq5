//+------------------------------------------------------------------+
//|                                    CoordinatesTimePriceAndXY.mq5 |
//|                            Copyright 2024, Diamond Systems Corp. |
//|                                        https://algotrading.today |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Diamond Systems Corp."
#property link "https://algotrading.today"
#property version "1.00"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=====================");

   int x1, y1, x2, y2, subW;
   double pointPrice;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   datetime bar1 = iTime(NULL, 0, 0);
   datetime bar2 = iTime(NULL, 0, 1);

   ChartTimePriceToXY(0, 0, bar1, ask, x1, y1);
   ChartTimePriceToXY(0, 0, bar2, ask, x2, y2);
   ChartXYToTimePrice(0, x1, (y1+(x1-x2)), subW, bar1, pointPrice);

   Print("x1: ", x1, ", y1: ", y1);
   Print("x2: ", x2, ", y2: ", y2);
   Print("time: ", bar1);
   Print("ask: ", ask);
   Print("pointPrice: ", pointPrice);
}

//+------------------------------------------------------------------+