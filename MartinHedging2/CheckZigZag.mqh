//+------------------------------------------------------------------+
//|                                                  CheckZigZag.mqh |
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

int   InpDepth = 12  ;    //Depth
int   InpDeviation = 5  ;    //Deviation
int   InpBackstep = 3  ;    //Backstep
int   BigMa = 10  ;    //大均线周期
int   SmallMa = 5  ;    //小均线周期


enum { FLUCTUATION = 0, TREND_UP = 1, TREND_DOWN = 2};
string TrendName[] = 
{  
   "FLUCTUATION", 
   "TREND_UP", 
   "TREND_DOWN"  
};

#define INDICATOR_NAME "ZigZagMaDiff"
#define EXTREMUM_COUNT 3
double gHighPoints[EXTREMUM_COUNT];
double gLowPoints[EXTREMUM_COUNT];

int gPreTrend = FLUCTUATION;
int gNearestExtremumBar = 9999;

int CheckTrend(int nPreTrend, string symbol1, string symbol2)
{  
   int nTrend = nPreTrend;
   int nTimeFrame = TimeFrame;
   string logMsg;
   int nBarsCnt = iBars(NULL, nTimeFrame);
   int i = 0;
   int nExtremumCnt = 0;
   int nBarsIndex[EXTREMUM_COUNT * 2];
   double dExtremumPoints[EXTREMUM_COUNT * 2];
   ArrayInitialize(dExtremumPoints, 0.0);
   ArrayInitialize(nBarsIndex, 0);
   bool bFirstZigZag = true;
   for (i = InpBackstep; i < nBarsCnt ; i++)
   {
      double dExtremum = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 symbol1, symbol2, 
                                 0, i);
      /*                                 
      if(dExtremum != 0.0)
      {
         if(bFirstZigZag) 
         {  
            // 跳过第一个zigzag值
            bFirstZigZag = false;
            continue;
         }
      }
      */
      
      if(dExtremum != 0.0 && nExtremumCnt < EXTREMUM_COUNT * 2)
      {
         dExtremumPoints[nExtremumCnt] = dExtremum;
         nBarsIndex[nExtremumCnt] = i;
         logMsg = StringFormat(" %s => Extremum value [%d] = %s.", 
                  __FUNCTION__, i, DoubleToString(dExtremum, 4));
         if(gIsNewBar)
         {
            //LogInfo(logMsg);  
         } 
         nExtremumCnt++;
      }
   }
   
   gNearestExtremumBar = nBarsIndex[0];
   
   logMsg = StringFormat(" %s => Extremum[0] = %s in Bars = %d", 
                  __FUNCTION__, DoubleToString(dExtremumPoints[0], 4), nBarsIndex[0]);
   // LogInfo(logMsg);  
            
   if(nExtremumCnt > 0)
   {
      if(dExtremumPoints[0] > dExtremumPoints[1])
      {
         for(i = 0; i < EXTREMUM_COUNT; i++)
         {
            gHighPoints[i] = dExtremumPoints[2 * i];
            gLowPoints[i] = dExtremumPoints[2 * i + 1];
         }
         nTrend = TREND_DOWN;
      }else 
      {
         for(i = 0; i < EXTREMUM_COUNT; i++)
         {
            gLowPoints[i] = dExtremumPoints[2 * i];
            gHighPoints[i] = dExtremumPoints[2 * i + 1];
         }
         nTrend = TREND_UP;
      }
   }
   
   logMsg = StringFormat(" %s => Trend = %s, L[0] = %s, H[0] = %s, E[0] = %s in Bar[%d],  E[1] = %s in Bar[%d]", 
                  __FUNCTION__, TrendName[nTrend], 
                  DoubleToString(gLowPoints[0], 4),DoubleToString(gHighPoints[0], 4),
                  DoubleToString(dExtremumPoints[0], 4),nBarsIndex[0],
                  DoubleToString(dExtremumPoints[1], 4), nBarsIndex[1]);
   if(gIsNewBar)
   //if(gTickCount % 20 == 0 || nTrend != nPreTrend )
   {
      LogInfo(logMsg);  
   }
   return nTrend;
}

