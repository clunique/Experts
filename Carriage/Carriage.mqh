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

double gMostTotalProfits = 0;
double gPreTotalProfits = 0;
   
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
      // LogInfo("--------------- New Bar -----------------");
   }
   
   string symbol = Symbol();
   // 1. 检查持仓情况
   if(!pBuyCarriage) {
      pBuyCarriage = new CCarriageOrder(symbol, OP_BUY, MAGIC_NUM, BASE_OPEN_LOTS, MULTIPLE_FOR_LOOP);
   }
   
   if(!pSellCarriage) {
      pSellCarriage = new CCarriageOrder(symbol, OP_SELL, MAGIC_NUM, BASE_OPEN_LOTS, MULTIPLE_FOR_LOOP);
   }
   
   // 装入当前持仓
   pBuyCarriage.LoadAllOrders();
   pSellCarriage.LoadAllOrders();
    
   if(!pBuyCarriage.hasOrder()) {
       pBuyCarriage.OpenOrder(false);
   }else {
       if(pBuyCarriage.ProcessOrder(
                     HEAVY_PROFITS_SETP, // 重仓盈利条件：最小价格波动值
                     HEAVY_TO_LIGHT_ROLLBACK, // 重转轻：价格反转条件：最小价格波动值
                     BACKWORD_PROFITS, // 重转轻：条件：获利回调系数
                     HEAVY_TO_LIGHT_MIN_OFFSET, // 重仓轻：重仓可以转轻仓的与对侧订单的最小价格差
                     LIGHT_STOPLOSS_STEP, // 轻仓：止损条件：最小价格波动值
                     LIGHT_TO_HEAVY_ROLLBACK, // 轻转重：价格反转条件：最小价格波动值
                     BACKWORD_STOPLOSS, // 轻仓条件：止损回调系数
                     PRICE_ROLLBACK_RATE, // 平所有仓条件，价格回归比例
                     pBuyCarriage.m_orderInfo.m_Prices)) {                     
           //pSellCarriage.CloseOrder(); 
       }
   }
   
   if(!pSellCarriage.hasOrder()) {
      pSellCarriage.OpenOrder(false);
   }   
   else {
      if(pSellCarriage.ProcessOrder(
                     HEAVY_PROFITS_SETP, // 重仓盈利条件：最小价格波动值
                     HEAVY_TO_LIGHT_ROLLBACK, // 重转轻：价格反转条件：最小价格波动值
                     BACKWORD_PROFITS, // 重转轻：条件：获利回调系数
                     HEAVY_TO_LIGHT_MIN_OFFSET, // 重仓轻：重仓可以转轻仓的与对侧订单的最小价格差
                     LIGHT_STOPLOSS_STEP, // 轻仓：止损条件：最小价格波动值
                     LIGHT_TO_HEAVY_ROLLBACK, // 轻转重：价格反转条件：最小价格波动值
                     BACKWORD_STOPLOSS, // 轻仓条件：止损回调系数
                     PRICE_ROLLBACK_RATE, // 平所有仓条件，价格回归比例
                     pBuyCarriage.m_orderInfo.m_Prices)) {
             //pBuyCarriage.CloseOrder();        
         }
     }
     
     
     double dLots = MathMin(pSellCarriage.m_orderInfo.m_Lots, pBuyCarriage.m_orderInfo.m_Lots);
     int nLoopCnt = pSellCarriage.m_nLoopCnt + pBuyCarriage.m_nLoopCnt;
     if(dLots > 0) {
         double dTakeProfits;
         if(dLots > 1) {
            double dPriceDiff = HEAVY_PROFITS_SETP * (nLoopCnt - 1);
            dTakeProfits = (dPriceDiff / 0.0001) * 10 * dLots * PRICE_ROLLBACK_RATE;
        }else {
            dTakeProfits = (HEAVY_PROFITS_SETP / 0.0001) * 10 * dLots;
        }
         
        double dTotalProfits = pBuyCarriage.m_orderInfo.m_Profits + pSellCarriage.m_orderInfo.m_Profits;
        gMostTotalProfits = MathMax(dTotalProfits, gMostTotalProfits);
        double dTakeProfisLevel = gMostTotalProfits * (1 - BACKWORD_STOPLOSS);
        if(dTotalProfits > dTakeProfits) {
            if(gPreTotalProfits < dTakeProfisLevel && dTotalProfits < dTakeProfisLevel) {
               pBuyCarriage.CloseOrder(); 
               pSellCarriage.CloseOrder();
               gMostTotalProfits = 0;
               gPreTotalProfits = 0; 
            }
        }
        gPreTotalProfits = dTotalProfits;
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