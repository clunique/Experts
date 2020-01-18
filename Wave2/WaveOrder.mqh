//+------------------------------------------------------------------+
//|                                                      ODOrder.mqh |
//|                                                          Cuilong |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "http://www.mql4.com"
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
#include "../Pub/OrderInfo.mqh"

#define MAX_ORDER_COUNT 200

struct OptParam
{
   double m_BaseOpenLots;  //基础开仓手数
   double m_StopLossPoint; //止损点数
   double m_TakeProfitPoint; //止盈点数
   double m_OffsetForBuySellStop; // 开挂单价格差
};

class CWaveOrder
{
private:
   string m_symbol;
   int m_nMagicNum;
   int m_nMagicNumMartin;
   
   COrderInfo m_buyOrder[MAX_ORDER_COUNT];
   COrderInfo m_sellOrder[MAX_ORDER_COUNT];
   int m_nBuyOrderCount;
   int m_nSellOrderCount;
   double m_dBuyLots;
   double m_dSellLots;
   string m_buyComment;
   string m_sellComment;
   double m_dBuyMostProfits;
   double m_dBuyLeastProfits;
   double m_dBuyPreProfits;
   double m_dBuyCurrentProfits;
   double m_dSellMostProfits;
   double m_dSellLeastProfits;
   double m_dSellPreProfits;
   double m_dSellCurrentProfits;    
      
   
   COrderInfo m_buyStopOrder[MAX_ORDER_COUNT];
   COrderInfo m_sellStopOrder[MAX_ORDER_COUNT];
   int m_nBuyStopOrderCount;
   int m_nSellStopOrderCount;
   double m_dBuyStopLots;
   double m_dSellStopLots;
   string m_buyStopComment;
   string m_sellStopComment;

   COrderInfo m_buyMartinOrder[MAX_ORDER_COUNT];
   COrderInfo m_sellMartinOrder[MAX_ORDER_COUNT];
   int m_nBuyMartinOrderCount;
   int m_nSellMartinOrderCount;
   double m_dBuyMartinLots;
   double m_dSellMartinLots;
   string m_buyMartinComment;
   string m_sellMartinComment;
   double m_dBuyMartinMostProfits;
   double m_dBuyMartinLeastProfits;
   double m_dBuyMartinPreProfits;
   double m_dBuyMartinCurrentProfits;
   
   double m_dSellMartinMostProfits;
   double m_dSellMartinLeastProfits;
   double m_dSellMartinPreProfits;
   double m_dSellMartinCurrentProfits;
   
   int m_xBuyBasePos;
   int m_yBuyBasePos;
   int m_xSellBasePos;
   int m_ySellBasePos;
 
   bool m_bShowText;
   bool m_bShowComment;
   
   long m_nTick;
   
private:
   void CleanOrders(COrderInfo & orders [] , int cnt) 
   {
      int i = 0;
      for(i = 0; i < cnt; i++)
      {
         orders[i].clear();
      }
   }
   
