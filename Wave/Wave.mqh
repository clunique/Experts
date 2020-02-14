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

double mostEquity = 0;
double preEquity = 0;
double gBaseEquity = BaseEquity;

double gStopCloseByUnbalance = false; // 因多空比例失衡导致暂停平仓

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
   string logMsg;
   string symbol = Symbol();
   if(!pWave) {
      pWave = new CWaveOrder(symbol, MagicNum);
      pWave.LoadAllOrders();
   }
   
   pWave.HeartBeat();
   
   if(pWave.GetBuyOrderCnt() == 0 && IsDataAndTimeAllowed()) {
      OptParam param;
      param.m_BaseOpenLots = MinOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForLong;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
      pWave.OpenBuyOrders(param);
      return;
   }
   
   if(pWave.GetSellOrderCnt() == 0 && IsDataAndTimeAllowed()) {
      OptParam param;
      param.m_BaseOpenLots = MinOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForShort;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
      pWave.OpenSellOrders(param);
      return;
   }
   
   bool bAppendOrderInHole = true;;
   if(gStopCloseByUnbalance) {
      bAppendOrderInHole = false;
   }
   
   if(IsDataAndTimeAllowed() 
      && pWave.CheckForAppendBuyOrder(AppendStep, RevertAppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots,
                                       bAppendOrderInHole)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForLong;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
      pWave.OpenBuyOrders(param);
   }
   
   if(IsDataAndTimeAllowed() 
      && pWave.CheckForAppendSellOrder(AppendStep, RevertAppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots,
                                       bAppendOrderInHole)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForShort;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
      pWave.OpenSellOrders(param);
   }
   
   /*
   if(EnableLongShortWholeClose 
      && pWave.GetBuyLots() >= BuyLotsForWholeClose
      && pWave.GetSellLots() >= SellLotsForWholeClose) {
      
      if(pWave.CheckForWholeCloseOrders(ProfitsWholeClose, EnableMovableForWholeClose, BackwardForWholeClose)) {
         pWave.CloseAllSellOrders();
         pWave.CloseAllBuyOrders();
      }
      
   } else {
      pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfitForLong, BackwardForLong,
                                 EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
      pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfitForShort, BackwardForShort,
                                EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
   }
   */
   
   if(!gStopCloseByUnbalance) {
      double dBuyLots = pWave.GetBuyLots();
      double dSellLots = pWave.GetSellLots();
      if(EnableLongShortUnbalance && dBuyLots > 0 && dSellLots > 0) {
         if(dBuyLots >= LotsForUnbalance || dSellLots >= LotsForUnbalance) {
            if(dBuyLots / dSellLots <= UnbalanceRate || dSellLots / dBuyLots <= UnbalanceRate) {
               logMsg = StringFormat("StopClose enabled: dBuyLots=%s, dSellLots=%s",
                                  DoubleToString(dBuyLots, 2), 
                                  DoubleToString(dSellLots, 2));
               LogInfo(logMsg); 
               gStopCloseByUnbalance = true;
            }
         }
      }
   }
   
   if(!gStopCloseByUnbalance) {
      pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfitForLong, BackwardForLong,
                                    EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
      pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfitForShort, BackwardForShort,
                                   EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
   }   
                                 
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }
   
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwardForClose));
   logMsg = StringFormat("gBaseEquity=%s,baseTargetEquity=%s, mostEquity=%s, realTargetEquity=%s",
                                  DoubleToString(gBaseEquity, 2), 
                                  DoubleToString(baseTargetEquity, 2),
                                  DoubleToString(mostEquity, 2),
                                  DoubleToString(realTargetEquity, 2));
   // LogInfo(logMsg); 
   if(EnableAutoCloseAll) {
       if(pWave.CheckForAutoCloseAll(gBaseEquity, preEquity, mostEquity, realTargetEquity)) {
         pWave.CloseAllSellOrders();
         pWave.CloseAllBuyOrders();
         pWave.CleanAllOrders();
         gBaseEquity =  AccountEquity();
         gStopCloseByUnbalance = false;
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