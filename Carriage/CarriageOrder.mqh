//+------------------------------------------------------------------+
//|                                                  MartinOrder.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "ClUtil.mqh"
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

string OpName [] = 
{
   "买单",
   "卖单"
};

enum { PM_HEAVY = 0, PM_LIGHT = 1};

#define LIGHT_LOTS 0.01

class CCarriageOrder
{
public:
   int m_nDirect;
   string m_symbol; 
   string m_comment;
   double m_dBaseLots;
   int m_nLotsMode;
   double m_dPriceCheckPoint;
   
   int m_nMagicNum;
   
   COrderInfo m_orderInfo;
   bool m_bExistOrder;
   
   double m_dHighestPrice;
   double m_dLowestPrice;
   double m_dPrePrice;
   bool m_bUpdatedCache;
       
private:
   int m_xBasePos;
   int m_yBasePos;
   
public:
   CCarriageOrder(string symbol, int nDirect, int nMagicNum, double dBaseLots) 
   {
      m_nDirect = nDirect;
      m_symbol = symbol;
      m_bUpdatedCache = false;
      m_dHighestPrice = 0;
      m_dLowestPrice = 0;
      m_dPrePrice = 0;
      m_nLotsMode = PM_HEAVY;
      m_dBaseLots = dBaseLots;
      m_dPriceCheckPoint = 0;
                
      if(nDirect == OP_BUY)
      {
         m_comment = "CBuy";
         m_xBasePos = 0;
         m_yBasePos = 0;
      }else
      {
         m_comment = "CSell";
         m_xBasePos = 0;
         m_yBasePos = 4;
      }
   }
   
   void UpdateCache() {
      m_dPrePrice = Close[0];
      m_dHighestPrice = MathMax(m_dHighestPrice, Close[0]);
      m_dLowestPrice = MathMin(m_dLowestPrice, Close[0]);
      m_bUpdatedCache = true;
   }
   
   void ResetCache() {
      m_dPrePrice = 0;
      m_dHighestPrice = 0;
      m_dLowestPrice = 0;
      m_bUpdatedCache = false;
   }
   
   void CleanOrders() 
   {
      m_orderInfo.clear();  
   }
   
   void LoadAllOrders()
   {
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos;
      if(m_nDirect == OP_BUY) {
         string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
         ShowText("Version", strVersion, clrYellow, xPos, yPos);
      }
          
      CleanOrders();
      
      string strOrderMsg = "";
      LoadOrderInfo();
      if(m_bExistOrder) {
         string strOrderMsg;
         if(m_nDirect == OP_BUY)
         {
            strOrderMsg = StringFormat("【多方】手数：%s，价格：%s，获利：%s", 
                        DoubleToString(m_orderInfo.m_Lots, 2), 
                        DoubleToString(m_orderInfo.m_Prices, 2),
                        DoubleToString(m_orderInfo.m_Profits));
            ShowText("BaseOrderStatistics", strOrderMsg, clrYellow, xPos, yPos);
         }else
         {
            strOrderMsg = StringFormat("【空方】手数：%s，价格：%s，获利：%s", 
                        DoubleToString(m_orderInfo.m_Lots, 2), 
                        DoubleToString(m_orderInfo.m_Prices, 2),
                        DoubleToString(m_orderInfo.m_Profits));
            ShowText("BaseOrderStatistics", strOrderMsg, clrYellow, xPos, yPos);
          }
       }
      
   }
   
   void LoadOrder(string symbol, int nDirect, int nMagicNum, COrderInfo & orderInfo) {
         double lots = 0;
         int nProtectingOrderCount = 0;
         COrderInfo orderInfoOut[MAX_ORDER_COUNT];
         LoadOrders(symbol, nDirect, nMagicNum, orderInfoOut, nProtectingOrderCount, lots);
         if(nProtectingOrderCount > 0) {
             orderInfo.m_Symbol = orderInfoOut[0].m_Symbol;
             orderInfo.m_Ticket =orderInfoOut[0].m_Ticket;
             orderInfo.m_OrderType = orderInfoOut[0].m_OrderType;
             orderInfo.m_Lots = orderInfoOut[0].m_Lots;
             orderInfo.m_Prices = orderInfoOut[0].m_Prices;
             orderInfo.m_StopLoss = orderInfoOut[0].m_StopLoss;
             orderInfo.m_TakeProfit = orderInfoOut[0].m_TakeProfit;
             orderInfo.m_Comment = orderInfoOut[0].m_Comment;
             orderInfo.m_Magic = orderInfoOut[0].m_Magic;
             orderInfo.m_TradeTime = orderInfoOut[0].m_Magic;
             orderInfo.m_Profits = orderInfoOut[0].m_Profits;
         }
   }
   
