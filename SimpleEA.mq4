//+------------------------------------------------------------------+
//|                                                     SimpleEA.mq4 |
//|                                                          Cuilong |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      ""
#property version   "1.00"
#property strict

#include "OrderInfo.mqh"

bool bEAStatusOK = true;                    // 允许"操盘手"EA运行

#define MAX_ORDER_COUNT 100
#define LOG_DEBUG 0
#define LOG_INFO 1
#define LOG_WARN 2
#define LOG_ERROR 3
#define LOG_DISABLE 4

//input parameters
input int LogLevel = LOG_INFO;
input double BaseOpenLots = 0.01;
input double Overweight_Multiple = 1.0;
input double MaxHoldingLots = 0.25;
input int OrderMax = 5;
input int MagicNumber = 5768;

// global vairables
int gTickCount = 0;
string gSymbol = "";
bool bNewBar = false;
int TimeFrame = PERIOD_M5;
int RSI_Period = 5;
int RSI_LowForOpen = 30;
int RSI_HighForOpen = 70;
int RSI_LowForClose = 20;
int RSI_HighForClose = 80;

int KDJ_TimeFrame = PERIOD_M5;
int KDJ_Period = 5;
int KDJ_LowForOpen = 20;
int KDJ_HighForOpen = 80;
int KDJ_LowForClose = 20;
int KDJ_HighForClose = 80;

enum { RSI = 0, KDJ = 1};
int Indicator = RSI;

enum { FLUCTUATION = 0, TREND_UP = 1, TREND_DOWN = 2 };

int gBuyOrdersCount = 0;
COrderInfo buyOrders[MAX_ORDER_COUNT];
datetime  gLastBuyOrderTime = 0;
double gBuyTotalLots = 0;

// Sell orders data
int gSellOrdersCount = 0;
COrderInfo sellOrders[MAX_ORDER_COUNT];
datetime  gLastSellOrderTime = 0;
double gSellTotalLots = 0;

datetime gCurrentBarTime = 0;

void LogDebug(string msg)
{
   if(LogLevel <= LOG_DEBUG)
   {
      PrintFormat("[debug]%d: %s", gTickCount, msg);
   }
}

void LogInfo(string msg)
{
   if(LogLevel <= LOG_INFO)
   {
      PrintFormat("[info]%s", msg);
   }
}

void LogWarn(string msg)
{
   if(LogLevel <= LOG_WARN)
   {
      PrintFormat("[warn]%s", msg);
   }
}

