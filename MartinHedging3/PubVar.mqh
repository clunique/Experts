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

#define EA_VERSION "V3.07"

#ifdef SHOW_COMMENT
input int MagicNum = 300;
input int TimeFrame = PERIOD_M5; //时间周期
input int Passcode = 0; // 启动口令
input string SYMBOL1 = "EURCHF"  ;   //货币对1(字符完全对应)
input string SYMBOL2_1 = "EURUSD"  ;   //货币对2-1(字符完全对应)
input string SYMBOL2_2 = "USDCHF"  ;   //货币对2-2(字符完全对应)

input double FactorForSymbol1 = 1.0; //货币对1价格差调整系数
input double FactorForSymbol2_1 = 1.0; //货币对2-1价格差调整系数
input double FactorForSymbol2_2 = 1.0; //货币对2-2价格差调整系数

input bool EnableTradingDate = false; //是否启用开仓起止日期
input datetime OpenOrderStartDate = ""; //开仓起始时间，为格林威治时间
input datetime OpenOrderEndDate = ""; //开仓截止时间，为格林威治时间

input bool StopShortSide = false;// 是否停止空方开仓
input bool StopLongSide = false; // 是否停止多方开仓
input bool EnableTradingTime = false; //是否启用开仓起止时段
input string OpenOrderStartTime = "00:00"; //开仓起始时间，为格林威治时间，格式"hh:mm", 如："00:01"
input string OpenOrderEndTime = "09:30"; //开仓截止时间，为格林威治时间，格式"hh:mm", 如："09:30"
input bool BaseOpenCheckReversOrder = true;  //基础开仓时是否检查反向订单数

input bool EnablePriceLimitForShortSideMin = false; //是否启用开空单价格低限
input double PriceLimitForShortSideMin = 1.002; //空单价格低限（高于此价格才开空单）
input bool EnablePriceLimitForLongSideMax = false; //是否启用开多单价格高限
input double PriceLimitForLongSideMax = 0.998; //多单价格高限（低于此价格才开多单）

input bool EnablePriceLimitForShortSideMax = false; //是否启用开空单价格高限
input double PriceLimitForShortSideMax = 1.002; //空单价格高限（低于此价格才开空单）
input bool EnablePriceLimitForLongSideMin = false; //是否启用开多单价格低限
input double PriceLimitForLongSideMin = 0.998; //多单价格低限（高于此价格才开多单）

input int StageMax = 5; // 最大加仓阶段数
input bool CheckAllOrdersInLastStage = false; // 最后一个阶段是否检查全部订单
   
input string Stage1 = "-----";  //阶段一:-----   
input double BaseOpenLotsOne1 = 0.02;  //阶段一单品种侧基础开仓手数
input double BaseOpenLotsTwo2_1_1 = 0.01;  //阶段一双品种侧1基础开仓手数
input double BaseOpenLotsTwo2_2_1 = 0.01;  //阶段一双品种侧2基础开仓手数
input double Multiple1 = 2.0;//阶段一加仓倍数
input double MulipleFactorForAppend1 = 1.0; //阶段一加仓倍数调整系数
input int AppendMax1 = 5;          // 阶段一最大加仓次数
input double PointOffsetForStage1 = 0.001; //阶段一加仓条件：下阶段加仓价格差
input double PointOffsetForAppend1 = 0.002; //阶段一加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend1 = 1.0; //阶段一加仓条件：最低价格差变化的调整系数
input double BackwordForAppend1 = 0.05; // 阶段一加仓条件：回调系数
input double TakeProfitsPerOrder1 = 20; //阶段一平仓条件：单轮的基础止盈获利金额
input double TakeProfitsFacorForLongSide1 = 1.0; // 阶段一平仓条件：多方动态计算止盈金额调整系数
input double TakeProfitsFacorForShortSide1 = 1.0; // 阶段一平仓条件：空方动态计算止盈金额调整系数
input double Backword1 = 0.05; // 阶段一平仓条件：移动止盈回调系数

