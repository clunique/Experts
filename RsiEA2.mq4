//+------------------------------------------------------------------+
//|                                                        RsiEA.mq4 |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ClUtil.mqh"
#include "OrderInfo.mqh"

#define MAX_ORDER_COUNT 20
#define DEFAULT_OPEN_LOW 31
#define DEFAULT_OPEN_HIGH 69
#define DEFAULT_CLOSE_LOW 31
#define DEFAULT_CLOSE_HIGH 69

#define DEFAULT_RSI_PERIOD 5

//input parameters
input int TimeFrame = PERIOD_M5;
input bool HeartBeat = false;
input bool MonitorCheckForOpen = false;
input bool MonitorCheckForClose = false;
input bool MonitorTrend = false;
input double BaseOpenLots = 0.01;
input double Overweight_Multiple = 2.0;
input double MaxHoldingLots = 0.31;
input int OrderMax = 5;
input int BollDiff = 5;
input int MagicNumber = 5768;
input int BollPeriod = 20;


string gSymbol;
int gTickCount = 0;
bool bNewBar = false;
datetime gCurrentBarTime = 0;
int gPreTrend = 0;


int RSI_Period = DEFAULT_RSI_PERIOD;
int RSI_LowForOpen = DEFAULT_OPEN_LOW;
int RSI_HighForOpen = DEFAULT_OPEN_HIGH;
int RSI_LowForClose = DEFAULT_CLOSE_HIGH;
int RSI_HighForClose = DEFAULT_CLOSE_HIGH;

enum { FLUCTUATION = 0, TREND_UP = 1, TREND_GREAT_UP = 2, TREND_DOWN = 3, TREND_GREAT_DOWN = 4};
string TrendName[] = 
{  
   "FLUCTUATION", 
   "TREND_UP", 
   "TREND_GREAT_UP",   
   "TREND_DOWN", 
   "TREND_GREAT_DOWN"  
};


int gBuyOrdersCount = 0;
COrderInfo buyOrders[MAX_ORDER_COUNT];
datetime  gLastBuyOrderTime = 0;
double gBuyTotalLots = 0;

// Sell orders data
int gSellOrdersCount = 0;
COrderInfo sellOrders[MAX_ORDER_COUNT];
datetime  gLastSellOrderTime = 0;
double gSellTotalLots = 0;

int CheckTrend()
{
   int trend = FLUCTUATION;
   string logMsg;
   double Boll_Main_0 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
   double Boll_Main_1 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
   double Boll_Main_2 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, 2);
   
   double Boll_Upper_0 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double Boll_Upper_1 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double Boll_Upper_2 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 2);
   
   double Boll_Lower_0 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double Boll_Lower_1 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double Boll_Lower_2 = iBands(gSymbol, TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 2);
   
   if(MonitorTrend)
   {
      logMsg = StringFormat("%s => Main2 = %s, Main1 = %s, Main0 = %s, Boll_Main_2 - Boll_Main_1 = %s",
                                    __FUNCTION__ ,
                                    DoubleToString(Boll_Main_2),
                                    DoubleToString(Boll_Main_1), 
                                    DoubleToString(Boll_Main_0),
                                    DoubleToString((Boll_Main_2 - Boll_Main_1) / Point));
      LogInfo(logMsg);
   }
   
   if(Boll_Main_1 >= Boll_Main_2)
   {
      trend = TREND_UP;
      if((Boll_Main_1 - Boll_Main_2) / Point > BollDiff)
      {
         trend = TREND_GREAT_UP;
      } 
   }
   
   if(Boll_Main_1 < Boll_Main_2)
   {
      trend = TREND_DOWN;
      if((Boll_Main_2 - Boll_Main_1) / Point > BollDiff)
      {
         trend = TREND_GREAT_DOWN;
      }
   }
   logMsg = StringFormat("Trend: %s.", TrendName[trend]);
   // LogDebug(logMsg);
   return trend;                  
}


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

