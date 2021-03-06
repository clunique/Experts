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

#define EA_VERSION "V1.00"

#ifdef SHOW_COMMENT

input int MagicNum = 1000;
input int Passcode = 0; // 启动口令

input bool EnableTradingDate = false; //是否启用开仓起止日期
input datetime OpenOrderStartDate = ""; //开仓起始时间，为格林威治时间
input datetime OpenOrderEndDate = ""; //开仓截止时间，为格林威治时间

input bool EnableTradingTime = false; //是否启用开仓起止时段
input string OpenOrderStartTime = "00:00"; //开仓起始时间，为格林威治时间，格式"hh:mm", 如："00:01"
input string OpenOrderEndTime = "09:30"; //开仓截止时间，为格林威治时间，格式"hh:mm", 如："09:30"

input double BaseOpenBuyLots = 0.01;   //多方基础开仓手数
input double BaseOpenSellLots = 0.01;   //空方基础开仓手数

input bool StopShortSide = false;// 是否停止空方开仓
input bool StopLongSide = false; // 是否停止多方开仓

input double BackwordForAppendLongMartin = 0.1;           //多单加马丁仓回撤比例
input double RevertAppendStepForLong1_5 = 0.003;    //多方1到5轮加仓间距
input double RevertAppendStepForLong6_10 = 0.003;    //多方6到10轮加仓间距
input double RevertAppendStepForLong11_15 = 0.003;    //多方11到15轮加仓间距
input double RevertAppendStepForLong16_20 = 0.003;    //多方16到20轮加仓间距
input double RevertAppendStepForLong21_25 = 0.003;    //多方21到25轮加仓间距
input double RevertAppendStepForLong26_30 = 0.003;    //多方26到30轮加仓间距
input double RevertAppendStepForLong31_35 = 0.003;    //多方31到35轮加仓间距
input double RevertAppendStepForLong36_40 = 0.003;    //多方36到40轮加仓间距

input double BackwordForAppendShortMartin = 0.1;    //空方加马丁仓回撤比例
input double RevertAppendStepForShort1_5 = 0.003;    //空方1到5轮加仓间距
input double RevertAppendStepForShort6_10 = 0.003;    //空方6到10轮加仓间距
input double RevertAppendStepForShort11_15 = 0.003;    //空方11到15轮加仓间距
input double RevertAppendStepForShort16_20 = 0.003;    //空方16到20轮加仓间距
input double RevertAppendStepForShort21_25 = 0.003;    //空方21到25轮加仓间距
input double RevertAppendStepForShort26_30 = 0.003;    //空方26到30轮加仓间距
input double RevertAppendStepForShort31_35 = 0.003;    //空方31到35轮加仓间距
input double RevertAppendStepForShort36_40 = 0.003;    //空方36到40轮加仓间距

input double PointOffsetForMovableTakeProfitForLong = 0.003; //多单移动止盈最小价格差
input double BackwordForLong = 0.1;           //多单移动止盈回调比例

input double PointOffsetForMovableTakeProfitForShort = 0.003; //空单移动止盈最小价格差
input double BackwordForShort = 0.1;           //空单移动止盈回调比例

input bool EnableMovableTakeProfitForLong = false; // 是否启用马丁多单移动止盈
input double FixedTakeProfitsForLong = 5.0; // 马丁多单固定止盈金额
input double TakeProfitsFacorForLongMartin = 0.6; //马丁多单移动止盈调整系数
input double BackwordForLongMartin = 0.1;    //马丁多单移动止盈回调比例

input bool EnableMovableTakeProfitForShort = false; // 是否启用马丁空单移动止盈
input double FixedTakeProfitsForShort = 5.0; // 马丁空单固定止盈金额
input double TakeProfitsFacorForShortMartin = 0.6; //马丁空单移动止盈调整系数
input double BackwordForShortMartin = 0.1;   //马丁空单移动止盈回调比例

