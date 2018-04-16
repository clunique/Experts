//+------------------------------------------------------------------+
//|                                                  MartinOrder.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "../Pub/ClUtil.mqh"
#include "../Pub/OrderInfo.mqh"

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
#define MAX_ORDER_COUNT 20

class CMartinOrder
{
public:
   int m_nTimeFrame;
   int m_nMainDirect;
   int m_nSubDirect;
   int m_nSymbol1OrderCount;
   int m_nSymbol2OrderCount;
   string m_symbol1;
   string m_symbol2;
   string m_comment;
   int m_nMagicNum;
   double m_dBaseOpenLots;
   double m_dMultiple;
   int m_nMaxOrderCount;
   COrderInfo m_orderInfo2[MAX_ORDER_COUNT];
   COrderInfo m_orderInfo1[MAX_ORDER_COUNT];
   
public:
   CMartinOrder(string symbol1, string symbol2, int nDirect, 
               int nTimeFrame, double BaseOpenLots, double dMultiple, int nMaxOrderCount) 
   {
      m_nMainDirect = nDirect;
      m_nSymbol1OrderCount = 0;
      m_nSymbol2OrderCount = 0;
      m_symbol1 = symbol1;
      m_symbol2 = symbol2;
      m_nTimeFrame = nTimeFrame;
      m_dBaseOpenLots = BaseOpenLots;
      m_dMultiple = dMultiple;
      m_nMaxOrderCount = nMaxOrderCount;
      if(nDirect == OP_BUY)
      {
         m_comment = "Buy";
         m_nSubDirect = OP_SELL;
         m_nMagicNum = 10000 + m_nTimeFrame;
      }else
      {
         m_comment = "Sell";
         m_nSubDirect = OP_BUY;
         m_nMagicNum = 20000 + m_nTimeFrame;
      }
   }
   int LoadAllOrders()
   {
      m_nSymbol2OrderCount = LoadOrders(m_symbol2, m_orderInfo2, m_nMainDirect, m_comment, m_nMagicNum);
      m_nSymbol1OrderCount = LoadOrders(m_symbol1, m_orderInfo1, m_nSubDirect, m_comment, m_nMagicNum);
      return MathMax(m_nSymbol1OrderCount, m_nSymbol2OrderCount);
   }
   
   int OpenOrders()
   {
      if(m_nSymbol2OrderCount < m_nMaxOrderCount)
      {
         double dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nSymbol2OrderCount), 2);
         OpenOrder(m_symbol2, m_nMainDirect, dLots, m_comment, m_nMagicNum);
         OpenOrder(m_symbol1, m_nSubDirect, dLots, m_comment, m_nMagicNum);
      }
      return 0;
   }
private:
   int LoadOrders(string symbol, COrderInfo & orderInfo[], int nDirect, string comment, int nMagicNum)
   {
      int nOrdersCnt = 0;
      return nOrdersCnt;
   }
   
   int OpenOrder(string symbol, int orderType, double dLots, string comment, int nMagicNum)
   {
      int ret = 0;
      string logMsg;
      logMsg = StringFormat("%s => Symbol = %s, orderType = %d, comment = %s, Lots = %s ",
                                  __FUNCTION__, symbol, orderType,
                                  comment, DoubleToString(dLots, 2));
      LogInfo(logMsg);
      
      RefreshRates();
      switch(orderType)
      {
      case OP_BUY:
         {
            // Open buy order
            double lots = dLots;
            while(true)
            {
               RefreshRates();
               double fAskPrice = MarketInfo(symbol, MODE_ASK);
               int ticket = OrderSend(symbol, OP_BUY, lots, fAskPrice, 3, 0, 0, comment, nMagicNum, 0, clrRed); 
               if(ticket > 0)
               {
                  logMsg = StringFormat("%s => Open buy order: Symbol = %s, Price = %s, Lots = %s",
                                  __FUNCTION__, symbol, 
                                  DoubleToString(fAskPrice, 4), DoubleToString(lots, 2));
                  LogInfo(logMsg);
                  break;
               }else 
               { 
                  int nErr = GetLastError(); 
                  logMsg = StringFormat("%s => Open buy order Error: %d.", __FUNCTION__, nErr);
                  LogInfo(logMsg);
                  if(IsFatalError(nErr))
                  {  
                     ret = nErr;
                     break;
                  } 
               }
            }
            
         }
         break;
      case OP_SELL:
         {
            // Open sell order
            double lots = dLots;
            while(true)
            {
               RefreshRates();
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               int ticket = OrderSend(symbol, OP_SELL, lots, fBidPrice, 3, 0, 0, comment, nMagicNum, 0, clrGreen); 
               if(ticket > 0) 
               {
                   logMsg = StringFormat("%s => Open sell order: Symbol = %s, Price = %s, Lots = %s",
                                  __FUNCTION__, symbol, 
                                  DoubleToString(fBidPrice, 4), DoubleToString(lots, 2));
                   LogInfo(logMsg);
                   break;
               }else
               { 
                  int nErr = GetLastError(); 
                  logMsg = StringFormat("%s => Open sell order Error: %d.", __FUNCTION__, nErr);
                  LogInfo(logMsg);
                  if(IsFatalError(nErr))
                  {  
                     ret = nErr;
                     break;
                  } 
               } 
            }
            
         }
         break;
      }
      return ret;
   }  
   
};
