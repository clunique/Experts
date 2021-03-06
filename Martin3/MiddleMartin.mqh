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
   
bool CheckForAppend(CMartinOrder * pBuy, CMartinOrder * pSell) {
   bool bAppend = false;
   double dLastOrderPriceBuy = pBuy.GetPriceLastOrder();
   double dLastOrderPriceSell = pSell.GetPriceLastOrder();
   
   if(dLastOrderPriceBuy > 0 && dLastOrderPriceSell > 0
      && dLastOrderPriceBuy - dLastOrderPriceSell >= PointOffsetForAppend) {
      double midPrice = (dLastOrderPriceBuy + dLastOrderPriceSell) / 2;
      double currPrice = Close[0];
      if(MathAbs(midPrice - currPrice) <= 0.0005) {
         LogInfo("++++++++++++ CheckForAppend ( Mid Price) +++++++++++++");
         string logMsg = StringFormat("PriceBuy = %s, PriceSell = %s, currPrice = %s",
                  DoubleToString(dLastOrderPriceBuy, 4), DoubleToString(dLastOrderPriceSell, 4),
                  DoubleToString(currPrice, 4));
         LogInfo(logMsg);
         bAppend = true;
      }
   }
   
   return bAppend;
}

void Main()
{
   if(IsExpired()) {
      return;
   }
   
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

   if(nBuyOrderCnt == 0)
   {
      pMoBuy.OpenOrders();
     
   }
   if(nSellOrderCnt == 0)
   {
      pMoSell.OpenOrders();
   }
   // 2. 检查平仓条件
   double dTakeProfitsForBuy = TakeProfits;
   double dTakeProfitsForSell = TakeProfits;
   if(DynamicTakeProfits) {
      dTakeProfitsForBuy = TakeProfitsPerOrder * nBuyOrderCnt * TakeProfitsFacor;
      dTakeProfitsForSell = TakeProfitsPerOrder * nSellOrderCnt * TakeProfitsFacor;
   }
   
   if(pMoBuy.CheckForClose(PointOffsetForProfit, dTakeProfitsForBuy, Backword))
   {
      // 满足平仓条件，平掉本方向的订单
      pMoBuy.CloseOrders();
   }else if(pMoSell.CheckForClose(PointOffsetForProfit, dTakeProfitsForSell, Backword))
   {
      pMoSell.CloseOrders();
   }else
   {
      pMoSell.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword);
      pMoBuy.CheckForAppend(PointOffsetForAppend, FactorForAppend, Backword);
      
      // 4. 不满足平仓条件，则检查加仓条件
      if(CheckForAppend(pMoBuy, pMoSell))
      {
          // 5. 满足加仓条件，则加仓
          int nOrderCnt = MathMax(nBuyOrderCnt, nSellOrderCnt);
          string logMsg = StringFormat("nOrderCnt = %d, nBuyOrderCnt = %s, nSellOrderCnt = %s",
                  nOrderCnt, nBuyOrderCnt, nSellOrderCnt);
          LogInfo(logMsg);
          pMoBuy.OpenOrders(nOrderCnt);
          pMoSell.OpenOrders(nOrderCnt);
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