//+------------------------------------------------------------------+
//|                                                       PubVar.mqh |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
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
#ifndef _PUB_VAR_H
#define _PUB_VAR_H

#define EA_VERSION "V1.05"

#ifdef SHOW_COMMENT

input int MagicNum = 1000;
input int TimeFrame = PERIOD_M5; //时间周期
input int Passcode = 0; // 启动口令

input bool EnableTradingDate = false; //是否启用开仓起止日期
input datetime OpenOrderStartDate = ""; //开仓起始时间，为格林威治时间
input datetime OpenOrderEndDate = ""; //开仓截止时间，为格林威治时间

input bool EnableTradingTime = false; //是否启用开仓起止时段
input string OpenOrderStartTime = "00:00"; //开仓起始时间，为格林威治时间，格式"hh:mm", 如："00:01"
input string OpenOrderEndTime = "09:30"; //开仓截止时间，为格林威治时间，格式"hh:mm", 如："09:30"

input bool EnableLongShortRateForAppend = false; //是否启用加仓时判断多空比例
input double EnableLongShortRateLotsForAppend = 0.1; // 启用加仓时判断用多空比例的起始手数（单方向）

input bool EnableLongShortRateForClose = false; //是否启用平仓时判断用多空比例
input double EnableLongShortRateLotsForClose = 0.1; // 启用平仓时判断用多空比例的起始手数（单方向）


input double MinOpenLots = 0.01;    //最小手数
input double BaseOpenLots = 0.01;   //基础开仓手数
input double AppendStep = 0.001;    //加仓间距
input double RevertAppendStep = 0.002;    //反向单加仓间距
input double PointOffsetForStopLoss = 0; //止损点数
input double PointOffsetForTakeProfit = 0; //止盈点数
input double PointOffsetForMovableTakeProfit = 0.003; //移动止盈最小价格差
input double Backword = 0.1;           //移动止盈回调比例

input double SpreadMax = 0.0005; // 要求最大点差  

input bool EnableAutoCloseAll = false; // 是否启用自动平所有仓
input double BaseEquity = 1000;  // 基础净值（本金）
input double TotalProfitRate = 0.5; // 总盈利比率
input double BackwordForClose = 0.05; //总净值回撤比率

input double MaxHandlingLots = 1.0; //单方向持仓最大手数

#else 

input int MagicNum = 1000;
input int TimeFrame = PERIOD_M5;
input int Passcode = 0; 

input bool EnableTradingDate = false; 
input datetime OpenOrderStartDate = "";
input datetime OpenOrderEndDate = "";

input bool EnableTradingTime = false;
input string OpenOrderStartTime = "00:00";
input string OpenOrderEndTime = "09:30";

input bool EnableLongShortRateForAppend = false;
input double EnableLongShortRateLotsForAppend = 0.1; 

input bool EnableLongShortRateForClose = false;
input double EnableLongShortRateLotsForClose = 0.1; 

input double MinOpenLots = 0.01;
input double BaseOpenLots = 0.01; 
input double AppendStep = 0.001;
input double RevertAppendStep = 0.002;
input double PointOffsetForStopLoss = 0;
input double PointOffsetForTakeProfit = 0;
input double PointOffsetForMovableTakeProfit = 0.003; 
input double Backword = 0.1; 

input double SpreadMax = 0.0005;

input bool EnableAutoCloseAll = false; 
input double BaseEquity = 1000; 
input double TotalProfitRate = 0.5;
input double BackwordForClose = 0.05;

input double MaxHandlingLots = 1.0; 

#endif

bool gIsNewBar = false;
bool gbShowText = false;
bool gbShowComment = false;

#endif


