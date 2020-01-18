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
   
   if(IsDataAndTimeAllowed() 
      && pWave.CheckForAppendBuyOrder(AppendStep, RevertAppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForLong;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForLong;
      pWave.OpenBuyOrders(param);
   }
   
   if(IsDataAndTimeAllowed() 
      && pWave.CheckForAppendSellOrder(AppendStep, RevertAppendStep, SpreadMax,
                                       EnableLongShortRateForAppend, EnableLongShortRateLotsForAppend, MaxHandlingLots)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLossForShort;
      param.m_TakeProfitPoint = PointOffsetForTakeProfitForShort;
      pWave.OpenSellOrders(param);
   }
   
   pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfitForLong, BackwordForLong,
                                 EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
   pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfitForShort, BackwordForShort,
                                 EnableLongShortRateForClose, EnableLongShortRateLotsForClose);
                                 
   double currentEquity = AccountEquity(); // 净值
   if(currentEquity > mostEquity) {
      mostEquity = currentEquity;
   }
   
   double baseTargetEquity = gBaseEquity * (1 + TotalProfitRate);
   double realTargetEquity = MathMax(baseTargetEquity, mostEquity * (1 - BackwordForClose));
   string logMsg = StringFormat("gBaseEquity=%s,baseTargetEquity=%s, mostEquity=%s, realTargetEquity=%s",
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