//+------------------------------------------------------------------+
//|                                                     RsiCheck.mqh |
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
#include "ClUtil.mqh"
#include "PubVar.mqh"
#include "TrendCheck.mqh"

int CheckForOpenRSI()
{
   int nDirect = -1;
   string logMsg;
   bool bIsNewBar = IsNewBar();
   if(bIsNewBar)
   {
      // LogInfo("CheckForOpenRSI: ===================New Bar=====================");
   }
   if(!bIsNewBar) 
      return nDirect;
   
   
   int nTrend = CheckTrend();
      
   int nPeriod = RSI_Period;
   int iRsi2 = MathFloor(iRSI(Symbol(), TimeFrame, nPeriod,PRICE_CLOSE,2));
   int iRsi1 = MathFloor(iRSI(Symbol(), TimeFrame, nPeriod,PRICE_CLOSE,1));
   int iRsi0 = MathFloor(iRSI(Symbol(), TimeFrame, nPeriod,PRICE_CLOSE,0));
   
   if(MonitorCheckForOpen)
   {
      logMsg = StringFormat(" %s => nPeriod = %d,  iRsi2 = %s, iRsi1 = %s, iRsi0 = %s", 
                  __FUNCTION__, nPeriod, 
                  DoubleToString(iRsi2, 3), 
                  DoubleToString(iRsi1, 3),
                  DoubleToString(iRsi0, 3));
      LogInfo(logMsg);
   }
   
   if(nTrend == TREND_GREAT_UP)
   {
      if(iRsi1 <= iRsi2)
      {
         nDirect = OP_BUY;
         logMsg = StringFormat(" %s =>  Direction = OP_BUY, nTrend = %s", 
                  __FUNCTION__, TrendName[nTrend]);
         LogInfo(logMsg); 
         return nDirect;      
      }
   }else if(nTrend == TREND_GREAT_DOWN)
   {
      if(iRsi1 >= iRsi2)
      {
         nDirect = OP_SELL;
         logMsg = StringFormat(" %s => Direction = OP_SELL, nTrend = %s", 
                  __FUNCTION__, TrendName[nTrend]);
         LogInfo(logMsg);
         return nDirect;      
      }     
      
   }else
   {
      if(iRsi1 <= RSI_LowForOpen)
      {
         //if(iRsi1 > iRsi2)
         {
            nDirect = OP_BUY;
            logMsg = __FUNCTION__ + ": Direction = OP_BUY, iRsi2 = " 
                        + DoubleToString(iRsi2, 3) 
                        + ", iRsi1 = " + DoubleToString(iRsi1, 3)
                        + ", iRsi0 = " + DoubleToString(iRsi0, 3);
            //LogInfo(logMsg);
         }
      }
      
      if(iRsi1 >= RSI_HighForOpen)
      {
         //if(iRsi1 < iRsi2)
         {
            nDirect = OP_SELL;
            logMsg = __FUNCTION__ + ": Direction = OP_SELL, iRsi2 = " 
                        + DoubleToString(iRsi2, 3) 
                        + ", iRsi1 = " + DoubleToString(iRsi1, 3)
                        + ", iRsi0 = " + DoubleToString(iRsi0, 3);
            //LogInfo(logMsg);
         }
      }
   }
   
   
   
   
   
   // logMsg = __FUNCTION__ + ": direction: " + IntegerToString(nDirect);
   // LogDebug(logMsg);
   return nDirect;
}


int CheckForCloseRSI()
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
      
   int nPeriod = RSI_Period;
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