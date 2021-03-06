//+------------------------------------------------------------------+
//|                                                MartinHedging.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "ClUtil.mqh"
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

#define STAGE_MAX 20

bool PassOK = false;

CMartinOrder * pMoBuy = NULL;
CMartinOrder * pMoSell = NULL;

double mostEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;
double gPreLoss = 0;
bool gDisableOpen = false;
   
bool IsDataAndTimeAllowed() {
   if(EnableTradingDate && !IsBetweenDate(OpenOrderStartDate, OpenOrderEndDate)) {
      return false;
   }
   
   if(EnableTradingTime && !IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
      return false;
   }
   return true; 
}

void Main()
{  
   if(gDisableOpen) return;

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
   optParam[0].m_PointOffsetForStage = PointOffsetForStage1;
   optParam[0].m_PointOffsetForAppend = PointOffsetForAppend1;
   optParam[0].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend1;
   optParam[0].m_AppendBackword = AppendBackword1;
   optParam[0].m_TakeProfitsPerLot = TakeProfitsPerLot1;
   optParam[0].m_TakeProfitsFacor = TakeProfitsFacor1;
   optParam[0].m_Backword = Backword1; 
   
   optParam[1].m_BaseOpenLots = BaseOpenLots2;
   optParam[1].m_MultipleForAppend = Multiple2;
   optParam[1].m_MulipleFactorForAppend = MulipleFactorForAppend2;
   optParam[1].m_AppendMax = AppendMax2;
   optParam[1].m_PointOffsetForStage = PointOffsetForStage2;
   optParam[1].m_PointOffsetForAppend = PointOffsetForAppend2;
   optParam[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2;
   optParam[1].m_AppendBackword = AppendBackword2;
   optParam[1].m_TakeProfitsPerLot = TakeProfitsPerLot2;
   optParam[1].m_TakeProfitsFacor = TakeProfitsFacor2;
   optParam[1].m_Backword = Backword2;
   
   optParam[2].m_BaseOpenLots = BaseOpenLots3;
   optParam[2].m_MultipleForAppend = Multiple3;
   optParam[2].m_MulipleFactorForAppend = MulipleFactorForAppend3;
   optParam[2].m_AppendMax = AppendMax3;
   optParam[2].m_PointOffsetForStage = PointOffsetForStage3;
   optParam[2].m_PointOffsetForAppend = PointOffsetForAppend3;
   optParam[2].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3;
   optParam[2].m_AppendBackword = AppendBackword3;
   optParam[2].m_TakeProfitsPerLot = TakeProfitsPerLot3;
   optParam[2].m_TakeProfitsFacor = TakeProfitsFacor3;
   optParam[2].m_Backword = Backword3;
   
   optParam[3].m_BaseOpenLots = BaseOpenLots4;
   optParam[3].m_MultipleForAppend = Multiple4;
   optParam[3].m_MulipleFactorForAppend = MulipleFactorForAppend4;
   optParam[3].m_AppendMax = AppendMax4;
   optParam[3].m_PointOffsetForStage = PointOffsetForStage4;
   optParam[3].m_PointOffsetForAppend = PointOffsetForAppend4;
   optParam[3].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend4;
   optParam[3].m_AppendBackword = AppendBackword4;
   optParam[3].m_TakeProfitsPerLot = TakeProfitsPerLot4;
   optParam[3].m_TakeProfitsFacor = TakeProfitsFacor4;
   optParam[3].m_Backword = Backword4;
   
   optParam[4].m_BaseOpenLots = BaseOpenLots5;
   optParam[4].m_MultipleForAppend = Multiple5;
   optParam[4].m_MulipleFactorForAppend = MulipleFactorForAppend5;
   optParam[4].m_AppendMax = AppendMax5;
   optParam[4].m_PointOffsetForStage = PointOffsetForStage5;
   optParam[4].m_PointOffsetForAppend = PointOffsetForAppend5;
   optParam[4].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend5;
   optParam[4].m_AppendBackword = AppendBackword5;
   optParam[4].m_TakeProfitsPerLot = TakeProfitsPerLot5;
   optParam[4].m_TakeProfitsFacor = TakeProfitsFacor5;
   optParam[4].m_Backword = Backword5;
   
   optParam[5].m_BaseOpenLots = BaseOpenLots6;
   optParam[5].m_MultipleForAppend = Multiple6;
   optParam[5].m_MulipleFactorForAppend = MulipleFactorForAppend6;
   optParam[5].m_AppendMax = AppendMax6;
   optParam[5].m_PointOffsetForStage = PointOffsetForStage6;
   optParam[5].m_PointOffsetForAppend = PointOffsetForAppend6;
   optParam[5].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend6;
   optParam[5].m_AppendBackword = AppendBackword6;
   optParam[5].m_TakeProfitsPerLot = TakeProfitsPerLot6;
   optParam[5].m_TakeProfitsFacor = TakeProfitsFacor6;
   optParam[5].m_Backword = Backword6;
   
   optParam[6].m_BaseOpenLots = BaseOpenLots7;
   optParam[6].m_MultipleForAppend = Multiple7;
   optParam[6].m_MulipleFactorForAppend = MulipleFactorForAppend7;
   optParam[6].m_AppendMax = AppendMax7;
   optParam[6].m_PointOffsetForStage = PointOffsetForStage7;
   optParam[6].m_PointOffsetForAppend = PointOffsetForAppend7;
   optParam[6].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend7;
   optParam[6].m_AppendBackword = AppendBackword7;
   optParam[6].m_TakeProfitsPerLot = TakeProfitsPerLot7;
   optParam[6].m_TakeProfitsFacor = TakeProfitsFacor7;
   optParam[6].m_Backword = Backword7;
   
   optParam[7].m_BaseOpenLots = BaseOpenLots8;
   optParam[7].m_MultipleForAppend = Multiple8;
   optParam[7].m_MulipleFactorForAppend = MulipleFactorForAppend8;
   optParam[7].m_AppendMax = AppendMax8;
   optParam[7].m_PointOffsetForStage = PointOffsetForStage8;
   optParam[7].m_PointOffsetForAppend = PointOffsetForAppend8;
   optParam[7].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend8;
   optParam[7].m_AppendBackword = AppendBackword8;
   optParam[7].m_TakeProfitsPerLot = TakeProfitsPerLot8;
   optParam[7].m_TakeProfitsFacor = TakeProfitsFacor8;
   optParam[7].m_Backword = Backword8;
   
   for(int i = 2; i < STAGE_MAX - 1; i++){
      optParam[i].m_BaseOpenLots = BaseOpenLots3;
      optParam[i].m_MultipleForAppend = Multiple3;
      optParam[i].m_MulipleFactorForAppend = MulipleFactorForAppend3;
      optParam[i].m_AppendMax = AppendMax3;
      optParam[i].m_PointOffsetForStage = PointOffsetForStage3;
      optParam[i].m_PointOffsetForAppend = PointOffsetForAppend3;
      optParam[i].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3;
      optParam[i].m_AppendBackword = AppendBackword3;
      optParam[i].m_TakeProfitsPerLot = TakeProfitsPerLot3;
      optParam[i].m_TakeProfitsFacor = TakeProfitsFacor3;
      optParam[i].m_Backword = Backword3;
   }
   
   string symbol = Symbol();
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(symbol, OP_BUY, MagicNum);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(symbol, OP_SELL, MagicNum);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders(optParam, StageMax);
   int nSellOrderCnt = pMoSell.LoadAllOrders(optParam, StageMax);
   
   int nStageBuy = pMoBuy.CalcStageNumber(nBuyOrderCnt, optParam, StageMax);
   int nAppendNumberBuy = pMoBuy.CalcAppendNumber(nStageBuy, nBuyOrderCnt, optParam, StageMax);
   
   int nStageSell = pMoSell.CalcStageNumber(nSellOrderCnt, optParam, StageMax);
   int nAppendNumberSell = pMoSell.CalcAppendNumber(nStageSell, nSellOrderCnt, optParam, StageMax);   

   double dBuyLots = pMoBuy.m_dLots;
   double dSellLots = pMoSell.m_dLots;
   
   if(nBuyOrderCnt == 0)
   {
      if(!StopLongSide && IsDataAndTimeAllowed()) {
         pMoBuy.OpenOrders(optParam, StageMax);
      }
     
   }
   
   if(nSellOrderCnt == 0)
   {
      if(!StopShortSide && IsDataAndTimeAllowed()) {
           pMoSell.OpenOrders(optParam, StageMax);
      }
   }
   
   
   // 2. 检查平仓条件            
   double dPriceDiff = 0;
   double dBuyLotsStage = 0;
   // if(nStageBuy == 0 || nStageBuy == STAGE_MAX - 1) {
      // 获取总价格差和总手数
   //    dPriceDiff = pMoBuy.GetPriceDiff();
   //    dBuyLotsStage = pMoBuy.m_dLots;      
   // }else {
      // 仅仅获取本间断的价格差和本阶段的总手数
   //    dPriceDiff = pMoBuy.GetPriceDiff(nAppendNumberBuy);
   //    dBuyLotsStage = pMoBuy.GetLots(nAppendNumberBuy);
   // }
   
   // 仅仅获取本间断的价格差和本阶段的总手数
   dPriceDiff = pMoBuy.GetPriceDiff(nAppendNumberBuy);
   dBuyLotsStage = pMoBuy.GetLots(nAppendNumberBuy);
     
   double dTakeProfitsBuy = 0;   
   if(nBuyOrderCnt > 1) {      
      dTakeProfitsBuy = (dPriceDiff / Point) * (dBuyLotsStage) * optParam[nStageBuy].m_TakeProfitsFacor;
   }else {
      dTakeProfitsBuy = (PointOffsetForProfit / Point) * dBuyLotsStage;
      if(dTakeProfitsBuy == 1) {
         dTakeProfitsBuy = 0;
      }
   }
  
   if(pMoBuy.CheckForClose(PointOffsetForProfit,  dTakeProfitsBuy, 
                              optParam[nStageBuy].m_Backword))
   {
      // 满足平仓条件，平掉本方向的订单
      if(nStageBuy == 0) {
         // 第一阶段或最后一个阶段，平全部订单
         // pMoBuy.CloseOrders();
         if(nAppendNumberBuy <= 1) {
            pMoBuy.CloseOrders(1);
         }else {
            pMoBuy.CloseOrders(nAppendNumberBuy - 1);
         }
      }else {
         // 其余阶段，仅平掉本阶段的订单，但剩余第一轮的订单 
         if(nAppendNumberBuy <= 1) {
            pMoBuy.CloseOrders(1);
         }else {
            pMoBuy.CloseOrders(nAppendNumberBuy - 1);
         }
      }
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
      if(nStageBuy < StageMax) {
            OptParam param = optParam[nStageBuy];
            double dOffset = param.m_PointOffsetForAppend;
            double factor = param.m_PointOffsetFactorForAppend;
            bool bFactor = true;
            if(nAppendNumberBuy >= param.m_AppendMax) {
               dOffset = param.m_PointOffsetForStage;
               factor = 1.0;
               bFactor = false;
            }  
            
            if(nAppendNumberBuy == 1) {
               bFactor = false;
            }
                      
            if(IsDataAndTimeAllowed()
               && pMoBuy.IsAllowBuy() 
               && pMoBuy.CheckForAppend(dOffset, factor, param.m_AppendBackword, nAppendNumberBuy, bFactor))
            {
               LogInfo("+++++++++++++++ Buy Append ++++++++++++++++++++++++++++++++++");
               string logMsg = StringFormat("多方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                        DoubleToString(dOffset, 4),
                        nStageBuy + 1, nAppendNumberBuy); 
               LogInfo(logMsg);
               if(!StopLongSide) {
                  pMoBuy.OpenOrders(optParam, StageMax);
               }
                        
            }
      }
   }
     
   dPriceDiff = 0;
   double dSellLotsStage = 0;
   //if(nStageSell == 0 || nStageSell == STAGE_MAX - 1) {
      // 获取总价格差和总手数
   //   dPriceDiff = pMoSell.GetPriceDiff();
   //   dSellLotsStage = pMoSell.m_dLots;      
   //}else {
      // 仅仅获取本间断的价格差和本阶段的总手数
   //   dPriceDiff = pMoSell.GetPriceDiff(nAppendNumberSell);
   //   dSellLotsStage = pMoSell.GetLots(nAppendNumberSell);
   //}
   
   // 仅仅获取本间断的价格差和本阶段的总手数
   dPriceDiff = pMoSell.GetPriceDiff(nAppendNumberSell);
   dSellLotsStage = pMoSell.GetLots(nAppendNumberSell);
   double dTakeProfitsSell = 0;   
   if(nSellOrderCnt > 1) {      
      dTakeProfitsSell = (dPriceDiff / Point ) * (dSellLotsStage) * optParam[nStageSell].m_TakeProfitsFacor;
   }else {
      
      dTakeProfitsSell = (PointOffsetForProfit / Point) * dSellLotsStage;
      if(nAppendNumberSell == 1) {
         dTakeProfitsSell = 0;
      }
   }
   
   if(pMoSell.CheckForClose(PointOffsetForProfit,dTakeProfitsSell, 
                              optParam[nStageSell].m_Backword)) {
                               // 满足平仓条件，平掉本方向的订单
      if(nStageSell == 0) {
         // 第一阶段或最后一个阶段，平全部订单
         // pMoSell.CloseOrders();
         
         if(nAppendNumberSell <= 1) {
            pMoSell.CloseOrders(1);
         }else {
            // 其余阶段，仅平掉本阶段的订单，但剩余第一轮的订单           
            pMoSell.CloseOrders(nAppendNumberSell - 1);
         }
      }else {
         if(nAppendNumberSell == 1) {
            pMoSell.CloseOrders(nAppendNumberSell);
         }else {
            // 其余阶段，仅平掉本阶段的订单，但剩余第一轮的订单           
            pMoSell.CloseOrders(nAppendNumberSell - 1);
         }
      }
   }else
   {
      // 4. 不满足平仓条件，则检查加仓条件
       if(nStageSell < StageMax) {
            OptParam param = optParam[nStageSell];
            double dOffset = param.m_PointOffsetForAppend;
            double factor = param.m_PointOffsetFactorForAppend;
            bool  bFactor = true;
            if(nAppendNumberSell >= param.m_AppendMax) {
               dOffset = param.m_PointOffsetForStage;
               factor = 1.0;
               bFactor = false;
            }
            
            if(nAppendNumberSell == 1) {
               bFactor = false;
            }
              
         if(IsDataAndTimeAllowed() 
            && pMoSell.IsAllowSell() 
            && pMoSell.CheckForAppend(dOffset, factor, param.m_AppendBackword, nAppendNumberSell, bFactor))
         {
              LogInfo("+++++++++++++++ Buy Append ++++++++++++++++++++++++++++++++++");
               string logMsg = StringFormat("空方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                        DoubleToString(dOffset, 4),
                        nStageSell + 1, nAppendNumberSell); 
               LogInfo(logMsg);
               if(!StopShortSide) {
                  pMoSell.OpenOrders(optParam, StageMax);
               }             
         }
      }
    
   }
   
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }     
   
   if(EnableAutoCloseAllForStopLoss) {
      double currentLoss = pMoSell.CalsUnrealizedLoss();
      if(gPreLoss > 0) {
         if(gPreLoss > TargetLossAmout && currentLoss < TargetLossAmout) {
            string logMsg = StringFormat("浮亏达到清仓标准：%s --> %s.", 
                        DoubleToString(gPreLoss, 2),DoubleToString(currentLoss, 2));
            LogInfo(logMsg);
            pMoSell.CloseOrders();
            pMoBuy.CloseOrders();
            gDisableOpen = true;
         }
      }
      gPreLoss = currentLoss;
   }
   
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   if(EnableAutoCloseAll) {
       if(pMoSell.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity)) {
         pMoSell.CloseOrders();
         pMoBuy.CloseOrders();
         gBaseEquity =  AccountEquity();
       }
   }
   
    // 检查止损条件
   if(EnableStopLoss) {   
      if(nSellOrderCnt > nBuyOrderCnt) {
         if(pMoSell.CheckStopLoss(StopLossRate)) {
            pMoSell.CloseOrders();
         }
      }
      
      if(nBuyOrderCnt > nSellOrderCnt) {
         if(pMoBuy.CheckStopLoss(StopLossRate)) {
            pMoBuy.CloseOrders();
         }
      } 
   }
   
   preEquity = currentEquity;  
   
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