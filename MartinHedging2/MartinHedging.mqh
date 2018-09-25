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
#include "CheckZigZag.mqh"
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

#define STAGE_MAX 3
bool PassOK = false;
   
void Main()
{
   if(!PassOK) {
      PassOK = CheckPasscode(Passcode);
      return;
   }
   
   if(!PassOK) return;
   
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
  
   OptParam optParam[STAGE_MAX];
   optParam[0].m_BaseOpenLots = BaseOpenLots1;
   optParam[0].m_MultipleForAppend = Multiple1;
   optParam[0].m_MulipleFactorForAppend = MulipleFactorForAppend1;
   optParam[0].m_AppendMax = AppendMax1;
   optParam[0].m_PointOffsetForAppend = PointOffsetForAppend1;
   optParam[0].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend1;
   
   optParam[1].m_BaseOpenLots = BaseOpenLots2;
   optParam[1].m_MultipleForAppend = Multiple2;
   optParam[1].m_MulipleFactorForAppend = MulipleFactorForAppend2;
   optParam[1].m_AppendMax = AppendMax2;
   optParam[1].m_PointOffsetForAppend = PointOffsetForAppend2;
   optParam[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2;
   
   optParam[2].m_BaseOpenLots = BaseOpenLots3;
   optParam[2].m_MultipleForAppend = Multiple3;
   optParam[2].m_MulipleFactorForAppend = MulipleFactorForAppend3;
   optParam[2].m_AppendMax = AppendMax3;
   optParam[2].m_PointOffsetForAppend = PointOffsetForAppend3;
   optParam[2].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3;
   
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(SYMBOL1, SYMBOL2, OP_BUY, TimeFrame, optParam);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(SYMBOL1, SYMBOL2, OP_SELL, TimeFrame, optParam);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders();
   int nSellOrderCnt = pMoSell.LoadAllOrders();

   if(nBuyOrderCnt == 0)
   {
      if(!StopLongSide) {
         if(EnableTradingTime) {
            if(IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
               if(BaseOpenCheckReversOrder && nSellOrderCnt == 2) 
               {
                  int nOrderCnt = 1; // MathMax(1, (OrderMax - nSellOrderCnt) / 2);
                  //pMoBuy.OpenOrders(nOrderCnt);
                  pMoBuy.OpenOrders(nOrderCnt, optParam, STAGE_MAX);
               } else 
               {  
                  pMoBuy.OpenOrders(OpenMicroLots, optParam, STAGE_MAX);
               }
            }
         }else {
            if(BaseOpenCheckReversOrder && nSellOrderCnt == 2) 
            {
               int nOrderCnt = 1; // MathMax(1, (OrderMax - nSellOrderCnt) / 2);
               //pMoBuy.OpenOrders(nOrderCnt);
               pMoBuy.OpenOrders(nOrderCnt, optParam, STAGE_MAX);
            } else 
            {  
               pMoBuy.OpenOrders(OpenMicroLots, optParam, STAGE_MAX);
            }
         }
      }
   }
   if(nSellOrderCnt == 0)
   {
      if(!StopShortSide) {
         if(EnableTradingTime) {
            if(IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
               if(BaseOpenCheckReversOrder && nBuyOrderCnt == 2) 
               {
                  int nOrderCnt = 1; //MathMax(1, (OrderMax - nBuyOrderCnt) / 2);
                  // pMoSell.OpenOrders(nOrderCnt);
                  pMoSell.OpenOrders(nOrderCnt, optParam, STAGE_MAX);
               } else 
               {
                  pMoSell.OpenOrders(OpenMicroLots, optParam, STAGE_MAX);
               }
            }
         }else {
            if(BaseOpenCheckReversOrder && nBuyOrderCnt == 2) 
            {
               int nOrderCnt = 1; //MathMax(1, (OrderMax - nBuyOrderCnt) / 2);
               // pMoSell.OpenOrders(nOrderCnt);
               pMoSell.OpenOrders(nOrderCnt, optParam, STAGE_MAX);
            } else 
            {
               pMoSell.OpenOrders(OpenMicroLots, optParam, STAGE_MAX);
            }
         }
      }
   }
   // 2. 检查平仓条件
   double dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      dTakeProfits = TakeProfitsPerOrder * nBuyOrderCnt * TakeProfitsFacor;
   }
   
   if(pMoBuy.CheckForClose1(PointOffsetForProfit, dTakeProfits, Backword))
   {
      // 满足平仓条件，平掉本方向的订单
      pMoBuy.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      int nStage = pMoBuy.CalcStageNumber(nBuyOrderCnt, optParam, STAGE_MAX);
      OptParam param = optParam[nStage];
      if(pMoBuy.CheckForAppend(param.m_PointOffsetForAppend, param.m_PointOffsetFactorForAppend, Backword))
      //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
      {
          // 5. 满足加仓条件，则加仓
           pMoBuy.OpenOrders(false, optParam, STAGE_MAX);
      }     
   }
   
   dTakeProfits = TakeProfits;
   if(DynamicTakeProfits) {
      dTakeProfits = TakeProfitsPerOrder * nSellOrderCnt * TakeProfitsFacor;
   }
   
   if(pMoSell.CheckForClose1(PointOffsetForProfit, dTakeProfits, Backword))
   {
      pMoSell.CloseOrders();
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      int nStage = pMoSell.CalcStageNumber(nSellOrderCnt, optParam, STAGE_MAX);
      OptParam param = optParam[nStage];
      
      if(pMoSell.CheckForAppend(param.m_PointOffsetForAppend, param.m_PointOffsetFactorForAppend, Backword))
      //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
      {
          // 5. 满足加仓条件，则加仓
           pMoSell.OpenOrders(false, optParam, STAGE_MAX);
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