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
   int m_nMagicNum;
   
   COrderInfo m_orderInfo;
   bool m_bExistOrder;
   
   double m_dPrePrice;
   double m_dMostProfits;
   double m_dPreProfits;
   double m_dLeastProfits;
   
   int m_nHtoLCount;
   bool m_bAlreaTakeProfits; // 重仓已经获利了结过了
       
private:
   int m_xBasePos;
   int m_yBasePos;
   
public:
   CCarriageOrder(string symbol, int nDirect, int nMagicNum, double dBaseLots, int nH2LMax) 
   {
      m_nDirect = nDirect;
      m_symbol = symbol;
      m_nLotsMode = PM_LIGHT;
      m_dBaseLots = dBaseLots;
      m_dPrePrice = 0;
      m_nHtoLCount = nH2LMax;
      m_bAlreaTakeProfits = false;
                
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
         yPos++;
         if(m_nDirect == OP_BUY)
         {
            strOrderMsg = StringFormat("【多方】手数：%s，价格：%s，获利：%s", 
                        DoubleToString(m_orderInfo.m_Lots, 2), 
                        DoubleToString(m_orderInfo.m_Prices, 2),
                        DoubleToString(m_orderInfo.m_Profits, 2));
            ShowText("BuyOrderStatistics", strOrderMsg, clrYellow, xPos, yPos);
         }else
         {
            strOrderMsg = StringFormat("【空方】手数：%s，价格：%s，获利：%s", 
                        DoubleToString(m_orderInfo.m_Lots, 2), 
                        DoubleToString(m_orderInfo.m_Prices, 2),
                        DoubleToString(m_orderInfo.m_Profits, 2));
            ShowText("SellOrderStatistics", strOrderMsg, clrYellow, xPos, yPos);
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
         
         m_dMostProfits = MathMax(m_dMostProfits, m_orderInfo.m_Profits);
         m_dLeastProfits = MathMin(m_dLeastProfits, m_orderInfo.m_Profits);
         
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
  
   void OpenOrder(bool bLight) {
      double dCurrentPrice = GetCurrentOpenPrice();
      double dLots = m_dBaseLots;
      if(bLight) {
         dLots = LIGHT_LOTS;
         m_nLotsMode = PM_LIGHT;
      }
      string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPrice, 4));
      OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
      m_bExistOrder = true;
      m_dMostProfits = 0;
      m_dPreProfits = 0;
      m_dLeastProfits = 0;
      
   }
   
   // 检查重仓->轻仓的转化条件，以跨越保护仓的价格为标准
   bool CheckForHeavyToLightByCrossOver(double dMinOffset)
   {
      bool bRet = false;
      if(m_bExistOrder)
      {
         // 注：重仓亏损时才转化为轻仓
         int nDirect = m_nDirect;
         double dProtectingPrice = m_orderInfo.m_Prices;
         double dCurrentPrice = Close[0];
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 2;
         string strPriceDiff = StringFormat("价格差：%s - %s = %s, H2L 计数：%d", 
                              DoubleToString(dCurrentPrice, 4),DoubleToString(dProtectingPrice, 4), 
                              DoubleToString(dCurrentPrice - dProtectingPrice, 4), m_nHtoLCount);
         if(nDirect == OP_BUY) {
            ShowText("PriceDiffBuyProtect", strPriceDiff, clrYellow, xPos, yPos);            
            if(dProtectingPrice - dCurrentPrice > dMinOffset) {
               bRet = true;
            }
         }else {
            ShowText("PriceDiffSellProtect", strPriceDiff, clrYellow, xPos, yPos);
             if(dCurrentPrice - dProtectingPrice > dMinOffset) {
                bRet = true;
             }
         }
        
      }
      return bRet;
   }
   
   // 检查重仓->轻仓的转化条件，以价格差为标准
   bool CheckForHeavyToLightByOffset(double dMinOffset)
   {
      bool bRet = false;
      if(m_bExistOrder)
      {
         int nDirect = m_nDirect;
         double dProtectingPrice = m_orderInfo.m_Prices;
         double dCurrentPrice = Close[0];
         string logMsg;
         logMsg = StringFormat("[%s]OrderPrice = %s, CurrentPrice = %d, lots = %s", 
                  __FUNCTION__, DoubleToString(dProtectingPrice, 4), 
                  DoubleToString(dCurrentPrice, 2), 
                  DoubleToString(m_orderInfo.m_Lots, 2));
         //LogInfo(logMsg); 
         
         if(nDirect == OP_BUY)
         {
           if(dProtectingPrice - dCurrentPrice > dMinOffset) {
               bRet = true;
           }
         }else
         {
           if(dCurrentPrice - dProtectingPrice > dMinOffset) {
               bRet = true;
           }
         }         
       }
       return bRet;
   }
   
   // 检查重仓->轻仓的转化条件，以获利金额为标准
   bool CheckForHeavyToLightByProfits(double dTakeProfits, double dBackword)
   {
      bool bRet = false;
      if(m_bExistOrder)
      {
         double dCurrentProfits =  m_orderInfo.m_Profits;
         double dRealStandardProfits = m_dMostProfits * (1 - dBackword);
         string strPriceDiff = StringFormat("当前：%s，最高：%s，移动止盈：%s", 
                              DoubleToString(dCurrentProfits, 2),
                              DoubleToString(m_dMostProfits, 2),
                              DoubleToString(dRealStandardProfits, 2));
                              
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 3;
         int nDirect = m_nDirect;
         if(nDirect == OP_BUY) {
            ShowText("ProfitsForBuyProtect", strPriceDiff, clrYellow, xPos, yPos); 
         }else {
            ShowText("ProfitsForSellrotect", strPriceDiff, clrYellow, xPos, yPos); 
         }  
         if(dCurrentProfits > dTakeProfits) {
            if(m_dPreProfits > dRealStandardProfits && dCurrentProfits <= dRealStandardProfits)
            {
               bRet = true;
            }             
         }         
       }
       m_dPreProfits = m_orderInfo.m_Profits;
       return bRet;
   }
   
  
   
   // 检查轻仓->重仓的转化条件，以价格差为标准
   bool CheckForLightToHeavyByOffset(double dOffset)
   {
      bool bRet = false;
      if(m_bExistOrder)
      {
         // 注：轻仓亏损时才转化为重仓
         int nDirect = m_nDirect;
         double dProtectingPrice = m_orderInfo.m_Prices;
         double dCurrentPrice = Close[0];
         string logMsg;
         logMsg = StringFormat("[%s]OrderPrice = %s, CurrentPrice = %d, lots = %s,  Cnt = %d", 
                  __FUNCTION__, DoubleToString(dProtectingPrice, 4), 
                  DoubleToString(dCurrentPrice, 2), 
                  DoubleToString(m_orderInfo.m_Lots, 2));
         //LogInfo(logMsg);       
         if(nDirect == OP_BUY) {            
            if(dProtectingPrice - dCurrentPrice > dOffset) {
               bRet = true;
            }
         }else {
            if(dCurrentPrice - dProtectingPrice > dOffset) {
                bRet = true;
            }
         }
      }
      return bRet;
   }
   
   // 检查轻仓->的重仓转化条件，以获利金额为标准
   bool CheckForLightToHeavyByProfits(double dBackword)
   {
      bool bRet = false;
      if(m_bExistOrder)
      {
         double dRealStandardProfits = m_dLeastProfits * (1 - dBackword);
         double dCurrentProfits =  m_orderInfo.m_Profits;
         if(dCurrentProfits < 0 && m_dLeastProfits < 0) {
            // 当亏损缩小时，需要转为重仓
            
            string strPriceDiff = StringFormat("当前：%s，最低：%s，移动止损：%s", 
                                 DoubleToString(dCurrentProfits, 2),
                                 DoubleToString(m_dLeastProfits, 2),
                                 DoubleToString(dRealStandardProfits, 2));
                                 
            int xPos = m_xBasePos;
            int yPos = m_yBasePos + 3;
            int nDirect = m_nDirect;
            if(nDirect == OP_BUY) {
               ShowText("ProfitsForBuyProtect", strPriceDiff, clrYellow, xPos, yPos); 
            }else {
               ShowText("ProfitsForSellrotect", strPriceDiff, clrYellow, xPos, yPos); 
            }
            if(m_dPreProfits < dRealStandardProfits && dCurrentProfits >= dRealStandardProfits)
            {
               bRet = true;
            }             
         }         
       }
       m_dPreProfits = m_orderInfo.m_Profits;
       return bRet;
   }
   
   // 检查轻仓->重仓的转化条件，以跨越保护仓的价格为标准
   bool CheckForLightToHeavyByCrossOver(double dMinOffset)
   {
      bool bRet = false;
      if(m_bExistOrder)
      {
         int nDirect = m_nDirect;
         double dProtectingPrice = m_orderInfo.m_Prices;
         double dCurrentPrice = Close[0];  
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 2;
         string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                              DoubleToString(dCurrentPrice, 4),DoubleToString(dProtectingPrice, 4), 
                              DoubleToString(dCurrentPrice - dProtectingPrice, 4));    
         if(nDirect == OP_BUY) { 
            ShowText("PriceDiffBuyProtect", strPriceDiff, clrYellow, xPos, yPos);             
            if(dCurrentPrice - dProtectingPrice > dMinOffset) {
               bRet = true;
            }
         }else {
             ShowText("PriceDiffSellProtect", strPriceDiff, clrYellow, xPos, yPos);
             if(dProtectingPrice - dCurrentPrice > dMinOffset) {
                bRet = true;
             }
         }
      }
      return bRet;
   }
   
