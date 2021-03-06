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

#define STAGE_MAX 5
bool PassOK = false;
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
   optParam[0].m_BaseOpenLots1 = BaseOpenLotsOne1;
   optParam[0].m_BaseOpenLots2_1 = BaseOpenLotsTwo2_1_1;
   optParam[0].m_BaseOpenLots2_2 = BaseOpenLotsTwo2_2_1;
   optParam[0].m_MultipleForAppend = Multiple1;
   optParam[0].m_MulipleFactorForAppend = MulipleFactorForAppend1;
   optParam[0].m_AppendMax = AppendMax1;
   optParam[0].m_PointOffsetForStage = PointOffsetForStage1;
   optParam[0].m_PointOffsetForAppend = PointOffsetForAppend1;
   optParam[0].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend1;
   optParam[0].m_BackwordForAppend = BackwordForAppend1;
   optParam[0].m_TakeProfitsPerOrder = TakeProfitsPerOrder1;
   optParam[0].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide1;
   optParam[0].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide1;
   optParam[0].m_Backword = Backword1; 
   
   optParam[1].m_BaseOpenLots1 = BaseOpenLotsOne2;
   optParam[1].m_BaseOpenLots2_1 = BaseOpenLotsTwo2_1_2;
   optParam[1].m_BaseOpenLots2_2 = BaseOpenLotsTwo2_2_2;
   optParam[1].m_MultipleForAppend = Multiple2;
   optParam[1].m_MulipleFactorForAppend = MulipleFactorForAppend2;
   optParam[1].m_AppendMax = AppendMax2;
   optParam[1].m_PointOffsetForStage = PointOffsetForStage2;
   optParam[1].m_PointOffsetForAppend = PointOffsetForAppend2;
   optParam[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2;
   optParam[1].m_BackwordForAppend = BackwordForAppend2;
   optParam[1].m_TakeProfitsPerOrder = TakeProfitsPerOrder2;
   optParam[1].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide2;
   optParam[1].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide2;
   optParam[1].m_Backword = Backword2;
   
   optParam[2].m_BaseOpenLots1 = BaseOpenLotsOne3;
   optParam[2].m_BaseOpenLots2_1 = BaseOpenLotsTwo2_1_3;
   optParam[2].m_BaseOpenLots2_2 = BaseOpenLotsTwo2_2_3;
   optParam[2].m_MultipleForAppend = Multiple3;
   optParam[2].m_MulipleFactorForAppend = MulipleFactorForAppend3;
   optParam[2].m_AppendMax = AppendMax3;
   optParam[2].m_PointOffsetForStage = PointOffsetForStage3;
   optParam[2].m_PointOffsetForAppend = PointOffsetForAppend3;
   optParam[2].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3;
   optParam[2].m_BackwordForAppend = BackwordForAppend3;
   optParam[2].m_TakeProfitsPerOrder = TakeProfitsPerOrder3;
   optParam[2].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide3;
   optParam[2].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide3;
   optParam[2].m_Backword = Backword3;
   
   optParam[3].m_BaseOpenLots1 = BaseOpenLotsOne4;
   optParam[3].m_BaseOpenLots2_1 = BaseOpenLotsTwo2_1_4;
   optParam[3].m_BaseOpenLots2_2 = BaseOpenLotsTwo2_2_4;
   optParam[3].m_MultipleForAppend = Multiple4;
   optParam[3].m_MulipleFactorForAppend = MulipleFactorForAppend4;
   optParam[3].m_AppendMax = AppendMax4;
   optParam[3].m_PointOffsetForStage = PointOffsetForStage4;
   optParam[3].m_PointOffsetForAppend = PointOffsetForAppend4;
   optParam[3].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend4;
   optParam[3].m_BackwordForAppend = BackwordForAppend4;
   optParam[3].m_TakeProfitsPerOrder = TakeProfitsPerOrder4;
   optParam[3].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide4;
   optParam[3].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide4;
   optParam[3].m_Backword = Backword4;
   
   optParam[4].m_BaseOpenLots1 = BaseOpenLotsOne5;
   optParam[4].m_BaseOpenLots2_1 = BaseOpenLotsTwo2_1_5;
   optParam[4].m_BaseOpenLots2_2 = BaseOpenLotsTwo2_2_5;
   optParam[4].m_MultipleForAppend = Multiple5;
   optParam[4].m_MulipleFactorForAppend = MulipleFactorForAppend5;
   optParam[4].m_AppendMax = AppendMax5;
   optParam[4].m_PointOffsetForStage = PointOffsetForStage5;
   optParam[4].m_PointOffsetForAppend = PointOffsetForAppend5;
   optParam[4].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend5;
   optParam[4].m_BackwordForAppend = BackwordForAppend5;
   optParam[4].m_TakeProfitsPerOrder = TakeProfitsPerOrder5;
   optParam[4].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide5;
   optParam[4].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide5;
   optParam[4].m_Backword = Backword5;
   
   // 1. 检查持仓情况
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(SYMBOL1, SYMBOL2_1, SYMBOL2_2, OP_BUY, TimeFrame, optParam, MagicNum);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(SYMBOL1, SYMBOL2_1, SYMBOL2_2, OP_SELL, TimeFrame, optParam, MagicNum);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders(optParam, StageMax);
   int nSellOrderCnt = pMoSell.LoadAllOrders(optParam, StageMax);

   if(nBuyOrderCnt == 0)
   {
      if(!StopLongSide) {
         if(IsDataAndTimeAllowed()) {
            if(pMoBuy.IsAllowBuy()) {
                  pMoBuy.OpenOrdersEx(false, optParam, StageMax);
            }            
         }
      }
   }
   if(nSellOrderCnt == 0)
   {
      if(!StopShortSide) {
         if(IsDataAndTimeAllowed()) {
           if(pMoSell.IsAllowSell()) {
               pMoSell.OpenOrdersEx(false, optParam, StageMax);
           }            
         }
      }
   }
   // 2. 检查平仓条件
   if(nBuyOrderCnt > 0) {   
      int nStageBuy = pMoBuy.CalcStageNumber(nBuyOrderCnt, optParam, StageMax);
      int nAppendNumberBuy = pMoBuy.CalcAppendNumber(nStageBuy, nBuyOrderCnt, optParam, StageMax);
      double dTakeProfitsBuy = 0;
      if(nStageBuy == 0 || (CheckAllOrdersInLastStage && nStageBuy == StageMax - 1)) {
           dTakeProfitsBuy = optParam[nStageBuy].m_TakeProfitsPerOrder * nBuyOrderCnt * optParam[nStageBuy].m_TakeProfitsFacorForLongSide;
           if(nStageBuy == 0 && nAppendNumberBuy == 1) {
               dTakeProfitsBuy = 0;
           }
      }else {
           dTakeProfitsBuy = optParam[nStageBuy].m_TakeProfitsPerOrder * nAppendNumberBuy * optParam[nStageBuy].m_TakeProfitsFacorForLongSide;
           if(nAppendNumberBuy == 1) {
               dTakeProfitsBuy = 0;
           }
      }
      
      if(pMoBuy.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsBuy, 
                                 optParam[nStageBuy].m_Backword))
       {
            // 满足平仓条件，平掉本方向的订单
            if(nStageBuy == 0 || (CheckAllOrdersInLastStage && nStageBuy == StageMax - 1)) {
               // 第一阶段或最后一个阶段，平全部订单
               pMoBuy.CloseOrders();
            }else {
               // 其余阶段，仅平掉本阶段的订单            
               pMoBuy.CloseOrders(nAppendNumberBuy);
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
                     && pMoBuy.CheckForAppend(dOffset, factor, param.m_BackwordForAppend, nAppendNumberBuy, bFactor))
               //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
               {
                  LogInfo("+++++++++++++++ Buy Append ++++++++++++++++++++++++++++++++++");
                  string logMsg = StringFormat("多方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                           DoubleToString(dOffset, 4),
                           nStageBuy + 1, nAppendNumberBuy); 
                  PrintFormat(logMsg);
                   // 5. 满足加仓条件，则加仓
                  if(!StopLongSide) {
                    pMoBuy.OpenOrdersEx(false, optParam, StageMax);
                  }
               }
            }     
      }     
   
   }
   
   if(nSellOrderCnt > 0) {
      int nStageSell = pMoSell.CalcStageNumber(nSellOrderCnt, optParam, StageMax);
      int nAppendNumberSell = pMoSell.CalcAppendNumber(nStageSell, nSellOrderCnt, optParam, StageMax);
      double dTakeProfitsSell = 0;
      if(nStageSell == 0 || (CheckAllOrdersInLastStage && nStageSell == StageMax - 1)) {
         dTakeProfitsSell = optParam[nStageSell].m_TakeProfitsPerOrder * nSellOrderCnt * optParam[nStageSell].m_TakeProfitsFacorForShortSide;
          if(nStageSell == 0 && nAppendNumberSell == 1) {
               dTakeProfitsSell = 0;
          }
      }else {
         dTakeProfitsSell = optParam[nStageSell].m_TakeProfitsPerOrder * nAppendNumberSell * optParam[nStageSell].m_TakeProfitsFacorForShortSide;
         if(nAppendNumberSell == 1) {
               dTakeProfitsSell = 0;
         }
      }
         
      if(pMoSell.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsSell, 
                                 optParam[nStageSell].m_Backword))
      {
         if(nStageSell == 0 || (CheckAllOrdersInLastStage && nStageSell == StageMax - 1)) {
            // 第一阶段或最后一个阶段，平全部订单
            pMoSell.CloseOrders();
         }else {
             // 其余阶段，仅平掉本阶段的订单
            
            pMoSell.CloseOrders(nAppendNumberSell);
         }
      }else
      {
         // 4. 不满足平仓条件，则检查加仓条件
         if(nStageSell < StageMax) {
            OptParam param = optParam[nStageSell];
            double dOffset = param.m_PointOffsetForAppend;
            double factor = param.m_PointOffsetFactorForAppend;
            bool bFactor = true;
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
                  && pMoSell.CheckForAppend(dOffset, factor, param.m_BackwordForAppend, nAppendNumberSell, bFactor))
            //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
            {
                  LogInfo("+++++++++++++++ Sell Append ++++++++++++++++++++++++++++++++++");
                  string logMsg = StringFormat("空方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                           DoubleToString(dOffset, 4),
                           nStageSell + 1, nAppendNumberSell); 
                  PrintFormat(logMsg);
                // 5. 满足加仓条件，则加仓
                 if(!StopShortSide) {
                     pMoSell.OpenOrdersEx(false, optParam, StageMax);
                 }
            }
         }
      }
   
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