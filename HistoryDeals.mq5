//+------------------------------------------------------------------+
//|                                                 HistoryDeals.mq5 |
//|                            Copyright 2024, Diamond Systems Corp. |
//|                                        https://algotrading.today |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Diamond Systems Corp."
#property link "https://algotrading.today"
#property version "1.00"
#property script_show_inputs

//--- inputs
input datetime i_DealHistoryFrom = __DATETIME__ - 604800;    // Deal History from
input datetime i_DealHistoryTo = __DATETIME__;               // Deal History to

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   if (! HistorySelect(i_DealHistoryFrom, i_DealHistoryTo))
   {
      Print("ERROR: HistorySelect(", i_DealHistoryFrom, ", ", i_DealHistoryTo, "); Code: ", GetLastError());
      return;
   }

   PrintFormat("History deals: %d (from %s to %s)", HistoryDealsTotal(), TimeToString(i_DealHistoryFrom), TimeToString(i_DealHistoryTo));
   
   ulong ticket;
   for (int i = HistoryDealsTotal() - 1; i >= 0; i--)
   {
      ticket = HistoryDealGetTicket(i);
      Print("--- ", i + 1, " ------------");
      Print("Ticket: ", ticket);
      Print("Symbol: ", HistoryDealGetString(ticket, DEAL_SYMBOL));
      Print("Order: ", (long)HistoryDealGetInteger(ticket, DEAL_ORDER));
      Print("Time: ", (datetime)HistoryDealGetInteger(ticket, DEAL_TIME));
      Print("Time MSC: ", (long)HistoryDealGetInteger(ticket, DEAL_TIME_MSC));
      Print("Type: ", EnumToString((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE)));
      Print("Entry: ", EnumToString((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY)));
      Print("Volume: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_VOLUME)));
      Print("Price: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_PRICE)));
      Print("Commission: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_COMMISSION)));
      Print("Swap: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_SWAP)));
      Print("Profit: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_PROFIT)));
      Print("Fee: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_FEE)));
      Print("SL: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_SL)));
      Print("TP: ", DoubleToString(HistoryDealGetDouble(ticket, DEAL_TP)));
      Print("Magic: ", (long)HistoryDealGetInteger(ticket, DEAL_MAGIC));
      Print("Reason: ", EnumToString((ENUM_DEAL_REASON)HistoryDealGetInteger(ticket, DEAL_REASON)));
      Print("Position ID: ", (long)HistoryDealGetInteger(ticket, DEAL_POSITION_ID));
      Print("Comment: ", HistoryDealGetString(ticket, DEAL_COMMENT));
      Print("External ID: ", HistoryDealGetString(ticket, DEAL_EXTERNAL_ID));
   }
   
   Print("------------------");
}

//+------------------------------------------------------------------+