void LogError(string msg)
{
   if(LogLevel <= LOG_ERROR)
   {
      PrintFormat("[error]%s", msg);
   }
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
   for(int i = 0; i < OrdersTotal();i ++)
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

int CheckForOpenRSI()
{
   int nDirect = -1;
   string logMsg;
   double iRSIPre = iRSI(gSymbol, TimeFrame, RSI_Period,PRICE_CLOSE,1);
   double iRSICurrent = iRSI(gSymbol, TimeFrame, RSI_Period,PRICE_CLOSE,0);
   
   if(bNewBar)
   {
      logMsg = __FUNCTION__ + ": RSI_Pre = " + DoubleToString(iRSIPre, 3) + ", RSI_Current = " + DoubleToString(iRSICurrent, 3);
      LogInfo(logMsg);
   }
   if(iRSIPre <= RSI_LowForOpen && iRSICurrent <= RSI_LowForOpen)
   {
      if(iRSICurrent > iRSIPre + 1.0)
      {
         nDirect = OP_BUY;
         logMsg = __FUNCTION__ + ": Direction = OP_BUY, RSI_Pre = " + DoubleToString(iRSIPre, 3) + ", RSI_Current = " + DoubleToString(iRSICurrent, 3);
         LogInfo(logMsg);
      }
   }else if(iRSIPre >= RSI_HighForOpen && iRSICurrent >= RSI_HighForOpen)
   {
      if(iRSICurrent < iRSIPre - 1.0)
      {
         nDirect = OP_SELL;
         logMsg = __FUNCTION__ + ": Direction = OP_SELL, RSI_Pre = " + DoubleToString(iRSIPre, 3) + ", RSI_Current = " + DoubleToString(iRSICurrent, 3);
         LogInfo(logMsg);
      }
   }   
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;
}

int CheckForOpenKDJ()
{
   int nDirect = -1;
   string logMsg;                    
   double iKDJPre = iStochastic(gSymbol, KDJ_TimeFrame, 5,3,3, MODE_EMA,0,MODE_MAIN,1);
   double iKDJCurrent = iStochastic(gSymbol, KDJ_TimeFrame, 5,3,3, MODE_EMA,0,MODE_MAIN,0);
   
   if(bNewBar)
   {
      logMsg = __FUNCTION__ + ": KDJ_Pre = " + DoubleToString(iKDJPre, 3) + ", KDJ_Current = " + DoubleToString(iKDJCurrent, 3);
      LogInfo(logMsg);
   }
   if(iKDJPre <= KDJ_LowForOpen && iKDJCurrent <= KDJ_LowForOpen)
   {
      if(iKDJCurrent > iKDJPre + 1.0)
      {
         nDirect = OP_BUY;
         logMsg = __FUNCTION__ + ": Direction = OP_BUY, KDJ_Pre = "
                   + DoubleToString(iKDJPre, 3) + ", KDJ_Current = "
                   + DoubleToString(iKDJCurrent, 3);
         LogInfo(logMsg);
      }
   }else if(iKDJPre >= KDJ_HighForOpen && iKDJCurrent >= KDJ_HighForOpen)
   {
      if(iKDJCurrent < iKDJPre - 1.0)
      {
         nDirect = OP_SELL;
         logMsg = __FUNCTION__ + ": Direction = OP_SELL, KDJ_Pre = " 
                  + DoubleToString(iKDJPre, 3) + ", KDJ_Current = " 
                  + DoubleToString(iKDJCurrent, 3);
         LogInfo(logMsg);
      }
   }   
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;
}

int CheckForCloseRSI()
{
   int nDirect = -1;
   string logMsg;
   double iRSIPre = iRSI(gSymbol, TimeFrame, RSI_Period,PRICE_CLOSE,1);
   double iRSICurrent = iRSI(gSymbol, TimeFrame, RSI_Period,PRICE_CLOSE,0);
   
   if(bNewBar)
   {
      logMsg = __FUNCTION__ + ": RSI_Pre = " + DoubleToString(iRSIPre, 3) 
            + ", RSI_Current = " + DoubleToString(iRSICurrent, 3);
      LogInfo(logMsg);
   }
   if(iRSIPre <= RSI_LowForOpen && iRSICurrent <= RSI_LowForOpen)
   {
      if(iRSICurrent > iRSIPre + 2.0)
      {
         nDirect = OP_SELL;
         logMsg = __FUNCTION__ + ": Direction = OP_SELL, RSI_Pre = " 
                  + DoubleToString(iRSIPre, 3) + ", RSI_Current = " 
                  + DoubleToString(iRSICurrent, 3);
         LogInfo(logMsg);
      }
   }else if(iRSIPre >= RSI_HighForOpen && iRSICurrent >= RSI_HighForOpen)
   {
      if(iRSICurrent < iRSIPre - 2.0)
      {
         nDirect = OP_BUY;
         logMsg = __FUNCTION__ + ": Direction = OP_BUY, RSI_Pre = " 
                  + DoubleToString(iRSIPre, 3) 
                  + ", RSI_Current = " + DoubleToString(iRSICurrent, 3);
         LogInfo(logMsg);
      }
   }   
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;
}

int CheckForCloseKDJ()
{
   int nDirect = -1;
   string logMsg;
   double iKDJPre = iStochastic(gSymbol, KDJ_TimeFrame, 5,3,3, MODE_EMA,0,MODE_MAIN,1);
   double iKDJCurrent = iStochastic(gSymbol, KDJ_TimeFrame, 5,3,3, MODE_EMA,0,MODE_MAIN,0);
   
   if(bNewBar)
   {
      logMsg = __FUNCTION__ + ": KDJ_Pre = " + DoubleToString(iKDJPre, 3) + ", KDJ_Current = " + DoubleToString(iKDJCurrent, 3);
      LogInfo(logMsg);
   }
   if(iKDJPre <= KDJ_LowForOpen && iKDJCurrent <= KDJ_LowForOpen)
   {
      if(iKDJCurrent > iKDJPre)
      {
         nDirect = OP_SELL;
         logMsg = __FUNCTION__ + ": Direction = OP_SELL, KDJ_Pre = " 
                  + DoubleToString(iKDJPre, 3) 
                  + ", KDJ_Current = " + DoubleToString(iKDJCurrent, 3);
         LogInfo(logMsg);
      }
   }else if(iKDJPre >= KDJ_HighForOpen && iKDJCurrent >= KDJ_HighForOpen)
   {
      if(iKDJCurrent < iKDJPre)
      {
         nDirect = OP_BUY;
         logMsg = __FUNCTION__ + ": Direction = OP_BUY, KDJ_Pre = " 
                  + DoubleToString(iKDJPre, 3) 
                  + ", KDJ_Current = " + DoubleToString(iKDJCurrent, 3);
         LogInfo(logMsg);
      }
   }   
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;
}

int CheckForOpen()
{
   if(Indicator == KDJ) 
   {
      return CheckForOpenKDJ();
   }
   else
   {
      return CheckForOpenRSI();
   }
}

int CheckForClose()
{
   if(Indicator == KDJ) 
   {
      return CheckForCloseKDJ();
   }
   else
   {
      return CheckForCloseRSI();
   }
}

int OpenOrder(int orderType)
{
   int ret = 0;
   datetime now = iTime(gSymbol, TimeFrame, 0);
   RefreshRates();
   switch(orderType)
   {
   case OP_BUY:
      if(gBuyOrdersCount < OrderMax 
            && now > gLastBuyOrderTime
            && gBuyTotalLots < MaxHoldingLots)
      {
         // Open buy order
         double lots = BaseOpenLots;
         if(gBuyOrdersCount > 0)
         {
            lots = NormalizeDouble(BaseOpenLots * MathPow(Overweight_Multiple, gBuyOrdersCount), 2);
         }
         int ticket = OrderSend(gSymbol, OP_BUY, lots, Ask, 3, 0, 0, "SimpleEA order", MagicNumber, 0, clrGreen); 
         if(ticket < 0) 
         { 
            ret = GetLastError(); 
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
            && gSellTotalLots < MaxHoldingLots)
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
   RefreshRates();
   if(orderType == OP_BUY)
   {
      for(int i = 0; i < gBuyOrdersCount;i ++)
      {
         double lots = buyOrders[i].m_Lots;
         int ticket = buyOrders[i].m_Ticket;
         if(ticket > 0)
         {
            if(OrderClose(ticket, lots, Bid, 3, clrGreen))
            {
               string logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                        + ", type = OP_BUY"
                        + ", price = " + DoubleToString(Bid) 
                        + ", lots = " + DoubleToString(lots);
               LogInfo(logMsg);
         
            } else
            {
               ret = GetLastError();
               return ret;
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
            if(OrderClose(ticket, lots, Ask, 3, clrRed))
            {
               string logMsg = __FUNCTION__ + ": ticket = " + IntegerToString(ticket) 
                        + ", type = OP_SELL"
                        + ", price = " + DoubleToString(Ask) 
                        + ", lots = " + DoubleToString(lots);
               LogInfo(logMsg);         
            } else
            {
               ret = GetLastError();
               return ret;
            }
         }
      }
   }
   return ret;
}

int CheckTrend()
{
   int trend = FLUCTUATION;
   string logMsg;
   double Boll_Main_0 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
   double Boll_Main_1 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
   double Boll_Main_2 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_MAIN, 2);
   
   double Boll_Upper_0 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double Boll_Upper_1 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double Boll_Upper_2 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_UPPER, 2);
   
   double Boll_Lower_0 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double Boll_Lower_1 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double Boll_Lower_2 = iBands(gSymbol, TimeFrame, 10, 2, 0, PRICE_CLOSE, MODE_LOWER, 2);
   
   if(bNewBar)
   {
      logMsg = StringFormat("%s => Main2 = %s, Main1 = %s, Main0 = %s",
                                    __FUNCTION__ , DoubleToString(Boll_Main_2), 
                                    DoubleToString(Boll_Main_1), 
                                    DoubleToString(Boll_Main_0));
      LogInfo(logMsg);
      
      logMsg = StringFormat("%s => Upper2 = %s, Upper1 = %s, Upper0 = %s",
                                    __FUNCTION__ , DoubleToString(Boll_Upper_2), 
                                    DoubleToString(Boll_Upper_1), 
                                    DoubleToString(Boll_Upper_0));
      LogInfo(logMsg);
      
      logMsg = StringFormat("%s => Lower2 = %s, Lower1 = %s, Lower0 = %s",
                                    __FUNCTION__ , DoubleToString(Boll_Lower_2), 
                                    DoubleToString(Boll_Lower_1), 
                                    DoubleToString(Boll_Lower_0));
      LogInfo(logMsg);
    }
      
   double diffV0 = Boll_Upper_0 - Boll_Lower_0;
   double diffV1 = Boll_Upper_1 - Boll_Lower_1;
   double diffV2 = Boll_Upper_2 - Boll_Lower_2;
   
   double diff0 = (diffV0 - diffV1) / Point;
   logMsg = StringFormat("%s => Diff1 = %s, Diff0 = %s, Diff = %s", __FUNCTION__, 
            DoubleToStr(diffV1, 6), 
            DoubleToStr(diffV0, 6), 
            DoubleToStr(diff0, 2));
   LogInfo(logMsg);
   
   if(diff0 > 5)
   {
      // 开口
      logMsg = "Boll open lager.";
      LogInfo(logMsg);
      if(Boll_Main_0 > Boll_Main_1)
      {
         logMsg = "Trend UP";
         LogInfo(logMsg);
         trend = TREND_UP;
      }else
      {
         logMsg = "Trend DOWN";
         LogInfo(logMsg);
         trend = TREND_DOWN;
      }      
   }
   else 
   {
      trend = FLUCTUATION;
   }
   logMsg = StringFormat("%s => Trend = %d", __FUNCTION__, trend);
   // LogInfo(logMsg);
   return trend;                  
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
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
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
   
   if(bNewBar)
   {
      logMsg = "OnTick start: tick count: " + IntegerToString(gTickCount);
      LogInfo(logMsg);
   }
   
   // 1. orders accounting
   int buyOrdersCnt = QueryCurrentOrders(OP_BUY);
   int sellOrdersCnt = QueryCurrentOrders(OP_SELL);
   
   int nTrend = CheckTrend();
   logMsg = StringFormat("OnTick: Trend = %d", nTrend);
   LogInfo(logMsg);
   
   if(buyOrdersCnt == 0 && sellOrdersCnt == 0)
   {
      // 2. check for open order 
      int nDirect = CheckForOpen();      
      if(nDirect != -1)
      {
         logMsg = "Catch open: direction = " + IntegerToString(nDirect);
         LogInfo(logMsg);
         OpenOrder(nDirect);        
      }
      
   }else
   {
      // 3. check for close orders
      int nDirect = CheckForClose();
      if(nDirect != -1)
      {        
         if(nDirect == OP_BUY)
         {  
            // Should close all buy orders
            logMsg = StringFormat("Close catch 1: trend = %d, direction = %d", nTrend, nDirect);
            LogInfo(logMsg);
            CloseOrders(OP_BUY);
            CleanBuyOrdersCache();
         
            // And then open sell order
            logMsg = StringFormat("Open catch 5: trend = %d, direction = %d", nTrend, nDirect);
            LogInfo(logMsg);
            OpenOrder(OP_SELL);
            
         }
         
         if(nDirect == OP_SELL)
         {
            // Should close all sell orders
            logMsg = StringFormat("Close catch 2: trend = %d, direction = %d", nTrend, nDirect);
            LogInfo(logMsg);
            CloseOrders(OP_SELL);
            CleanSellOrdersCache();   
                     
            // And then open buy order
            logMsg = StringFormat("Open catch 6: trend = %d, direction = %d", nTrend, nDirect);
            LogInfo(logMsg);
            OpenOrder(OP_BUY);
            
         }
      }
   }  
   
   if(bNewBar)
   {
      logMsg = "OnTick end: tick count: " + IntegerToString(gTickCount);
      LogInfo(logMsg);
   }   
  }
//+------------------------------------------------------------------+     