   int LoadOrders(string symbol, int orderType, string comment, int nMagicNum, 
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
               && OrderType() == orderType)
            {
                  orderInfo[nOrdersCnt].m_Symbol = symbol;
                  orderInfo[nOrdersCnt].m_Ticket = OrderTicket(); 
                  orderInfo[nOrdersCnt].m_Prices = OrderOpenPrice();
                  orderInfo[nOrdersCnt].m_Lots = OrderLots();
                  orderInfo[nOrdersCnt].m_Comment = OrderComment();
                  orderInfo[nOrdersCnt].m_OrderType = orderType;
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
   
   int OpenOrder(string symbol, int orderType, double dLots, string comment, int nMagicNum,
                  double pointForStoploss, double pointForTakeprofit, double offsetForBuySellStop)
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
      case OP_BUYSTOP:
         {
            // Open buy order
            double lots = dLots;
            while(true)
            {
               RefreshRates();
               double fAskPrice = MarketInfo(symbol, MODE_ASK);
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               double minstoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL);
               
               if(orderType == OP_BUYSTOP) {
                  fAskPrice += offsetForBuySellStop;
               } 
               
               int ticket = OrderSend(symbol, orderType, lots, fAskPrice, 3, 0, 0, comment, nMagicNum, 0, clrRed);                
               if(ticket > 0 && (pointForStoploss > 0 || pointForTakeprofit > 0)) { 
                  int nAddStops = AddLiteralStopsByPips(ticket, orderType, pointForStoploss, pointForTakeprofit); 
                  logMsg = StringFormat("Symbol: %s,  ticket: %d, AddStops result: %d",
                                  symbol, ticket, nAddStops);
                  LogInfo(logMsg);   
               }
               
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
                  LogError(logMsg);
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
      case OP_SELLSTOP:
         {
            // Open sell order
            double lots = dLots;
            while(true)
            {
               RefreshRates();
               double fAskPrice = MarketInfo(symbol, MODE_ASK);
               double fBidPrice = MarketInfo(symbol, MODE_BID);
               double minstoplevel = MarketInfo(Symbol(),MODE_STOPLEVEL); 
               
               if(orderType == OP_SELLSTOP) {
                  fBidPrice -= offsetForBuySellStop;
               } 
                         
               int ticket = OrderSend(symbol, orderType, lots, fBidPrice, 3, 0, 0, comment, nMagicNum, 0, clrGreen);
               if(ticket > 0 && (pointForStoploss > 0 || pointForTakeprofit > 0)) { 
                  int nAddStops = AddLiteralStopsByPips(ticket, orderType, pointForStoploss, pointForTakeprofit); 
                  logMsg = StringFormat("Symbol: %s,  ticket: %d, AddStops result: %d",
                                  symbol, ticket, nAddStops);
                  LogInfo(logMsg);   
               }
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
                  LogError(logMsg);
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
   
   int AddLiteralStopsByPips(int iTicketToGo, int iType, double iSL, double iTP)
   {
     int iDigits, iNumRetries, iError;
     double dAsk, dBid, dSL, dTP;
     
     iDigits = MarketInfo(Symbol(), MODE_DIGITS);
   
     if(OrderSelect(iTicketToGo, SELECT_BY_TICKET)==true) // SELECT_BY_TICKET
       {
          // is server or context busy - try n times to submit the order
          iNumRetries = 12;
         
          while(iNumRetries > 0)    // Retries Block  
             {
                if (!IsTradeAllowed()) {
                     Sleep(500);
                }
                RefreshRates();
                  
                if (iType == OP_BUY || iType == OP_BUYSTOP)
                {
                   dAsk = MarketInfo(Symbol(), MODE_ASK);
                   dBid = MarketInfo(Symbol(), MODE_BID);
                   
                   dSL = NormalizeDouble(dBid - iSL, iDigits);
                   dTP = NormalizeDouble(dBid + iTP, iDigits);
                }
   
                  if (iType == OP_SELL || iType == OP_SELLSTOP)
                    {
                      dAsk = MarketInfo(Symbol(), MODE_ASK);
                      dBid = MarketInfo(Symbol(), MODE_BID);
                      
                      dSL = NormalizeDouble(dAsk + iSL, iDigits);
                      dTP = NormalizeDouble(dAsk - iTP, iDigits);
                    }
                             
                 OrderModify(OrderTicket(), OrderOpenPrice(), dSL, dTP, 0);
                   
                 iError = GetLastError();
                     
                 if (iError==0) {
                     iNumRetries = 0;
                     return 0;
                 }
                 else  // retry if error is "busy", otherwise give up
                    {            
                        if(iError==ERR_SERVER_BUSY || iError==ERR_TRADE_CONTEXT_BUSY || iError==ERR_BROKER_BUSY || iError==ERR_NO_CONNECTION || iError == ERR_COMMON_ERROR
                          || iError==ERR_TRADE_TIMEOUT || iError==ERR_INVALID_PRICE || iError==ERR_OFF_QUOTES || iError==ERR_PRICE_CHANGED || iError==ERR_REQUOTE)
                           { 
                              Print("ECN Stops Not Added Error: ", iError);
                              Sleep(500);
                              iNumRetries--;
                           }
                         else
                           {
                              iNumRetries = 0;
                              Print("ECN Stops Not Added Error: ", iError);
                              // Alert("ECN Stops Not Added Error: ", iError);
                              return -2;
                           }
                    }
                    
            }   // Retries Block 
         
   
       } // SELECT_BY_TICKET
     else
      {
        Print("ECN Stops Invalid Ticket: ", iTicketToGo);
        // Alert("ECN Stops Invalid Ticket: ", iTicketToGo);   
        return -1;
      }  
      return 0;     
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
      LogImportant(logMsg);    
         
     
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
            LogImportant(logMsg);
            if(OrderClose(ticket, lots, fPrice, 3, clr))
            {                 
               break;
         
            } else
            {
               int nErr = GetLastError(); // 平仓失败 :( 
               logMsg = StringFormat("%s => Close buy order Error: %d, ticket = %d.",
                         __FUNCTION__, nErr, ticket);
               LogError(logMsg);
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
   
   int DeleteOrder(COrderInfo & orderInfo)
   {
      int ret = 0;
      double lots = orderInfo.m_Lots;
      int ticket = orderInfo.m_Ticket;
      string symbol = orderInfo.m_Symbol;
      int orderType = orderInfo.m_OrderType;
      
      string logMsg;  
      
      logMsg = "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  DELETE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<";
      LogInfo(logMsg); 
      logMsg = StringFormat("%s => Symbol = %s, orderType = %d, Lots = %s, ticket = %d",
                                  __FUNCTION__, symbol, orderType,
                                  DoubleToString(lots, 2), ticket);
      LogImportant(logMsg);    
         
     
      if(ticket > 0)
      {
         color clr = clrRed;
         if(!OrderDelete(ticket, clr)) {
            int nErr = GetLastError(); // 删除订单失败 :( 
            logMsg = StringFormat("%s => Delete order Error: %d, ticket = %d.",
                      __FUNCTION__, nErr, ticket);
            LogError(logMsg);
         }  
      }
          
      return ret;
   }
   
   double GetSpread(string symbol) {
      RefreshRates();
      double dBid = MarketInfo(Symbol(), MODE_BID);
      double dAsk = MarketInfo(Symbol(), MODE_ASK);
  
      double dSpread =  dAsk - dBid;
      return dSpread;
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
   
   void ShowVersion(string label, string text, color clr, int x, int y)
   {
      if(m_nTick % 4 == 0) {
         DisplayText(label, text, clr, x, y);
      }
   }
   
   void ShowText(string label, string text, color clr, int x, int y)
   {
      string labelInternal = StringFormat("%s-%d", label, m_nMagicNum);
      if(m_bShowText && m_nTick % 4 == 0) {
         DisplayText(labelInternal, text, clr, x, y);
      }
   }
   
public:
   CWaveOrder(string symbol, int magicNum) {
      m_symbol = symbol;
      m_nMagicNum = magicNum;
      m_nMagicNumMartin = m_nMagicNum + 1;
      m_nBuyOrderCount = 0;
      m_nSellOrderCount = 0;
      m_nBuyMartinOrderCount = 0;
      m_nSellMartinOrderCount = 0;
      m_dBuyLots = 0.0;
      m_dSellLots = 0.0;
      m_buyComment = "WBuy";
      m_sellComment = "WSell";
      
      m_buyMartinComment = "WBuyM";
      m_sellMartinComment = "WSellM";
      
      m_buyStopComment = "WBuyStop";
      m_sellStopComment = "WSellStop";
      
      m_dBuyMostProfits = 0.0;
      m_dBuyLeastProfits = 0.0;
      m_dBuyPreProfits = 0.0;
      m_dBuyCurrentProfits = 0.0;      
      m_dSellMostProfits = 0.0;
      m_dSellLeastProfits = 0.0;
      m_dSellPreProfits = 0.0;
      m_dSellCurrentProfits = 0.0;
      
      m_dBuyMartinMostProfits = 0.0;
      m_dBuyMartinLeastProfits = 0.0;
      m_dBuyMartinPreProfits = 0.0;
      m_dBuyMartinCurrentProfits = 0.0;      
      m_dSellMartinMostProfits = 0.0;
      m_dSellMartinLeastProfits = 0.0;
      m_dSellMartinPreProfits = 0.0;
      m_dSellMartinCurrentProfits = 0.0;   
            
      m_xBuyBasePos = 0;
      m_yBuyBasePos = 0;
      m_xSellBasePos = 0;
      m_ySellBasePos = 4;
      
      m_nTick = 0;
      m_bShowComment = gbShowComment;
      m_bShowText = gbShowText;
   }
   
   void HeartBeat() {
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos;
      string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, m_nTick++);
      ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
      
      yPos++;
      string strOrders = StringFormat("【多方】订单数：%d，手数：%s", 
                     m_nBuyOrderCount + m_nBuyMartinOrderCount, 
                     DoubleToString(m_dBuyLots + m_dBuyMartinLots, 2));
      ShowText("OrderStatisticsBuy", strOrders, clrYellow, xPos, yPos);
      
      yPos++;
      string strProfits = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dBuyCurrentProfits + m_dBuyMartinCurrentProfits, 2),
                           DoubleToString(m_dBuyMostProfits + m_dBuyMartinMostProfits, 2), 
                           DoubleToString((m_dBuyMostProfits + m_dBuyMartinMostProfits) * (1 - BackwordForLong), 2));
      ShowText("ProfitsBuy", strProfits, clrYellow, xPos, yPos); 
      
      yPos++;   
      strOrders = StringFormat("【空方】订单数：%d，手数：%s", 
                     m_nSellOrderCount + m_nSellMartinOrderCount, 
                     DoubleToString(m_dSellLots + m_dSellMartinLots, 2));
      ShowText("OrderStatisticsSell", strOrders, clrYellow, xPos, yPos);
      
      yPos++;  
      strProfits = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dSellCurrentProfits + m_dSellMartinCurrentProfits, 2),
                           DoubleToString(m_dSellMostProfits + m_dSellMartinMostProfits, 2), 
                           DoubleToString((m_dSellMostProfits + m_dSellMostProfits) * (1 - BackwordForShort), 2));
      ShowText("ProfitsSell", strProfits, clrYellow, xPos, yPos); 
   }
   int GetBuyOrderCnt() {
      return m_nBuyOrderCount;
   }
   
   int GetBuyStopOrderCnt() {
      return m_nBuyStopOrderCount;
   }

   int GetSellOrderCnt() {
      return m_nSellOrderCount;
   }
   
   int GetSellStopOrderCnt() {
      return m_nSellStopOrderCount;
   }
   
   int GetBuyMartinOrderCnt() {
      return m_nBuyMartinOrderCount;
   }
   
   int GetSellMartinOrderCnt() {
      return m_nSellMartinOrderCount;
   }
      
   void CleanBuyOrders() 
   {
      CleanOrders(m_buyOrder, m_nBuyOrderCount);
      m_nBuyOrderCount = 0;
      m_dBuyLots = 0; 
   }
   
   void CleanBuyMartinOrders() 
   {
      CleanOrders(m_buyMartinOrder, m_nBuyMartinOrderCount);
      m_nBuyMartinOrderCount = 0;
      m_dBuyMartinLots = 0;  
   }
   
   void CleanBuyStopOrders() 
   {
      CleanOrders(m_buyStopOrder, m_nBuyStopOrderCount);
      m_nBuyStopOrderCount = 0;
      m_dBuyStopLots = 0;
   }

   void CleanSellOrders() 
   {
      CleanOrders(m_sellOrder, m_nSellOrderCount);
      m_nSellOrderCount = 0;
      m_dSellLots = 0;
   }
   void CleanSellMartinOrders() 
   {
      CleanOrders(m_sellMartinOrder, m_nSellMartinOrderCount);
      m_nSellMartinOrderCount = 0;
      m_dSellMartinLots = 0;
   }
   
   void CleanSellStopOrders() 
   {
      CleanOrders(m_sellStopOrder, m_nSellStopOrderCount);
      m_nSellStopOrderCount = 0;
      m_dSellStopLots = 0;
   }
   
   void CleanAllOrders() {
      CleanBuyOrders();
      CleanSellOrders();
      CleanBuyMartinOrders();
      CleanSellMartinOrders();
      CleanBuyStopOrders();
      CleanSellStopOrders();
   }
   
   int LoadAllOrders() {
      int buyCnt = LoadBuyOrders();
      int sellCnt = LoadSellOrders();
      int buyMartinCnt = LoadBuyMartinOrders();
      int sellMartinCnt = LoadSellMartinOrders();
      return buyCnt + sellCnt + buyMartinCnt + sellMartinCnt;
   }
   
   int LoadAllMartinOrders() {
      int buyCnt = LoadBuyMartinOrders();
      int sellCnt = LoadSellMartinOrders();
      return buyCnt + sellCnt;
   }
   
   int LoadBuyOrders()
   {
      string logMsg;
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos;
      // string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
      // ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
                
      CleanBuyOrders();
      
      m_nBuyOrderCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       m_buyOrder, m_nBuyOrderCount, m_dBuyLots );
                                       
      if(m_nBuyOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, Buy, comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol,
                                  m_buyComment, m_nBuyOrderCount, DoubleToString(m_dBuyLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_buyOrder[m_nBuyOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_buyOrder[m_nBuyOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_buyOrder, m_nBuyOrderCount);
         
         m_dBuyPreProfits = m_dBuyCurrentProfits;
         m_dBuyCurrentProfits = dProfits;
         if(m_dBuyCurrentProfits > m_dBuyMostProfits) 
         {
            m_dBuyMostProfits = m_dBuyCurrentProfits;
         }
         
         if(m_dBuyCurrentProfits < m_dBuyLeastProfits) 
         {
            m_dBuyLeastProfits = m_dBuyCurrentProfits;
         }          
                        
         yPos++;
         string strProfits = StringFormat("【多方】订单数：%d，手数：%s", 
                     m_nBuyOrderCount, DoubleToString(m_dBuyLots, 2));
         ShowText("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
                        
      }
      return m_nBuyOrderCount;
   }
   
   int LoadBuyMartinOrders()
   {
      string logMsg;
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos;
      // string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
      // ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
                
      CleanBuyMartinOrders();
      
      m_nBuyMartinOrderCount = LoadOrders(m_symbol, OP_BUY, m_buyMartinComment, m_nMagicNumMartin,
                                       m_buyMartinOrder, m_nBuyMartinOrderCount, m_dBuyMartinLots );
                                       
      if(m_nBuyMartinOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, Buy, comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol,
                                  m_buyMartinComment, m_nBuyMartinOrderCount, DoubleToString(m_dBuyMartinLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_buyMartinOrder, m_nBuyMartinOrderCount);
         
         m_dBuyMartinPreProfits = m_dBuyMartinCurrentProfits;
         m_dBuyMartinCurrentProfits = dProfits;
         if(m_dBuyMartinCurrentProfits > m_dBuyMartinMostProfits) 
         {
            m_dBuyMartinMostProfits = m_dBuyMartinCurrentProfits;
         }
         
         if(m_dBuyMartinCurrentProfits < m_dBuyMartinLeastProfits) 
         {
            m_dBuyMartinLeastProfits = m_dBuyMartinCurrentProfits;
         }          
                        
         yPos++;
         string strProfits = StringFormat("【多方】订单数：%d，手数：%s", 
                     m_nBuyMartinOrderCount, DoubleToString(m_dBuyMartinLots, 2));
         ShowText("OrderStatisticsBuyMartin", strProfits, clrYellow, xPos, yPos);
                        
      }
      return m_nBuyMartinOrderCount;
   }
   
   int LoadBuyStopOrders()
   {
      string logMsg;
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos;
      // string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
      // ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
                
      CleanBuyStopOrders();
      
      m_nBuyStopOrderCount = LoadOrders(m_symbol, OP_BUYSTOP, m_buyStopComment, m_nMagicNum, 
                                       m_buyStopOrder, m_nBuyStopOrderCount, m_dBuyStopLots );
                                       
      return m_nBuyStopOrderCount;
   }
   
   int LoadSellOrders()
   {
      string logMsg;
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos;
               
      CleanSellOrders();
      
      m_nSellOrderCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       m_sellOrder, m_nSellOrderCount, m_dSellLots );
                                       
      if(m_nSellOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, Sell, comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol,
                                  m_sellComment, m_nSellOrderCount, DoubleToString(m_dSellLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_sellOrder[m_nSellOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_sellOrder[m_nSellOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_sellOrder, m_nSellOrderCount);
         
         m_dSellPreProfits = m_dSellCurrentProfits;
         m_dSellCurrentProfits = dProfits;
         if(m_dSellCurrentProfits > m_dSellMostProfits) 
         {
            m_dSellMostProfits = m_dSellCurrentProfits;
         }
         
         if(m_dSellCurrentProfits < m_dSellLeastProfits) 
         {
            m_dSellLeastProfits = m_dSellCurrentProfits;
         }          
                        
         yPos++;
         string strProfits = StringFormat("【空方】订单数：%d，手数：%s", 
                     m_nSellOrderCount, DoubleToString(m_dSellLots, 2));
         ShowText("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
                        
      }
      return m_nSellOrderCount;
   }
   
   int LoadSellMartinOrders()
   {
      string logMsg;
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos;
               
      CleanSellMartinOrders();
      
      m_nSellMartinOrderCount = LoadOrders(m_symbol, OP_SELL, m_sellMartinComment, m_nMagicNumMartin, 
                                       m_sellMartinOrder, m_nSellMartinOrderCount, m_dSellMartinLots );
                                       
      if(m_nSellMartinOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, Sell, comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol,
                                  m_sellMartinComment, m_nSellMartinOrderCount, DoubleToString(m_dSellMartinLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_sellMartinOrder, m_nSellMartinOrderCount);
         
         m_dSellMartinPreProfits = m_dSellMartinCurrentProfits;
         m_dSellMartinCurrentProfits = dProfits;
         if(m_dSellMartinCurrentProfits > m_dSellMartinMostProfits) 
         {
            m_dSellMartinMostProfits = m_dSellMartinCurrentProfits;
         }
         
         if(m_dSellMartinCurrentProfits < m_dSellMartinLeastProfits) 
         {
            m_dSellMartinLeastProfits = m_dSellMartinCurrentProfits;
         }          
                        
         yPos++;
         string strProfits = StringFormat("【空方】订单数：%d，手数：%s", 
                     m_nSellMartinOrderCount, DoubleToString(m_dSellMartinLots, 2));
         ShowText("OrderStatisticsSellMartin", strProfits, clrYellow, xPos, yPos);
                        
      }
      return m_nSellMartinOrderCount;
   }
   
   int LoadSellStopOrders()
   {
      string logMsg;
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos;
               
      CleanSellStopOrders();
      
      m_nSellStopOrderCount = LoadOrders(m_symbol, OP_SELLSTOP, m_sellStopComment, m_nMagicNum, 
                                       m_sellStopOrder, m_nSellStopOrderCount, m_dSellStopLots );
                                       
      return m_nSellStopOrderCount;
   }
   
   int OpenBuyOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int nDirct = OP_BUY;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_buyComment, m_nMagicNum, m_nBuyOrderCount + 1);   
      }
      OpenOrder(m_symbol, nDirct, optParam.m_BaseOpenLots, comment, m_nMagicNum,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint, optParam.m_OffsetForBuySellStop);
      
      // 重新装载多方订单
      CleanBuyOrders();
      LoadBuyOrders();
      return 0;
   }
   
   int OpenBuyMartinOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int nDirct = OP_BUY;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_buyMartinComment, m_nMagicNumMartin, m_nBuyMartinOrderCount + 1);   
      }
      OpenOrder(m_symbol, nDirct, optParam.m_BaseOpenLots, comment, m_nMagicNumMartin,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint, optParam.m_OffsetForBuySellStop);
      
      // 重新装载多方订单
      CleanBuyMartinOrders();
      LoadBuyMartinOrders();
      return 0;
   }
   