int CheckForOpenRSI(int nPreTrend, int nTrend)
{
   int nDirect = -1;
   string logMsg;
   
   if(MonitorCheckForClose)
   {
      logMsg = StringFormat(" %s => PreTrend = %s, Trend = %s", 
                  __FUNCTION__,
                  TrendName[nPreTrend], TrendName[nTrend]);
      LogInfo(logMsg);
   }
   int nPeriod = RSI_Period;
   
   /******************************************************************* 
   if(nPreTrend != nTrend && nTrend == TREND_GREAT_DOWN)
   {
      nDirect = OP_SELL;
      if(MonitorCheckForClose)
      {
         logMsg = StringFormat(" %s => PreTrend = %s, Trend = %s, Direct = %d", 
                     __FUNCTION__,
                     TrendName[nPreTrend], TrendName[nTrend], nDirect);
         LogInfo(logMsg);
      }
      return nDirect;
   }
   
   if(nPreTrend != nTrend && nTrend == TREND_GREAT_UP)
   {
      nDirect = OP_BUY;
      if(MonitorCheckForClose)
      {
         logMsg = StringFormat(" %s => PreTrend = %s, Trend = %s, Direct = %d", 
                     __FUNCTION__,
                     TrendName[nPreTrend], TrendName[nTrend], nDirect);
         LogInfo(logMsg);
      }      
      return nDirect;
   }
   ***************************************************************************/ 
   
   double iRsi2 = iRSI(gSymbol, TimeFrame, nPeriod,PRICE_CLOSE,2);
   double iRsi1 = iRSI(gSymbol, TimeFrame, nPeriod,PRICE_CLOSE,1);
   double iRsi0 = iRSI(gSymbol, TimeFrame, nPeriod,PRICE_CLOSE,0);
   
   if(MonitorCheckForOpen)
   {
      logMsg = StringFormat(" %s => nPeriod = %d,  iRsi2 = %s, iRsi1 = %s, iRsi0 = %s", 
                  __FUNCTION__, nPeriod, 
                  DoubleToString(iRsi2, 3), 
                  DoubleToString(iRsi1, 3),
                  DoubleToString(iRsi0, 3));
      LogInfo(logMsg);
   }
   
   if(iRsi1 <= RSI_LowForOpen)
   {
      if(iRsi0 > iRsi1)
      {
         nDirect = OP_BUY;
         logMsg = __FUNCTION__ + ": Direction = OP_BUY, iRsi2 = " 
                     + DoubleToString(iRsi2, 3) 
                     + ", iRsi1 = " + DoubleToString(iRsi1, 3)
                     + ", iRsi0 = " + DoubleToString(iRsi0, 3);
         //LogInfo(logMsg);
      }
   }
   
   if(iRsi1 >= RSI_HighForOpen)
   {
      if(iRsi0 < iRsi1)
      {
         nDirect = OP_SELL;
         logMsg = __FUNCTION__ + ": Direction = OP_SELL, iRsi2 = " 
                     + DoubleToString(iRsi2, 3) 
                     + ", iRsi1 = " + DoubleToString(iRsi1, 3)
                     + ", iRsi0 = " + DoubleToString(iRsi0, 3);
         //LogInfo(logMsg);
      }
   }
   
   
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;
}


int CheckForCloseRSI(int nPreTrend, int nTrend)
{
   int nDirect = -1;
   string logMsg;
   
    /******************************************************************* 
   if(nPreTrend != nTrend && nTrend == TREND_GREAT_DOWN)
   {
      nDirect = OP_BUY;
      if(MonitorCheckForClose)
      {
         logMsg = StringFormat(" %s => PreTrend = %s, Trend = %s, Direct = %d", 
                     __FUNCTION__,
                     TrendName[nPreTrend], TrendName[nTrend], nDirect);
         LogInfo(logMsg);
      }
      return nDirect;
   }
   
   if(nPreTrend != nTrend && nTrend == TREND_GREAT_UP)
   {
      nDirect = OP_SELL;
      if(MonitorCheckForClose)
      {
         logMsg = StringFormat(" %s => PreTrend = %s, Trend = %s, Direct = %d", 
                     __FUNCTION__,
                     TrendName[nPreTrend], TrendName[nTrend], nDirect);
         LogInfo(logMsg);
      }      
      return nDirect;
   }
   *******************************************************************/
   
   int nPeriod = RSI_Period;
   double iRsi2 = iRSI(gSymbol, TimeFrame, nPeriod,PRICE_CLOSE,2);
   double iRsi1 = iRSI(gSymbol, TimeFrame, nPeriod,PRICE_CLOSE,1);
   double iRsi0 = iRSI(gSymbol, TimeFrame, nPeriod,PRICE_CLOSE,0);
   
   if(MonitorCheckForClose)
   {
      logMsg = StringFormat(" %s => nPeriod = %d, LowLimit = %s, HighLimit = %s, RSI_2 = %s, RSI_1 = %s, RSI_0 = %s", 
                  __FUNCTION__, nPeriod,
                  DoubleToString(RSI_LowForOpen + gSellOrdersCount, 3),
                  DoubleToString(RSI_HighForOpen - gBuyOrdersCount, 3), 
                  DoubleToString(iRsi2, 3), 
                  DoubleToString(iRsi1, 3),
                  DoubleToString(iRsi0, 3));
      LogInfo(logMsg);
   }   
   
   if(iRsi1 <= RSI_LowForOpen + gSellOrdersCount)
   {
      if(iRsi0 > iRsi1)
      {
         nDirect = OP_SELL;
         logMsg = __FUNCTION__ + ": Direction = OP_SELL, iRsi2 = " 
                  + DoubleToString(iRsi2, 3) + ", iRsi1 = " 
                  + DoubleToString(iRsi1, 3);
         //LogInfo(logMsg);
      }
   }
   
   if(iRsi1 >= RSI_HighForOpen - gBuyOrdersCount)
   {
      if(iRsi0 < iRsi1)
      {
         nDirect = OP_BUY;
         logMsg = __FUNCTION__ + ": Direction = OP_BUY, iRsi2 = " 
                     + DoubleToString(iRsi2, 3) 
                     + ", iRsi1 = " + DoubleToString(iRsi1, 3)
                     + ", iRsi0 = " + DoubleToString(iRsi0, 3);
         //LogInfo(logMsg);
      }
   }
    
    
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;
}

