//+------------------------------------------------------------------+
//|                                                MartinHedging.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "MartinOrder.mqh"
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

CMartinOrder * pMoBuy = NULL;
CMartinOrder * pMoSell = NULL;
   
void Main()
{  
   bool bIsNewBar = IsNewBar();
   if(!gIsNewBar && bIsNewBar)
   {
      gIsNewBar = bIsNewBar;
   }else
   {
      gIsNewBar = false;
   }
   
   if(gIsNewBar) {
      LogInfo("--------------- New Bar -----------------");
   }
   
   string symbol = Symbol();
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(symbol, OP_BUY, TimeFrame, BaseOpenLots, Overweight_Multiple, MulipleFactorForAppend, OrderMax);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(symbol, OP_SELL, TimeFrame, BaseOpenLots, Overweight_Multiple, MulipleFactorForAppend, OrderMax);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders();
   int nSellOrderCnt = pMoSell.LoadAllOrders();

   if(nBuyOrderCnt == 0 && nSellOrderCnt == 0) {
       pMoBuy.OpenOrdersMicro();
       pMoSell.OpenOrdersMicro();
   }else {
      if(nBuyOrderCnt == 0)
      {
         double dLastSellPrice = pMoSell.GetPriceLastOrder();
         RefreshRates();
         double dCurrentPrice =  MarketInfo(symbol, MODE_ASK);
         
         if(dCurrentPrice > dLastSellPrice) {
            // 如果当前价格比空单的最近一次的价格还要高，则开微手0.01手的单
            int nLoopCount = pMoBuy.GetLoopCount();
            if(nLoopCount == -1 || 
               (BaseOpenLotsInLoop 
                  && (nSellOrderCnt == 2 || nSellOrderCnt == 3) 
                  && (nLoopCount == 1 || nLoopCount == 2)))
            {
               // 2018-06-12, 改为始终开微手，不开基础手
               // pMoBuy.OpenOrders();
               pMoBuy.OpenOrdersMicro();
            }else {
               pMoBuy.OpenOrdersMicro();
            }
         }else {
            pMoBuy.OpenOrders();
         } 
      }
      
      if(nSellOrderCnt == 0)
      {
         double dLastBuyPrice = pMoBuy.GetPriceLastOrder();
         RefreshRates();
         double dCurrentPrice =  MarketInfo(symbol, MODE_BID);
         
         if(dCurrentPrice < dLastBuyPrice) {
            // 如果当前价格比多单的最近一次的价格还要底，则开微手0.01手的单
            int nLoopCount = pMoSell.GetLoopCount();
            if(nLoopCount == -1 || 
               (BaseOpenLotsInLoop 
                  && (nBuyOrderCnt == 2 || nBuyOrderCnt == 3) 
                  && (nLoopCount == 1 || nLoopCount == 2)))
            {
               // 2018-06-12, 改为始终开微手，不开基础手
               // pMoSell.OpenOrders();
               pMoSell.OpenOrdersMicro();
            }else {
               pMoSell.OpenOrdersMicro();
            }
         }else {
            // 否则，开普通手
            pMoSell.OpenOrders();
         } 
      }
   }
   // 2. 检查平仓条件
   double dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      if(nBuyOrderCnt > 1) {
         dTakeProfits = TakeProfitsPerOrder * TakeProfitsFacor * nBuyOrderCnt;
      }else {
         dTakeProfits = TakeProfitsPerOrder;
      }
   }
   
   if(pMoBuy.CheckForClose(PointOffsetForProfit, dTakeProfits, Backword))
   {
      // 满足平仓条件，平掉本方向的订单
      pMoBuy.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(pMoBuy.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword) 
         // && !IsFriday()
         )
      //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
      {
          // 5. 满足加仓条件，则加仓
           pMoBuy.OpenOrders();
      }  
     
   }
   
   dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      if(nSellOrderCnt > 1) {
         dTakeProfits = TakeProfitsPerOrder * TakeProfitsFacor * nSellOrderCnt;
      }else {
         dTakeProfits = TakeProfitsPerOrder;
      }
   }
   
   if(pMoSell.CheckForClose(PointOffsetForProfit, dTakeProfits, Backword))
   {
      pMoSell.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(pMoSell.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword)
          //&& !IsFriday()
          )
      //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
      {
          // 5. 满足加仓条件，则加仓
           pMoSell.OpenOrders();
      }
   }
   
  
   gTickCount++;
}

void Destroy()
{
   if(pMoBuy) {
      delete pMoBuy; 
      pMoBuy = NULL;
   }
   
   if(pMoSell) {
       delete pMoSell;
       pMoSell = NULL;
   }
}