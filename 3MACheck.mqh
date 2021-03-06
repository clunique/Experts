//+------------------------------------------------------------------+
//|                                                   CheckTrend.mqh |
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
#include "3MAPubVar.mqh"
#include "3MAUtil.mqh"

enum { FLUCTUATION = 0, TREND_UP = 1, TREND_DOWN = 2};
string TrendName[] = 
{  
   "FLUCTUATION", 
   "TREND_UP", 
   "TREND_DOWN"  
};

#define MA_COUNT 4

datetime dtTrendUpBegin = 0;
datetime dtTrendDownBegin = 0;

bool IsTrendUp(int & ma30 [], int & ma50[], int & ma100[])
{
   bool bUp = false;
   if(ma100[1] < ma50[1] && ma50[1] <= ma30[1])
   {
      // 各均线按顺序排列
      if(ma100[1] > ma100[2]
         && ma50[1] > ma50[2]
         // && ma30[1] >= ma30[2]
         )
      {
         // 各个均线都处在上涨的方向
         bUp = true;
      }
   }
   return bUp;
}


bool IsTrendDown(int & ma30 [], int & ma50[], int & ma100[])
{
   bool bDown = false;
   if(ma100[1] > ma50[1] && ma50[1] >= ma30[1])
   {
      // 各均线按顺序排列
      if(ma100[1] < ma100[2]
         && ma50[1] < ma50[2]
         // && ma30[1] <= ma30[2]
         )
      {
         // 各个均线都处在上涨的方向
         bDown = true;
      }
   }
   return bDown;
}


int CheckTrend(int nTimeFrame)
{
   int nTrend = FLUCTUATION;
   int ma30[MA_COUNT], ma50[MA_COUNT], ma100[MA_COUNT];
   int i = 0;
  
   for(i = 1; i < MA_COUNT; i++)
   {
      ma30[i] = MathFloor(iMA(NULL, nTimeFrame, 30, 0, MODE_SMA, PRICE_TYPICAL, i) / Point);
   }
   
   for(i = 1; i < MA_COUNT; i++)
   {
      ma50[i] = MathFloor(iMA(NULL, nTimeFrame, 50, 0, MODE_SMA, PRICE_TYPICAL, i) / Point);
   }
   
   for(i = 1; i < MA_COUNT; i++)
   {
      ma100[i] = MathFloor(iMA(NULL, nTimeFrame, 100, 0, MODE_SMA, PRICE_TYPICAL, i) / Point);
   }
   
   if(IsTrendUp(ma30, ma50, ma100))
   {
      nTrend = TREND_UP;
      if(dtTrendUpBegin == 0)
      {
         dtTrendUpBegin = Time[1];
      }
   }else if(IsTrendDown(ma30, ma50, ma100)) 
   {
      nTrend = TREND_DOWN;
      if(dtTrendDownBegin == 0)
      {
         dtTrendDownBegin = Time[1];
      }
   }
   
   return nTrend;
}

bool CheckForOpenBuy(int nTrend)
{
   int bRet = false;
   string logMsg;
   if(nTrend != TREND_UP)
   {
      return bRet;
   }
   
   int i = 0;
   int nTimeFrame = TimeFrame;
   bool bLowerThanM100 = false;
   for(i = 1; i <= 100; i++)
   {
      double ma100 = iMA(NULL, nTimeFrame, 100, 0, MODE_SMA, PRICE_TYPICAL, i);
      double ma50 = iMA(NULL, nTimeFrame, 50, 0, MODE_SMA, PRICE_TYPICAL, i);
      
      datetime time_i = iTime(NULL, nTimeFrame, i);
      if(time_i < dtTrendUpBegin)
      {
         break;
      }
      
      // 历史上收盘价曾经跌破过MA100，趋势不稳定，不适合入场
      if(Close[i] <= ma100)
      {
         bLowerThanM100 = true;
         logMsg = StringFormat(" %s => Close price(%s) was lower than ma100(%s) in time %s.", 
                  __FUNCTION__, DoubleToString(Close[i], 5), 
                  DoubleToString(ma100, 5),
                  TimeToString(time_i, TIME_DATE|TIME_SECONDS));
         LogInfo(logMsg);
         break;
      }
      
   }
   
   if(bLowerThanM100)
   {
      return bRet;
   }
   
   double ma50Pre = iMA(NULL, nTimeFrame, 50, 0, MODE_SMA, PRICE_TYPICAL, 1);
   double ma30Pre = iMA(NULL, nTimeFrame, 30, 0, MODE_SMA, PRICE_TYPICAL, 1);
   
   if(Open[1] <= ma50Pre && Close[1] > ma50Pre)
   {
      bRet = true;
   }else if(Open[1] <= ma30Pre && Close[1] > ma30Pre)
   {
      bRet = true;
   }   
   
   return bRet;
}


