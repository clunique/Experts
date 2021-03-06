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

class CTridentOrder
{
public:
   int m_nDirect;
   string m_symbol; 
   string m_commentBase;
   string m_commentAppending;
   string m_commentProtecting;
   
   int m_nMagicNumBase;
   int m_nMagicNumAppending;
   int m_nMagicNumProtecting;
   
   COrderInfo m_baseOrder;
   bool m_bExistBaseOrder;
   
   COrderInfo m_appdendingOrder;
   bool m_bExistAppendingOrder;
   
   COrderInfo m_protectingOrder;
   bool m_bExistProtectingOrder;
   int m_nProtectingMode;
   double m_dProtectingLinePrice;
   int m_nProtectingDirect;
   double m_dProtectingHighestPrice;
   double m_dProtectingLowestPrice;
   
   double m_dHighestPrice;
   double m_dLowestPrice;
   double m_dPrePrice;
   bool bUpdatedCache;
     
private:
   int m_xBasePos;
   int m_yBasePos;
   
public:
   CTridentOrder(string symbol, int nDirect, int nMagicNum) 
   {
      m_nDirect = nDirect;
      m_symbol = symbol;
      m_nMagicNumBase = nMagicNum + 1;
      m_nMagicNumAppending = nMagicNum + 2;
      m_nMagicNumProtecting = nMagicNum + 3;
      m_xBasePos = 0;
      m_yBasePos = 0;
      bUpdatedCache = false;
      m_dHighestPrice = 0;
      m_dLowestPrice = 0;
      m_dPrePrice = 0;
      m_dProtectingLinePrice = 0;
      m_dProtectingHighestPrice = 0;
      m_dProtectingLowestPrice = 0;
           
      if(nDirect == OP_BUY)
      {
         m_commentBase = "TBuyB";
         m_commentAppending = "TBuyA";
         m_commentProtecting = "TBuyP";
         m_nProtectingDirect = OP_SELL;
      }else
      {
         m_commentBase = "TSellB";
         m_commentAppending = "TSellA";
         m_commentProtecting = "TSellP";
         m_nProtectingDirect = OP_BUY;
      }
   }
   
   void UpdateCache() {
      m_dPrePrice = Close[0];
      m_dHighestPrice = MathMax(m_dHighestPrice, Close[0]);
      m_dLowestPrice = MathMin(m_dLowestPrice, Close[0]);
      bUpdatedCache = true;
   }
   
   void ResetCache() {
      m_dPrePrice = 0;
      m_dHighestPrice = 0;
      m_dLowestPrice = 0;
      bUpdatedCache = false;
   }
   
   void CleanOrders() 
   {
      m_baseOrder.clear();
      m_appdendingOrder.clear();
      m_protectingOrder.clear();      
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
      LoadBaseOrder();
      strOrderMsg = StringFormat("【基础】手数：%s，价格：%s，获利：%s", 
                     DoubleToString(m_baseOrder.m_Lots, 2), 
                     DoubleToString(m_baseOrder.m_Prices, 2),
                     DoubleToString(m_baseOrder.m_Profits));
      ShowText("BaseOrderStatistics", strOrderMsg, clrYellow, xPos, yPos);
         
               
      LoadAppendingOrder(); 
      yPos++;
      strOrderMsg = StringFormat("【追加】手数：%s，价格：%s，获利：%s", 
                     DoubleToString(m_baseOrder.m_Lots, 2), 
                     DoubleToString(m_baseOrder.m_Prices, 2),
                     DoubleToString(m_baseOrder.m_Profits));
      ShowText("AppendingOrderStatistics", strOrderMsg, clrYellow, xPos, yPos);
              
      LoadProtectingOrder();
      yPos++;
      strOrderMsg = StringFormat("【保护】手数：%s，价格：%s，获利：%s", 
                     DoubleToString(m_baseOrder.m_Lots, 2), 
                     DoubleToString(m_baseOrder.m_Prices, 2),
                     DoubleToString(m_baseOrder.m_Profits));
      ShowText("ProtectingOrderStatistics", strOrderMsg, clrYellow, xPos, yPos);
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
   
   void LoadBaseOrder() {
      LoadOrder(m_symbol, m_nDirect, m_nMagicNumBase, m_baseOrder);
      if(m_baseOrder.m_Lots > 0) {
         m_bExistBaseOrder = true;
      }else {
         m_bExistBaseOrder = false;
      }
   }
   
   void LoadAppendingOrder() {
      LoadOrder(m_symbol, m_nDirect, m_nMagicNumAppending, m_appdendingOrder);
      if(m_appdendingOrder.m_Lots > 0) {
         m_bExistAppendingOrder = true;
      }else {
         m_bExistAppendingOrder = false;
      }
   
   }
   
   void LoadProtectingOrder() {
      LoadOrder(m_symbol, m_nProtectingDirect, m_nMagicNumProtecting, m_protectingOrder);
      if(m_protectingOrder.m_Lots > 0) {
         m_bExistProtectingOrder = true;
         if(m_protectingOrder.m_Lots > 0.01) {
            m_nProtectingMode = PM_HEAVY;
         }else {
            m_nProtectingMode = PM_LIGHT;
         }
      }else {
         m_bExistProtectingOrder = false;
      }
      
   }
   
   bool IsBaseOrderExist() {return m_bExistBaseOrder;}
   bool IsAppendingOrderExist() {return m_bExistAppendingOrder;}
   bool IsProtectingOrderExist() {return m_bExistProtectingOrder;}
 
   void OpenBaseOrder(double dLots) {
      double dCurrentPrice = 0;
      RefreshRates();
      if(m_nDirect == OP_BUY)
      {
         dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
      } else {
         dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
      }
      string comment = StringFormat("%s(%s)", m_commentBase, DoubleToString(dCurrentPrice, 4));
      OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNumBase);
   }
   
