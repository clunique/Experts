//+------------------------------------------------------------------+
//|                                                MartinHedging.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "CarriageOrder.mqh"
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

CCarriageOrder * pBuyCarriage = NULL;
CCarriageOrder * pSellCarriage = NULL;
   
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
   if(!pBuyCarriage) {
      pBuyCarriage = new CCarriageOrder(symbol, OP_BUY, MAGIC_NUM, BASE_OPEN_LOTS);
   }
   
   if(!pSellCarriage) {
      pSellCarriage = new CCarriageOrder(symbol, OP_SELL, MAGIC_NUM, BASE_OPEN_LOTS);
   }
   
   // 装入当前持仓
   pBuyCarriage.LoadAllOrders();
   pSellCarriage.LoadAllOrders();
    
   if(!pBuyCarriage.hasOrder()) {
       // 还没有开基础仓，开基础仓
       //pBuyCarriage.OpenOrder(true, BASE_OPEN_LOTS);
   }else {
       //pBuyCarriage.ProcessOrder(BASE_CLOSE_MIN_OFFSET, BASE_CLOSE_BACKWORD_OFFSET);
   }
   
   if(!pSellCarriage.hasOrder()) {
      // pSellCarriage.OpenOrder(true, BASE_OPEN_LOTS);
      pSellCarriage.OpenOrder(true, LIGHT_LOTS);
   }   
   else {
      pSellCarriage.ProcessOrder(BASE_CLOSE_MIN_OFFSET, BASE_CLOSE_BACKWORD_OFFSET);
   }

   pBuyCarriage.UpdateCache();
   pSellCarriage.UpdateCache();
   gTickCount++;
}

void Destroy()
{
   if(pBuyCarriage) {
      delete pBuyCarriage; 
      pBuyCarriage = NULL;
   }
   
    if(pSellCarriage) {
       delete pSellCarriage;
       pSellCarriage = NULL;
   }
}