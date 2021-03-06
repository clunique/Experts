//+------------------------------------------------------------------+
//|                                                    OrderUtil.mqh |
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
#include "../Pub/OrderInfo.mqh"
#include "../Pub/ClUtil.mqh"

#define MAX_ORDER_COUNT 20

input int BuyMagic = 100000;
input int SellMagic = 200000;

int gBuyOrdersCount = 0;
COrderInfo buyOrders[MAX_ORDER_COUNT];
datetime  gLastBuyOrderTime = 0;
double gBuyTotalLots = 0;

// Sell orders data
int gSellOrdersCount = 0;
COrderInfo sellOrders[MAX_ORDER_COUNT];
datetime  gLastSellOrderTime = 0;
double gSellTotalLots = 0;

int QueryCurrentOrders(string symbol, int orderType)
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
   
   int nBuyMagic = BuyMagic + TimeFrame;
   int nSellMagic = SellMagic + TimeFrame;
   int nOrdersTotalCnt = OrdersTotal();
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == symbol 
            && (OrderMagicNumber() == nBuyMagic || OrderMagicNumber() == nSellMagic)
            && OrderType() == orderType)
         {
            switch(orderType)
            {
            case OP_BUY: 
               buyOrders[gBuyOrdersCount].m_Symbol = symbol;
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
               sellOrders[gSellOrdersCount].m_Symbol = symbol;
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

int OpenOrder(string symbol, int orderType, string comment, double dLots)
{
   int ret = 0;
   string logMsg;
   
   logMsg = StringFormat("%s => Symbol = %s, orderType = %d, comment = %s, Lots = %s ",
                               __FUNCTION__, symbol, orderType,
                               comment, DoubleToString(dLots, 2));
   LogInfo(logMsg);
   
   logMsg = StringFormat("%s => BuyOrdersCount = %d, LastBuyOrderTime = %s, BuyTotalLots = %s, SellOrdersCount = %d, LastSellOrderTime = %d, SellTotalLots = %s ",
                               __FUNCTION__, gBuyOrdersCount, TimeToString(gLastBuyOrderTime, TIME_SECONDS), DoubleToString(gBuyTotalLots, 2),
                               gSellOrdersCount, TimeToString(gLastSellOrderTime, TIME_SECONDS), DoubleToString(gSellTotalLots, 2));
   LogInfo(logMsg);
   
   double accMargin = AccountMargin();
   double freeMargin = AccountFreeMargin();
   
   if(CheckFreeMargin && accMargin / freeMargin > 0.3) {
        logMsg = StringFormat("%s => Free margin not enouth: margin = %s, free margin = %s.",
                        __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(freeMargin,3));
        LogWarn(logMsg); 
        return -1; 
   }
   
   int nBuyMagic = BuyMagic + TimeFrame;
   int nSellMagic = SellMagic + TimeFrame;
   datetime now = iTime(symbol, TimeFrame, 0);
   RefreshRates();
    
   switch(orderType)
   {
   case OP_BUY:
      if(gBuyOrdersCount < OrderMax 
            && now > gLastBuyOrderTime + TimeFrame * AppendOrderInterval * 60
            && gBuyTotalLots <= MaxHoldingLots)
      {
         // Open buy order
         double lots = dLots;
         while(true)
         {
            RefreshRates();
            double fAskPrice = MarketInfo(symbol, MODE_ASK);
            int ticket = OrderSend(symbol, OP_BUY, lots, fAskPrice, 3, 0, 0, comment, nBuyMagic, 0, clrRed); 
            if(ticket > 0)
            {
               logMsg = StringFormat("%s => Open buy order: Symbol = %s, Price = %s, Lots = %s",
                               __FUNCTION__, symbol, 
                               DoubleToString(fAskPrice, 4), DoubleToString(lots, 2));
               LogInfo(logMsg);
               break;
            }else 
            { 
               int nErr = GetLastError(); 
               logMsg = StringFormat("%s => Open buy order Error: %d.", __FUNCTION__, nErr);
               LogInfo(logMsg);
               if(IsFatalError(nErr))
               {  
                  ret = nErr;
                  break;
               } 
            }
         }
         
      }
      break;
   case OP_SELL:
      if(gSellOrdersCount < OrderMax 
            && now > gLastSellOrderTime + TimeFrame * AppendOrderInterval * 60
            && gSellTotalLots <= MaxHoldingLots)
      {
         // Open sell order
         double lots = dLots;
         while(true)
         {
            RefreshRates();
            double fBidPrice = MarketInfo(symbol, MODE_BID);
            int ticket = OrderSend(symbol, OP_SELL, lots, fBidPrice, 3, 0, 0, comment, nSellMagic, 0, clrGreen); 
            if(ticket > 0) 
            {
                logMsg = StringFormat("%s => Open sell order: Symbol = %s, Price = %s, Lots = %s",
                               __FUNCTION__, symbol, 
                               DoubleToString(fBidPrice, 4), DoubleToString(lots, 2));
                LogInfo(logMsg);
                break;
            }else
            { 
               int nErr = GetLastError(); 
               logMsg = StringFormat("%s => Open sell order Error: %d.", __FUNCTION__, nErr);
               LogInfo(logMsg);
               if(IsFatalError(nErr))
               {  
                  ret = nErr;
                  break;
               } 
            } 
         }
         
      }
      break;
   }
   return ret;
}

int CloseOrders(int orderType)
{
   int ret = 0;
   string logMsg;
   if(orderType == OP_BUY)
   {
      for(int i = 0; i < gBuyOrdersCount;i++)
      {
         double lots = buyOrders[i].m_Lots;
         int ticket = buyOrders[i].m_Ticket;
         string symbol = buyOrders[i].m_Symbol;
         if(ticket > 0)
         {
            while(true)
            {
               RefreshRates();
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                           + ", type = OP_BUY"
                           + ", price = " + DoubleToString(fBidPrice, 4) 
                           + ", lots = " + DoubleToString(lots, 2);
               LogInfo(logMsg);
               if(OrderClose(ticket, lots, fBidPrice, 3, clrRed))
               {                 
                  break;
            
               } else
               {
                  int nErr = GetLastError(); // 平仓失败 :( 
                  logMsg = StringFormat("%s => Close buy order Error: %d, ticket = %d.",
                            __FUNCTION__, nErr, ticket);
                  LogInfo(logMsg);
                  if(IsFatalError(nErr))
                  {  
                     ret = nErr;
                     break;
                  }                   
              }
            }  
         }
       }  
   }
   
   if(orderType == OP_SELL)
   {
      for(int i = 0; i < gSellOrdersCount; i++)
      {
         double lots = sellOrders[i].m_Lots;
         int ticket = sellOrders[i].m_Ticket;
         string symbol = sellOrders[i].m_Symbol;
         if(ticket > 0)
         {
            while(true)
            {
               RefreshRates();
               double fAskPrice = MarketInfo(symbol, MODE_ASK);
               logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                           + ", type = OP_SELL"
                           + ", price = " + DoubleToString(fAskPrice, 4) 
                           + ", lots = " + DoubleToString(lots, 2);
               LogInfo(logMsg);
               if(OrderClose(ticket, lots, fAskPrice, 3, clrGreen))
               {
                  break;
               } else
               {
                  int nErr = GetLastError(); // 平仓失败 :( 
                  logMsg = StringFormat("%s => Close sell order Error: %d, ticket = %d, price = %s.", 
                           __FUNCTION__, nErr, ticket, DoubleToString(fAskPrice, 4));
                  LogInfo(logMsg);
                  if(IsFatalError(nErr))
                  {  
                     ret = nErr;
                     break;
                  }                   
              }
            }            
         }
      }
   }
   return ret;
}

double CalcTotalProfits(const string comment,
                        const string& symbol [], bool bOutput)
{
   double fTotalProfits = 0;
   double fProfits[];
   string logMsg;
   int nBuyMagic = BuyMagic + TimeFrame;
   int nSellMagic = SellMagic + TimeFrame;
   int symbolCnt = ArraySize(symbol);
   int nOrdersTotalCnt = OrdersTotal();
   ArrayResize(fProfits, symbolCnt);
   ArrayInitialize(fProfits, 0);
   
   RefreshRates();
   for(int j = 0; j < symbolCnt; j++)
   {
      fProfits[j] = 0;
      for(int i = 0; i < nOrdersTotalCnt; i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol() == symbol[j]
              && (OrderMagicNumber() == nBuyMagic || OrderMagicNumber() == nSellMagic)
              && (comment == "" || OrderComment() == comment)
               )
            {
               int nTicket = OrderTicket(); 
               double fPrice = OrderOpenPrice();
               double fLots = OrderLots();
               string strComment = OrderComment();
               int nOrderType = OrderType();
               datetime dtOpentime = OrderOpenTime();
               double fProfit = OrderProfit();
               if(nOrderType == OP_BUY || nOrderType == OP_SELL)
               {
                  if(bOutput) 
                  {
                     logMsg = StringFormat("订单[#%d]: 开单时间：%s, 开单价格：%s，手数：%s，类型：%s，获利：%s",
                                 nTicket, TimeToString(dtOpentime, TIME_SECONDS),
                                 DoubleToString(fPrice, 5), DoubleToString(fLots, 2), 
                                 OpName[nOrderType], DoubleToString(fProfit, 3));
                     LogInfo(logMsg); 
                   } 
                   fProfits[j] += fProfit;    
               
               }
             }
          }          
      }
      
      if(bOutput) 
      {
         logMsg = StringFormat("品种 -- %s: 获利：%s",
                               symbol[j], DoubleToString(fProfits[j], 3));
         LogInfo(logMsg);
      } 
      
      fTotalProfits += fProfits[j];
   }
   if(bOutput) 
   {
      logMsg = StringFormat("总获利：%s",DoubleToString(fTotalProfits, 3));
      LogInfo(logMsg);
   } 
   return fTotalProfits;
}