   // 检查基础仓的平仓条件，适用于只有基础仓的情况
   bool CheckForCloseBaseOrder(double dMinOffset, double dBackwordOffset) {
      bool bRet = false;
      if(!bUpdatedCache) {
         // 尚未更新缓存，直接返回
         return bRet;
      }   
         
      double dBaseOrderPrice = m_baseOrder.m_Prices;
      double dCurrentPrice = Close[0];
      if(m_nDirect == OP_BUY){
         if(dCurrentPrice - dBaseOrderPrice > dMinOffset) {
            double checkPoint = m_dHighestPrice - dBackwordOffset;
            if(m_dPrePrice >= checkPoint && dCurrentPrice < checkPoint){
               bRet = true;
            }
            
         }
      } else {
          if(dBaseOrderPrice - dCurrentPrice > dMinOffset) {
            double checkPoint = m_dLowestPrice + dBackwordOffset;
            if(m_dPrePrice <= checkPoint && dCurrentPrice > checkPoint){
               bRet = true;
            }
            
         }
      }
      return bRet;
   }
   
   void CloseBaseOrder() {
      CloseOrder(m_baseOrder);
   }
   
   // 检查基于基础仓的加仓条件，适用于只有基础仓的时候
   bool CheckForOpenAppendingOrder(double dMinOffset, double dBackwordOffset) {
      bool bRet = false;
      if(!bUpdatedCache) {
         // 尚未更新缓存，直接返回
         return bRet;
      }  
      
      double dBaseOrderPrice = m_baseOrder.m_Prices;
      double dCurrentPrice = Close[0];
      if(m_nDirect == OP_BUY){
         if(dBaseOrderPrice - dCurrentPrice > dMinOffset) {
            double checkPoint = m_dLowestPrice + dBackwordOffset;
            if(m_dPrePrice <= checkPoint && dCurrentPrice > checkPoint){
               bRet = true;
            }
            
         }
      } else {
          if(dCurrentPrice - dBaseOrderPrice > dMinOffset) {
            double checkPoint = m_dHighestPrice - dBackwordOffset;
            if(m_dPrePrice >= checkPoint && dCurrentPrice < checkPoint){
               bRet = true;
            }            
         }
      }     
      
      return bRet;
   }
   