int CheckForOpenEx(int nPreTrend, int nTrend, string symbol1, string symbol2)
{
   int nDirect = -1;
   
   string logMsg;
   double dHighest = MathMax(gHighPoints[0], gHighPoints[1]);
   dHighest = MathMax(dHighest, gHighPoints[2]);
   
   double dLowest = MathMin(gLowPoints[0], gLowPoints[1]);
   dLowest = MathMin(dLowest, gLowPoints[2]); 
   
   double dMidPoint1 = dLowest + (dHighest - dLowest) * 0.382;
   double dMidPoint2 = dLowest + (dHighest - dLowest) * 0.618;
   int nTimeFrame = TimeFrame;
   double dLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 symbol1, symbol2, 
                                 1, 0);
     
   if(nPreTrend != TREND_UP && nTrend == TREND_UP)
   {
     logMsg = StringFormat(" %s =>Trend changed, DOWN-->UP, Nearest bar = %d, L2 = %s, L1 = %s, L0 = %s, Current = %s, MP1 = %s", 
                     __FUNCTION__, gNearestExtremumBar, 
                     DoubleToString(gLowPoints[2], 4), 
                     DoubleToString(gLowPoints[1], 4), 
                     DoubleToString(gLowPoints[0], 4), 
                     DoubleToString(dLabel2, 4), 
                     DoubleToString(dMidPoint1, 4));
      //if(gIsNewBar)
      {
         LogInfo(logMsg);  
      }
         
      if(
            gLowPoints[0] < gLowPoints[1] && gLowPoints[0] < gLowPoints[2] && 
            dLabel2 <= dMidPoint1 
            && gNearestExtremumBar <= InpBackstep + 2)
      {
         nDirect = OP_BUY;
         logMsg = StringFormat(" %s =>Catch direct, OP_BUY", __FUNCTION__);
         // if(gIsNewBar)
         {
            LogInfo(logMsg);  
         }
      } 
   }else if(nPreTrend != TREND_DOWN && nTrend == TREND_DOWN)
   {
   
      logMsg = StringFormat(" %s => Trend changed, UP --> DOWN, Nearest bar = %d, H2 = %s, H1 = %s, H0 = %s, Current = %s, MP2 = %s",
                     __FUNCTION__, gNearestExtremumBar, 
                     DoubleToString(gHighPoints[2], 4), 
                     DoubleToString(gHighPoints[1], 4), 
                     DoubleToString(gHighPoints[0], 4), 
                     DoubleToString(dLabel2, 4), 
                     DoubleToString(dMidPoint2, 4));
       
      // if(gIsNewBar)
      {
         LogInfo(logMsg);  
      }
      
      if(  gHighPoints[0] > gHighPoints[1] && gHighPoints[0] > gHighPoints[2] && 
           dLabel2 >= dMidPoint2   
               && gNearestExtremumBar <= InpBackstep + 2)
      {
        nDirect = OP_SELL;
        logMsg = StringFormat(" %s =>Catch direct, OP_SELL", __FUNCTION__);
         // if(gIsNewBar)
         {
            LogInfo(logMsg);  
         } 
      }
   }
   
   return nDirect;
   
}