   int OpenBuyStopOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int orderType = OP_BUYSTOP;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_buyStopComment, m_nMagicNum, m_nBuyStopOrderCount + 1);   
      }
      OpenOrder(m_symbol, orderType, optParam.m_BaseOpenLots, comment, m_nMagicNum,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint, optParam.m_OffsetForBuySellStop);
      
      // 重新装载多方订单
      CleanBuyStopOrders();
      LoadBuyStopOrders();
      return 0;
   }
   
   
   int OpenSellOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int orderType = OP_SELL;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_sellComment, m_nMagicNum, m_nSellOrderCount + 1);   
      }
      OpenOrder(m_symbol, orderType, optParam.m_BaseOpenLots, comment, m_nMagicNum,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint, optParam.m_OffsetForBuySellStop);
      
      // 重新装载空方订单
      CleanSellStopOrders();
      LoadSellOrders();
      return 0;
   }
   
   int OpenSellMartinOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int orderType = OP_SELL;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_sellMartinComment, m_nMagicNumMartin, m_nSellMartinOrderCount + 1);   
      }
      OpenOrder(m_symbol, orderType, optParam.m_BaseOpenLots, comment, m_nMagicNumMartin,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint, optParam.m_OffsetForBuySellStop);
      
      // 重新装载空方订单
      CleanSellMartinOrders();
      LoadSellMartinOrders();
      return 0;
   }
   
   int OpenSellStopOrders(OptParam & optParam)
   {
      // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
      string comment = ""; 
      int orderType = OP_SELLSTOP;           
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d", m_sellStopComment, m_nMagicNum, m_nSellStopOrderCount + 1);   
      }
      OpenOrder(m_symbol, orderType, optParam.m_BaseOpenLots, comment, m_nMagicNum,
                optParam.m_StopLossPoint, optParam.m_TakeProfitPoint, optParam.m_OffsetForBuySellStop);
      
      // 重新装载空方订单
      CleanSellStopOrders();
      LoadSellStopOrders();
      return 0;
   }
   
   double GetHighestPriceFromOrders(COrderInfo & orders [], int nCnt) {
      double price = 0;
      int i = 0;
      for(i = 0; i < nCnt; i++)
      {
         if(i == 0) {
            price = orders[i].m_Prices;
         }
         
         if(orders[i].m_Prices > price) {
            price = orders[i].m_Prices;
         }
      }
      return price;
   }
   
   double GetLowestPriceFromOrders(COrderInfo & orders [], int nCnt) {
      double price = 0;
      int i = 0;
      for(i = 0; i < nCnt; i++)
      {
         if(i == 0) {
            price = orders[i].m_Prices;
         }
         
         if(orders[i].m_Prices < price) {
            price = orders[i].m_Prices;
         }
      }
      return price;
   }
   
   bool HasHoleInOrders(COrderInfo & orders [], int nCnt, double dPriceDiff, int nDirect) {
      bool bHasHole = true;
      RefreshRates();
      double fPrice = 0;
      if(nDirect == OP_BUY) {
         fPrice = MarketInfo(m_symbol, MODE_ASK);
      }else {
         fPrice = MarketInfo(m_symbol, MODE_BID);
      }
      int i = 0;
      for(i = 0; i < nCnt; i++)
      {
         if(MathAbs(fPrice - orders[i].m_Prices) < dPriceDiff) {
            bHasHole = false;
            break;
         }
      }
      return bHasHole;
   }
   
   bool CheckForAppendBuyOrder(double dPriceDiff, double dSpreadMax,
                               bool bEnableLongShortRateForAppend, double dEnableLongShortRateLotsForAppend,
                               double dMaxHandlingLots) {
      string logMsg;
      if(m_nBuyOrderCount <= 0) {
         return false;
      } 
      
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendBuyOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
            LogInfo(logMsg);
         return false;
      }
      
      if(m_dBuyLots > dMaxHandlingLots) {
         return false;
      }
      
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForAppend){
         if(m_dBuyLots >= dEnableLongShortRateLotsForAppend || m_dSellLots >= dEnableLongShortRateLotsForAppend) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双发的比例关系
            if(m_dBuyLots <= m_dSellLots) {
               // 多方的总手数小于等于空方的总手数，允许加仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许加仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许加仓
            checkLongShortRate = true;
         }         
      }
      
      if(!checkLongShortRate) {
         return false;
      }
      
      double highestBuyPrice = GetHighestPriceFromOrders(m_buyOrder, m_nBuyOrderCount);
      RefreshRates(); 
      double fAskPrice = MarketInfo(m_symbol, MODE_ASK);
      if(highestBuyPrice > 0 && fAskPrice - highestBuyPrice > dPriceDiff) {
         logMsg = StringFormat("CheckForAppendBuyOrder(%s), current prise = %s, highestBuyPrice = %s, dPriseDiff = %s",
                                  m_symbol, DoubleToString(fAskPrice, 5),
                                  DoubleToString(highestBuyPrice, 5), 
                                  DoubleToString(dPriceDiff, 5));
         LogInfo(logMsg);
         return true;
      }
      
      /*
      bool bHasHole = HasHoleInOrders( m_buyOrder, m_nBuyOrderCount, dPriceDiff, OP_BUY); 
      if(bHasHole) { 
         double lowestSellPrice = GetLowestPriceFromOrders(m_sellOrder, m_nSellOrderCount);                 
         if(fAskPrice - lowestSellPrice > dRevertAppendStep) {
            return true;
         }   
      }
      */
      return false;
   }
   
   bool CheckForAppendBuyMartinOrder(double & dRevertAppendSteps[], double dSpreadMax, double dMaxHandlingLots) {
      string logMsg;
          
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendBuyMartinOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
         LogInfo(logMsg);
         return false;
      }
      
      if(m_dBuyLots + m_dBuyMartinLots > dMaxHandlingLots) {
         return false;
      }
            
          
      // 计算正常轮转多方订单的最高价格
      double highestBuyPrice = GetHighestPriceFromOrders(m_buyOrder, m_nBuyOrderCount);
      RefreshRates(); 
      double fAskPrice = MarketInfo(m_symbol, MODE_ASK);
      logMsg = StringFormat("多方马丁订单数(%s), %d",
                                  m_symbol, m_nSellMartinOrderCount);
      LogInfo(logMsg);      
      double dRevertAppendStep = dRevertAppendSteps[m_nBuyMartinOrderCount];
      logMsg = StringFormat("多方马丁加仓判断：(%s), current prise = %s, highestBuyPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fAskPrice, 5),
                                  DoubleToString(highestBuyPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
      LogInfo(logMsg);
      if(highestBuyPrice > 0 && highestBuyPrice - fAskPrice > dRevertAppendStep) {
         // 对于多方来讲，行情回撤，达到预设的回撤点位，满足加马丁仓条件
         logMsg = StringFormat("多方马丁加仓条件满足：(%s), current prise = %s, highestBuyPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fAskPrice, 5),
                                  DoubleToString(highestBuyPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
         LogInfo(logMsg);
         return true;
      }
     
      return false;
   }
   
   bool CheckForAppendSellOrder(double dPriceDiff, double dSpreadMax,
                                 bool bEnableLongShortRateForAppend, double dEnableLongShortRateLotsForAppend,
                                  double dMaxHandlingLots) {
      string logMsg;
      if(m_nSellOrderCount <= 0) {
         return false;
      } 
      
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendSellOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
            LogInfo(logMsg);
         return false;
      }
      
      if(m_dSellLots > dMaxHandlingLots) {
         return false;
      }
      
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForAppend){
         if(m_dBuyLots >= dEnableLongShortRateLotsForAppend || m_dSellLots >= dEnableLongShortRateLotsForAppend) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双发的比例关系
            if(m_dSellLots <= m_dBuyLots) {
               // 空方的总手数小于等于多方的总手数，允许加仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许加仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许加仓
            checkLongShortRate = true;
         }         
      }
      
      if(!checkLongShortRate) {
         return false;
      }
   
      // 计算正常轮转空方订单的最低价格
      double lowestSellPrice = GetLowestPriceFromOrders(m_sellOrder, m_nSellOrderCount);
      RefreshRates();
      double fBidPrice = MarketInfo(m_symbol, MODE_BID);
      if(lowestSellPrice > 0 && lowestSellPrice - fBidPrice > dPriceDiff) {
         // 价格持续下行时的情况
         logMsg = StringFormat("CheckForAppendSellOrder(%s), current prise = %s, lowestSellPrice = %s, dPriceDiff = %s",
                                  m_symbol, DoubleToString(fBidPrice, 5),
                                  DoubleToString(lowestSellPrice, 5), 
                                  DoubleToString(dPriceDiff, 5));
         LogInfo(logMsg);
         return true;
      }
      /*
      bool bHasHole = HasHoleInOrders( m_sellOrder, m_nSellOrderCount, dPriceDiff, OP_SELL);
      if(bHasHole) {
         // 获取买单中的最高价格
         double highestBuyPrice = GetHighestPriceFromOrders(m_buyOrder, m_nBuyOrderCount);
         if(highestBuyPrice - fBidPrice > dRevertAppendStep) {
            // 当前价格比买单中的最高价格还低时，返回ture
            return true;
         }  
      }  
      */             
      return false;
   }
   
   bool CheckForAppendSellMartinOrder(double & dRevertAppendSteps[], double dSpreadMax, double dMaxHandlingLots) {
      string logMsg;
            
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendBuyMartinOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
         LogInfo(logMsg);
         return false;
      }
      
      if(m_dSellLots + m_dSellMartinLots > dMaxHandlingLots) {
         return false;
      }
            
      // 计算正常轮转空方订单的最低价格
      double lowestSellPrice = GetLowestPriceFromOrders(m_sellOrder, m_nSellOrderCount);
      RefreshRates();
      double fBidPrice = MarketInfo(m_symbol, MODE_BID);
      logMsg = StringFormat("空方马丁订单数(%s), %d",
                                  m_symbol, m_nSellMartinOrderCount);
      LogInfo(logMsg);
      double dRevertAppendStep = dRevertAppendSteps[m_nSellMartinOrderCount];
      logMsg = StringFormat("空方马丁加仓判断(%s), current prise = %s, lowestSellPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fBidPrice, 5),
                                  DoubleToString(lowestSellPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
      LogInfo(logMsg);
      if(lowestSellPrice > 0 && fBidPrice - lowestSellPrice > dRevertAppendStep) {
         // 对于空方来讲，行情反弹，达到预设的回撤点位，满足加马丁仓条件
         logMsg = StringFormat("空方马丁加仓条件满足(%s), current prise = %s, lowestSellPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fBidPrice, 5),
                                  DoubleToString(lowestSellPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
         LogInfo(logMsg);
         return true;
        
      }
     
      return false;
   }
   
   double GetProfitByTicket(int nTicket, COrderInfo & orders [], int nCnt) {
      double profit = 0;
      int i =0;
      for(i = 0; i < nCnt; i++) {
         if(orders[i].m_Ticket == nTicket) {
            profit = orders[i].m_Profits;
            break;
         }
      }
      return profit;
  
   }
   
   double GetHighestBuyOrderPrice() {
      double highestBuyPrice = GetHighestPriceFromOrders(m_buyOrder, m_nBuyOrderCount);
      return highestBuyPrice;
   }
   
   double GetLowestBuyMartinOrderPrice() {
      double lowestBuyMartinPrice = GetLowestPriceFromOrders(m_buyMartinOrder, m_nBuyMartinOrderCount);
      return lowestBuyMartinPrice;
   }
   
   double GetLowestSellOrderPrice() {
      double lowestSellPrice = GetLowestPriceFromOrders(m_sellOrder, m_nSellOrderCount); 
      return lowestSellPrice;
   }
   
   double GetHighestSellMartinOrderPrice() {
      double highestSellPrice = GetHighestPriceFromOrders(m_sellMartinOrder, m_nSellMartinOrderCount);
      return highestSellPrice;
   }
   
   double GetAllBuyLots() {
      return m_dBuyLots + m_dBuyMartinLots;
   }
   
   double GetAllSellLots() {
      return m_dSellLots + m_dSellMartinLots;
   }
   
   void CheckForCloseBuyOrders(double minPriceDiff, double dBackword,
                                bool bEnableLongShortRateForClose, double dEnableLongShortRateLotsForClose) {
      string logMsg;
      logMsg = StringFormat("CheckForCloseBuyOrders(%s), minPriceDiff: %s, dBackword: %s, bEnableLongShortRateForClose: %d, dEnableLongShortRateLotsForClose: %d",
                                  m_symbol, 
                                  DoubleToString(minPriceDiff, 5),
                                  DoubleToString(dBackword, 2), 
                                  bEnableLongShortRateForClose,
                                  DoubleToString(dEnableLongShortRateLotsForClose, 2)
                                  );
      LogInfo(logMsg);
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForClose){
         if(m_dBuyLots >= dEnableLongShortRateLotsForClose || m_dSellLots >= dEnableLongShortRateLotsForClose) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双方的比例关系
            if(m_dBuyLots >= m_dSellLots) {
               // 多方的总手数大于等于空方的总手数，允许平仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许平仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许平仓
            checkLongShortRate = true;
         }         
      }
       logMsg = StringFormat("CheckForCloseBuyOrders(%s), checkLongShortRate: %d",
                                  m_symbol, 
                                  checkLongShortRate
                                  );
      LogInfo(logMsg);
      if(!checkLongShortRate) {
         return;
      }
      
      COrderInfo buyOrders[MAX_ORDER_COUNT];
      int nBuyOrderCount = 0;
      double dBuyLots = 0;
      bool bNeedReloadBuyOrders = false;
      nBuyOrderCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       buyOrders, nBuyOrderCount, dBuyLots);
      if(nBuyOrderCount != m_nBuyOrderCount) {
         logMsg = StringFormat("多方订单数量有变化(%s)：%d -> %d)",
                                  m_symbol, m_nBuyOrderCount,
                                  nBuyOrderCount);
         LogInfo(logMsg); 
         bNeedReloadBuyOrders = true;
      }
      RefreshRates();                                 
      double fPrice = MarketInfo(m_symbol, MODE_BID);
      int i =0;
      m_dBuyCurrentProfits = 0;
      m_dBuyMostProfits = 0;
      logMsg = StringFormat("CheckForCloseBuyOrders(%s), m_nBuyOrderCount: %d, nBuyOrderCount = %d",
                                  m_symbol, m_nBuyOrderCount,
                                  nBuyOrderCount
                                  );
      LogInfo(logMsg);
      for(i = 0; i < m_nBuyOrderCount; i++) {
         double profits = GetProfitByTicket(m_buyOrder[i].m_Ticket,
                  buyOrders, nBuyOrderCount);
         
         double movableProfits = m_buyOrder[i].m_MostProfits * (1 - dBackword);
         double priceDiff = fPrice - m_buyOrder[i].m_Prices;
         if(priceDiff > minPriceDiff
            && profits < movableProfits
            && m_buyOrder[i].m_Profits > profits){
            logMsg = StringFormat("Buy order close(%s, %d), pre: %s, current: %s, most: %s, movable: %s, priceDiff: %s",
                                  m_symbol, m_buyOrder[i].m_Ticket,
                                  DoubleToString(m_buyOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_buyOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg);
            
            CloseOrder(m_buyOrder[i]);
            bNeedReloadBuyOrders = true;
         }else {
            logMsg = StringFormat("Buy order profits(%s, %d), pre: %s, current: %s, most: %s,  movable: %s, priceDiff: %s",
                                  m_symbol, m_buyOrder[i].m_Ticket,
                                  DoubleToString(m_buyOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_buyOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg);         
            m_buyOrder[i].m_Profits = profits;
            if(profits > m_buyOrder[i].m_MostProfits) {
               m_buyOrder[i].m_MostProfits = profits;
            }
            m_dBuyCurrentProfits += profits;
            m_dBuyMostProfits += m_buyOrder[i].m_MostProfits;
            
         }
      }
      
      if(bNeedReloadBuyOrders) {
         LoadBuyOrders();
      }
   }
   
   void CheckForCloseSellOrders(double minPriceDiff, double dBackword ,
                                 bool bEnableLongShortRateForClose, double dEnableLongShortRateLotsForClose) {
      string logMsg;
      logMsg = StringFormat("CheckForCloseSellOrders(%s), minPriceDiff: %s, dBackword: %s, bEnableLongShortRateForClose: %d, dEnableLongShortRateLotsForClose: %d",
                                  m_symbol, 
                                  DoubleToString(minPriceDiff, 5),
                                  DoubleToString(dBackword, 2), 
                                  bEnableLongShortRateForClose,
                                  DoubleToString(dEnableLongShortRateLotsForClose, 2)
                                  );
      LogInfo(logMsg);
      bool checkLongShortRate = true;
      if(bEnableLongShortRateForClose){
         if(m_dBuyLots >= dEnableLongShortRateLotsForClose || m_dSellLots >= dEnableLongShortRateLotsForClose) {
            // 多方或空方的任意一方的手数大于等于设置的手数, 继续判断多空双方的比例关系
            if(m_dSellLots >= m_dBuyLots) {
               // 空方的总手数大于等于多方的总手数，允许平仓
               checkLongShortRate = true;
            }else {
               // 否则，不允许平仓
               checkLongShortRate = false;
            }
            
         }else {
            // 多方或空方的任意一方的手数均小于于设置的手数，允许平仓
            checkLongShortRate = true;
         }         
      }
      
      logMsg = StringFormat("CheckForCloseSellOrders(%s), checkLongShortRate: %d",
                                  m_symbol, 
                                  checkLongShortRate
                                  );
      LogInfo(logMsg);
      if(!checkLongShortRate) {
         return;
      }
      
      COrderInfo sellOrders[MAX_ORDER_COUNT];
      int nSellOrderCount = 0;
      double dSellLots = 0;
      bool bNeedReloadSellOrders = false;
      nSellOrderCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       sellOrders, nSellOrderCount, dSellLots);
      if(nSellOrderCount != m_nSellOrderCount) {
         logMsg = StringFormat("空方订单数量有变化(%s)：%d -> %d)",
                                  m_symbol, m_nSellOrderCount,
                                  nSellOrderCount);
         LogInfo(logMsg); 
         bNeedReloadSellOrders = true;
      }
      RefreshRates();                                 
      double fPrice = MarketInfo(m_symbol, MODE_ASK);
      int i =0;
      m_dSellCurrentProfits = 0;
      m_dSellMostProfits = 0;
      logMsg = StringFormat("CheckForCloseSellOrders(%s), m_nSellOrderCount: %d, nSellOrderCount = %d",
                                  m_symbol, m_nSellOrderCount,
                                  nSellOrderCount
                                  );
      LogInfo(logMsg);
      
      for(i = 0; i < m_nSellOrderCount; i++) {
         double profits = GetProfitByTicket(m_sellOrder[i].m_Ticket,
                  sellOrders, nSellOrderCount);
         
         double movableProfits = m_sellOrder[i].m_MostProfits * (1 - dBackword);
         double priceDiff = m_sellOrder[i].m_Prices - fPrice;
         logMsg = StringFormat("CheckForCloseSellOrders(%s), index = %d,  profits: %s, most: %s,  movableProfits = %s, priceDiff = %s",
                                  m_symbol, i, 
                                  DoubleToString(profits, 2), 
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 2)
                                  );
         LogInfo(logMsg);
         if(priceDiff > minPriceDiff 
            && profits < movableProfits 
            && m_sellOrder[i].m_Profits > profits){
            logMsg = StringFormat("Sell order close(%s, %d), pre: %s, current: %s, most: %s, movable: %s, priceDiff: %s",
                                  m_symbol, m_sellOrder[i].m_Ticket,
                                  DoubleToString(m_sellOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg); 
            CloseOrder(m_sellOrder[i]);
            bNeedReloadSellOrders = true;
         }else {
            logMsg = StringFormat("Sell order profits(%s, %d), pre: %s, current: %s, most: %s, movable: %s, priceDiff: %s",
                                  m_symbol, m_sellOrder[i].m_Ticket,
                                  DoubleToString(m_sellOrder[i].m_Profits, 2), 
                                  DoubleToString(profits, 2),
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2),
                                  DoubleToString(movableProfits, 2),
                                  DoubleToString(priceDiff, 4));
            LogInfo(logMsg); 
            m_sellOrder[i].m_Profits = profits;
            if(profits > m_sellOrder[i].m_MostProfits) {
               m_sellOrder[i].m_MostProfits = profits;
               logMsg = StringFormat("CheckForCloseSellOrders(%s), index = %d,  set most to: %s",
                                  m_symbol, i, 
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2)
                                  );
               LogInfo(logMsg);
            }
            logMsg = StringFormat("CheckForCloseSellOrders(%s), index = %d,  most: %s",
                                  m_symbol, i, 
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2)
                                  );
            LogInfo(logMsg);
         
            m_dSellCurrentProfits += profits;
            m_dSellMostProfits += m_sellOrder[i].m_MostProfits;
         }
      }
      
      if(bNeedReloadSellOrders) {
         CleanSellOrders();
         LoadSellOrders();
      }
   }
   
   double CalcCurrentBuyOrderProfits() {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       orders, nCount, dLots);
      return CalcTotalProfits(orders, nCount);
   }
   
   double CalcCurrentBuyMartinOrderProfits() {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNumMartin, 
                                       orders, nCount, dLots);
      return CalcTotalProfits(orders, nCount);
   }
   
   double CalcCurrentSellOrderProfits() {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       orders, nCount, dLots);
      return CalcTotalProfits(orders, nCount);
   }
   
   double CalcCurrentSellMartinOrderProfits() {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_SELL, m_sellMartinComment, m_nMagicNumMartin, 
                                       orders, nCount, dLots);
      return CalcTotalProfits(orders, nCount);
   }
   
   void CheckForCloseBuyMartinOrders(double minTakeProfit, double dBackword) {
      bool bClose = false;
      double dPreProfits = m_dBuyCurrentProfits + m_dBuyMartinCurrentProfits;
      double dCurrentBuyOrderProfits = CalcCurrentBuyOrderProfits();
      double dCurrentBuyMartinOrderProfits = CalcCurrentBuyMartinOrderProfits();
      double dMostProfits = m_dBuyMostProfits + m_dBuyMartinMostProfits;
      
      double dCurrentProfits = dCurrentBuyOrderProfits + dCurrentBuyMartinOrderProfits;
      double dRealStandardProfits = MathMax(minTakeProfit, dMostProfits * (1 - dBackword));
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos + 2;
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(dCurrentProfits, 2),DoubleToString(dMostProfits, 2), 
                           DoubleToString(dRealStandardProfits, 2));
      
      ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
     
      if(dCurrentProfits > minTakeProfit)
      {        
         if(dPreProfits > dRealStandardProfits && dCurrentProfits <= dRealStandardProfits)
         {
            string logMsg = StringFormat("CheckForCloseBuyMartinOrders：standard = %s, Pre = %s, Current = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentProfits, 2) );
            LogInfo(logMsg);
            bClose = true;
         }          
      }     
      m_dBuyCurrentProfits = dCurrentBuyOrderProfits;
      if(m_dBuyCurrentProfits > m_dBuyMostProfits) {
         m_dBuyMostProfits = m_dBuyCurrentProfits;
      }
      m_dBuyMartinCurrentProfits = dCurrentBuyMartinOrderProfits;
      if(m_dBuyMartinCurrentProfits > m_dBuyMartinMostProfits ) {
         m_dBuyMartinMostProfits = m_dBuyMartinCurrentProfits;
      }
      
      
      if(bClose) {
         CloseAllBuyOrders();
         CleanBuyOrders();
         
         CloseAllBuyMartinOrders();
         CleanBuyMartinOrders();
         
         CloseAllSellStopOrders(); // 平掉之前的空方挂单
         CleanSellStopOrders();
      }
   }
   
   void CheckForCloseSellMartinOrders(double minTakeProfit, double dBackword) {
      bool bClose = false;
      double dPreProfits = m_dSellCurrentProfits + m_dSellMartinCurrentProfits;
      double dCurrentSellOrderProfits = CalcCurrentSellOrderProfits();
      double dCurrentSellMartinOrderProfits = CalcCurrentSellMartinOrderProfits();
      double dCurrentProfits = dCurrentSellOrderProfits + dCurrentSellMartinOrderProfits;
      double dMostProfits = m_dSellMostProfits + m_dSellMartinMostProfits;
      
      double dRealStandardProfits = MathMax(minTakeProfit, dMostProfits * (1 - dBackword));
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos + 2;
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(dCurrentProfits, 2),DoubleToString(dMostProfits, 2), 
                           DoubleToString(dRealStandardProfits, 2));
      
      ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos); 
     
      if(dCurrentProfits > minTakeProfit)
      {        
         if(dPreProfits > dRealStandardProfits && dCurrentProfits <= dRealStandardProfits)
         {
            string logMsg = StringFormat("CheckForCloseSellMartinOrders：standard = %s, Pre = %s, Current = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentProfits, 2) );
            LogInfo(logMsg);
            bClose = true;
         }          
      }     
           
      m_dSellCurrentProfits = dCurrentSellOrderProfits;
      if(m_dSellCurrentProfits > m_dSellMostProfits) {
         m_dSellMostProfits = m_dSellCurrentProfits;
      }
      m_dBuyMartinCurrentProfits = dCurrentSellMartinOrderProfits;
      if(m_dSellMartinCurrentProfits > m_dSellMartinMostProfits ) {
         m_dSellMartinMostProfits = m_dSellMartinCurrentProfits;
      }
      
      if(bClose) {
         CloseAllSellOrders();
         CleanSellOrders();
         
         CloseAllSellMartinOrders();
         CleanSellOrders();
         
         CloseAllBuyStopOrders(); // 平掉之前的多方挂单
         CleanBuyStopOrders();
      }
   }
   
   bool CheckForAutoCloseAll(double baseBalance, double preEquity, double mostEquity, double realTargetEquity) {
      double currentEquity = AccountEquity(); // 净值
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos + 1;
      string strAutoCloseAll = StringFormat("净值:本金:%s,当前:%s,最大:%s,止盈:%s", 
               DoubleToString(baseBalance, 2),
               DoubleToString(currentEquity, 2),
               DoubleToString(mostEquity, 2),
               DoubleToString(realTargetEquity, 2));
      ShowText("AutoCloseAll", strAutoCloseAll, clrYellow, xPos, yPos);    
           
      if(currentEquity > baseBalance && preEquity > realTargetEquity && currentEquity <= realTargetEquity) {
         return true;
      }
      return false;
    }
    
    int CloseAllOrders() {
      CloseAllBuyOrders();
      CleanBuyOrders();
      
      CloseAllBuyMartinOrders();
      CleanBuyMartinOrders();
      
      CloseAllSellOrders();
      CleanSellOrders();
      
      CloseAllSellMartinOrders();
      CleanSellMartinOrders();
      
      LoadAllOrders();
      return 0;
    }
    
    int CloseAllBuyOrders()
    {
      int nRet = 0;
      for(int i = m_nBuyOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_buyOrder[i]);
      }
      m_dBuyMostProfits = 0.0;
      m_dBuyLeastProfits = 0.0;
      m_dBuyPreProfits = 0;
      m_dBuyCurrentProfits = 0;
      
      return nRet;
    }
    
    int CloseAllBuyStopOrders()
    {
      string logMsg = StringFormat("CloseAllBuyStopOrders(%s), count = %d",
                                  m_symbol, m_nBuyStopOrderCount
                                  );
      LogInfo(logMsg);
      int nRet = 0;
      for(int i = m_nBuyStopOrderCount - 1; i >= 0; i--)
      {
         DeleteOrder(m_buyStopOrder[i]);
      }
      
      return nRet;
    }
    
    int CloseAllBuyMartinOrders()
    {
      int nRet = 0;
      for(int i = m_nBuyMartinOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_buyMartinOrder[i]);
      }
     
      m_dBuyMartinMostProfits = 0.0;
      m_dBuyMartinLeastProfits = 0.0;
      m_dBuyMartinPreProfits = 0;
      m_dBuyMartinCurrentProfits = 0;
      
      
      return nRet;
    }
    
    int CloseAllSellOrders()
    {
      int nRet = 0;
      for(int i = m_nSellOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_sellOrder[i]);
      }
      
      m_dSellMostProfits = 0.0;
      m_dSellLeastProfits = 0.0;
      m_dSellPreProfits = 0;
      m_dSellCurrentProfits = 0;
      
      return nRet;
    }
    
    int CloseAllSellStopOrders()
    {
      string logMsg = StringFormat("CloseAllSellStopOrders(%s), count = %d",
                                  m_symbol, m_nSellStopOrderCount
                                  );
      LogInfo(logMsg);
      int nRet = 0;
      for(int i = m_nSellStopOrderCount - 1; i >= 0; i--)
      {
         DeleteOrder(m_sellStopOrder[i]);
      }
      
      return nRet;
    }
    
    int CloseAllSellMartinOrders()
    {
      int nRet = 0;
      for(int i = m_nSellMartinOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_sellMartinOrder[i]);
      }
      
      m_dSellMartinMostProfits = 0.0;
      m_dSellMartinLeastProfits = 0.0;
      m_dSellMartinPreProfits = 0;
      m_dSellMartinCurrentProfits = 0;
      
      return nRet;
    }
    
    int ResetProfitsData() {
      m_dBuyMostProfits = 0.0;
      m_dBuyLeastProfits = 0.0;
      m_dBuyPreProfits = 0;
      m_dBuyCurrentProfits = 0;
      
      m_dBuyMartinMostProfits = 0.0;
      m_dBuyMartinLeastProfits = 0.0;
      m_dBuyMartinPreProfits = 0;
      m_dBuyMartinCurrentProfits = 0;
      
      m_dSellMostProfits = 0.0;
      m_dSellLeastProfits = 0.0;
      m_dSellPreProfits = 0;
      m_dSellCurrentProfits = 0;
      
      m_dSellMartinMostProfits = 0.0;
      m_dSellMartinLeastProfits = 0.0;
      m_dSellMartinPreProfits = 0;
      m_dSellMartinCurrentProfits = 0;
      
      return 0;
    }
};