   void LoadOrderInfo() {
      LoadOrder(m_symbol, m_nDirect, m_nMagicNum, m_orderInfo);
      if(m_orderInfo.m_Lots > 0) {
         m_bExistOrder = true;
         
         if(m_orderInfo.m_Lots > LIGHT_LOTS) {
            m_nLotsMode = PM_HEAVY;
         }else {
            m_nLotsMode = PM_LIGHT;
         }
         
      }else {
         m_bExistOrder = false;
      }
   }
   
   bool hasOrder() {return m_bExistOrder;}
   
   double GetCurrentOpenPrice() {
      double dCurrentPrice = 0;
      RefreshRates();
      if(m_nDirect == OP_BUY)
      {
         dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
      } else {
         dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
      }
      return dCurrentPrice;
   }
   
   double GetCurrentClosePrice() {
      double dCurrentPrice = 0;
      RefreshRates();
      if(m_nDirect == OP_BUY)
      {
         dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
      } else {
         dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
      }
      return dCurrentPrice;
   }
  
   void OpenOrder(bool bResetCheckPoint, double dLots) {
      double dCurrentPrice = GetCurrentOpenPrice();
      string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPrice, 4));
      OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
      if(bResetCheckPoint) {
         m_dPriceCheckPoint = dCurrentPrice;
      }
   }
   
   void ProcessOrder(double dMinOffset, double dBackwordOffset){
      if(!m_bUpdatedCache) {
         return;
      }
      
      if(m_nLotsMode == PM_HEAVY) {
         ProcessHeavyToLight(dMinOffset, dBackwordOffset);
      }else if(m_nLotsMode == PM_LIGHT) {
        ProcessLightToHeavy(dMinOffset, dBackwordOffset);
      }
      
   }
   
   void ProcessHeavyToLight(double dMinOffset, double dBackwordOffset) {
      bool bClose = false;
      bool bResetPriceCheckPoint = false;
      string logMsg;
      logMsg = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Heavy --> Light >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
      LogInfo(logMsg); 
      if(m_nDirect == OP_BUY) {        
         double dCurrentPrice = GetCurrentClosePrice();
         if(m_dPriceCheckPoint - dCurrentPrice > dMinOffset) {
            // 当前价格低于检查点的价格，说明行情在下行，需要转换成轻仓
            bClose = true;
            logMsg = StringFormat("[%s] Flag3: 当前价格 = %s, 检查点价格 = %d, 价差 = %s,  ",
                                  __FUNCTION__, DoubleToString(dCurrentPrice, 4), 
                                  DoubleToString(m_dPriceCheckPoint, 4), DoubleToString(dMinOffset, 4));
            LogInfo(logMsg);
         }else {
            // 检查点的价格设置为最高价格回撤一定的点数
            double checkPoint = m_dHighestPrice - dBackwordOffset;
            if(m_dPrePrice > checkPoint 
               && dCurrentPrice <= checkPoint) {
            
               // 当前的价格行情，由上往下穿过检查的价格值
               bClose = true;
               
               // 需要重新设置检查点价格
               bResetPriceCheckPoint =  true;
               
               logMsg = StringFormat("[%s] Flag4: 当前价格 = %s, 检查点价格 = %d, 价差 = %s,  ",
                                  __FUNCTION__, DoubleToString(dCurrentPrice, 4), 
                                  DoubleToString(m_dPriceCheckPoint, 4), DoubleToString(dMinOffset, 4));
               LogInfo(logMsg);
            }
         }       
      }
      
      if(m_nDirect == OP_SELL) {
         bool bResetPriceCheckPoint = false;
         double dCurrentPrice = GetCurrentClosePrice();
         if(dCurrentPrice - m_dPriceCheckPoint > dMinOffset) {
            // 当前价格高于检查点的价格，说明行情在上行，需要转换成轻仓
            bClose = true;
         }else {
            // 检查点的价格设置为最低价格回撤一定的点数
            double checkPoint = m_dLowestPrice + dBackwordOffset;
            if(m_dPrePrice < checkPoint 
               && dCurrentPrice >= checkPoint) {
            
               // 当前的价格行情，由下往上穿过检查点价格值
               bClose = true;
               
               // 需要重新设置检查点价格
               bResetPriceCheckPoint =  true;
            }
         }                 
      }
      
      if(bClose) {
         CloseOrder(m_orderInfo);
         OpenOrder(bResetPriceCheckPoint, LIGHT_LOTS);
      }
   }
   
   void ProcessLightToHeavy(double dMinOffset, double dBackwordOffset) {
      bool bClose = false;
      bool bResetPriceCheckPoint = false;
      string logMsg;
      logMsg = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Light --> Heavy >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
      LogInfo(logMsg); 
      if(m_nDirect == OP_BUY) {        
         double dCurrentPrice = GetCurrentClosePrice();
         if(dCurrentPrice - m_dPriceCheckPoint > dMinOffset) {
            // 当前价格高于检查点的价格，说明行情在上行，需要转换成重仓
            bClose = true;
         }else {
            // 检查点的价格设置为最高价格回撤一定的点数
            double checkPoint = m_dLowestPrice + dBackwordOffset;
            if(m_dPrePrice < checkPoint 
               && dCurrentPrice >= checkPoint) {
            
               // 当前的价格行情，由上往下穿过检查的价格值
               bClose = true;
               
               // 需要重新设置检查点价格
               bResetPriceCheckPoint =  true;
            }
         }       
      }
      
      if(m_nDirect == OP_SELL) { 
         double dCurrentPrice = GetCurrentClosePrice();
         if(m_dPriceCheckPoint - dCurrentPrice > dMinOffset) {
            // 当前价格低于检查点的价格，说明行情在下行，需要转换成轻仓
            logMsg = StringFormat("[%s] Flag1: 当前价格 = %s, 检查点价格 = %d, 价差 = %s,  ",
                                  __FUNCTION__, DoubleToString(dCurrentPrice, 4), 
                                  DoubleToString(m_dPriceCheckPoint, 4), DoubleToString(dMinOffset, 4));
            LogInfo(logMsg);
            bClose = true;
         }else {
            // 检查点的价格设置为最高价格回撤一定的点数
            double checkPoint = m_dHighestPrice - dBackwordOffset;
            if(m_dPrePrice > checkPoint 
               && dCurrentPrice <= checkPoint) {
               logMsg = StringFormat("[%s] Flag2: 当前价格 = %s, 检查点价格 = %d, 价差 = %s,  ",
                                  __FUNCTION__, DoubleToString(dCurrentPrice, 4), 
                                  DoubleToString(m_dPriceCheckPoint, 4), DoubleToString(dMinOffset, 4));
               LogInfo(logMsg);
            
               // 当前的价格行情，由上往下穿过检查的价格值
               bClose = true;
               
               // 需要重新设置检查点价格
               bResetPriceCheckPoint =  true;
            }
         }   
      }
      
      if(bClose) {
         CloseOrder(m_orderInfo);
         OpenOrder(bResetPriceCheckPoint, m_dBaseLots);
      }

   }
   