input string Stage2 = "-----";  //阶段二:-----    
input double BaseOpenLotsOne2 = 0.02;  //阶段二单品种侧基础开仓手数
input double BaseOpenLotsTwo2_1_2 = 0.01;  //阶段二双品种侧1基础开仓手数
input double BaseOpenLotsTwo2_2_2 = 0.01;  //阶段二双品种侧2基础开仓手数
input double Multiple2 = 2.0;//阶段二加仓倍数
input double MulipleFactorForAppend2 = 1.0; //阶段二加仓倍数调整系数
input int AppendMax2 = 5;          // 阶段二最大加仓次数
input double PointOffsetForStage2 = 0.001; //阶段二加仓条件：下阶段加仓价格差
input double PointOffsetForAppend2 = 0.002; //阶段二加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend2 = 1.0; //阶段二加仓条件：最低价格差变化的调整系数
input double BackwordForAppend2 = 0.05; // 阶段二加仓条件：回调系数
input double TakeProfitsPerOrder2 = 20; //阶段二平仓条件：单轮的基础止盈获利金额
input double TakeProfitsFacorForLongSide2 = 1.0; // 阶段二平仓条件：多方动态计算止盈金额调整系数
input double TakeProfitsFacorForShortSide2 = 1.0; // 阶段二平仓条件：空方动态计算止盈金额调整系数
input double Backword2 = 0.05; // 阶段二平仓条件：移动止盈回调系数

input string Stage3 = "-----";  //阶段三:-----    
input double BaseOpenLotsOne3 = 0.02;  //阶段三单品种侧基础开仓手数
input double BaseOpenLotsTwo2_1_3 = 0.01;  //阶段三双品种侧1基础开仓手数
input double BaseOpenLotsTwo2_2_3 = 0.01;  //阶段三双品种侧2基础开仓手数
input double Multiple3 = 2.0;//阶段三加仓倍数
input double MulipleFactorForAppend3 = 1.0; //阶段三加仓倍数调整系数
input int AppendMax3 = 5;          // 阶段三最大加仓次数
input double PointOffsetForStage3 = 0.001; //阶段三加仓条件：下阶段加仓价格差
input double PointOffsetForAppend3 = 0.002; //阶段三加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend3 = 1.0; //阶段三加仓条件：最低价格差变化的调整系数
input double BackwordForAppend3 = 0.05; // 阶段三加仓条件：回调系数
input double TakeProfitsPerOrder3 = 20; //阶段三平仓条件：单轮的基础止盈获利金额
input double TakeProfitsFacorForLongSide3 = 1.0; // 阶段三平仓条件：多方动态计算止盈金额调整系数
input double TakeProfitsFacorForShortSide3 = 1.0; // 阶段三平仓条件：空方动态计算止盈金额调整系数
input double Backword3 = 0.05; // 阶段三平仓条件：移动止盈回调系数

input string Stage4 = "-----";  //阶段四:-----    
input double BaseOpenLotsOne4 = 0.02;  //阶段四单品种侧基础开仓手数
input double BaseOpenLotsTwo2_1_4 = 0.01;  //阶段四双品种侧1基础开仓手数
input double BaseOpenLotsTwo2_2_4 = 0.01;  //阶段四双品种侧2基础开仓手数
input double Multiple4 = 2.0;//阶段四加仓倍数
input double MulipleFactorForAppend4 = 1.0; //阶段四加仓倍数调整系数
input int AppendMax4 = 5;          // 阶段四最大加仓次数
input double PointOffsetForStage4 = 0.001; //阶段四加仓条件：下阶段加仓价格差
input double PointOffsetForAppend4 = 0.002; //阶段四加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend4 = 1.0; //阶段四加仓条件：最低价格差变化的调整系数
input double BackwordForAppend4 = 0.05; // 阶段四加仓条件：回调系数
input double TakeProfitsPerOrder4 = 20; //阶段四平仓条件：单轮的基础止盈获利金额
input double TakeProfitsFacorForLongSide4 = 1.0; // 阶段四平仓条件：多方动态计算止盈金额调整系数
input double TakeProfitsFacorForShortSide4 = 1.0; // 阶段四平仓条件：空方动态计算止盈金额调整系数
input double Backword4 = 0.05; // 阶段四平仓条件：移动止盈回调系数

