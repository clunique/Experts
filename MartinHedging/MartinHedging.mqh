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
void Main()
{
   // 1. 检查持仓情况
   CMartinOrder moBuy(SYMBOL1, SYMBOL2, OP_BUY, TimeFrame, BaseOpenLots, Overweight_Multiple, OrderMax);
   CMartinOrder moSell(SYMBOL1, SYMBOL2, OP_SELL, TimeFrame, BaseOpenLots, Overweight_Multiple, OrderMax);
   
   int nBuyOrderCnt = moBuy.LoadAllOrders();
   int nSellOrderCnt = moSell.LoadAllOrders();
   if(nBuyOrderCnt == 0)
   {
      moBuy.OpenOrders();
   }
   
   if(nSellOrderCnt == 0)
   {
      moSell.OpenOrders();
   }
   // 2. 检查平仓条件
   
   // 3. 满足平仓条件，则平仓
   
   // 4. 不满足平仓条件，则检查加仓条件
   
   // 5. 满足加仓条件，则加仓
}