int CheckForOpen(int nPreTrend, int nTrend, string symbol1, string symbol2)
{
   int nDirect = -1;
   
   string logMsg;
   double dHighest = gHighPoints[0];//MathMax(gHighPoints[0], gHighPoints[1]);
   
   double dLowest = gLowPoints[0];//MathMin(gLowPoints[0], gLowPoints[1]);
   
   double dHiLevel = dHighest;
   if(gHighPoints[0] > gHighPoints[1]) {
      dHiLevel = dHighest + (dHighest - dLowest) * IncDropFactor;
   }
   
   double dLoLevel = dLowest;
   if(gLowPoints[0] < gLowPoints[1]) {
      dLoLevel = dLowest - (dHighest - dLowest) * IncDropFactor;
   }
   
   int nTimeFrame = TimeFrame;
   
   // 获取前一根柱子的label2的值
   double dLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 symbol1, symbol2, 
                                 1, 1);
    if(gIsNewBar) 
    {
      logMsg = StringFormat("CheckForOpen: HiLev = %s, LoLevel = %s, Pre bar = %s.", 
         DoubleToString(dHiLevel, 4), DoubleToString(dLoLevel, 4), DoubleToString(dLabel2, 4));
      LogInfo(logMsg);
    }
     
   if(dLabel2 >= dHiLevel) {
      nDirect = OP_SELL;
      //if(gIsNewBar) 
      {
         logMsg = StringFormat("CheckForOpen: HiLev = %s, Pre bar = %s.", 
            DoubleToString(dHiLevel, 4), DoubleToString(dLabel2, 4));
         LogInfo(logMsg);
         logMsg = StringFormat("CheckForOpen: Cache direct %d.", nDirect);
         LogInfo(logMsg);
      }
   }
   
   if(dLabel2 <= dLoLevel) {
      nDirect = OP_BUY;
      //if(gIsNewBar) 
      {
         logMsg = StringFormat("CheckForOpen: LoLev = %s, Pre bar = %s.", 
            DoubleToString(dLoLevel, 4), DoubleToString(dLabel2, 4));
         LogInfo(logMsg);
         logMsg = StringFormat("CheckForOpen: Cache direct %d.", nDirect);
         LogInfo(logMsg);
      }
     
   }
   
   return nDirect;
   
}

int CheckForAppend(int nPreTrend, int nTrend, string symbol1, string symbol2)
{
   string logMsg;
   
   LogInfo("++++++++++++++++ CheckForAppend +++++++++++++++++++");
   int nDiret = CheckForOpen(nPreTrend, nTrend, symbol1, symbol2);
   if(nDiret != -1) {
      logMsg = StringFormat("CheckForAppend OK, direct = %d", nDiret);
   }
   return nDiret;
   
}
int CheckForClose(int nPreTrend, int nTrend, string symbol1, string symbol2)
{
   int nDirect = -1;
   
   string logMsg;
   double dHighest = MathMax(gHighPoints[0], gHighPoints[1]);
   
   double dLowest = MathMin(gLowPoints[0], gLowPoints[1]);
   
   double dHiLevel = dHighest;
   if(gHighPoints[0] > gHighPoints[1]) {
      dHiLevel = dHighest + (dHighest - dLowest) * IncDropFactor;
   }
   
   double dLoLevel = dLowest;
   if(gLowPoints[0] < gLowPoints[1]) {
      dLoLevel = dLowest - (dHighest - dLowest) * IncDropFactor;
   }
   
   int nTimeFrame = TimeFrame;
   
   // 获取前一根柱子的label2的值
   double dLabel2 = iCustom(NULL, nTimeFrame, INDICATOR_NAME, 
                                 InpDepth,InpDeviation,InpBackstep,
                                 BigMa,SmallMa,
                                 symbol1, symbol2, 
                                 1, 1);
    //if(gIsNewBar) 
    {
      logMsg = StringFormat("CheckForClose: HiLev = %s, LoLevel = %s, Pre bar = %s.", 
         DoubleToString(dHiLevel, 4), DoubleToString(dLoLevel, 4), DoubleToString(dLabel2, 4));
      LogInfo(logMsg);
    }
     
   if(dLabel2 >= dHiLevel) {
      nDirect = OP_BUY;
      //if(gIsNewBar) 
      {
         logMsg = StringFormat("CheckForClose: HiLev = %s, Pre bar = %s.", 
            DoubleToString(dHiLevel, 4), DoubleToString(dLabel2, 4));
         LogInfo(logMsg);
         logMsg = StringFormat("CheckForClose: Cache close %d.", nDirect);
         LogInfo(logMsg);
      }
   }
   
   if(dLabel2 <= dLoLevel) {
      nDirect = OP_SELL;
      //if(gIsNewBar) 
      {
         logMsg = StringFormat("CheckForClose: LoLev = %s, Pre bar = %s.", 
            DoubleToString(dLoLevel, 4), DoubleToString(dLabel2, 4));
         LogInfo(logMsg);
         logMsg = StringFormat("CheckForClose: Cache close %d.", nDirect);
         LogInfo(logMsg);
      }
     
   }
   
   return nDirect;
   
}

