//+------------------------------------------------------------------+
//|                                                 BuffersPrint.mq5 |
//|                            Copyright 2024, Diamond Systems Corp. |
//|                                        https://algotrading.today |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Diamond Systems Corp."
#property link "https://algotrading.today"
#property version "1.00"
#property script_show_inputs

input string i_IndicatorName = "AT/Tests/Buffers";    // Indicator name
input int    i_BufferCnt = 10;                        // Buffers count
input int    i_BufferStartPos = 0;                    // Copy "Start position"
input int    i_BufferCount = 10;                      // Copy "Count"

//--- global variables
int g_handleCustom;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   g_handleCustom = iCustom(NULL, 0, i_IndicatorName);

   for (int i = 0; i < i_BufferCnt; i++)
      PrintBuffer(i);
}

//+------------------------------------------------------------------+
//| Print buffer                                                     |
//+------------------------------------------------------------------+
void PrintBuffer(int bufferNum)
{
   double buffer[];
   int copyCnt = CopyBuffer(g_handleCustom, bufferNum, i_BufferStartPos, i_BufferCount, buffer);

   PrintFormat("======================== Buffer %d =========================", bufferNum);
   for (int i = 0; i < copyCnt; i++)
      PrintFormat("[%d] %.5f", i + i_BufferStartPos, buffer[i]);
}

//+------------------------------------------------------------------+