input string Stage5 = "-----";  //阶段五:-----    
input double BaseOpenLotsOne5 = 0.02;  //阶段五单品种侧基础开仓手数
input double BaseOpenLotsTwo2_1_5 = 0.01;  //阶段五双品种侧1基础开仓手数
input double BaseOpenLotsTwo2_2_5 = 0.01;  //阶段五双品种侧2基础开仓手数
input double Multiple5 = 2.0;//阶段五加仓倍数
input double MulipleFactorForAppend5 = 1.0; //阶段五加仓倍数调整系数
input int AppendMax5 = 5;          // 阶段五最大加仓次数
int PointOffsetForStage5 = 0.001; //阶段五加仓条件：下阶段加仓价格差
input double PointOffsetForAppend5 = 0.002; //阶段五加仓条件：本阶段内最低价格差变化幅度
input double PointOffsetFactorForAppend5 = 1.0; //阶段五加仓条件：最低价格差变化的调整系数
input double BackwordForAppend5 = 0.05; // 阶段五加仓条件：回调系数
input double TakeProfitsPerOrder5 = 20; //阶段五平仓条件：单轮的基础止盈获利金额
input double TakeProfitsFacorForLongSide5 = 1.0; // 阶段五平仓条件：多方动态计算止盈金额调整系数
input double TakeProfitsFacorForShortSide5 = 1.0; // 阶段五平仓条件：空方动态计算止盈金额调整系数
input double Backword5 = 0.05; // 阶段五平仓条件：移动止盈回调系数

input double PointOffsetForProfit = 0.001; //平仓条件：最小价格差变化幅度
// input bool DynamicTakeProfits = true; //平仓条件：是否启用按加仓轮数动态计算止盈金额
// input double TakeProfitsPerOrder = 20; //平仓条件：单轮的基础止盈获利金额
// input double TakeProfitsFacor = 1.0; // 平仓条件：动态计算止盈金额调整系数
// input double TakeProfits = 20; //平仓条件：基础固定止盈获利金额(不启用按加仓轮数动态计算止盈金额）
input double Backword = 0.05; // 平仓条件：移动止盈回调系数

input double IncDropFactor = 0.382; // 涨跌幅限度比例（T）
input bool CheckFreeMargin = true;// 是否检查预付款比例
input double AdvanceRate = 100;// 预付款百分比，低于此值将不再加仓

input bool EnableStopLoss = true; //止损条件：是否启用自动止损
input double StopLossRate = 0.3;// 止损条件：止损比例
input double SpreadMax = 0.0005; // 要求最小点差

input bool EnableAutoCloseAllForStopLoss = false; // 是否启用自动止损清仓
input double TargetLossAmout = 3000;       // 浮亏金额

#else
input int MagicNum = 300;
input int TimeFrame = PERIOD_M5; 
input int Passcode = 0; 
input string SYMBOL1 = "EURCHF";  
input string SYMBOL2_1 = "EURUSD";  
input string SYMBOL2_2 = "USDCHF"; 

input double FactorForSymbol1 = 1.0; 
input double FactorForSymbol2_1 = 1.0;
input double FactorForSymbol2_2 = 1.0;

input bool EnableTradingDate = false;
input datetime OpenOrderStartDate = "";
input datetime OpenOrderEndDate = "";

input bool StopShortSide = false;
input bool StopLongSide = false; 
input bool EnableTradingTime = false;
input string OpenOrderStartTime = "00:00"; 
input string OpenOrderEndTime = "09:30"; 
input bool BaseOpenCheckReversOrder = true; 

input bool EnablePriceLimitForShortSideMin = false; 
input double PriceLimitForShortSideMin = 1.002;
input bool EnablePriceLimitForLongSideMax = false;
input double PriceLimitForLongSideMax = 0.998;

input bool EnablePriceLimitForShortSideMax = false;
input double PriceLimitForShortSideMax = 1.002;
input bool EnablePriceLimitForLongSideMin = false;
input double PriceLimitForLongSideMin = 0.998;

input int StageMax = 5;
input bool CheckAllOrdersInLastStage = false;
   
input string Stage1 = "-----"; 
input double BaseOpenLotsOne1 = 0.02; 
input double BaseOpenLotsTwo2_1_1 = 0.01;
input double BaseOpenLotsTwo2_2_1 = 0.01;
input double Multiple1 = 2.0;
input double MulipleFactorForAppend1 = 1.0; 
input int AppendMax1 = 5;       
input double PointOffsetForStage1 = 0.001; 
input double PointOffsetForAppend1 = 0.002; 
input double PointOffsetFactorForAppend1 = 1.0; 
input double BackwordForAppend1 = 0.05;
input double TakeProfitsPerOrder1 = 20;
input double TakeProfitsFacorForLongSide1 = 1.0;
input double TakeProfitsFacorForShortSide1 = 1.0;  
input double Backword1 = 0.05; 

