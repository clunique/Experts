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

#define EA_VERSION "V0.1"

input int MAGIC_NUM = 9000;
input int TimeFrame = PERIOD_M5; //时间周期
input double BASE_OPEN_LOTS = 0.05; // 基础开仓手数
input double OFFSET_HEAVY_TO_LIGHT_PROFITS = 0.004; // 重转轻：盈利条件1：最小价格波动值
input double OFFSET_HEAVY_TO_LIGHT_PROFITS2 = 0.001; // 重转轻：盈利条件2：最小价格波动值，再次平仓时使用
input double OFFSET_HEAVY_TO_LIGHT_ROLLBACK = 0.0005; // 重转轻：价格反转条件：最小价格波动值
input int HEAVY_TO_LIGHT_MAX = 1; // 重转轻：条件：最大次数限制
input double BACKWORD_PROFITS = 0.05; //  重转轻：条件：获利回调系数

input double OFFSET_LIGHT_TO_HEAVY_ROLLBACK = 0.0005; // 轻转重：价格反转条件：最小价格波动值
input double OFFSET_LIGHT_TO_HEAVY_STOPLOSS = 0.002; //  轻转重：止损条件：最小价格波动值
input double BACKWORD_STOPLOSS = 0.05; //  重转轻：条件：止损回调系数

int gTickCount = 0;
bool gIsNewBar = false;
#endif


