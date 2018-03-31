//+------------------------------------------------------------------+
//|                                                          3MA.mq4 |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "3MAUtil.mqh"
#include "3MACheck.mqh"
#include "3MAOrderUtil.mqh"

int gPreTrend = 0;
int gTickCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
   if(IsNewBar() || gTickCount == 0)
   {
       // 1. orders accounting
      int buyOrdersCnt = QueryCurrentOrders(OP_BUY);
      int sellOrdersCnt = QueryCurrentOrders(OP_SELL);
   
      int nTrend = CheckTrend(TimeFrame);
      string logMsg;
      logMsg = StringFormat("OnTick: Trend = %s", TrendName[nTrend]);
      LogInfo(logMsg); 
      
      if(CheckForOpenBuy(nTrend)) 
      {
         // Open buy order
         OpenOrder(OP_BUY);
      }
      
      if(CheckForOpenSell(nTrend))
      {
         // Open sell order
          OpenOrder(OP_SELL);
      }
      
      int nDirect = CheckForClose();
      if(nDirect != -1)
      {
         CloseOrders(nDirect);
      }
      else 
      {
         if(gPreTrend == TREND_UP && nTrend != TREND_UP)
         {
            // Close buy order
            CloseOrders(OP_BUY);
         }
         
         if(gPreTrend == TREND_DOWN && nTrend != TREND_DOWN)
         {
            // Close sell order
            CloseOrders(OP_SELL);
            
         }        
      } 
     
      gPreTrend = nTrend;
            
   }
   gTickCount++;
}
//+------------------------------------------------------------------+
