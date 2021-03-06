//+------------------------------------------------------------------+
//|                                                     MaCheck2.mqh |
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
#include "TrendCheck.mqh"




int CheckForOpen()
{
   int nDirect = -1;
   string logMsg;
   bool bIsNewBar = IsNewBar();
   if(bIsNewBar)
   {
      // LogInfo("CheckForOpen: ===================New Bar=====================");
   }
   if(!bIsNewBar) 
      return nDirect;
      
   int nTrend = CheckTrend();
   logMsg = StringFormat("CheckForOpen: trend = %s", TrendName[nTrend]);
   LogInfo(logMsg);
               
   if(nTrend == TREND_GREAT_DOWN || nTrend == TREND_GREAT_UP)
   {
      return nDirect;
   }
   
   int ma[MA_COUNT];
   int pa[MA_COUNT];
   for(int i = 1; i < MA_COUNT; i++)
   {
      pa[i] = MathFloor((High[i] + Low[i]) / 2 / Point);
      ma[i] = MathFloor(iMA(NULL, TimeFrame, MA_Period, 0, MODE_SMA, PRICE_TYPICAL, i) / Point);
      logMsg = StringFormat("CheckForOpen: ma[%d] = %d, pa[%d] = %d", 
               i, ma[i],
               i, pa[i]);
      if(IsNewBar())
      {
        //LogInfo(logMsg);
      }
   }
   
   //均线向上穿过K线
   if(pa[2] < ma[2] && pa[1] >= ma[1])
   {
      nDirect = OP_BUY; 
      logMsg = StringFormat("CheckForOpen 1: nDirect = %d", nDirect);
      if(IsNewBar())
      {
        LogInfo(logMsg);
      }      
   }
   
   //均线向下穿过K线
   if(pa[2] > ma[2] && pa[1] <= ma[1])
   {
      nDirect = OP_SELL;
      logMsg = StringFormat("CheckForOpen 2: nDirect = %d", nDirect);
      if(IsNewBar())
      {
        LogInfo(logMsg);
      } 
   }
   
   return nDirect;
}

int CheckForClose()
{
   int nDirect = -1;
   string logMsg;
   bool bIsNewBar = IsNewBar();
   if(bIsNewBar)
   {
      // LogInfo("CheckForClose: ===================New Bar=====================");
   }
   if(!bIsNewBar) 
      return nDirect;
      
   int nTrend = CheckTrend();
   logMsg = StringFormat("CheckForClose: trend = %s", TrendName[nTrend]);
   LogInfo(logMsg);
   if(gPreTrend != -1)
   {
      if(gPreTrend != nTrend)
      {
         logMsg = StringFormat("CheckForClose trend changed: %s --> %s", TrendName[gPreTrend], TrendName[nTrend]);
         LogInfo(logMsg);
      }
      
      if(gPreTrend == TREND_GREAT_UP && nTrend != TREND_GREAT_UP)
      {
         nDirect = OP_BUY;
         logMsg = StringFormat("CheckForClose 1: nDirect = %d", nDirect);
         if(IsNewBar())
         {
           LogInfo(logMsg);
         } 
      }
      
      if(gPreTrend == TREND_GREAT_DOWN && nTrend != TREND_GREAT_DOWN)
      {
         nDirect = OP_SELL;
         logMsg = StringFormat("CheckForClose 2: nDirect = %d", nDirect);
         if(IsNewBar())
         {
           LogInfo(logMsg);
         } 
      }
      
      if(nTrend == TREND_GREAT_DOWN && gPreTrend != TREND_GREAT_DOWN)
      {
         nDirect = OP_BUY;
         logMsg = StringFormat("CheckForClose 3: nDirect = %d", nDirect);
         if(IsNewBar())
         {
           LogInfo(logMsg);
         } 
      }
      
      if(nTrend == TREND_GREAT_UP && gPreTrend != TREND_GREAT_UP)
      {
         nDirect = OP_SELL;
         logMsg = StringFormat("CheckForClose 4: nDirect = %d", nDirect);
         if(IsNewBar())
         {
           LogInfo(logMsg);
         } 
      }
      
   }
   
   gPreTrend = nTrend;
   
   return nDirect;
}

/*
int CheckForClose()
{
   int nDirect = -1;
   bool bIsNewBar = IsNewBar();
   if(bIsNewBar)
   {
      LogInfo("CheckForOpen: ===================New Bar=====================");
   }
   if(!bIsNewBar) 
      return nDirect;
      
   string logMsg;
   int ma[MA_COUNT];
   int pa[MA_COUNT];
   for(int i = 1; i < MA_COUNT; i++)
   {
      pa[i] = MathFloor((High[i] + Low[i]) / 2 / Point);
      ma[i] = MathFloor(iMA(NULL, TimeFrame, MA_Period, 0, MODE_SMA, PRICE_TYPICAL, i) / Point);
      logMsg = StringFormat("CheckForClose: ma[%d] = %d, pa[%d] = %d", 
               i, ma[i],
               i, pa[i]);
      if(IsNewBar())
      {
        LogInfo(logMsg);
      } 
    }
   
   
         
   //在下行行情中，出现转折
   if(pa[2] < ma[2] && pa[1] >= ma[1])
   {
      if(ma[1] > ma[2])
      {
         nDirect = OP_SELL;
         logMsg = StringFormat("CheckForClose 1: nDirect = %d", nDirect);
         if(IsNewBar())
         {
           LogInfo(logMsg);
         }          
      }
   }
   
   //在上行行情中，出现转折
   if(pa[2] > ma[2] && pa[1] <= ma[1])
   {
      if(ma[1] < ma[2])
      {
         nDirect = OP_SELL;
         logMsg = StringFormat("CheckForClose 2: nDirect = %d", nDirect);
        if(IsNewBar())
         {
           LogInfo(logMsg);
         } 
      }
   }
   
   return nDirect;
}
*/