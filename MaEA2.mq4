//+------------------------------------------------------------------+
//|                                                        MaEA2.mq4 |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "MaCheck2.mqh"
#include "OrderUtil.mqh"
#include "RsiCheck.mqh"
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
      if(IsNewBar())
      {
         logMsg = StringFormat("OnTick: ============== New bar (%d) ================", gTickCount);
         LogInfo(logMsg);
      }
      
       // 1. orders accounting
      int buyOrdersCnt = QueryCurrentOrders(OP_BUY);
      int sellOrdersCnt = QueryCurrentOrders(OP_SELL);
      
      // 2. check for open order 
      bool bOrderEmpty = (buyOrdersCnt == 0 && sellOrdersCnt == 0);
      if(bOrderEmpty)
      {
         // 2. check for open order 
         // 没有持仓，检查开仓条件
         int nDirect = CheckForOpenRSI();   
         if(nDirect != -1)
         {
            logMsg = "Catch open 1: direction = " + IntegerToString(nDirect);
            LogInfo(logMsg);
            OpenOrder(nDirect);        
         }
      }else
      {
         // 有持仓，先检查平仓条件
         int nDirect = CheckForCloseRSI();
         if(nDirect != -1)
         {
            if(nDirect == OP_BUY)
            {
               logMsg = "Catch close 1: direction = " + IntegerToString(nDirect);
               LogInfo(logMsg);
               CloseOrders(nDirect);
               CleanBuyOrdersCache();
               
               // OpenOrder(OP_SELL);
            }
            if(nDirect == OP_SELL)
            {
               logMsg = "Catch close 2: direction = " + IntegerToString(nDirect);
               LogInfo(logMsg);
               CloseOrders(nDirect);
               CleanSellOrdersCache();
               
               // OpenOrder(OP_BUY);
            }           
            
         }
         // 如果不满足平仓条件，则再检查开仓条件，以便加仓
         nDirect = CheckForOpenRSI();
         if(nDirect != -1)
         {
            // 再次查询持仓情况
            buyOrdersCnt = QueryCurrentOrders(OP_BUY);
            sellOrdersCnt = QueryCurrentOrders(OP_SELL);
            logMsg = "Catch open 2: direction = " + IntegerToString(nDirect);
            LogInfo(logMsg);
            OpenOrder(nDirect);        
         }
                 
      }  
  }
//+------------------------------------------------------------------+
