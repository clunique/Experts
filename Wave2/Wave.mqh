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

#define MARTIN_APPEND_MAX 6

bool PassOK = false;

bool gDisableOpen = false;

double mostEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;

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
   string symbol = Symbol();
   if(!pWave) {
      pWave = new CWaveOrder(symbol, MagicNum); 
      pWave.LoadAllOrders();
   }
      
   pWave.HeartBeat();
   
   int nBuyOrderCnt = pWave.GetBuyOrderCnt();
   int nBuyStopCount = pWave.GetBuyStopOrderCnt();
   int nSellOrderCnt = pWave.GetSellOrderCnt();
   int nSellStopCount = pWave.GetSellStopOrderCnt();
   string logMsg = StringFormat("New tickcount(%s): nBuyOrderCnt = %d, nBuyStopCount = %d, nSellOrderCnt = %d, nSellStopCount = %d ",
                                     symbol,nBuyOrderCnt, 
                                     nBuyStopCount, nSellOrderCnt, nSellStopCount);
   LogInfo(logMsg);
         
   
   
   if(IsDataAndTimeAllowed()) {
      if(pWave.GetBuyOrderCnt() == 0) {
         // 尚未开任何多单
         if(pWave.GetBuyStopOrderCnt() == 0) {
            // 尚未开任何挂单，则开挂单
            OptParam param;
            param.m_BaseOpenLots = MinOpenLots;
            param.m_StopLossPoint = PointOffsetForStopLossForLong;
            param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
            param.m_OffsetForBuySellStop = OffsetForBuySellStop;
            pWave.OpenBuyStopOrders(param);
            return;
         }
      }
   }
   
   if(IsDataAndTimeAllowed()) {
      if(pWave.GetSellOrderCnt() == 0) {
         // 尚未开任何空单
         if(pWave.GetSellStopOrderCnt() == 0) {
            // 尚未开任何挂单，则开挂单
            OptParam param;
            param.m_BaseOpenLots = MinOpenLots;
            param.m_StopLossPoint = PointOffsetForStopLossForShort;
            param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
            param.m_OffsetForBuySellStop = OffsetForBuySellStop;
            pWave.OpenSellStopOrders(param);
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
      
      double dRevertAppendLotsForLong[MARTIN_APPEND_MAX];
      dRevertAppendLotsForLong[0] = RevertAppendLotsForLong1;
      dRevertAppendLotsForLong[1] = RevertAppendLotsForLong2;
      dRevertAppendLotsForLong[2] = RevertAppendLotsForLong3;
      dRevertAppendLotsForLong[3] = RevertAppendLotsForLong4;
      dRevertAppendLotsForLong[4] = RevertAppendLotsForLong5;
      dRevertAppendLotsForLong[5] = RevertAppendLotsForLong6;
      
      // 检查多方的马丁加仓订单
      if(pWave.CheckForAppendBuyMartinOrder(dRevertAppendStepsForLong, SpreadMax,
                                          MaxHandlingLots)) {
           // 多方马丁加仓
           int nBuyMartinCount = pWave.GetBuyMartinOrderCnt();
           OptParam param;
           param.m_BaseOpenLots = dRevertAppendLotsForLong[nBuyMartinCount];
           param.m_StopLossPoint = PointOffsetForStopLossForLongMartin;
           param.m_TakeProfitPoint = PointOffsetForTakeProfitForLongMartin;
           pWave.OpenBuyMartinOrders(param);
           pWave.CloseAllSellStopOrders();
           pWave.LoadSellStopOrders();
      }
      
      double dRevertAppendStepsForShort[MARTIN_APPEND_MAX];
      dRevertAppendStepsForShort[0] = RevertAppendStepForShort1;
      dRevertAppendStepsForShort[1] = RevertAppendStepForShort2;
      dRevertAppendStepsForShort[2] = RevertAppendStepForShort3;
      dRevertAppendStepsForShort[3] = RevertAppendStepForShort4;
      dRevertAppendStepsForShort[4] = RevertAppendStepForShort5;
      dRevertAppendStepsForShort[5] = RevertAppendStepForShort6;
      
      double dRevertAppendLotsForShort[MARTIN_APPEND_MAX];
      dRevertAppendLotsForShort[0] = RevertAppendLotsForShort1;
      dRevertAppendLotsForShort[1] = RevertAppendLotsForShort2;
      dRevertAppendLotsForShort[2] = RevertAppendLotsForShort3;
      dRevertAppendLotsForShort[3] = RevertAppendLotsForShort4;
      dRevertAppendLotsForShort[4] = RevertAppendLotsForShort5;
      dRevertAppendLotsForShort[5] = RevertAppendLotsForShort6;
      
      // 检查空方的马丁加仓订单
      if(pWave.CheckForAppendSellMartinOrder(dRevertAppendStepsForShort, SpreadMax,
                                          MaxHandlingLots)) {
         // 空方马丁加仓
         int nSellMartinCount = pWave.GetSellMartinOrderCnt();
         OptParam param;
         param.m_BaseOpenLots = dRevertAppendLotsForShort[nSellMartinCount];
         param.m_StopLossPoint = PointOffsetForStopLossForShortMartin;
         param.m_TakeProfitPoint = PointOffsetForTakeProfitForShortMartin;
         pWave.OpenSellMartinOrders(param);
         pWave.CloseAllBuyStopOrders();
         pWave.LoadBuyStopOrders();
      }
   }
   
   int nBuyMartinCount = pWave.GetBuyMartinOrderCnt();
   if(nBuyMartinCount > 0) {
      // 已经持有马丁多单，走马丁平仓判断流程
      LogInfo("============ 多单马丁平仓判断流程 =================");
      double highestBuyPrice = pWave.GetHighestBuyOrderPrice();
      double lowestBuyMartinPrice = pWave.GetLowestBuyMartinOrderPrice();
      double dPriceDiff = highestBuyPrice - lowestBuyMartinPrice;
      double dBuyLots = pWave.GetAllBuyLots();
        
      double dTakeProfitsBuy = (dPriceDiff / Point) * dBuyLots * TakeProfitsFacorForLongMartin;
      pWave.CheckForCloseBuyMartinOrders(dTakeProfitsBuy, BackwordForLongMartin);
   }else {
      LogInfo("============ 多单普通轮转的平仓判断流程 =================");
      // 没有持有马丁多单，走普通轮转的平仓判断流程
      pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfitForLong, BackwordForLong,
                                 EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
   }
   
   int nSellMartinCount = pWave.GetSellMartinOrderCnt();
   if(nSellMartinCount > 0) {
      // 已经持有马丁多单，走马丁平仓判断流程
      LogInfo("============ 空单马丁平仓判断流程 =================");
      double lowestSellMartinPrice = pWave.GetLowestSellOrderPrice();
      double highestSellPrice = pWave.GetHighestSellMartinOrderPrice();
      double dPriceDiff = highestSellPrice - lowestSellMartinPrice;
      double dSellLots = pWave.GetAllSellLots();
        
      double dTakeProfitsSell = (dPriceDiff / Point) * dSellLots * TakeProfitsFacorForShortMartin;
      pWave.CheckForCloseSellMartinOrders(dTakeProfitsSell, BackwordForShortMartin);
   }else {
      LogInfo("============ 空单普通轮转的平仓判断流程 =================");
      pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfitForShort, BackwordForShort,
                                 EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
   }
                                
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }
   
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   if(EnableAutoCloseAll) {
       if(pWave.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity)) {
         pWave.CloseAllOrders();
         pWave.CleanAllOrders();
         gBaseEquity =  AccountEquity();
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