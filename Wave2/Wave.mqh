//+------------------------------------------------------------------+
//|                                                    OneDirect.mqh |
//|                                                          Cuilong |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "http://www.mql4.com"
#property strict
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
#include "PubVar.mqh"
#include "ClUtil.mqh"
#include "WaveOrder.mqh"



bool PassOK = false;

bool gDisableOpen = false;

bool gDisableOpenBuy = false;
bool gDisableOpenSell = false;

double mostEquity = 0;
double leastEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;

int gBuyStopCount = 0;
int gSellStopCount = 0;

CWaveOrder * pWave = NULL;

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
   string logMsg = "";
   string symbol = Symbol();
   
   if(gDisableOpen) return;
   
   if(!pWave) {
      pWave = new CWaveOrder(symbol, MagicNum); 
      pWave.LoadAllOrders();
   }
      
   pWave.HeartBeat();
   
   pWave.LoadBuyStopOrders();
   pWave.LoadSellStopOrders();
   
   int nBuyStopCount = pWave.GetBuyStopOrderCnt();
   if(nBuyStopCount != gBuyStopCount) {
      logMsg = StringFormat("BuyStopCount changed: %d -> %d",
                                     gBuyStopCount, nBuyStopCount);
      LogInfo(logMsg);
   
      gBuyStopCount = nBuyStopCount;
      
      // 当多方挂单数量变化时，重新装载多方订单
      pWave.LoadBuyOrders();
      
   }
   
   int nSellStopCount = pWave.GetSellStopOrderCnt();
   if(nSellStopCount != gSellStopCount) {
      logMsg = StringFormat("SellStopCount changed: %d -> %d",
                                     gSellStopCount, nSellStopCount);
      LogInfo(logMsg);
      gSellStopCount = nSellStopCount;
      
      // 当空方挂单数量变化时，重新装载空方订单
      pWave.LoadSellOrders();
   }
   
   int nBuyOrderCnt = pWave.GetBuyOrderCnt();
   int nSellOrderCnt = pWave.GetSellOrderCnt();
   
   logMsg = StringFormat("New tickcount(%s): nBuyOrderCnt = %d, nBuyStopCount = %d, nSellOrderCnt = %d, nSellStopCount = %d ",
                                     symbol,nBuyOrderCnt, 
                                     nBuyStopCount, nSellOrderCnt, nSellStopCount);
   LogInfo(logMsg);
         
   
   
   if(IsDataAndTimeAllowed()) {
      if(pWave.GetBuyOrderCnt() == 0) {
         // 尚未开任何多单
         bool bNeedOpen = true;
         if(gDisableOpenBuy) {
            bNeedOpen = false;
         }
         
         if(bNeedOpen) {
            if(EnableCheckOppositeOrderCount && pWave.GetSellMartinOrderCnt() >= OppositeOrderCount) {
               bNeedOpen = false;
               gDisableOpenBuy = true;
            }
         } 
         
         if(bNeedOpen) {
            if(pWave.GetBuyStopOrderCnt() != 0) {
               bNeedOpen = false;
            }
         }
         
         if(bNeedOpen) {
            // 尚未开任何挂单，则开挂单
            OptParam param;
            param.m_BaseOpenLots = MinOpenLots;
            param.m_StopLossPoint = PointOffsetForStopLossForLong;
            param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
            param.m_OffsetForBuySellStop = OffsetForBuySellStop;
            pWave.OpenBuyStopOrders(param);
            // pWave.OpenBuyOrders(param);
            return;
         }
      }
   }
   
   if(IsDataAndTimeAllowed()) {
      if(pWave.GetSellOrderCnt() == 0) {
         // 尚未开任何空单
         
         bool bNeedOpen = true;
         if(gDisableOpenSell) {
            bNeedOpen = false;
         }
         
         if(bNeedOpen) {
            if(EnableCheckOppositeOrderCount && pWave.GetBuyMartinOrderCnt() >= OppositeOrderCount) {
               bNeedOpen = false;
               gDisableOpenSell = true;
            }
         } 
         
         if(bNeedOpen) {
            if(pWave.GetSellStopOrderCnt() != 0) {
               bNeedOpen = false;
            }
         }
         
         if(bNeedOpen) {
            // 尚未开任何挂单，则开挂单
            OptParam param;
            param.m_BaseOpenLots = MinOpenLots;
            param.m_StopLossPoint = PointOffsetForStopLossForShort;
            param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
            param.m_OffsetForBuySellStop = OffsetForBuySellStop;
            pWave.OpenSellStopOrders(param);
            // pWave.OpenSellOrders(param);
            return;
         }
      }
   }
  
   
   if(IsDataAndTimeAllowed()) {
      // 检查多方的轮转订单
      if(pWave.CheckForAppendBuyOrder(AppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots)) {
         OptParam param;
         param.m_BaseOpenLots = BaseOpenLots;
         param.m_StopLossPoint = PointOffsetForStopLossForLong;
         param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
         pWave.OpenBuyOrders(param);
      }
      // 检查空方的轮转订单
      if(pWave.CheckForAppendSellOrder(AppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots)) {
         OptParam param;
         param.m_BaseOpenLots = BaseOpenLots;
         param.m_StopLossPoint = PointOffsetForStopLossForShort;
         param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
         pWave.OpenSellOrders(param);
      }
      
      double dRevertAppendStepsForLong[MARTIN_APPEND_MAX];
      dRevertAppendStepsForLong[0] = RevertAppendStepForLong1;
      dRevertAppendStepsForLong[1] = RevertAppendStepForLong2;
      dRevertAppendStepsForLong[2] = RevertAppendStepForLong3;
      dRevertAppendStepsForLong[3] = RevertAppendStepForLong4;
      dRevertAppendStepsForLong[4] = RevertAppendStepForLong5;
      dRevertAppendStepsForLong[5] = RevertAppendStepForLong6;
      dRevertAppendStepsForLong[6] = RevertAppendStepForLong7;
      dRevertAppendStepsForLong[7] = RevertAppendStepForLong8;
      dRevertAppendStepsForLong[8] = RevertAppendStepForLong9;
      dRevertAppendStepsForLong[9] = RevertAppendStepForLong10;
      
      double dRevertAppendLotsForLong[MARTIN_APPEND_MAX];
      dRevertAppendLotsForLong[0] = RevertAppendLotsForLong1;
      dRevertAppendLotsForLong[1] = RevertAppendLotsForLong2;
      dRevertAppendLotsForLong[2] = RevertAppendLotsForLong3;
      dRevertAppendLotsForLong[3] = RevertAppendLotsForLong4;
      dRevertAppendLotsForLong[4] = RevertAppendLotsForLong5;
      dRevertAppendLotsForLong[5] = RevertAppendLotsForLong6;
      dRevertAppendLotsForLong[6] = RevertAppendLotsForLong7;
      dRevertAppendLotsForLong[7] = RevertAppendLotsForLong8;
      dRevertAppendLotsForLong[8] = RevertAppendLotsForLong9;
      dRevertAppendLotsForLong[9] = RevertAppendLotsForLong10;
      
      // 检查多方的马丁加仓订单
      if(pWave.CheckForAppendBuyMartinOrder(dRevertAppendStepsForLong, SpreadMax,
                                          MaxHandlingLots, BackwordForAppendLongMartin)) {
           // 多方马丁加仓
           int nBuyMartinCount = pWave.GetBuyMartinOrderCnt();
           if(nBuyMartinCount < MARTIN_APPEND_MAX) {
              OptParam param;
              param.m_BaseOpenLots = dRevertAppendLotsForLong[nBuyMartinCount];
              param.m_StopLossPoint = PointOffsetForStopLossForLongMartin;
              param.m_TakeProfitPoint = PointOffsetForTakeProfitForLongMartin;
              pWave.OpenBuyMartinOrders(param);
              pWave.CloseAllSellStopOrders();
              pWave.LoadSellStopOrders();
           }    
      }
      
      double dRevertAppendStepsForShort[MARTIN_APPEND_MAX];
      dRevertAppendStepsForShort[0] = RevertAppendStepForShort1;
      dRevertAppendStepsForShort[1] = RevertAppendStepForShort2;
      dRevertAppendStepsForShort[2] = RevertAppendStepForShort3;
      dRevertAppendStepsForShort[3] = RevertAppendStepForShort4;
      dRevertAppendStepsForShort[4] = RevertAppendStepForShort5;
      dRevertAppendStepsForShort[5] = RevertAppendStepForShort6;
      dRevertAppendStepsForShort[6] = RevertAppendStepForShort7;
      dRevertAppendStepsForShort[7] = RevertAppendStepForShort8;
      dRevertAppendStepsForShort[8] = RevertAppendStepForShort9;
      dRevertAppendStepsForShort[9] = RevertAppendStepForShort10;
      
      double dRevertAppendLotsForShort[MARTIN_APPEND_MAX];
      dRevertAppendLotsForShort[0] = RevertAppendLotsForShort1;
      dRevertAppendLotsForShort[1] = RevertAppendLotsForShort2;
      dRevertAppendLotsForShort[2] = RevertAppendLotsForShort3;
      dRevertAppendLotsForShort[3] = RevertAppendLotsForShort4;
      dRevertAppendLotsForShort[4] = RevertAppendLotsForShort5;
      dRevertAppendLotsForShort[5] = RevertAppendLotsForShort6;
      dRevertAppendLotsForShort[6] = RevertAppendLotsForShort7;
      dRevertAppendLotsForShort[7] = RevertAppendLotsForShort8;
      dRevertAppendLotsForShort[8] = RevertAppendLotsForShort9;
      dRevertAppendLotsForShort[9] = RevertAppendLotsForShort10;
      
      // 检查空方的马丁加仓订单
      if(pWave.CheckForAppendSellMartinOrder(dRevertAppendStepsForShort, SpreadMax,
                                          MaxHandlingLots, BackwordForAppendShortMartin)) {
         // 空方马丁加仓
         int nSellMartinCount = pWave.GetSellMartinOrderCnt();
         if(nSellMartinCount < MARTIN_APPEND_MAX) {
            OptParam param;
            param.m_BaseOpenLots = dRevertAppendLotsForShort[nSellMartinCount];
            param.m_StopLossPoint = PointOffsetForStopLossForShortMartin;
            param.m_TakeProfitPoint = PointOffsetForTakeProfitForShortMartin;
            pWave.OpenSellMartinOrders(param);
            pWave.CloseAllBuyStopOrders();
            pWave.LoadBuyStopOrders();
         }
        
      }
   }
   
   if(EnableLongShortWholeClose 
      && pWave.GetAllBuyLots() >= BuyLotsForWholeClose
      && pWave.GetAllSellLots() >= SellLotsForWholeClose) {
      // 已经持有马丁多单，走马丁平仓判断流程
         LogInfo("============ 整体止盈判断流程 =================");
      if(pWave.CheckForWholeCloseOrders(ProfitsWholeClose, EnableMovableForWholeClose, BackwardForWholeClose)) {
         pWave.CloseAllOrders();
         pWave.CleanAllOrders();
      }
      
   }else {
   
      int nBuyMartinCount = pWave.GetBuyMartinOrderCnt();
      if(nBuyMartinCount > 0) {
         if(nBuyMartinCount < EnableStage2CountForLongMartin2) {
            // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 多单马丁平仓判断流程 =================");
            double highestBuyPrice = pWave.GetHighestBuyOrderPrice();
            double lowestBuyMartinPrice = pWave.GetLowestBuyMartinOrderPrice();
            double dPriceDiff = highestBuyPrice - lowestBuyMartinPrice;
            double dBuyLots = pWave.GetAllBuyLots();
              
            double dTakeProfitsBuy = (dPriceDiff / Point) * dBuyLots * TakeProfitsFacorForLongMartin;
            if(pWave.CheckForCloseBuyMartinOrders(dTakeProfitsBuy, BackwordForLongMartin)) {
               gDisableOpenSell = false;
            }
         }else if(nBuyMartinCount >= EnableStage2CountForLongMartin2 
                  && nBuyMartinCount < EnableStage3CountForLongMartin3) {
             // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 多单马丁平仓判断流程(二阶段) =================");
            double highestBuyPrice = pWave.GetHighestBuyMartinOrderPrice();
            double lowestBuyMartinPrice = pWave.GetLowestBuyMartinOrderPrice();
            double dPriceDiff = highestBuyPrice - lowestBuyMartinPrice;
            double dBuyLots = pWave.GetMartinBuyLotsForStage2();
              
            double dTakeProfitsBuy = (dPriceDiff / Point) * dBuyLots * TakeProfitsFacorForLongMartin2;
            pWave.CheckForCloseBuyMartinOrdersStage2(dTakeProfitsBuy, BackwordForLongMartin2, CheckLastNForLong);
         } else {
             LogInfo("============ 多单马丁平仓判断流程(三阶段) =================");
            double highestBuyPrice = pWave.GetHighestBuyMartinOrderPrice();
            double lowestBuyMartinPrice = pWave.GetLowestBuyMartinOrderPrice();
            double dPriceDiff = highestBuyPrice - lowestBuyMartinPrice;
            double dBuyLots = pWave.GetMartinBuyLotsForStage2();
              
            double dTakeProfitsBuy = dBuyLots * TakeProfitsForLongMartin3;
            pWave.CheckForCloseBuyMartinOrdersStage3(dTakeProfitsBuy);
         }
      }else {
         LogInfo("============ 多单普通轮转的平仓判断流程 =================");
         // 没有持有马丁多单，走普通轮转的平仓判断流程
         pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfitForLong, BackwordForLong,
                                    EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
      }
      
      int nSellMartinCount = pWave.GetSellMartinOrderCnt();
      if(nSellMartinCount > 0) {
         if(nSellMartinCount < EnableStage2CountForShortMartin2) {
            // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 空单马丁平仓判断流程 =================");
            double lowestSellPrice = pWave.GetLowestSellOrderPrice();
            double highestSellMartinPrice = pWave.GetHighestSellMartinOrderPrice();
            double dPriceDiff = highestSellMartinPrice - lowestSellPrice;
            double dSellLots = pWave.GetAllSellLots();
              
            double dTakeProfitsSell = (dPriceDiff / Point) * dSellLots * TakeProfitsFacorForShortMartin;
            if(pWave.CheckForCloseSellMartinOrders(dTakeProfitsSell, BackwordForShortMartin)) {
               gDisableOpenBuy = false;
            }
         } else if(nSellMartinCount >= EnableStage2CountForShortMartin2
                     && (nSellMartinCount < EnableStage3CountForShortMartin3)) {
            // 已经持有马丁多单，走马丁平仓判断流程
            LogInfo("============ 空单马丁平仓判断流程(二阶段) =================");
            double lowestSellPrice = pWave.GetLowestSellMartinOrderPrice();
            double highestSellMartinPrice = pWave.GetHighestSellMartinOrderPrice();
            double dPriceDiff = highestSellMartinPrice - lowestSellPrice;
            double dSellLots = pWave.GetMartinSellLotsForStage2();
              
            double dTakeProfitsSell = (dPriceDiff / Point) * dSellLots * TakeProfitsFacorForShortMartin2;
            pWave.CheckForCloseSellMartinOrdersStage2(dTakeProfitsSell, BackwordForShortMartin2, CheckLastNForShort);
         } else {
            LogInfo("============ 空单马丁平仓判断流程(三阶段) =================");
            double lowestSellPrice = pWave.GetLowestSellMartinOrderPrice();
            double highestSellMartinPrice = pWave.GetHighestSellMartinOrderPrice();
            double dPriceDiff = highestSellMartinPrice - lowestSellPrice;
            double dSellLots = pWave.GetMartinSellLotsForStage2();
              
            double dTakeProfitsSell = dSellLots * TakeProfitsForShortMartin3;
            pWave.CheckForCloseSellMartinOrdersStage3(dTakeProfitsSell);
         }
      }else {
         LogInfo("============ 空单普通轮转的平仓判断流程 =================");
         pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfitForShort, BackwordForShort,
                                    EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
      }
   }
                                
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }
   
   if(currentEquity < leastEquity) {
      leastEquity = currentEquity;
   }
   
   // 整体移动止盈
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   if(EnableAutoCloseAll) {
       if(pWave.CheckForAutoCloseAll(gBaseEquity, preEquity, leastEquity, mostEquity, realTargetEquity)) {
         pWave.CloseAllOrders();
         pWave.CleanAllOrders();
         gBaseEquity =  AccountEquity();
       }
   }  
    
   // 整体移动止损
   double targetStopLossEquity = gBaseEquity * (1 - AutoCloseAllForStopLossRate);
   if(EnableAutoCloseAllForStopLoss) {
      // 启用了整体止损
      if(pWave.CheckForAutoStopLossAll(targetStopLossEquity)) {
         pWave.CloseAllOrders();
         pWave.CleanAllOrders();
         gBaseEquity =  AccountEquity();
         if(!ContinueOpenAfterCloseAllForStopLoss) {
            gDisableOpen = true;
         }
      }
      
   }
   preEquity = currentEquity;  
  
}

void Destroy()
{
   if(pWave) {
      delete pWave; 
      pWave = NULL;
   }
}