int OpenOrder(int orderType)
{
   int ret = 0;
   
   double accMargin = AccountMargin();
   double freeMargin = AccountFreeMargin();
   
   if(accMargin / freeMargin > 0.5) {
        string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, free margin = %s.",
                        __FUNCTION__, DoubleToString(accMargin), DoubleToString(freeMargin));
        LogWarn(logMsg); 
        return -1; 
   }
   
   datetime now = iTime(gSymbol, TimeFrame, 0);
   RefreshRates();
   switch(orderType)
   {
   case OP_BUY:
      if(gBuyOrdersCount < OrderMax 
            && now > gLastBuyOrderTime
            && gBuyTotalLots <= MaxHoldingLots)
      {
         // Open buy order
         double lots = BaseOpenLots;
         if(gBuyOrdersCount > 0)
         {
            lots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, gBuyOrdersCount), 2);
         }
         int ticket = OrderSend(gSymbol, OP_BUY, lots, Ask, 3, 0, 0, "SimpleEA order", MagicNumber, 0, clrGreenYellow); 
         if(ticket < 0) 
         { 
            ret = GetLastError(); 
            string logMsg = StringFormat("%s(%d) => Error: %d.", __FUNCTION__, __LINE__, ret);
            LogInfo(logMsg);
         } else 
         {
            string logMsg = __FUNCTION__ + ": type = OP_BUY"
                        + ", price = " + DoubleToString(Ask) 
                        + ", lots = " + DoubleToString(lots);
            LogInfo(logMsg);
         } 
      }
      break;
   case OP_SELL:
      if(gSellOrdersCount < OrderMax 
            && now > gLastSellOrderTime
            && gSellTotalLots <= MaxHoldingLots)
      {
         // Open sell order
         double lots = BaseOpenLots;
         if(gSellOrdersCount > 0)
         {
            lots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, gSellOrdersCount), 2);
         }
         int ticket = OrderSend(gSymbol, OP_SELL, lots, Bid, 3, 0, 0, "SimpleEA order", MagicNumber, 0, clrRed); 
         if(ticket < 0) 
         { 
            ret = GetLastError();
            string logMsg = StringFormat("%s(%d) => Error: %d.", __FUNCTION__, __LINE__, ret);
            LogInfo(logMsg);
         } else 
         {
             string logMsg = __FUNCTION__ + ": type = OP_SELL"
                        + ", price = " + DoubleToString(Bid) 
                        + ", lots = " + DoubleToString(lots);
             LogInfo(logMsg);
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
      for(int i = 0; i < gBuyOrdersCount;i ++)
      {
         double lots = buyOrders[i].m_Lots;
         int ticket = buyOrders[i].m_Ticket;
         if(ticket > 0)
         {
            while(true)
            {
               RefreshRates();
               if(OrderClose(ticket, lots, Bid, 3, clrGainsboro))
               {
                  logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                           + ", type = OP_BUY"
                           + ", price = " + DoubleToString(Bid) 
                           + ", lots = " + DoubleToString(lots);
                  LogInfo(logMsg);
            
               } else
               {
                  int Error = GetLastError(); // 平仓失败 :( 
                  logMsg = StringFormat("%s => Close buy order Error: %d.", __FUNCTION__, Error);
                  LogInfo(logMsg);
                  if(IsFatalError(Error))
                  {  
                     break;
                  }                   
              }
            }  
         }
       }  
   }
   
   if(orderType == OP_SELL)
   {
      for(int i = 0; i < gSellOrdersCount;i ++)
      {
         double lots = sellOrders[i].m_Lots;
         int ticket = sellOrders[i].m_Ticket;
         if(ticket > 0)
         {
            while(true)
            {
               RefreshRates();
               if(OrderClose(ticket, lots, Ask, 3, clrRed))
               {
                  logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                           + ", type = OP_BUY"
                           + ", price = " + DoubleToString(Ask) 
                           + ", lots = " + DoubleToString(lots);
                  LogInfo(logMsg);
            
               } else
               {
                  int Error = GetLastError(); // 平仓失败 :( 
                  logMsg = StringFormat("%s => Close buy order Error: %d.", __FUNCTION__, Error);
                  LogInfo(logMsg);
                  if(IsFatalError(Error))
                  {  
                     break;
                  }                   
              }
            }            
         }
      }
   }
   return ret;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   gSymbol = Symbol();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   gTickCount++;
   
   datetime now = iTime(gSymbol, TimeFrame, 0);
   if(now > gCurrentBarTime)
   {
      bNewBar = true;
      gCurrentBarTime = now;     
   }else 
   {
      bNewBar = false;
   }
   string logMsg = ""; 
   
   if(HeartBeat)
   {
      logMsg = "OnTick start: tick count: " + IntegerToString(gTickCount);
      LogInfo(logMsg);
   }
   
   // 1. orders accounting
   int buyOrdersCnt = QueryCurrentOrders(OP_BUY);
   int sellOrdersCnt = QueryCurrentOrders(OP_SELL);
   
   int nTrend = CheckTrend();
   
   if(nTrend != gPreTrend)
   {
      logMsg = StringFormat("Trend changed %s ---> %s", TrendName[gPreTrend], TrendName[nTrend]);
      LogInfo(logMsg);
   }
   
   if(buyOrdersCnt == 0 && sellOrdersCnt == 0)
   {
      // 2. check for open order 
      int nDirect = CheckForOpenRSI(gPreTrend, nTrend);      
      if(nDirect != -1)
      {
         logMsg = "Catch open: direction = " + IntegerToString(nDirect);
         LogInfo(logMsg);
         
         if(nDirect == OP_BUY)
         {
            logMsg = StringFormat("Open catch 1: , direction = %d", nDirect);
            LogInfo(logMsg);
            OpenOrder(OP_BUY);
         }else if(nDirect == OP_SELL)
         {
            logMsg = StringFormat("Open catch 2: direction = %d", nDirect);
            LogInfo(logMsg);
            OpenOrder(OP_SELL);
         }       
      }
      
   }else
   {
      // 3. check for close orders
      int nDirect = CheckForCloseRSI(gPreTrend, nTrend);
      if(nDirect != -1)
      {        
         if(nDirect == OP_BUY)
         {             
            // Should close all buy orders
            logMsg = StringFormat("Close catch 1: direction = %d",  nDirect);
            //LogInfo(logMsg);
            CloseOrders(OP_BUY);
            CleanBuyOrdersCache();
         
            // And then open sell order
            logMsg = StringFormat("Open catch 5: direction = %d",  nDirect);
            //LogInfo(logMsg);
            OpenOrder(OP_SELL);
            
         }
         
         if(nDirect == OP_SELL)
         {
            // Should close all sell orders
            logMsg = StringFormat("Close catch 2: direction = %d", nDirect);
            //LogInfo(logMsg);
            CloseOrders(OP_SELL);
            CleanSellOrdersCache();   
                     
            // And then open buy order
            logMsg = StringFormat("Open catch 6: direction = %d",  nDirect);
            //LogInfo(logMsg);
            OpenOrder(OP_BUY);
            
         }
      }
   } 
   
   gPreTrend = nTrend;
   
  }
//+------------------------------------------------------------------+
