//+------------------------------------------------------------------+
//|                                                   BollingEA3.mq4 |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "ClUtil.mqh"
#include "OrderUtil.mqh"
#include "RsiCheck.mqh"
#include "BollCheck.mqh"

int gPreTrend = FLUCTUATION;
string gSymbol;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   gSymbol = Symbol();
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
   string logMsg;
   
   // 1. orders accounting
   int buyOrdersCnt = QueryCurrentOrders(OP_BUY);
   int sellOrdersCnt = QueryCurrentOrders(OP_SELL);
   
   bool bOrderEmpty = (buyOrdersCnt == 0 && sellOrdersCnt == 0);
   
   int nTrend = CheckTrend(gPreTrend);
   if(gPreTrend != nTrend)
   {
      logMsg = StringFormat("%s => Trend changed: %s ---> %s",
                         __FUNCTION__ , TrendName[gPreTrend], TrendName[nTrend]);
      LogInfo(logMsg);
      
      if(gPreTrend == TREND_GREAT_UP && nTrend != TREND_GREAT_UP)
      {
         // Should close all buy orders
         logMsg = StringFormat("Close buy catch 0:  direction = %d", OP_BUY);
         LogInfo(logMsg);
         CloseOrders(OP_BUY);
         CleanBuyOrdersCache();
         
      }
      
      if(gPreTrend == TREND_GREAT_DOWN && nTrend != TREND_GREAT_DOWN)
      {
         // Should close all sell orders
         logMsg = StringFormat("Close sell catch 0:  direction = %d", OP_SELL);
         LogInfo(logMsg);
         CloseOrders(OP_SELL);
         CleanBuyOrdersCache();
         
      }      
      
      if(gPreTrend != TREND_GREAT_UP && nTrend == TREND_GREAT_UP)
      {
         // Should close all sell orders
         logMsg = StringFormat("Close catch 3: direction = %d", OP_SELL);
         LogInfo(logMsg);
         CloseOrders(OP_SELL);
         CleanSellOrdersCache();   
                  
         // And then open buy order
         logMsg = StringFormat("Open catch 3: direction = %d", OP_BUY);
         //LogInfo(logMsg);
         OpenOrder(OP_BUY); 
      }
      
      if(gPreTrend != TREND_GREAT_DOWN && nTrend == TREND_GREAT_DOWN)
      {
         // Should close all buy orders
         logMsg = StringFormat("Close catch 4: direction = %d", OP_BUY);
         LogInfo(logMsg);
         CloseOrders(OP_BUY);
         CleanSellOrdersCache();   
                  
         // And then open buy order
         logMsg = StringFormat("Open catch 4: direction = %d", OP_SELL);
         //LogInfo(logMsg);
         OpenOrder(OP_SELL);
      }
   }else
   {
      if(nTrend == TREND_UP || nTrend == TREND_DOWN)
      {
         // Use RSI
         int nDirect = CheckForCloseByBoll();
         if(nDirect != -1)
         {        
            if(nDirect == OP_BUY)
            {             
               // Should close all buy orders
               logMsg = StringFormat("Close catch 1:  direction = %d", nDirect);
               LogInfo(logMsg);
               CloseOrders(OP_BUY);
               CleanBuyOrdersCache();
            
               // And then open sell order
               logMsg = StringFormat("Open catch 1: direction = %d", nDirect);
               //LogInfo(logMsg);
               OpenOrder(OP_SELL);              
            }
            
            if(nDirect == OP_SELL)
            {              
               // Should close all sell orders
               logMsg = StringFormat("Close catch 2: direction = %d", nDirect);
               LogInfo(logMsg);
               CloseOrders(OP_SELL);
               CleanSellOrdersCache();   
                        
               // And then open buy order
               logMsg = StringFormat("Open catch 2: direction = %d", nDirect);
               //LogInfo(logMsg);
               OpenOrder(OP_BUY);              
            }
         }
      }
   }
   gPreTrend = nTrend;
}
//+------------------------------------------------------------------+
