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
      param.m_StopLossPoint = PointOffsetForStopLoss;
      param.m_TakeProfitPoint = PointOffsetForTakeProfit;
      pWave.OpenBuyOrders(param);
      return;
   }
   
   if(pWave.GetSellOrderCnt() == 0 && IsDataAndTimeAllowed()) {
      OptParam param;
      param.m_BaseOpenLots = MinOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLoss;
      param.m_TakeProfitPoint = PointOffsetForTakeProfit;
      pWave.OpenSellOrders(param);
      return;
   }
   
   if(IsDataAndTimeAllowed() && pWave.CheckForAppendBuyOrder(AppendStep, SpreadMax)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLoss;
      param.m_TakeProfitPoint = PointOffsetForTakeProfit;
      pWave.OpenBuyOrders(param);
   }
   
   if(IsDataAndTimeAllowed() && pWave.CheckForAppendSellOrder(AppendStep, SpreadMax)) {
      OptParam param;
      param.m_BaseOpenLots = BaseOpenLots;
      param.m_StopLossPoint = PointOffsetForStopLoss;
      param.m_TakeProfitPoint = PointOffsetForTakeProfit;
      pWave.OpenSellOrders(param);
   }
   
   pWave.CheckForCloseBuyOrders(PointOffsetForMovableTakeProfit, Backword);
   pWave.CheckForCloseSellOrders(PointOffsetForMovableTakeProfit, Backword);
   
}

void Destroy()
{
   if(pWave) {
      delete pWave; 
      pWave = NULL;
   }
}