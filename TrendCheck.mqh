//+------------------------------------------------------------------+
//|                                                   TrendCheck.mqh |
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
#include "PubVar.mqh"
#include "ClUtil.mqh"

#define MA_COUNT 4

input int TrendStandard = 8;
input int MA_Period = 7;

enum { FLUCTUATION = 0, TREND_UP = 1, TREND_GREAT_UP = 2, TREND_DOWN = 3, TREND_GREAT_DOWN = 4};
string TrendName[] = 
{  
   "FLUCTUATION", 
   "TREND_UP", 
   "TREND_GREAT_UP",   
   "TREND_DOWN", 
   "TREND_GREAT_DOWN"  
};

int gPreTrend = -1;

int CheckTrend()
{
   int nTrend = FLUCTUATION;
   int ma[MA_COUNT];
   int pa[MA_COUNT];
   string logMsg;
   for(int i = 1; i < MA_COUNT; i++)
   {
      pa[i] = MathFloor((High[i] + Low[i]) / 2 / Point);
      ma[i] = MathFloor(iMA(NULL, TimeFrame, MA_Period, 0, MODE_SMA, PRICE_TYPICAL, i) / Point);
      logMsg = StringFormat("CheckTrend: ma[%d] = %d, pa[%d] = %d", 
               i, ma[i],
               i, pa[i]);
   }
   
   logMsg = StringFormat("CheckTrend: ma[2] = %d, ma[1] = %d, ma[1] - ma[2] = %d", 
               ma[2], ma[1], ma[1] - ma[2]);
   if(IsNewBar())
   {
     // LogInfo(logMsg);
   }
   
   if(ma[2] < ma[1])
   {
      nTrend = TREND_UP;
      if((ma[1] - ma[2] > TrendStandard
          || ma[2] - ma[3] >= TrendStandard
         )
         && pa[1] - ma[1] > TrendStandard / 2)
      {
         nTrend = TREND_GREAT_UP;
      }
   }
   
   if(ma[2] > ma[1])
   {
      nTrend = TREND_DOWN;
      if((ma[2] - ma[1] > TrendStandard
          || ma[3] - ma[2] >= TrendStandard
         )
         && ma[1] - pa[1] > TrendStandard / 2)
      {
         nTrend = TREND_GREAT_DOWN;
      }
   }
         
   /* 
   if(ma[3] < ma[2])
   {
      if(ma[2] < ma[1])
      {
         nTrend = TREND_UP;
         if((ma[1] > ma[2] && ma[2] > ma[3] && ma[1] - ma[3] >= TrendStandard)
               || (ma[1] - ma[2] >= TrendStandard / 3))
         {
            nTrend = TREND_GREAT_UP;
         }
      }else 
      {
         nTrend = FLUCTUATION;
      }
   
   }else 
   {  
      if(ma[2] > ma[1])
      {
         nTrend = TREND_DOWN;
         if((ma[1] < ma[2] && ma[2] < ma[3] && ma[3] - ma[1] >= TrendStandard)
            || (ma[2] - ma[1] >=  TrendStandard))
         {
            nTrend = TREND_GREAT_DOWN;
         }
      }else 
      {
         nTrend = FLUCTUATION;
      }
   }
   */
   return nTrend;  
}