input bool EnableLongShortWholeClose = false; // 是否启用多空双方整体平仓
input double BuyLotsForWholeClose = 1.0;  // 整体平仓多方最低手数
input double SellLotsForWholeClose = 1.0;  // 整体平仓空方最低手数
input double ProfitsWholeClose = 0.0; // 多空双方整体平仓盈利金额
input bool EnableMovableForWholeClose = false; // 是否启用整体平仓移动止盈
input double BackwardForWholeClose = 0.1; //多空整体移动止盈回调比例

input double SpreadMax = 0.0005; // 要求最大点差  

input bool EnableAutoCloseAll = true; // 是否启用自动平所有仓
input double BaseEquity = 1000;  // 基础净值（本金）
input double TotalProfitRate = 0.1; // 总盈利比率
input double BackwordForClose = 0.005; //总净值回撤比率

input double MaxHandlingLots = 1.0; //单方向持仓最大手数

input bool EnableAutoCloseAllForStopLoss = false; // 是否启用自动止损清仓
input double AutoCloseAllForStopLossRate = 0.3;       // 自动止损比例
input bool ContinueOpenAfterCloseAllForStopLoss = true; // 自动整体止损后，是否继续开仓

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

input double BaseOpenBuyLots = 0.01;   
input double BaseOpenSellLots = 0.01;  

input bool EnableCheckOppositeOrderCount = false;
input int OppositeOrderCount = 6;

input bool StopShortSide = false;
input bool StopLongSide = false; 
input double BackwordForAppendLongMartin = 0.1;          
input double RevertAppendStepForLong1_5 = 0.003;    
input double RevertAppendStepForLong6_10 = 0.003;   
input double RevertAppendStepForLong11_15 = 0.003;   
input double RevertAppendStepForLong16_20 = 0.003;    
input double RevertAppendStepForLong21_25 = 0.003;   
input double RevertAppendStepForLong26_30 = 0.003;   
input double RevertAppendStepForLong31_35 = 0.003;   
input double RevertAppendStepForLong36_40 = 0.003;   

input double BackwordForAppendShortMartin = 0.1; 
input double RevertAppendStepForShort1_5 = 0.003;  
input double RevertAppendStepForShort6_10 = 0.003; 
input double RevertAppendStepForShort11_15 = 0.003;
input double RevertAppendStepForShort16_20 = 0.003;
input double RevertAppendStepForShort21_25 = 0.003; 
input double RevertAppendStepForShort26_30 = 0.003; 
input double RevertAppendStepForShort31_35 = 0.003; 
input double RevertAppendStepForShort36_40 = 0.003;

input double PointOffsetForMovableTakeProfitForLong = 0.003;
input double BackwordForLong = 0.1;          

input double PointOffsetForMovableTakeProfitForShort = 0.003;
input double BackwordForShort = 0.1;          

input bool EnableMovableTakeProfitForLong = false;
input double FixedTakeProfitsForLong = 5.0;
input double TakeProfitsFacorForLongMartin = 0.6;
input double BackwordForLongMartin = 0.1;                      

input bool EnableMovableTakeProfitForShort = false;
input double FixedTakeProfitsForShort = 5.0; 
input double TakeProfitsFacorForShortMartin = 0.6;
input double BackwordForShortMartin = 0.1; 

input bool EnableLongShortWholeClose = false;
input double BuyLotsForWholeClose = 1.0;
input double SellLotsForWholeClose = 1.0;
input double ProfitsWholeClose = 0.0;
input bool EnableMovableForWholeClose = false;
input double BackwardForWholeClose = 0.1;      

input double SpreadMax = 0.0005;

input bool EnableAutoCloseAll = true; 
input double BaseEquity = 1000; 
input double TotalProfitRate = 0.1;
input double BackwordForClose = 0.005;

input double MaxHandlingLots = 1.0; 

input bool EnableAutoCloseAllForStopLoss = false;
input double AutoCloseAllForStopLossRate = 0.3;
input bool ContinueOpenAfterCloseAllForStopLoss = true;

#endif

bool gIsNewBar = false;
bool gbShowText = false;
bool gbShowComment = false;

#endif