bool CheckForOpenSell(int nTrend)
{
   int bRet = false;
   string logMsg;
    if(nTrend != TREND_DOWN)
   {
      return bRet;
   }
   
   int i = 0;
   int nTimeFrame = TimeFrame;
   bool bUpperThanM100 = false;
   for(i = 1; i <= 100; i++)
   {
      double ma100 = iMA(NULL, nTimeFrame, 100, 0, MODE_SMA, PRICE_TYPICAL, i);
      double ma50 = iMA(NULL, nTimeFrame, 50, 0, MODE_SMA, PRICE_TYPICAL, i);
      
      datetime time_i = iTime(NULL, nTimeFrame, i);
      if(time_i < dtTrendDownBegin)
      {
         break;
      }
      
      // 历史上收盘价曾经高过MA100，趋势不稳定，不适合入场
      if(Close[i] >= ma100)
      {
         bUpperThanM100 = true;
         logMsg = StringFormat(" %s => Close price(%s) was higher than ma100(%s) in time %s.", 
                  __FUNCTION__, DoubleToString(Close[i], 5), 
                  DoubleToString(ma100, 5),
                  TimeToString(time_i, TIME_DATE|TIME_SECONDS));
         LogInfo(logMsg);
         break;
      }
   }
   
   if(bUpperThanM100)
   {
      return bRet;
   }
   
   double ma50Pre = iMA(NULL, nTimeFrame, 50, 0, MODE_SMA, PRICE_TYPICAL, 1);
   double ma30Pre = iMA(NULL, nTimeFrame, 30, 0, MODE_SMA, PRICE_TYPICAL, 1);
   
   if(Open[1] >= ma50Pre && Close[1] < ma50Pre)
   {
      bRet = true;
   }else if(Open[1] >= ma30Pre && Close[1] < ma30Pre)
   {
      bRet = true;
   }  
   
   return bRet;
}


int CheckForClose()
{
   int nDirect = -1;
   int nPeriod = RSI_Period;
   string logMsg;
   int iRsi2 = MathFloor(iRSI(Symbol(), TimeFrame, nPeriod,PRICE_CLOSE,2));
   int iRsi1 = MathFloor(iRSI(Symbol(), TimeFrame, nPeriod,PRICE_CLOSE,1));
   int iRsi0 = MathFloor(iRSI(Symbol(), TimeFrame, nPeriod,PRICE_CLOSE,0));
   
   if(MonitorCheckForClose)
   {
      logMsg = StringFormat(" %s => nPeriod = %d, RSI_2 = %s, RSI_1 = %s, RSI_0 = %s", 
                  __FUNCTION__, nPeriod, 
                  DoubleToString(iRsi2, 3), 
                  DoubleToString(iRsi1, 3),
                  DoubleToString(iRsi0, 3));
      LogInfo(logMsg);
   }   
   
   if(iRsi2 <= RSI_LowForClose)
   {
      if(iRsi1 > iRsi2)
      {
         nDirect = OP_SELL;
         logMsg = __FUNCTION__ + ": Direction = OP_SELL, iRsi2 = " 
                  + DoubleToString(iRsi2, 3) + ", iRsi1 = " 
                  + DoubleToString(iRsi1, 3);
         //LogInfo(logMsg);
      }
   }
   
   if(iRsi2 >= RSI_HighForClose)
   {
      if(iRsi1 < iRsi2)
      {
         nDirect = OP_BUY;
         logMsg = __FUNCTION__ + ": Direction = OP_BUY, iRsi2 = " 
                     + DoubleToString(iRsi2, 3) 
                     + ", iRsi1 = " + DoubleToString(iRsi1, 3)
                     + ", iRsi0 = " + DoubleToString(iRsi0, 3);
         //LogInfo(logMsg);
      }
   }
    
    
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;

}
