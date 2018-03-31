//+------------------------------------------------------------------+
//|                                                      MaCheck.mqh |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "ClUtil.mqh"
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

enum { FLUCTUATION = 0, TREND_UP = 1, TREND_GREAT_UP = 2, TREND_DOWN = 3, TREND_GREAT_DOWN = 4};
string TrendName[] = 
{  
   "FLUCTUATION", 
   "TREND_UP", 
   "TREND_GREAT_UP",   
   "TREND_DOWN", 
   "TREND_GREAT_DOWN"  
};

#define MA_COUNT 4

int gPreTrend = -1;
int CheckTrend()
{
   int nTrend = FLUCTUATION;
   double ma[MA_COUNT];
   double pa[MA_COUNT];
   for(int i = 1; i < MA_COUNT; i++)
   {
      pa[i] = (High[i] + Low[i]) / 2;
      ma[i] = iMA(NULL,0, 7, 0, MODE_SMA, PRICE_TYPICAL, i);
   }
   
   if(ma[3] < ma[2])
   {
      if(ma[2] < ma[1])
      {
         nTrend = TREND_UP;
      }else 
      {
         nTrend = FLUCTUATION;
      }
   
   }else 
   {  
      if(ma[2] > ma[1])
      {
         nTrend = TREND_DOWN;
      }else 
      {
         nTrend = FLUCTUATION;
      }
   }
   return nTrend;
}

int CheckForOpen()
{
   int nDirect = -1;
   if(Volume[0] > 1) 
      return nDirect;
      
   int nTrend = CheckTrend();
   string logMsg = StringFormat("CheckForOpen: trend = %d", nTrend);
   if(bNewBar)
   {
      LogInfo(logMsg);
   }
   if(gPreTrend == -1)
   {
      gPreTrend = nTrend;
      return nDirect;
   }
  
   if(nTrend != gPreTrend)
   {
      if(gPreTrend == FLUCTUATION)
      {
         if(nTrend == TREND_UP)
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForOpen 1: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
         
         if(nTrend == TREND_DOWN)
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForOpen 2: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
      }   
   }else 
   {
      double ma = iMA(NULL,0, 7, 0, MODE_SMA, PRICE_TYPICAL, 1);
      if(nTrend == TREND_DOWN || nTrend == FLUCTUATION)
      {
         if((Open[1] < ma && Close[1] > ma) || Open[1] > ma)
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForOpen 3: nDirect = %d", nDirect);
            LogInfo(logMsg);            
         }
      }
      
      if(nTrend == TREND_UP || nTrend == FLUCTUATION)
      {
         if((Open[1] > ma && Close[1] < ma) || Open[1] < ma)
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForOpen 4: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
      }
   }
      
   gPreTrend = nTrend;   
   return nDirect;
}

int CheckForClose()
{
   int nDirect = -1;
   if(Volume[0] > 1) 
      return nDirect;
      
   int nTrend = CheckTrend();
   string logMsg = StringFormat("CheckForClose: trend = %d", nTrend);
   LogInfo(logMsg);
   if(gPreTrend == -1)
   {
      gPreTrend = nTrend;
      return nDirect;
   }
  
   if(nTrend != gPreTrend)
   {
      if(gPreTrend == FLUCTUATION)
      {
         if(nTrend == TREND_UP)
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForClose 1: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
         
         if(nTrend == TREND_DOWN)
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForClose 2: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
      }   
      
      if(gPreTrend == TREND_UP)
      {
         if(nTrend == FLUCTUATION)
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForClose 3: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
      }
      
      if(gPreTrend == TREND_DOWN)
      {
         if(nTrend == FLUCTUATION)
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForClose 4: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
      }
   }else 
   {
      double ma = iMA(NULL,0, 7, 0, MODE_SMA, PRICE_TYPICAL, 1);
      if(nTrend == TREND_DOWN || nTrend == FLUCTUATION)
      {
         if((Open[1] < ma && Close[1] > ma) || Open[1] > ma)
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForClose 5: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
      }
      
      if(nTrend == TREND_UP || nTrend == FLUCTUATION)
      {
         if((Open[1] > ma && Close[1] < ma) || Open[1] < ma)
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForClose 6: nDirect = %d", nDirect);
            LogInfo(logMsg);
         }
      }
   }
   
   gPreTrend = nTrend;   
   return nDirect;
}