input string Stage2 = "-----"; 
input double BaseOpenLotsOne2 = 0.02;
input double BaseOpenLotsTwo2_1_2 = 0.01;
input double BaseOpenLotsTwo2_2_2 = 0.01;
input double Multiple2 = 2.0;
input double MulipleFactorForAppend2 = 1.0; 
input int AppendMax2 = 5;         
input double PointOffsetForStage2 = 0.001; 
input double PointOffsetForAppend2 = 0.002;
input double PointOffsetFactorForAppend2 = 1.0;
input double BackwordForAppend2 = 0.05;
input double TakeProfitsPerOrder2 = 20; 
input double TakeProfitsFacorForLongSide2 = 1.0;
input double TakeProfitsFacorForShortSide2 = 1.0;  
input double Backword2 = 0.05; 

input string Stage3 = "-----"; 
input double BaseOpenLotsOne3 = 0.02;
input double BaseOpenLotsTwo2_1_3 = 0.01;
input double BaseOpenLotsTwo2_2_3 = 0.01;
input double Multiple3 = 2.0;
input double MulipleFactorForAppend3 = 1.0; 
input int AppendMax3 = 5;        
input double PointOffsetForStage3 = 0.001;
input double PointOffsetForAppend3 = 0.002; 
input double PointOffsetFactorForAppend3 = 1.0;
input double BackwordForAppend3 = 0.05; 
input double TakeProfitsPerOrder3 = 20; 
input double TakeProfitsFacorForLongSide3 = 1.0;
input double TakeProfitsFacorForShortSide3 = 1.0; 
input double Backword3 = 0.05; 

input string Stage4 = "-----"; 
input double BaseOpenLotsOne4 = 0.02; 
input double BaseOpenLotsTwo2_1_4 = 0.01;
input double BaseOpenLotsTwo2_2_4 = 0.01;
input double Multiple4 = 2.0;
input double MulipleFactorForAppend4 = 1.0; 
input int AppendMax4 = 5;         
input double PointOffsetForStage4 = 0.001;
input double PointOffsetForAppend4 = 0.002;
input double PointOffsetFactorForAppend4 = 1.0;
input double BackwordForAppend4 = 0.05;
input double TakeProfitsPerOrder4 = 20;
input double TakeProfitsFacorForLongSide4 = 1.0;
input double TakeProfitsFacorForShortSide4 = 1.0; 
input double Backword4 = 0.05; 

input string Stage5 = "-----";   
input double BaseOpenLotsOne5 = 0.02; 
input double BaseOpenLotsTwo2_1_5 = 0.01;
input double BaseOpenLotsTwo2_2_5 = 0.01;
input double Multiple5 = 2.0;
input double MulipleFactorForAppend5 = 1.0; 
input int AppendMax5 = 5;          
int PointOffsetForStage5 = 0.001;
input double PointOffsetForAppend5 = 0.002;
input double PointOffsetFactorForAppend5 = 1.0;
input double BackwordForAppend5 = 0.05; 
input double TakeProfitsPerOrder5 = 20; 
input double TakeProfitsFacorForLongSide5 = 1.0;
input double TakeProfitsFacorForShortSide5 = 1.0; 
input double Backword5 = 0.05; 

input double PointOffsetForProfit = 0.001;
// input bool DynamicTakeProfits = true; 
// input double TakeProfitsPerOrder = 20;
// input double TakeProfitsFacor = 1.0; 
// input double TakeProfits = 20; 
input double Backword = 0.05; 

input double IncDropFactor = 0.382; 
input bool CheckFreeMargin = true;
input double AdvanceRate = 100;

input bool EnableStopLoss = true; 
input double StopLossRate = 0.3;

input double SpreadMax = 0.0005;

input bool EnableAutoCloseAllForStopLoss = false; 
input double TargetLossAmout = 3000;       

#endif

int gTickCount = 0;
bool gIsNewBar = false;

#endif


