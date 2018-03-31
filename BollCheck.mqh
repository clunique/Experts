//+------------------------------------------------------------------+
//|                                                    BollCheck.mqh |
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

int CheckTrend(int preTrend)
{
   int nTrend = preTrend;
   string logMsg;
   double Main_0 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, 0);
   double Main_1 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
   double Main_2 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, 2);
   
   double Upper_0 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double Upper_1 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double Upper_2 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 2);
   
   double Lower_0 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double Lower_1 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double Lower_2 = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 2);
   
   if(MonitorTrend)
   {
      logMsg = StringFormat("%s => Upper2 = %s, Upper1 = %s, Upper0 = %s",
                                    __FUNCTION__ , DoubleToString(Upper_2, 5), 
                                    DoubleToString(Upper_1, 5), 
                                    DoubleToString(Upper_0), 5);
      LogDebug(logMsg);
      
      logMsg = StringFormat("%s => Main2 = %s, Main1 = %s, Main0 = %s",
                                       __FUNCTION__ , DoubleToString(Main_2, 5), 
                                       DoubleToString(Main_1, 5), 
                                       DoubleToString(Main_0, 5));
      LogDebug(logMsg);
      
      logMsg = StringFormat("%s => Lower2 = %s, Lower1 = %s, Lower0 = %s",
                                    __FUNCTION__ , DoubleToString(Lower_2, 5), 
                                    DoubleToString(Lower_1, 5), 
                                    DoubleToString(Lower_0, 5));
      LogDebug(logMsg);
   }
   double thredshold = Point * TrendThreshold;
   if(preTrend == FLUCTUATION || preTrend == TREND_UP || preTrend == TREND_DOWN) 
   {
      if((Main_0 - Main_1) > thredshold && (Lower_1 - Lower_0) > thredshold)
      {
         logMsg = StringFormat("%s => Main_0 - Main_1 = %s, Lower_1 - Lower_0 = %s",
                                    __FUNCTION__ , 
                                    DoubleToString(Main_0 - Main_1, 5),
                                    DoubleToString(Lower_1 - Lower_0, 5));
         LogInfo(logMsg);
         nTrend = TREND_GREAT_UP;
      } else if((Main_1 - Main_0) > thredshold && (Upper_0 - Upper_1) > thredshold)
      {
         logMsg = StringFormat("%s => Main_1 - Main_0 = %s, Upper_0 - Upper_1 = %s",
                                    __FUNCTION__ , 
                                    DoubleToString(Main_1 - Main_0, 5),
                                    DoubleToString(Upper_0 - Upper_1, 5));
         LogInfo(logMsg);
         nTrend = TREND_GREAT_DOWN;
      } else 
      {
         if(Main_0 >= Main_1)
         {
            nTrend = TREND_UP;
         }else 
         {
            nTrend = TREND_DOWN;
         }   
      }
   }
   
   if(preTrend == TREND_GREAT_UP)
   {
       if(Lower_0 - Lower_1  > thredshold)
       {
         nTrend = TREND_UP;
       }
   }
   
   if(preTrend == TREND_GREAT_DOWN)
   {
        if(Upper_1 - Upper_0 > thredshold)
       {
         nTrend = TREND_DOWN;
       }
   }  
     
   return nTrend;                  
}

int GetContinueTrend()
{
   int nTrend = FLUCTUATION;
   if((High[1] > High[3] && High[3] > High[5] && High[1] - High[5] >= 50 * Point)
      || (Low[1] > Low[3]  && Low[3] > Low[5] && Low[1] - Low[5] >= 50 * Point))
   {
      nTrend = TREND_GREAT_UP;
   }
   
   if((High[1] < High[3] && High[3] < High[5] && High[5] - High[1] >= 50 * Point)
      || (Low[1] < Low[3] && Low[3] < Low[5] && Low[5] - Low[1] >= 50 * Point))
   {
      nTrend = TREND_GREAT_DOWN;
   }
   
   return nTrend;
}

