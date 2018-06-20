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
      pBuyCarriage = new CCarriageOrder(symbol, OP_BUY, MAGIC_NUM, BASE_OPEN_LOTS, HEAVY_TO_LIGHT_MAX);
   }
   
   if(!pSellCarriage) {
      pSellCarriage = new CCarriageOrder(symbol, OP_SELL, MAGIC_NUM, BASE_OPEN_LOTS, HEAVY_TO_LIGHT_MAX);
   }
   
   // 装入当前持仓
   pBuyCarriage.LoadAllOrders();
   pSellCarriage.LoadAllOrders();
    
   if(!pBuyCarriage.hasOrder()) {
       pBuyCarriage.OpenOrder(false);
   }else {
       double dLots = pBuyCarriage.m_orderInfo.m_Lots;
       double dTakeProfits = (OFFSET_HEAVY_TO_LIGHT_PROFITS / 0.0001) * 10 * dLots;
       pBuyCarriage.ProcessOrder(
                     OFFSET_HEAVY_TO_LIGHT_PROFITS,  // 重转轻：盈利条件1：最小价格波动值
                     OFFSET_HEAVY_TO_LIGHT_PROFITS2, // 重转轻：盈利条件2：最小价格波动值，再次平仓时使用 
                     OFFSET_HEAVY_TO_LIGHT_ROLLBACK, // 重转轻：价格反转条件：最小价格波动值
                     HEAVY_TO_LIGHT_MAX,         // 重转轻：条件：最大次数限制
                     BACKWORD_PROFITS, // 重转轻：条件：获利回调系数
                     dTakeProfits, // 重转轻：条件：最少获利金额
                     OFFSET_LIGHT_TO_HEAVY_STOPLOSS, // 轻转重：止损条件：最小价格波动值
                     OFFSET_LIGHT_TO_HEAVY_ROLLBACK, // 轻转重：价格反转条件：最小价格波动值
                     BACKWORD_STOPLOSS //  重转轻：条件：止损回调系数
                     );
   }
   
   if(!pSellCarriage.hasOrder()) {
      pSellCarriage.OpenOrder(false);
   }   
   else {
      double dLots = pSellCarriage.m_orderInfo.m_Lots;
      double dTakeProfits = (OFFSET_HEAVY_TO_LIGHT_PROFITS / 0.0001) * 10 * dLots;
      pSellCarriage.ProcessOrder(
                     OFFSET_HEAVY_TO_LIGHT_PROFITS,  // 重转轻：盈利条件1：最小价格波动值
                     OFFSET_HEAVY_TO_LIGHT_PROFITS2, // 重转轻：盈利条件2：最小价格波动值，再次平仓时使用 
                     OFFSET_HEAVY_TO_LIGHT_ROLLBACK, // 重转轻：价格反转条件：最小价格波动值
                     HEAVY_TO_LIGHT_MAX,         // 重转轻：条件：最大次数限制
                     BACKWORD_PROFITS, // 重转轻：条件：获利回调系数
                     dTakeProfits, // 重转轻：条件：最少获利金额
                     OFFSET_LIGHT_TO_HEAVY_STOPLOSS, // 轻转重：止损条件：最小价格波动值
                     OFFSET_LIGHT_TO_HEAVY_ROLLBACK, // 轻转重：价格反转条件：最小价格波动值
                     BACKWORD_STOPLOSS //  重转轻：条件：止损回调系数
                     );
     }

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