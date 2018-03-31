//+------------------------------------------------------------------+
//|                                                    TradeUtil.mqh |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

#include "ClUtil.mqh"
#include "OrderInfo.mqh"

#define MAX_ORDER_COUNT 20

int gBuyOrdersCount = 0;
COrderInfo buyOrders[MAX_ORDER_COUNT];
datetime  gLastBuyOrderTime = 0;
double gBuyTotalLots = 0;

// Sell orders data
int gSellOrdersCount = 0;
COrderInfo sellOrders[MAX_ORDER_COUNT];
datetime  gLastSellOrderTime = 0;
double gSellTotalLots = 0;

int QueryCurrentOrders(int orderType)
{
   int nOrdersCnt = 0;
   
   if(orderType == OP_BUY)
   {
       CleanBuyOrdersCache(); 
   }
   
   if(orderType == OP_SELL)
   {
      CleanSellOrdersCache(); 
   }
   
    
   int nOrdersTotalCnt = OrdersTotal();
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == gSymbol 
            && OrderMagicNumber() == MagicNumber
            && OrderType() == orderType)
         {
            switch(orderType)
            {
            case OP_BUY: 
               buyOrders[gBuyOrdersCount].m_Ticket = OrderTicket(); 
               buyOrders[gBuyOrdersCount].m_Prices = OrderClosePrice();
               buyOrders[gBuyOrdersCount].m_Lots = OrderLots();
               buyOrders[gBuyOrdersCount].m_Comment = OrderComment();
               buyOrders[gBuyOrdersCount].m_OrderType = orderType;
               buyOrders[gBuyOrdersCount].m_TradeTime = OrderOpenTime();
               if(gLastBuyOrderTime < OrderOpenTime())
               {
                  gLastBuyOrderTime = OrderOpenTime();
               }
               gBuyTotalLots += OrderLots();
               gBuyOrdersCount++;
               nOrdersCnt++;
               break;
            case OP_SELL:
               sellOrders[gSellOrdersCount].m_Ticket = OrderTicket();
               sellOrders[gSellOrdersCount].m_Prices = OrderClosePrice();
               sellOrders[gSellOrdersCount].m_Lots = OrderLots();
               sellOrders[gSellOrdersCount].m_Comment = OrderComment();
               sellOrders[gSellOrdersCount].m_OrderType = orderType;
               sellOrders[gSellOrdersCount].m_TradeTime = OrderOpenTime();
               if(gLastSellOrderTime < OrderOpenTime())
               {
                  gLastSellOrderTime = OrderOpenTime();
               }
               gSellTotalLots += OrderLots();
               gSellOrdersCount++;
               nOrdersCnt++;
               break;             
            }
         }
      }
   }
   return nOrdersCnt;
}

void CleanBuyOrdersCache() 
{
   int i = 0;
   for(i = 0; i < gBuyOrdersCount; i++)
   {
      buyOrders[i].clear();
   }
   gBuyOrdersCount = 0;
   gLastBuyOrderTime = 0;
   gBuyTotalLots = 0;
}

void CleanSellOrdersCache() 
{
   int i = 0;
   for(i = 0; i < gSellOrdersCount; i++)
   {
      sellOrders[i].clear();
   }
   gSellOrdersCount = 0;
   gLastSellOrderTime = 0;
   gSellTotalLots = 0;
}

void CleanOrdersCache() 
{
   CleanBuyOrdersCache(); 
   CleanSellOrdersCache();
}
