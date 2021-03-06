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

#define EA_VERSION "V0.9"

input int MagicNum = 80000;
input int TimeFrame = PERIOD_M5; //时间周期
input double MaxHoldingLots = 0.5; //最多持仓手数
input double BaseOpenLots = 0.02;  //基础开仓手数
input bool BaseOpenCheckReversOrder = true;  //基础开仓时是否检查反向订单数
input double Overweight_Multiple = 1.5;//加仓倍数
input bool Overweight_Fab = true; // 启用Fabonacci加仓
input double MulipleFactorForAppend = 1.0; //加仓倍数调整系数
input int OrderMax = 4;          // 最大加仓次数，最后一次加仓将启用保护仓
input bool BaseOpenLotsInLoop = true; // 中间轮数是否开基础仓
input double PointOffsetForAppend = 0.0062; //加仓条件：最低价格差变化幅度
input double FactorForAppend = 1.0; //加仓条件：最低价格差变化的调整系数
input double BackwordForAppend = 0.10; // 加仓条件：加仓回调系数
// input double DeficitForAppend = 100; //加仓条件：最低亏损金额
input double PointOffsetForProfit = 0.001; //平仓条件：最小价格差变化幅度
input bool DynamicTakeProfits = true; //平仓条件：是否启用按加仓轮数动态计算止盈金额
input double BackwordForProfits = 0.05; // 平仓条件：移动止盈回调系数
input double TakeProfitsFacor = 0.32; // 平仓条件：动态计算止盈金额调整系数
input double TakeProfits = 20; //平仓条件：基础固定止盈获利金额
input bool CheckFreeMargin = true;// 是否检查预付款比例

input double OpenProtectingOrderOffset = 0.001; //  保护仓：开保护仓的价格变化幅度

input double HEAVY_PROFITS_SETP = 0.001; // 保护仓：重仓盈利条件：最小价格波动值
input double HEAVY_TO_LIGHT_MIN_OFFSET = 0.0062; // 保护仓：重仓可以转轻仓的与对侧订单的最小价格差
input double HEAVY_TO_LIGHT_ROLLBACK = 0.0005; // 保护仓：重转轻：价格反转条件：最小价格波动值
input double BACKWORD_PROFITS = 0.05; //  保护仓：重转轻：获利回调系数

input double LIGHT_TO_HEAVY_ROLLBACK = 0.0005; // 保护仓：轻转重：价格反转条件：最小价格波动值
input double LIGHT_STOPLOSS_STEP = 0.0005; //  保护仓：轻转轻：止损条件：最小价格波动值
input double BACKWORD_STOPLOSS = 0.05; //  保护仓：轻转重：条件：止损回调系数
input double PRICE_ROLLBACK_RATE = 0.6; //保护仓：平所有仓条件，价格回归比例

input double AdvanceRate = 1000;// 预付款百分比，低于此值将不再加仓

int gTickCount = 0;
bool gIsNewBar = false;
#endif


