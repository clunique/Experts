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
   
   // 1. orders accounting
   int buyOrdersCnt = QueryCurrentOrders(OP_BUY);
   int sellOrdersCnt = QueryCurrentOrders(OP_SELL);
   
   bool bOrderEmpty = (buyOrdersCnt == 0 && sellOrdersCnt == 0);
   
   if(bOrderEmpty)
   {
      // 2. check for open order 
      int nDirect = CheckForOpenByBoll();      
      if(nDirect != -1)
      {
         logMsg = "Catch open: direction = " + IntegerToString(nDirect);
         //LogInfo(logMsg);
         OpenOrder(nDirect);        
      }
   }else
   {
      // 3. check for close orders
      int nDirect = CheckForCloseByBoll();
      if(nDirect != -1)
      {        
         if(nDirect == OP_BUY)
         {  
            // Should close all buy orders
            logMsg = StringFormat("Close catch 1: direction = %d", nDirect);
            //LogInfo(logMsg);
            CloseOrders(OP_BUY);
            CleanBuyOrdersCache();
         
            // And then open sell order
            logMsg = StringFormat("Open catch 5: direction = %d", nDirect);
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
            logMsg = StringFormat("Open catch 6: direction = %d", nDirect);
            //LogInfo(logMsg);
            OpenOrder(OP_BUY);
            
         }
      }  
   }
  
}
//+------------------------------------------------------------------+