// input double OFFSET_HEAVY_TO_LIGHT_PROFITS = 0.004; // 重转轻：盈利条件1：最小价格波动值
// input double OFFSET_HEAVY_TO_LIGHT_PROFITS = 0.001; // 重转轻：盈利条件2：最小价格波动值，再次平仓时使用
// input double OFFSET_HEAVY_TO_LIGHT_ROLLBACK = 0.0005; // 重转轻：价格反转条件：最小价格波动值
// input int HEAVY_TO_LIGHT_MAX = 1; // 重转轻：条件：最大次数限制
// input double BACKWORD_PROFITS = 0.05; //  重转轻：条件：获利回调系数

// input double OFFSET_LIGHT_TO_HEAVY_STOPLOSS = 0.002; //  轻转重：止损条件：最小价格波动值
// input double OFFSET_LIGHT_TO_HEAVY_ROLLBACK = 0.0005; // 轻转重：价格反转条件：最小价格波动值

// input double BACKWORD_STOPLOSS = 0.05; //  重转轻：条件：止损回调系数

   void ProcessOrder(double dH2LProfits,  // 重转轻：盈利条件1：最小价格波动值
                     double dH2LProfits2, // 重转轻：盈利条件2：最小价格波动值，再次平仓时使用 
                     double dH2LRollback, // 重转轻：价格反转条件：最小价格波动值
                     int nH2LMax,         // 重转轻：条件：最大次数限制
                     double dH2LBackword, // 重转轻：条件：获利回调系数
                     double dTakeProfits, // 重转轻：条件：最少获利金额
                     double dL2HStoploss, // 轻转重：止损条件：最小价格波动值
                     double dL2HRollback, // 轻转重：价格反转条件：最小价格波动值
                     double dL2HBackword //  重转轻：条件：止损回调系数
                     ) {
       if(m_nLotsMode == PM_HEAVY) {
         if(CheckForHeavyToLightByCrossOver(dH2LRollback))  {
            // 当前价格反转造成的重变轻
            string logMsg;
            logMsg = StringFormat("[TTTT]Dir = %d, Heavy -> Light, Cross over.", m_nDirect);
            //LogInfo(logMsg);
            
            if(m_nHtoLCount < nH2LMax) {
               CloseOrder(m_orderInfo);
               OpenOrder(true);
               m_nHtoLCount++;
               LogInfo(logMsg);
            }
           
         }else {    
            double dOffsetToCheck = dH2LProfits;
            if(m_bAlreaTakeProfits) {
               dOffsetToCheck = dH2LProfits2;
            }    
            bool bOffset = CheckForHeavyToLightByOffset(dOffsetToCheck);
            bool bProfits = CheckForHeavyToLightByProfits(dTakeProfits, dH2LBackword);
            if(bOffset && bProfits) {
               string logMsg;
               logMsg = StringFormat("[TTTTT]Dir = %d, Heavy -> Light, Take profits.", m_nDirect);
               LogInfo(logMsg);
                // 满足重仓转轻仓的条件，平掉重仓，开轻仓
                // 重仓获利后，转为轻仓
               CloseOrder(m_orderInfo);
               OpenOrder(true);
               m_bAlreaTakeProfits = true; // 重仓获利了结，转轻仓
               m_nHtoLCount = 0;               
            }
           
         }
      }else if(m_nLotsMode == PM_LIGHT) {
        
         if(CheckForLightToHeavyByCrossOver(dL2HRollback)) {
            string logMsg;
            logMsg = StringFormat("[TTTT]Dir = %d, Light -> Heavy , Cross over.", m_nDirect);
            LogInfo(logMsg);
             // 当前价格跨过了轻仓的价格，需要转为重仓
            CloseOrder(m_orderInfo);
            OpenOrder(false);
         }else {
            bool bOffset = CheckForLightToHeavyByOffset(dL2HStoploss);
            bool bProfits = CheckForLightToHeavyByProfits(dL2HBackword);
            if(bOffset && bProfits) {
               string logMsg;
               logMsg = StringFormat("[TTTT]Dir = %d, Light -> Heavy , Stop loss.", m_nDirect);
               LogInfo(logMsg);
               // 满足重仓转轻仓的条件，平掉重仓，开轻仓
               // 持有轻仓时，持续亏损，当亏损从最大有所缩小时，转为重
               CloseOrder(m_orderInfo);
               OpenOrder(false);
               m_bAlreaTakeProfits = false;
               m_nHtoLCount = 0;
            }
         }
        
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