private:
   void OutputLog(string msg)
   {
      //if(gTickCount % 20 == 0)
      if(gIsNewBar)
      {
            LogInfo(msg);
      }
   }
   
   int LoadOrders(string symbol, int nDirect, int nMagicNum, 
                  COrderInfo & orderInfo[], int & count, double & lots)
   {
      int nOrdersCnt = 0;
      int nOrdersTotalCnt = OrdersTotal();
      double dLots = 0;
      for(int i = 0; i < nOrdersTotalCnt; i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderSymbol() == symbol 
               && OrderMagicNumber() == nMagicNum
               && OrderType() == nDirect)
            {
                  orderInfo[nOrdersCnt].m_Symbol = symbol;
                  orderInfo[nOrdersCnt].m_Ticket = OrderTicket(); 
                  orderInfo[nOrdersCnt].m_Prices = OrderOpenPrice();
                  orderInfo[nOrdersCnt].m_Lots = OrderLots();
                  orderInfo[nOrdersCnt].m_Comment = OrderComment();
                  orderInfo[nOrdersCnt].m_OrderType = nDirect;
                  orderInfo[nOrdersCnt].m_TradeTime = OrderOpenTime();
                  double commission = OrderCommission();
                  double swap = OrderSwap();
                  
                  string logMsg;
                  logMsg = StringFormat("commission = %s, swap = %d", 
                           DoubleToString(commission, 2), DoubleToString(swap, 2));    
                  // LogInfo(logMsg);             
                  orderInfo[nOrdersCnt].m_Profits = OrderProfit() + commission + swap;
                  nOrdersCnt++; 
                  dLots +=  OrderLots();
            }
         }
      }
      
      count = nOrdersCnt;
      lots = dLots;
      return nOrdersCnt;
   }
   
   int OpenOrder(string symbol, int orderType, double dLots, string comment, int nMagicNum)
   {
      int ret = 0;
      string logMsg;
      logMsg = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OPEN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
      LogInfo(logMsg); 
      logMsg = StringFormat("%s => Symbol = %s, orderType = %d, Lots = %s, magic = %d, comment = %s,  ",
                                  __FUNCTION__, symbol, orderType,
                                  DoubleToString(dLots, 2), nMagicNum, comment);
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
                                  DoubleToString(fAskPrice, 5), DoubleToString(lots, 2));
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
                                  DoubleToString(fBidPrice, 5), DoubleToString(lots, 2));
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
   
   int CloseOrder(COrderInfo & orderInfo)
   {
      int ret = 0;
      double lots = orderInfo.m_Lots;
      int ticket = orderInfo.m_Ticket;
      string symbol = orderInfo.m_Symbol;
      int orderType = orderInfo.m_OrderType;
      
      string logMsg;  
      
      logMsg = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  CLOSE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<";
      LogInfo(logMsg); 
      logMsg = StringFormat("%s => Symbol = %s, orderType = %d, Lots = %s, ticket = %d",
                                  __FUNCTION__, symbol, orderType,
                                  DoubleToString(lots, 2), ticket);
      LogInfo(logMsg);   
         
     
      if(ticket > 0)
      {
         while(true)
         {
            RefreshRates();
            double fPrice = 0;
            color clr = clrRed;
            if(orderType == OP_BUY)
            {
               clr = clrRed;
               fPrice = MarketInfo(symbol, MODE_BID);
            }else
            {
               clr = clrGreen;
               fPrice = MarketInfo(symbol, MODE_ASK);
            }
            logMsg = StringFormat("%s: ticket = %d, type = %d, price = %s, lots = %s",
                         __FUNCTION__, ticket, orderType, DoubleToString(fPrice, 5),DoubleToString(lots, 2));
            LogInfo(logMsg);
            if(OrderClose(ticket, lots, fPrice, 3, clr))
            {                 
               break;
         
            } else
            {
               int nErr = GetLastError(); // 平仓失败 :( 
               logMsg = StringFormat("%s => Close buy order Error: %d, ticket = %d.",
                         __FUNCTION__, nErr, ticket);
               LogInfo(logMsg);
               if(IsFatalError(nErr))
               {  
                  ret = nErr;
                  break;
               }                   
           }
         }  
      }
          
      return ret;
   }
   
   double CalcTotalProfits(const COrderInfo & orderInfo [], int orderCnt)
   {
      double fProfits = 0;
      for(int i = 0; i < orderCnt; i++)
      {
         fProfits += orderInfo[i].m_Profits;
      }         
         
      return fProfits;
   }
   
   void ShowText(string label, string text, color clr, int x, int y)
   {
      if(gTickCount % 4 == 0) {
            DisplayText(label, text, clr, x, y);
      }
   }
   
};