   void OpenAppendingOrder(double dLots) {
      double dCurrentPrice = 0;
      RefreshRates();
      if(m_nDirect == OP_BUY)
      {
         dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
      } else {
         dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
      }
    
      string comment = StringFormat("%s(%s)", m_commentAppending, DoubleToString(dCurrentPrice, 4));
      OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNumAppending);
   }
   
   // 检查有加仓时的平仓条件，适用于既有基础仓，又有加仓的情况
   bool CheckForCloseAppendingOrder(double dMinOffset, double dBackwordOffset) {
      bool bRet = false;
      if(!bUpdatedCache) {
         // 尚未更新缓存，直接返回
         return bRet;
      } 
      double dBaseLos = m_baseOrder.m_Lots;
      double dBasePrice = m_baseOrder.m_Prices;
      double dAppendLots = m_appdendingOrder.m_Lots;
      double dAppendPrice = m_appdendingOrder.m_Prices;
      
      double dPriceStopLoss = (dBasePrice * dBaseLos + dAppendPrice * dAppendLots) / (dBaseLos + dAppendLots);
      double dCurrentPrice = Close[0];
      if(m_nDirect == OP_BUY){
         if(dCurrentPrice - dPriceStopLoss > dMinOffset) {
            double checkPoint = m_dHighestPrice - dBackwordOffset;
            if(m_dPrePrice >= checkPoint && dCurrentPrice < checkPoint){
               bRet = true;
            }           
         }
      } else {
          if(dPriceStopLoss - dCurrentPrice > dMinOffset) {
            double checkPoint = m_dLowestPrice + dBackwordOffset;
            if(m_dPrePrice <= checkPoint && dCurrentPrice > checkPoint){
               bRet = true;
            }            
         }
      }
      
      return bRet;
   }
   
   void CloseAppendingOrder() {
       CloseOrder(m_baseOrder);
       CloseOrder(m_appdendingOrder);
   }
   
   
   
   // 检查保护仓的加仓条件，适用于既有基础仓，又有加仓的情况
   bool CheckForOpenProtectingOrder() {
      bool bRet = false;
      if(!bUpdatedCache) {
         // 尚未更新缓存，直接返回
         return bRet;
      } 
      
      if(m_bExistAppendingOrder && !m_bExistProtectingOrder) {
         double dAppendingOrderPrice = m_appdendingOrder.m_Prices;
         double dCurrentPrice = Close[0];
         if(m_nDirect == OP_BUY){
            //if(m_dPrePrice >= dAppendingOrderPrice && dCurrentPrice < dAppendingOrderPrice){
            if(dCurrentPrice < dAppendingOrderPrice){
               bRet = true;
            }               
            
         } else {
            //if(m_dPrePrice <= dAppendingOrderPrice && dCurrentPrice > dAppendingOrderPrice){
            if(dCurrentPrice > dAppendingOrderPrice){
               bRet = true;
            }            
         }           
      }      
      return bRet;
   }
   
    void OpenProtectingOrder() {
      if(m_bExistBaseOrder && m_bExistAppendingOrder) {
         double dLots = m_baseOrder.m_Lots + m_appdendingOrder.m_Lots;
         double dCurrentPrice = 0;
         RefreshRates();
         if(m_nProtectingDirect == OP_BUY)
         { 
            dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
         } else {
            dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
         }
         
         string comment = StringFormat("%s(%s)", m_commentProtecting, DoubleToString(dCurrentPrice, 4));
         OpenOrder(m_symbol, m_nProtectingDirect, dLots, comment, m_nMagicNumProtecting);
         m_dProtectingHighestPrice = MathMax(m_dProtectingHighestPrice, dCurrentPrice);
         m_dProtectingLowestPrice =  MathMin(m_dProtectingLowestPrice, dCurrentPrice);
      }
   }
   
   // 检查是否需要平掉保护仓的条件，适用于已经开了保护仓的情况
   bool CheckForCloseProtectingOrder() {
      bool bRet = false;
      if(m_bExistProtectingOrder) {
         double dAppendingOrderPrice = m_appdendingOrder.m_Prices;
         double dCurrentPrice = Close[0];
         if(m_nDirect == OP_BUY){
            if(m_dPrePrice <= dAppendingOrderPrice && dCurrentPrice > dAppendingOrderPrice){
               // 拿前一次Ticke的价格和当前价格分别与加仓单的价格比较，
               // 如果价格从下往上穿过加仓单的价格，说明行情在向上行发展，可以去掉保护仓了
               bRet = true;
            }               
            
         } else {
            if(m_dPrePrice >= dAppendingOrderPrice && dCurrentPrice < dAppendingOrderPrice){
               // 拿前一次Ticke的价格和当前价格分别与加仓单的价格比较，
               // 如果价格从上往下穿过加仓单的价格，说明行情在向下行发展，可以去掉保护仓了
               bRet = true;
            }            
         }
      }
      return bRet;
   }
   
   void CloseProtectingOrder() {
      CloseOrder(m_protectingOrder);
      m_dProtectingHighestPrice = 0;
      m_dProtectingLowestPrice = 0;
   }
   
   void ProcessProtectingOrder() {
      if(m_bExistProtectingOrder) {
         if(m_dProtectingLinePrice == 0) {
            // 保护线为0，说明还没有平过保护仓
            double dAppendPrice = m_appdendingOrder.m_Prices;
            if(m_nProtectingDirect == OP_SELL) {
               
            }            
         }else {
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