int CheckForOpenByBoll()
{
   // Check for open
   int nDirect = -1;
   string logMsg;
   
   int nTrend = GetContinueTrend();
   if(nTrend != FLUCTUATION)
   {
      gPreTrend = nTrend;
      return nDirect;
   }  
   
   gPreTrend = nTrend;
   
   double main[3], upper[3], lower[3];
   int checkBar = 1;
   int checkPreBar = checkBar + 1;
   for(int i = 0; i < 3; i++)
   {
      main[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, i);
      upper[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, i);
      lower[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, i);
   }
  
   if(High[checkBar] > upper[checkBar])
   {
      if(High[checkPreBar] > upper[checkPreBar])
      {
         if( High[checkBar] < High[checkPreBar] || MathAbs(Close[checkBar] - Low[checkBar]) < TrendThreshold * Point)
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForOpenByBoll 1:  direction = %d", nDirect);
            LogInfo(logMsg);
         }
      }
   }   
   
   if(High[checkBar] <= upper[checkBar] 
      && High[checkPreBar] > upper[checkPreBar])
   {
      nDirect = OP_SELL;
      logMsg = StringFormat("CheckForOpenByBoll 2:  direction = %d", nDirect);
      LogInfo(logMsg);
   } 
   
   if(Low[checkBar] < lower[checkBar])
   {
      if(Low[checkPreBar] < lower[checkPreBar])
      {
        if(Low[checkBar] > Low[checkPreBar] || MathAbs(Close[checkBar] - High[checkBar]) < TrendThreshold * Point)
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForOpenByBoll 3:  direction = %d", nDirect);
            LogInfo(logMsg);
         } 
      }
   }
   
   if(Low[checkBar] >= lower[checkBar] && Low[checkPreBar] < lower[checkPreBar])
   {
      nDirect = OP_BUY;
      logMsg = StringFormat("CheckForOpenByBoll 4:  direction = %d", nDirect);
      LogInfo(logMsg);
   }
    
   return nDirect;
}

bool IsNotBreakUpForLong()
{
   int sampleCount = 5;
   int i = 0;
   bool bRet = true;
   double main[5], upper[5], lower[5];
   for(i = 0; i < 5; i++)
   {
      main[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, i);
      upper[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, i);
      lower[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, i);
   }
   
   for(i = 0; i < sampleCount; i++)
   {
      if(High[i] > upper[i])
      {
         bRet = false;
         break;
      }
   }
   
   return bRet;
}

bool IsNotBreakDownForLong()
{
   int sampleCount = 5;
   int i = 0;
   bool bRet = true;
   double main[5], upper[5], lower[5];
   for(i = 0; i < 5; i++)
   {
      main[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, i);
      upper[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, i);
      lower[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, i);
   }
   
   for(i = 0; i < sampleCount; i++)
   {
      if(Low[i] < lower[i])
      {
         bRet = false;
         break;
      }
   }   
   return bRet;
}

