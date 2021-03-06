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

#define EA_VERSION "V1.2"

#define SHOW_COMMENT

#ifdef SHOW_COMMENT 
   
   input int TimeFrame = PERIOD_M5; //时间周期
   input int Passcode = 0; // 启动口令
   input string SYMBOL1 = "EURUSD"  ;   //货币对1(字符完全对应)
   input string SYMBOL2 = "GBPUSD"  ;   //货币对2(字符完全对应)
   input double MaxHoldingLots = 5.0; //最多持仓手数
   input double BaseOpenLots = 0.1;  //基础开仓手数
   input bool StopShortSide = false;// 是否停止空方开仓
   input bool StopLongSide = false; // 是否停止多方开仓
   input bool OpenMicroLots = true; //初始是否开微手单
   input bool EnableTradingTime = true; //是否启用开仓起止时段
   input string OpenOrderStartTime = "00:00"; //开仓起始时间，为格林威治时间，格式"hh:mm", 如："00:01"
   input string OpenOrderEndTime = "09:30"; //开仓截止时间，为格林威治时间，格式"hh:mm", 如："09:30"
   
   input bool BaseOpenCheckReversOrder = true;  //基础开仓时是否检查反向订单数
   input double Overweight_Multiple = 2;//加仓倍数（自动）
   input double MulipleFactorForAppend = 1.0; //加仓倍数调整系数（自动）
   input int OrderMax = 5;          // 最大加仓次数（总共）
   input int OrderMaxAuto = 4;          // 最大加仓次数（自动）
   input double PointOffsetForAppend = 0.006; //加仓条件（自动）：最低价格差变化幅度
   input double FactorForAppend = 0.80; //加仓条件：最低价格差变化的调整系数
   input double PointOffsetForAppendManual = 0.006; //加仓条件（手动）：指定价格差变化幅度
   input double LotsForAppendManual = 0.5; //加仓条件（手动）：首次手动加仓手数
   input double Overweight_MultipleManual = 1;//加仓倍数（手动）
   input double MulipleFactorForAppendManual = 1.0; //加仓倍数调整系数（手动）
   input double PointOffsetForProfit = 0.001; //平仓条件：最小价格差变化幅度
   input bool DynamicTakeProfits = true; //平仓条件：是否启用按加仓轮数动态计算止盈金额
   input double TakeProfitsPerOrder = 20; //平仓条件：单轮的基础止盈获利金额
   input double TakeProfitsFacor = 1.0; // 平仓条件：动态计算止盈金额调整系数
   input double TakeProfits = 20; //平仓条件：基础固定止盈获利金额(不启用按加仓轮数动态计算止盈金额）
   input double Backword = 0.05; // 平仓条件：移动止盈回调系数
   input double IncDropFactor = 0.382; // 涨跌幅限度比例（T）
   input bool CheckFreeMargin = true;// 是否检查预付款比例
   input double AdvanceRate = 100;// 预付款百分比，低于此值将不再加仓

#else
   
   input int TimeFrame = PERIOD_M5; 
   input int Passcode = 0;
   input string SYMBOL1 = "EURUSD"  ;
   input string SYMBOL2 = "GBPUSD"  ;
   input double MaxHoldingLots = 5.0;
   input double BaseOpenLots = 0.1;  
   input bool OpenMicroLots = true; 
   input bool BaseOpenCheckReversOrder = true; 
   input double Overweight_Multiple = 2;
   input double MulipleFactorForAppend = 1.0;
   input int OrderMax = 5;         
   input int OrderMaxAuto = 4;     
   input double PointOffsetForAppend = 0.006;
   input double FactorForAppend = 0.80; 
   input double PointOffsetForAppendManual = 0.006;
   input double LotsForAppendManual = 0.5;
   input double Overweight_MultipleManual = 1;
   input double MulipleFactorForAppendManual = 1.0;
   input double PointOffsetForProfit = 0.001; 
   input bool DynamicTakeProfits = true; 
   input double TakeProfitsPerOrder = 10;
   input double TakeProfitsFacor = 2.0; 
   input double TakeProfits = 20; 
   input double Backword = 0.05; 
   input double IncDropFactor = 0.382;
   input bool CheckFreeMargin = true;
   input double AdvanceRate = 100;
#endif 

int gTickCount = 0;
bool gIsNewBar = false;

#endif


