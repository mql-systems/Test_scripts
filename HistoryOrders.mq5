//+------------------------------------------------------------------+
//|                                                HistoryOrders.mq5 |
//|                            Copyright 2024, Diamond Systems Corp. |
//|                                        https://algotrading.today |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Diamond Systems Corp."
#property link "https://algotrading.today"
#property version "1.00"
#property script_show_inputs

//--- inputs
input datetime i_OrderHistoryFrom = __DATETIME__ - 604800;    // Order History from
input datetime i_OrderHistoryTo = __DATETIME__;               // Order History to

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   if (! HistorySelect(i_OrderHistoryFrom, i_OrderHistoryTo))
   {
      Print("ERROR: HistorySelect(", i_OrderHistoryFrom, ", ", i_OrderHistoryTo, "); Code: ", GetLastError());
      return;
   }

   PrintFormat("History orders %d (from %s to %s)", HistoryOrdersTotal(), TimeToString(i_OrderHistoryFrom), TimeToString(i_OrderHistoryTo));
   
   ulong ticket;
   for (int i = HistoryOrdersTotal() - 1; i >= 0; i--)
   {
      ticket = HistoryOrderGetTicket(i);
      Print("--- ", i + 1, " ------------");
      Print("Ticket: ", ticket);
      Print("Symbol: ", HistoryOrderGetString(ticket, ORDER_SYMBOL));
      Print("Time Setup: ", (datetime)HistoryOrderGetInteger(ticket, ORDER_TIME_SETUP));
      Print("Type: ", EnumToString((ENUM_ORDER_TYPE)HistoryOrderGetInteger(ticket, ORDER_TYPE)));
      Print("State: ", EnumToString((ENUM_ORDER_STATE)HistoryOrderGetInteger(ticket, ORDER_STATE)));
      Print("Time Expiration: ", (datetime)HistoryOrderGetInteger(ticket, ORDER_TIME_EXPIRATION));
      Print("Time Done: ", (datetime)HistoryOrderGetInteger(ticket, ORDER_TIME_DONE));
      Print("Time Setup MSC: ", (long)HistoryOrderGetInteger(ticket, ORDER_TIME_SETUP_MSC));
      Print("Time Done MSC: ", (long)HistoryOrderGetInteger(ticket, ORDER_TIME_DONE_MSC));
      Print("Type Filling: ", EnumToString((ENUM_ORDER_TYPE_FILLING)HistoryOrderGetInteger(ticket, ORDER_TYPE_FILLING)));
      Print("Type Time: ", EnumToString((ENUM_ORDER_TYPE_TIME)HistoryOrderGetInteger(ticket, ORDER_TYPE_TIME)));
      Print("Volume Initial: ", DoubleToString(HistoryOrderGetDouble(ticket, ORDER_VOLUME_INITIAL)));
      Print("Volume Current: ", DoubleToString(HistoryOrderGetDouble(ticket, ORDER_VOLUME_CURRENT)));
      Print("Price Open: ", DoubleToString(HistoryOrderGetDouble(ticket, ORDER_PRICE_OPEN)));
      Print("SL: ", DoubleToString(HistoryOrderGetDouble(ticket, ORDER_SL)));
      Print("TP: ", DoubleToString(HistoryOrderGetDouble(ticket, ORDER_TP)));
      Print("Price Current: ", DoubleToString(HistoryOrderGetDouble(ticket, ORDER_PRICE_CURRENT)));
      Print("Price StopLimit: ", DoubleToString(HistoryOrderGetDouble(ticket, ORDER_PRICE_STOPLIMIT)));
      Print("Magic: ", (long)HistoryOrderGetInteger(ticket, ORDER_MAGIC));
      Print("Reason: ", EnumToString((ENUM_ORDER_REASON)HistoryOrderGetInteger(ticket, ORDER_REASON)));
      Print("Position ID: ", (long)HistoryOrderGetInteger(ticket, ORDER_POSITION_ID));
      Print("Position By ID: ", (long)HistoryOrderGetInteger(ticket, ORDER_POSITION_BY_ID));
      Print("Comment: ", HistoryOrderGetString(ticket, ORDER_COMMENT));
      Print("External ID: ", HistoryOrderGetString(ticket, ORDER_EXTERNAL_ID));
   }
   
   Print("------------------");
}

//+------------------------------------------------------------------+