int CheckForCloseByBoll()
{  
   int nDirect = -1;
   string logMsg;
   
   int nTrend = GetContinueTrend();
  
   if(gPreTrend != nTrend)
   {
      logMsg = StringFormat("CheckForCloseByBoll:  gPreTrend = %d, Trend = %d", gPreTrend, nTrend);
      LogInfo(logMsg);
      if(gPreTrend == TREND_GREAT_UP && nTrend != TREND_GREAT_UP)
      {  
         nDirect = OP_BUY;
         gPreTrend = nTrend;
         logMsg = StringFormat("CheckForCloseByBoll 00:  direction = %d", nDirect);
         LogInfo(logMsg);
         return nDirect;
      }
      
      if(gPreTrend == TREND_GREAT_DOWN && nTrend != TREND_GREAT_DOWN)
      {
         nDirect = OP_SELL;
         gPreTrend = nTrend;
         logMsg = StringFormat("CheckForCloseByBoll 01:  direction = %d", nDirect);
         LogInfo(logMsg);
         return nDirect;
      }      
   }
   
   if(nTrend == TREND_GREAT_DOWN || nTrend == TREND_GREAT_UP)
   {
      gPreTrend = nTrend;
      return nDirect;
   }  
   
   gPreTrend = nTrend;
   
   double main[3], upper[3], lower[3];
   int checkBar = 1;
   int checkPreBar = checkBar + 1;
   for(int i = 0; i < 3; i++)
   {
      main[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_MAIN, i);
      upper[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, i);
      lower[i] = iBands(Symbol(), TimeFrame, BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, i);
   }
  
  if(High[checkBar] >= upper[checkBar])
   {
      if(High[checkPreBar] > upper[checkPreBar])
      {
         if(MathAbs(Close[checkBar] - Low[checkBar]) < TrendThreshold * Point)
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForCloseByBoll 1:  direction = %d", nDirect);
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 1:  High[%d]= %s, upper[%d] = %s",
                        checkBar, DoubleToString(High[checkBar], 6), 
                        checkBar, DoubleToString(upper[checkBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 1:  High[%d]= %s, upper[%d] = %s",
                        checkPreBar, DoubleToString(High[checkPreBar], 6), 
                        checkPreBar, DoubleToString(upper[checkPreBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 1:  Close[%d]= %s, Low[%d] = %s",
                        checkBar, DoubleToString(Close[checkBar], 6), 
                        checkBar, DoubleToString(Low[checkBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
         }
      }
   }   
   
   if(High[checkBar] < upper[checkBar])
   { 
      if(High[checkPreBar] > upper[checkPreBar])
      {
          nDirect = OP_BUY;
          logMsg = StringFormat("CheckForCloseByBoll 2:  direction = %d", nDirect);
          if(bNewBar)
            { 
               LogInfo(logMsg);
            }
          logMsg = StringFormat("CheckForCloseByBoll 2:  High[%d]= %s, upper[%d] = %s",
                        checkBar, DoubleToString(High[checkBar], 6), 
                        checkBar, DoubleToString(upper[checkBar], 6));
          if(bNewBar)
            { 
               LogInfo(logMsg);
            }
          logMsg = StringFormat("CheckForCloseByBoll 2:  High[%d]= %s, upper[%d] = %s",
                     checkPreBar, DoubleToString(High[checkPreBar], 6), 
                     checkPreBar, DoubleToString(upper[checkPreBar], 6));
          if(bNewBar)
            { 
               LogInfo(logMsg);
            }
      }else 
      {
         if(IsNotBreakUpForLong()
               && (upper[checkPreBar] - High[checkPreBar]) < TrendThreshold * Point 
               && High[checkBar] < High[checkPreBar])
         {
            nDirect = OP_BUY;
            logMsg = StringFormat("CheckForCloseByBoll 3:  direction = %d", nDirect);
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 3:  High[%d]= %s, upper[%d] = %s",
                        checkBar, DoubleToString(High[checkBar], 6), 
                        checkBar, DoubleToString(upper[checkBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 3:  High[%d]= %s, upper[%d] = %s",
                        checkPreBar, DoubleToString(High[checkPreBar], 6), 
                        checkPreBar, DoubleToString(upper[checkPreBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
         }
      }
   } 
   
   if(Low[checkBar] <= lower[checkBar])
   {
      if(Low[checkPreBar] < lower[checkPreBar])
      {
        if(MathAbs(Close[checkBar] - High[checkBar]) < TrendThreshold * Point)
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForCloseByBoll 4:  direction = %d", nDirect);
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 4:  Low[%d]= %s, lower[%d] = %s",
                        checkBar, DoubleToString(Low[checkBar], 6), 
                        checkBar, DoubleToString(lower[checkBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 4:  Low[%d]= %s, lower[%d] = %s",
                        checkPreBar, DoubleToString(Low[checkPreBar], 6), 
                        checkPreBar, DoubleToString(lower[checkPreBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 4:  Close[%d]= %s, High[%d] = %s",
                        checkBar, DoubleToString(Close[checkBar], 6), 
                        checkBar, DoubleToString(High[checkBar], 6));
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
         } 
      }
   }
   
   if(Low[checkBar] > lower[checkBar])
   {    
      if(Low[checkPreBar] < lower[checkPreBar])
      {
         nDirect = OP_SELL;
         logMsg = StringFormat("CheckForCloseByBoll 5:  direction = %d", nDirect);
         if(bNewBar)
            { 
               LogInfo(logMsg);
            }
         logMsg = StringFormat("CheckForCloseByBoll 5:  Low[%d]= %s, lower[%d] = %s",
                        checkBar, DoubleToString(Low[checkBar], 6),
                        checkBar, DoubleToString(lower[checkBar], 6));
         if(bNewBar)
            { 
               LogInfo(logMsg);
            }
         logMsg = StringFormat("CheckForCloseByBoll 5:  Low[%d]= %s, lower[%d] = %s",
                        checkPreBar, DoubleToString(Low[checkPreBar], 6), 
                        checkPreBar, DoubleToString(lower[checkPreBar], 6));
         if(bNewBar)
            { 
               LogInfo(logMsg);
            }
      }else 
      {
         if(IsNotBreakDownForLong()
            && Low[checkPreBar] - lower[checkPreBar] < TrendThreshold * Point
            && Low[checkBar] > Low[checkPreBar])
         {
            nDirect = OP_SELL;
            logMsg = StringFormat("CheckForCloseByBoll 6:  direction = %d", nDirect);
            if(bNewBar)
            { 
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseByBoll 6:  Low[%d]= %s, lower[%d] = %s",
                        checkPreBar, DoubleToString(Low[checkPreBar], 6), 
                        checkPreBar, DoubleToString(lower[checkPreBar], 6));
           if(bNewBar)
            { 
               LogInfo(logMsg);
            }
         }
      }
   }
   return nDirect;

}