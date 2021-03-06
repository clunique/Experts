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

#define STAGE_MAX 5
bool PassOK = true;
double gPreLoss = 0;
bool gDisableOpen = false;


double mostEquity = 0;
double leastEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;

bool IsDataAndTimeAllowed() {
   if(EnableTradingDate && !IsBetweenDate(OpenOrderStartDate, OpenOrderEndDate)) {
      return false;
   }
   
   if(EnableTradingTime && !IsBetweenTime(OpenOrderStartTime, OpenOrderEndTime)) {
      return false;
   }
   return true; 
}

bool IsCloseOrderDataAndTimeAllowed() {
   if(EnableForbiddenCloseOrderTime && IsBetweenDate(ForbiddenCloseOrderStartTime, ForbiddenCloseOrderEndTime)) {
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
   optParam[0].m_BaseOpenLots2 = BaseOpenLotsTwo1;
   optParam[0].m_MultipleForAppend = Multiple1;
   optParam[0].m_MulipleFactorForAppend = MulipleFactorForAppend1;
   optParam[0].m_AppendMax = AppendMax1;
   optParam[0].m_PointOffsetForStage = PointOffsetForStage1;
   optParam[0].m_PointOffsetForAppend = PointOffsetForAppend1;
   optParam[0].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend1;
   optParam[0].m_TakeProfitsPerOrder = TakeProfitsPerOrder1;
   optParam[0].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide1;
   optParam[0].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide1;
   optParam[0].m_TakeProfitsPerOrderInPassing = TakeProfitsPerOrderInPassing1;
   optParam[0].m_TakeProfitsFacorForLongSideInPassing = TakeProfitsFacorForLongSideInPassing1;
   optParam[0].m_TakeProfitsFacorForShortSideInPassing = TakeProfitsFacorForShortSideInPassing1;
   optParam[0].m_Backword = Backword1; 
   optParam[0].m_OffsetForBuySellStop = 0;
   optParam[0].m_EnableInPassing = EnableInPassing1;
   
   optParam[1].m_BaseOpenLots1 = BaseOpenLotsOne1;
   optParam[1].m_BaseOpenLots2 = BaseOpenLotsTwo1;
   optParam[1].m_MultipleForAppend = Multiple2;
   optParam[1].m_MulipleFactorForAppend = MulipleFactorForAppend2;
   optParam[1].m_AppendMax = AppendMax2;
   optParam[1].m_PointOffsetForStage = PointOffsetForStage2;
   optParam[1].m_PointOffsetForAppend = PointOffsetForAppend2;
   optParam[1].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend2;
   optParam[1].m_TakeProfitsPerOrder = TakeProfitsPerOrder2;
   optParam[1].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide2;
   optParam[1].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide2;
   optParam[1].m_TakeProfitsPerOrderInPassing = TakeProfitsPerOrderInPassing2;
   optParam[1].m_TakeProfitsFacorForLongSideInPassing = TakeProfitsFacorForLongSideInPassing2;
   optParam[1].m_TakeProfitsFacorForShortSideInPassing = TakeProfitsFacorForShortSideInPassing2;
   optParam[1].m_Backword = Backword2;
   optParam[1].m_EnableInPassing = EnableInPassing2;
   
   optParam[2].m_BaseOpenLots1 = BaseOpenLotsOne1;
   optParam[2].m_BaseOpenLots2 = BaseOpenLotsTwo1;
   optParam[2].m_MultipleForAppend = Multiple3;
   optParam[2].m_MulipleFactorForAppend = MulipleFactorForAppend3;
   optParam[2].m_AppendMax = AppendMax3;
   optParam[2].m_PointOffsetForStage = PointOffsetForStage3;
   optParam[2].m_PointOffsetForAppend = PointOffsetForAppend3;
   optParam[2].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend3;
   optParam[2].m_TakeProfitsPerOrder = TakeProfitsPerOrder3;
   optParam[2].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide3;
   optParam[2].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide3;
   optParam[2].m_TakeProfitsPerOrderInPassing = TakeProfitsPerOrderInPassing3;
   optParam[2].m_TakeProfitsFacorForLongSideInPassing = TakeProfitsFacorForLongSideInPassing3;
   optParam[2].m_TakeProfitsFacorForShortSideInPassing = TakeProfitsFacorForShortSideInPassing3;
   optParam[2].m_Backword = Backword3;
   optParam[2].m_EnableInPassing = EnableInPassing3;
   
   optParam[3].m_BaseOpenLots1 = BaseOpenLotsOne1;
   optParam[3].m_BaseOpenLots2 = BaseOpenLotsTwo1;
   optParam[3].m_MultipleForAppend = Multiple4;
   optParam[3].m_MulipleFactorForAppend = MulipleFactorForAppend4;
   optParam[3].m_AppendMax = AppendMax4;
   optParam[3].m_PointOffsetForStage = PointOffsetForStage4;
   optParam[3].m_PointOffsetForAppend = PointOffsetForAppend4;
   optParam[3].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend4;
   optParam[3].m_TakeProfitsPerOrder = TakeProfitsPerOrder4;
   optParam[3].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide4;
   optParam[3].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide4;
   optParam[3].m_TakeProfitsPerOrderInPassing = TakeProfitsPerOrderInPassing4;
   optParam[3].m_TakeProfitsFacorForLongSideInPassing = TakeProfitsFacorForLongSideInPassing4;
   optParam[3].m_TakeProfitsFacorForShortSideInPassing = TakeProfitsFacorForShortSideInPassing4;
   optParam[3].m_Backword = Backword4;
   optParam[3].m_EnableInPassing = EnableInPassing4;
   
   optParam[4].m_BaseOpenLots1 = BaseOpenLotsOne1;
   optParam[4].m_BaseOpenLots2 = BaseOpenLotsTwo1;
   optParam[4].m_MultipleForAppend = Multiple5;
   optParam[4].m_MulipleFactorForAppend = MulipleFactorForAppend5;
   optParam[4].m_AppendMax = AppendMax5;
   optParam[4].m_PointOffsetForStage = PointOffsetForStage5;
   optParam[4].m_PointOffsetForAppend = PointOffsetForAppend5;
   optParam[4].m_PointOffsetFactorForAppend = PointOffsetFactorForAppend5;
   optParam[4].m_TakeProfitsPerOrder = TakeProfitsPerOrder5;
   optParam[4].m_TakeProfitsFacorForLongSide = TakeProfitsFacorForLongSide5;
   optParam[4].m_TakeProfitsFacorForShortSide = TakeProfitsFacorForShortSide5;
   optParam[4].m_TakeProfitsPerOrderInPassing = TakeProfitsPerOrderInPassing5;
   optParam[4].m_TakeProfitsFacorForLongSideInPassing = TakeProfitsFacorForLongSideInPassing5;
   optParam[4].m_TakeProfitsFacorForShortSideInPassing = TakeProfitsFacorForShortSideInPassing5;
   optParam[4].m_Backword = Backword5;
   optParam[4].m_EnableInPassing = EnableInPassing5;
   
   // 1. 检查持仓情况
   bool bDiff = true;
   if(0 == StringCompare(PRICE_SUM_OR_DIFF, "和", false) 
      || 0 == StringCompare(PRICE_SUM_OR_DIFF, "SUM", false)) {
      bDiff = false;
   } 
   
   if(!pMoBuy) {
      pMoBuy = new CMartinOrder(SYMBOL1, SYMBOL2, OP_BUY, TimeFrame, optParam, MagicNum, bDiff);
   }
   
   if(!pMoSell) {
      pMoSell = new CMartinOrder(SYMBOL1, SYMBOL2, OP_SELL, TimeFrame, optParam, MagicNum, bDiff);
   }
   int nBuyOrderCnt = pMoBuy.LoadAllOrders(optParam, StageMaxForLong);
   int nSellOrderCnt = pMoSell.LoadAllOrders(optParam, StageMaxForShort);

   if(nBuyOrderCnt == 0)
   {
      if(!StopLongSide) {
         if(IsDataAndTimeAllowed()) {
            int nOrderCnt = 1;            
            if(pMoBuy.IsAllowBuy()) {
               pMoBuy.OpenOrdersEx(false, optParam, StageMaxForLong);
            }            
         }
      }
   }
   if(nSellOrderCnt == 0)
   {
      if(!StopShortSide) {
         if(IsDataAndTimeAllowed()) {
            int nOrderCnt = 1;
            if(pMoSell.IsAllowSell()) {
               pMoSell.OpenOrdersEx(false, optParam, StageMaxForShort);
            }            
         }
      }
   }
   // 2. 检查平仓条件
   if(nBuyOrderCnt > 0) {   
      int nStageBuy = pMoBuy.CalcStageNumber(nBuyOrderCnt, optParam, StageMaxForLong);
      int nAppendNumberBuy = pMoBuy.CalcAppendNumber(nStageBuy, nBuyOrderCnt, optParam, StageMaxForLong);
      double dTakeProfitsBuy = 0;
      double dTakeProfitsBuyInPassing = 0;
      if(CheckAllOrdersInLastStage && nStageBuy == StageMaxForLong - 1) {
           dTakeProfitsBuy = optParam[nStageBuy].m_TakeProfitsPerOrder * nBuyOrderCnt * optParam[nStageBuy].m_TakeProfitsFacorForLongSide;
           dTakeProfitsBuyInPassing = optParam[nStageBuy].m_TakeProfitsPerOrderInPassing * nBuyOrderCnt * optParam[nStageBuy].m_TakeProfitsFacorForLongSideInPassing;
           
           if(nStageBuy == 0 && nAppendNumberBuy == 1) {
               dTakeProfitsBuy = 0;
           }
      }else {
           if(nAppendNumberBuy > 2) {
              nAppendNumberBuy = 2; 
           }
           
           dTakeProfitsBuy = optParam[nStageBuy].m_TakeProfitsPerOrder * nAppendNumberBuy * optParam[nStageBuy].m_TakeProfitsFacorForLongSide;
           dTakeProfitsBuyInPassing = optParam[nStageBuy].m_TakeProfitsPerOrderInPassing * nAppendNumberBuy * optParam[nStageBuy].m_TakeProfitsFacorForLongSideInPassing;
           if(nAppendNumberBuy == 1) {
               dTakeProfitsBuy = 0;
           }
      }
      
      if(pMoBuy.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsBuy, 
                                 optParam[nStageBuy].m_Backword, false))
       {
            // 满足平仓条件，平掉本方向的订单
            /*
            if(CheckAllOrdersInLastStage && nStageBuy == StageMaxForLong - 1) {
               // 第一阶段或最后一个阶段，平全部订单
               pMoBuy.CloseOrders();
            }else {
               // 其余阶段，仅平掉本阶段的订单            
               pMoBuy.CloseOrders(nAppendNumberBuy, false);
            }
            */
            if(IsCloseOrderDataAndTimeAllowed()) {
               pMoBuy.CloseOrders(nAppendNumberBuy, false);
            }
       }else if(pMoBuy.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsBuyInPassing, 
                                 optParam[nStageBuy].m_Backword, true))
       {
         // 本阶段带单平仓            
         if(IsCloseOrderDataAndTimeAllowed()) {
            pMoBuy.CloseOrders(nAppendNumberBuy, true);
         }
            
       }else 
       {
            // 4. 不满足平仓条件，则检查加仓条件
            if(nStageBuy < StageMaxForLong) {
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
                    // && pMoBuy.IsAllowBuy() 
                     && pMoBuy.CheckForAppend(dOffset, factor, param.m_Backword, nAppendNumberBuy, bFactor))
               //if(pMoBuy.CheckForAppendByOffset(PointOffsetForAppend))
               {
                  LogInfo("+++++++++++++++ Buy Append ++++++++++++++++++++++++++++++++++");
                  string logMsg = StringFormat("多方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                           DoubleToString(dOffset, 4),
                           nStageBuy + 1, nAppendNumberBuy); 
                  PrintFormat(logMsg);
                   // 5. 满足加仓条件，则加仓
                  if(!StopLongSide) {
                    pMoBuy.OpenOrdersEx(false, optParam, StageMaxForLong);
                  }
               }
            }     
      }     
   
   }
   
   if(nSellOrderCnt > 0) {
      int nStageSell = pMoSell.CalcStageNumber(nSellOrderCnt, optParam, StageMaxForShort);
      int nAppendNumberSell = pMoSell.CalcAppendNumber(nStageSell, nSellOrderCnt, optParam, StageMaxForShort);
      double dTakeProfitsSell = 0;
      double dTakeProfitsSellInPassing = 0;
      if(nStageSell == 0 || (CheckAllOrdersInLastStage && nStageSell == StageMaxForShort - 1)) {
          dTakeProfitsSell = optParam[nStageSell].m_TakeProfitsPerOrder * nSellOrderCnt * optParam[nStageSell].m_TakeProfitsFacorForShortSide;
          dTakeProfitsSellInPassing = optParam[nStageSell].m_TakeProfitsPerOrderInPassing * nSellOrderCnt * optParam[nStageSell].m_TakeProfitsFacorForShortSideInPassing;
          
          if(nStageSell == 0 && nAppendNumberSell == 1) {
               dTakeProfitsSell = 0;
          }
      }else {
         if(nAppendNumberSell > 2) {
            nAppendNumberSell = 2;
         }
         dTakeProfitsSell = optParam[nStageSell].m_TakeProfitsPerOrder * nAppendNumberSell * optParam[nStageSell].m_TakeProfitsFacorForShortSide;
         dTakeProfitsSellInPassing = optParam[nStageSell].m_TakeProfitsPerOrderInPassing * nAppendNumberSell * optParam[nStageSell].m_TakeProfitsFacorForShortSideInPassing;
         
         if(nAppendNumberSell == 1) {
               dTakeProfitsSell = 0;
         }
      }
         
      if(pMoSell.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsSell, 
                                 optParam[nStageSell].m_Backword, false))
      {
         /*
         if(CheckAllOrdersInLastStage && nStageSell == StageMaxForShort - 1) {
            // 第一阶段或最后一个阶段，平全部订单
            pMoSell.CloseOrders();
         }else {
             // 其余阶段，仅平掉本阶段的订单
            pMoSell.CloseOrders(nAppendNumberSell, optParam[nStageSell].m_EnableInPassing);
         }
         */
         if(IsCloseOrderDataAndTimeAllowed()) {
            pMoSell.CloseOrders(nAppendNumberSell, false);
         }
      }else if(pMoSell.CheckForClose1(PointOffsetForProfit, 
                                 dTakeProfitsSellInPassing, 
                                 optParam[nStageSell].m_Backword, true))
      {
         // 本阶段带单平仓
         if(IsCloseOrderDataAndTimeAllowed()) {
            pMoSell.CloseOrders(nAppendNumberSell, true);
         }
         
      }else
      {
         // 4. 不满足平仓条件，则检查加仓条件
         if(nStageSell < StageMaxForShort) {
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
                  // && pMoSell.IsAllowSell() 
                  && pMoSell.CheckForAppend(dOffset, factor, param.m_Backword, nAppendNumberSell, bFactor))
            //if(pMoSell.CheckForAppendByOffset(PointOffsetForAppend))//, DeficitForAppend, Backword))
            {
                  LogInfo("+++++++++++++++ Sell Append ++++++++++++++++++++++++++++++++++");
                  string logMsg = StringFormat("空方加仓：offset = %s, Stage = %d, AppendNumber = %d.", 
                           DoubleToString(dOffset, 4),
                           nStageSell + 1, nAppendNumberSell); 
                  PrintFormat(logMsg);
                // 5. 满足加仓条件，则加仓
                 if(!StopShortSide) {
                     pMoSell.OpenOrdersEx(false, optParam, StageMaxForShort);
                 }
            }
         }
      }
   
   }
   
   
    // 整体移动止盈
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   if(EnableAutoCloseAll) {
       double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
       mostEquity =  MathMax(currentEquity, mostEquity);
       if(leastEquity > 0) {
         leastEquity =  MathMin(currentEquity, leastEquity);
       }else {
         leastEquity =  currentEquity;
       }
       if(pMoSell.CheckForAutoCloseAll(gBaseEquity, preEquity, leastEquity, mostEquity, realTargetEquity)) {
         pMoBuy.CloseOrders();
         pMoSell.CloseOrders();
         gBaseEquity =  AccountInfoDouble(ACCOUNT_EQUITY);
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