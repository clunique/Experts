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

input int MAGIC_NUM = 8000;
input int TimeFrame = PERIOD_M5; //时间周期
input double BASE_OPEN_LOTS = 1.0; // 基础开仓手数
input double BASE_CLOSE_MIN_OFFSET = 0.0005; // 平仓条件1：最小价格波动值
input double BASE_CLOSE_BACKWORD_OFFSET = 0.001; // 【平仓条件2：价格折返波动值

int gTickCount = 0;
bool gIsNewBar = false;
#endif


