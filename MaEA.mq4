//+------------------------------------------------------------------+
//|                                                         MaEA.mq4 |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "PubVar.mqh"
#include "MaCheck.mqh"
#include "ClUtil.mqh"
#include "OrderUtil.mqh"

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
   string logMsg;
  
   gTickCount++;
    
   datetime now = iTime(NULL, TimeFrame, 0);
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
      int nDirect = CheckForOpen();      
      if(nDirect != -1)
      {
         logMsg = "Catch open: direction = " + IntegerToString(nDirect);
         //LogInfo(logMsg);
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
            logMsg = StringFormat("Close catch 1: direction = %d", nDirect);
            //LogInfo(logMsg);
            CloseOrders(OP_BUY);
            CleanBuyOrdersCache();
         }
         
         if(nDirect == OP_SELL)
         {
            // Should close all sell orders
            logMsg = StringFormat("Close catch 2: direction = %d", nDirect);
            //LogInfo(logMsg);
            CloseOrders(OP_SELL);
            CleanSellOrdersCache();   
         }
      } else 
      {
         nDirect = CheckForOpen();
         if((nDirect = OP_BUY && buyOrdersCnt > 0)
            ||(nDirect = OP_SELL && sellOrdersCnt > 0))
         {
            logMsg = "Catch open 2: direction = " + IntegerToString(nDirect);
            //LogInfo(logMsg);
            OpenOrder(nDirect);        
         }
      } 
   }
   
  }
//+------------------------------------------------------------------+
