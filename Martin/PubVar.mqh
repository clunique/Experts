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

#define EA_VERSION "V0.4"

input int TimeFrame = PERIOD_M5; //时间周期
input double MaxHoldingLots = 5.0; //最多持仓手数
input double BaseOpenLots = 0.1;  //基础开仓手数
input bool BaseOpenCheckReversOrder = true;  //基础开仓时是否检查反向订单数
input double Overweight_Multiple = 2;//加仓倍数
input double MulipleFactorForAppend = 1.0; //加仓倍数调整系数
input int OrderMax = 5;          // 最大加仓次数

input double MaxHoldingLotsFri = 5.0; //Fri:最多持仓手数
input double BaseOpenLotsFri = 0.1;  //Fri:基础开仓手数
input bool BaseOpenCheckReversOrderFri = true;  //Fri:基础开仓时是否检查反向订单数
input double Overweight_MultipleFri = 2;//Fri:加仓倍数
input double MulipleFactorForAppendFri = 1.0; //Fri:加仓倍数调整系数
input int OrderMaxFri = 5;          // Fri:最大加仓次数

input double PointOffsetForAppend = 0.007; //加仓条件：最低价格差变化幅度
input double FactorForAppend = 0.8; //加仓条件：最低价格差变化的调整系数
// input double DeficitForAppend = 100; //加仓条件：最低亏损金额
input double PointOffsetForProfit = 0.001; //平仓条件：最小价格差变化幅度
input bool DynamicTakeProfits = true; //平仓条件：是否启用按加仓轮数动态计算止盈金额
input double TakeProfitsPerOrder = 20; //平仓条件：单轮的基础止盈获利金额
input double TakeProfitsFacor = 1.0; // 平仓条件：动态计算止盈金额调整系数
input double TakeProfits = 20; //平仓条件：基础固定止盈获利金额
input double Backword = 0.05; // 平仓条件：移动止盈回调系数
input bool CheckFreeMargin = true;// 是否检查预付款比例
input double AdvanceRate = 500;// 预付款百分比，低于此值将不再加仓

int gTickCount = 0;
bool gIsNewBar = false;
#endif


