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

#define EA_VERSION "V2.1"

input int TimeFrame = PERIOD_M5; //时间周期
input int Passcode = 0; // 启动口令
input string SYMBOL1 = "EURUSD"  ;   //货币对1(字符完全对应)
input string SYMBOL2 = "GBPUSD"  ;   //货币对2(字符完全对应)

input bool StopShortSide = false;// 是否停止空方开仓
input bool StopLongSide = false; // 是否停止多方开仓
input bool OpenMicroLots = true; //初始是否开微手单
input bool EnableTradingTime = true; //是否启用开仓起止时段
input string OpenOrderStartTime = "00:00"; //开仓起始时间，为格林威治时间，格式"hh:mm", 如："00:01"
input string OpenOrderEndTime = "09:30"; //开仓截止时间，为格林威治时间，格式"hh:mm", 如："09:30"
input bool BaseOpenCheckReversOrder = true;  //基础开仓时是否检查反向订单数
   
input string Stage1 = "-----";  //阶段一:-----   
input double BaseOpenLots1 = 0.01;  //阶段一基础开仓手数
input double Multiple1 = 1.5;//阶段一加仓倍数
input double MulipleFactorForAppend1 = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1 = 5;          // 阶段一最大加仓次数
input double PointOffsetForAppend1 = 0.001; //阶段一加仓条件：最低价格差变化幅度
input double PointOffsetFactorForAppend1 = 0.80; //阶段一加仓条件：最低价格差变化的调整系数

input string Stage2 = "-----";  //阶段二:-----    
input double BaseOpenLots2 = 0.02;  //阶段二基础开仓手数
input double Multiple2 = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2 = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2 = 5;          // 阶段二最大加仓次数
input double PointOffsetForAppend2 = 0.001; //阶段二加仓条件：最低价格差变化幅度
input double PointOffsetFactorForAppend2 = 0.80; //阶段二加仓条件：最低价格差变化的调整系数

input string Stage3 = "-----";  //阶段三:-----    
input double BaseOpenLots3 = 0.03;  //阶段三基础开仓手数
input double Multiple3 = 2.5;//阶段三加仓倍数
input double MulipleFactorForAppend3 = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3 = 5;          // 阶段三最大加仓次数
input double PointOffsetForAppend3 = 0.001; //阶段三加仓条件：最低价格差变化幅度
input double PointOffsetFactorForAppend3 = 0.80; //阶段三加仓条件：最低价格差变化的调整系数

input double PointOffsetForProfit = 0.001; //平仓条件：最小价格差变化幅度
input bool DynamicTakeProfits = true; //平仓条件：是否启用按加仓轮数动态计算止盈金额
input double TakeProfitsPerOrder = 20; //平仓条件：单轮的基础止盈获利金额
input double TakeProfitsFacor = 1.0; // 平仓条件：动态计算止盈金额调整系数
input double TakeProfits = 20; //平仓条件：基础固定止盈获利金额(不启用按加仓轮数动态计算止盈金额）
input double Backword = 0.05; // 平仓条件：移动止盈回调系数
input double IncDropFactor = 0.382; // 涨跌幅限度比例（T）
input bool CheckFreeMargin = true;// 是否检查预付款比例
input double AdvanceRate = 100;// 预付款百分比，低于此值将不再加仓

input bool EnableStopLoss = true; //止损条件：是否启用自动止损
input double StopLossRate = 0.3;// 止损条件：止损比例


int gTickCount = 0;
bool gIsNewBar = false;

#endif


