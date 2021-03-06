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
#define MARTIN_APPEND_MAX 10


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
   
   double m_dWholePreProfits;
   double m_dWholeCurrentProfits;
   double m_dWholeMostProfits;   
   
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
                   
                   dSL = dBid - iSL;
                   dTP = dBid + iTP;
                }
   
                  if (iType == OP_SELL || iType == OP_SELLSTOP)
                    {
                      dAsk = MarketInfo(Symbol(), MODE_ASK);
                      dBid = MarketInfo(Symbol(), MODE_BID);
                      
                      dSL = dAsk + iSL;
                      dTP = dAsk - iTP;
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
      string logMsg = StringFormat("计算点差：%s: %s - %s = %s",
                                  symbol, DoubleToString(dAsk, 5),
                                  DoubleToString(dBid, 5), DoubleToString(dSpread, 5));
      LogImportant(logMsg);
      
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
      
      m_dWholePreProfits = 0.0;
      m_dWholeCurrentProfits = 0.0;  
      m_dWholeMostProfits = 0.0;   
            
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
      string strProfits = StringFormat("获利:当前%s,最低%s,最高%s,移动止盈%s", 
                           DoubleToString(m_dBuyCurrentProfits + m_dBuyMartinCurrentProfits, 2),
                           DoubleToString(m_dBuyLeastProfits + m_dBuyMartinLeastProfits, 2),
                           DoubleToString(m_dBuyMostProfits + m_dBuyMartinMostProfits, 2), 
                           DoubleToString((m_dBuyMostProfits + m_dBuyMartinMostProfits) * (1 - BackwordForLong), 2));
      ShowText("ProfitsBuy", strProfits, clrYellow, xPos, yPos); 
      
      yPos++;   
      strOrders = StringFormat("【空方】订单数：%d，手数：%s", 
                     m_nSellOrderCount + m_nSellMartinOrderCount, 
                     DoubleToString(m_dSellLots + m_dSellMartinLots, 2));
      ShowText("OrderStatisticsSell", strOrders, clrYellow, xPos, yPos);
      
      yPos++;  
      strProfits = StringFormat("获利:当前%s,最低%s,最高%s,移动止盈%s", 
                           DoubleToString(m_dSellCurrentProfits + m_dSellMartinCurrentProfits, 2),
                           DoubleToString(m_dSellLeastProfits + m_dSellMartinLeastProfits, 2),
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
         // ShowText("OrderStatisticsBuyMartin", strProfits, clrYellow, xPos, yPos);
                        
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
      
      int nBuyStopOrderCount = 0;
      nBuyStopOrderCount = LoadOrders(m_symbol, OP_BUYSTOP, m_buyStopComment, m_nMagicNum, 
                                       m_buyStopOrder, nBuyStopOrderCount, m_dBuyStopLots );
      if(m_nBuyStopOrderCount != nBuyStopOrderCount) {
         // LoadBuyOrders();
         m_nBuyStopOrderCount = nBuyStopOrderCount;
      }
                                    
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
         // ShowText("OrderStatisticsSellMartin", strProfits, clrYellow, xPos, yPos);
                        
      }
      return m_nSellMartinOrderCount;
   }
   
   int LoadSellStopOrders()
   {
      string logMsg;
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos;
               
      CleanSellStopOrders();
      
      int nSellStopOrderCount = 0;
      nSellStopOrderCount = LoadOrders(m_symbol, OP_SELLSTOP, m_sellStopComment, m_nMagicNum, 
                                       m_sellStopOrder, nSellStopOrderCount, m_dSellStopLots );
      if(m_nSellStopOrderCount != nSellStopOrderCount) {
         // LoadSellOrders();
         m_nSellStopOrderCount = nSellStopOrderCount;
      }
                                       
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
      
      if(m_nBuyMartinOrderCount > 0) {
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
   
   bool CheckForAppendBuyMartinOrder(double & dRevertAppendSteps[], double dSpreadMax, 
                                       double dMaxHandlingLots, double dBackword) {
      string logMsg;
          
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendBuyMartinOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
         LogInfo(logMsg);
         return false;
      }
      
      if(m_dBuyLots + m_dBuyMartinLots >= dMaxHandlingLots) {
         return false;
      }
           
           
      if(m_nBuyMartinOrderCount >= MARTIN_APPEND_MAX) {
         logMsg = StringFormat("多方马丁订单数共%d, 超过最大数%d",
                                  m_nBuyMartinOrderCount,  MARTIN_APPEND_MAX);
         LogInfo(logMsg);
         return false;
      } 
          
      // 计算正常轮转多方订单的最高价格
      double lastBuyPrice = GetHighestPriceFromOrders(m_buyOrder, m_nBuyOrderCount);
      
      // 2020-04-21，如果有马丁单存在，则找到最后一笔马丁单的价格
      if(m_nBuyMartinOrderCount > 0) {
         // lastBuyPrice = m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_Prices;
         lastBuyPrice = GetLowestBuyMartinOrderPrice();
      }
      
      RefreshRates(); 
      double fAskPrice = MarketInfo(m_symbol, MODE_ASK);
      logMsg = StringFormat("多方马丁订单数(%s), %d",
                                  m_symbol, m_nSellMartinOrderCount);
      LogInfo(logMsg);      
      double dRevertAppendStep = dRevertAppendSteps[m_nBuyMartinOrderCount];
      logMsg = StringFormat("多方马丁加仓判断：(%s), current prise = %s, highestBuyPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fAskPrice, 5),
                                  DoubleToString(lastBuyPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
      LogInfo(logMsg);
      if(lastBuyPrice > 0 && lastBuyPrice - fAskPrice > dRevertAppendStep) {
         // 对于多方来讲，行情回撤，达到预设的回撤点位，满足加马丁仓条件
         logMsg = StringFormat("多方马丁加仓条件满足：(%s), current prise = %s, highestBuyPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fAskPrice, 5),
                                  DoubleToString(lastBuyPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
         LogInfo(logMsg);
        
         // 获取当前买单的盈利情况
         COrderInfo buyOrders[MAX_ORDER_COUNT];
         int nBuyOrderCount = 0;
         double dBuyLots = 0;
         nBuyOrderCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                          buyOrders, nBuyOrderCount, dBuyLots);
         int i = nBuyOrderCount - 1;
         if(i >= 0) {
            // 获取最近一笔买单的盈利情况
            double profits = GetProfitByTicket(buyOrders[i].m_Ticket,
                     buyOrders, nBuyOrderCount);
            
            if(profits < m_buyOrder[i].m_LeastProfits) {
               m_buyOrder[i].m_LeastProfits = profits;
            } 
            
            double movableProfits = m_buyOrder[i].m_LeastProfits * (1 - dBackword);
            logMsg = StringFormat("多方马丁加仓回撤条件判断(%s), pre = %s, current = %s, movable = %s",
                                  m_symbol, DoubleToString( m_buyOrder[i].m_Profits, 2),
                                  DoubleToString(profits, 2), 
                                  DoubleToString(movableProfits, 2)); 
            LogInfo(logMsg); 
            
            if(profits < 0) {
               if(profits > movableProfits
                  && m_buyOrder[i].m_Profits < movableProfits){
                     // 行情发生了反转
                     logMsg = StringFormat("多方马丁加仓回撤条件满足(%s), pre = %s, current = %s, movable = %s",
                                  m_symbol, DoubleToString( m_buyOrder[i].m_Profits, 2),
                                  DoubleToString(profits, 2), 
                                  DoubleToString(movableProfits, 2)); 
                     LogInfo(logMsg);
                     
                     // added, 2020-04-16,更新盈利数值
                     m_buyOrder[i].m_Profits = profits; 
                     return true;
               }
            }
            // added, 2020-04-16,更新盈利数值
            m_buyOrder[i].m_Profits = profits;
         }
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
      
      if(m_nSellMartinOrderCount > 0) {
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
   
   bool CheckForAppendSellMartinOrder(double & dRevertAppendSteps[], double dSpreadMax, 
                                       double dMaxHandlingLots, double dBackword) {
      string logMsg;
            
      double dSpread = GetSpread(m_symbol);
      if(dSpread >= dSpreadMax) {
         logMsg = StringFormat("CheckForAppendBuyMartinOrder(%s), spread out of range.(%s)",
                                  m_symbol, DoubleToString(dSpread, 4));
         LogInfo(logMsg);
         return false;
      }
      
      if(m_dSellLots + m_dSellMartinLots >= dMaxHandlingLots) {
         logMsg = StringFormat("空方马丁订单手数共%s,超过最大数%s",
                                  DoubleToString(m_dSellLots + m_dSellMartinLots, 2), DoubleToString(dMaxHandlingLots, 2));
         LogInfo(logMsg);
         return false;
      }
      
      if(m_nSellMartinOrderCount >= MARTIN_APPEND_MAX) {
         logMsg = StringFormat("空方马丁订单数共%d, 超过最大数%d",
                                  m_nSellMartinOrderCount,  MARTIN_APPEND_MAX);
         LogInfo(logMsg);
         return false;
      }
            
      // 计算正常轮转空方订单的最低价格
      double lastSellPrice = GetLowestPriceFromOrders(m_sellOrder, m_nSellOrderCount);
      
      // 2020-04-21，如果有马丁单存在，则找到最后一笔马丁单的价格
      if(m_nSellMartinOrderCount > 0) {
         // lastSellPrice = m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_Prices;
         lastSellPrice = GetHighestSellMartinOrderPrice();
      }
      
      RefreshRates();
      double fBidPrice = MarketInfo(m_symbol, MODE_BID);
      logMsg = StringFormat("空方马丁订单数(%s), %d",
                                  m_symbol, m_nSellMartinOrderCount);
      LogInfo(logMsg);
      double dRevertAppendStep = dRevertAppendSteps[m_nSellMartinOrderCount];
      logMsg = StringFormat("空方马丁加仓判断(%s), current prise = %s, lowestSellPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fBidPrice, 5),
                                  DoubleToString(lastSellPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
      LogInfo(logMsg);
      if(lastSellPrice > 0 && fBidPrice - lastSellPrice > dRevertAppendStep) {
         // 对于空方来讲，行情反弹，达到预设的回撤点位，满足加马丁仓条件
         logMsg = StringFormat("空方马丁加仓条件满足(%s), current prise = %s, lowestSellPrice = %s, dRevertAppendStep = %s",
                                  m_symbol, DoubleToString(fBidPrice, 5),
                                  DoubleToString(lastSellPrice, 5), 
                                  DoubleToString(dRevertAppendStep, 5));
         LogInfo(logMsg);
         
         // 获取当前卖单的盈利情况
         COrderInfo sellOrders[MAX_ORDER_COUNT];
         int nSellOrderCount = 0;
         double dSellLots = 0;
         nSellOrderCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                          sellOrders, nSellOrderCount, dSellLots);
         int i = nSellOrderCount - 1;
         if(i >= 0) {
            // 获取最近一笔卖单的盈利情况
            double profits = GetProfitByTicket(sellOrders[i].m_Ticket,
                     sellOrders, nSellOrderCount);
                     
            if(profits < m_sellOrder[i].m_LeastProfits) {
               m_sellOrder[i].m_LeastProfits = profits;
            } 
            
            double movableProfits = m_sellOrder[i].m_LeastProfits * (1 - dBackword);
            logMsg = StringFormat("空方马丁加仓回撤条件判断(%s), pre = %s, current = %s, movable = %s",
                                  m_symbol, DoubleToString( m_sellOrder[i].m_Profits, 2),
                                  DoubleToString(profits, 2), 
                                  DoubleToString(movableProfits, 2)); 
            LogInfo(logMsg);        
            if(profits < 0) {
               if(profits > movableProfits
                  && m_sellOrder[i].m_Profits < movableProfits){
                     // 行情发生了反转
                     logMsg = StringFormat("空方马丁加仓回撤条件满足(%s), pre = %s, current = %s, movable = %s",
                                  m_symbol, DoubleToString( m_sellOrder[i].m_Profits, 2),
                                  DoubleToString(profits, 2), 
                                  DoubleToString(movableProfits, 2)); 
                     LogInfo(logMsg);
                     // added, 2020-04-16,更新盈利数值
                     m_sellOrder[i].m_Profits = profits;
                     return true;
               }
            }
            
            // added, 2020-04-16,更新盈利数值
            m_sellOrder[i].m_Profits = profits;
         }
         
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
   
   double GetHighestBuyMartinOrderPrice() {
      double highestBuyPrice = GetHighestPriceFromOrders(m_buyMartinOrder, m_nBuyMartinOrderCount);
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
   
   double GetLowestSellMartinOrderPrice() {
      double lowestSellPrice = GetLowestPriceFromOrders(m_sellMartinOrder, m_nSellMartinOrderCount); 
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
  
   double GetMartinBuyLotsForStage2() {
      double lotsOfOrder0 = 0;
      double lotsOfOrderN = 0;
      if(m_nBuyMartinOrderCount > 0) {
         lotsOfOrder0 = m_buyMartinOrder[0].m_Lots; 
      }
      
      if(m_nBuyMartinOrderCount > 1) {
         lotsOfOrderN = m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_Lots;
      }
      return lotsOfOrder0 + lotsOfOrderN;
   }
   
   double GetMartinSellLotsForStage2() {
      double lotsOfOrder0 = 0;
      double lotsOfOrderN = 0;
      if(m_nSellMartinOrderCount > 0) {
         lotsOfOrder0 = m_sellMartinOrder[0].m_Lots; 
      }
      
      if(m_nSellMartinOrderCount > 1) {
         lotsOfOrderN = m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_Lots;
      }
      return lotsOfOrder0 + lotsOfOrderN;
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
         double profits = GetProfitByTicket(buyOrders[i].m_Ticket,
                  buyOrders, nBuyOrderCount);
         
         double movableProfits = m_buyOrder[i].m_MostProfits * (1 - dBackword);
         double priceDiff = fPrice - m_buyOrder[i].m_Prices;
         if(priceDiff > minPriceDiff
            && profits < movableProfits
            && m_buyOrder[i].m_Profits > movableProfits
            && profits > 0){
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
            
            if(profits < m_buyOrder[i].m_LeastProfits) {
               m_buyOrder[i].m_LeastProfits = profits;
            }
            
            logMsg = StringFormat("多方订单获利(%s, %d), 当前：%s，最大: %s, 最少: %s",
                                  m_symbol, m_buyOrder[i].m_Ticket,
                                  DoubleToString(m_buyOrder[i].m_Profits, 2), 
                                  DoubleToString(m_buyOrder[i].m_MostProfits, 2),
                                  DoubleToString( m_buyOrder[i].m_LeastProfits, 2));
            LogInfo(logMsg);  
            
            m_dBuyCurrentProfits += profits;
            m_dBuyMostProfits += m_buyOrder[i].m_MostProfits;
            m_dBuyLeastProfits += m_buyOrder[i].m_LeastProfits;
            
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
         double profits = GetProfitByTicket(sellOrders[i].m_Ticket,
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
            && m_sellOrder[i].m_Profits > movableProfits
            && profits > 0){
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
               // LogInfo(logMsg);
            }
            
            if(profits < m_sellOrder[i].m_LeastProfits) {
               m_sellOrder[i].m_LeastProfits = profits;
            }
            
            logMsg = StringFormat("空方订单获利(%s, %d), 当前：%s，最大: %s, 最少: %s",
                                  m_symbol, m_sellOrder[i].m_Ticket,
                                  DoubleToString(m_sellOrder[i].m_Profits, 2), 
                                  DoubleToString(m_sellOrder[i].m_MostProfits, 2),
                                  DoubleToString( m_sellOrder[i].m_LeastProfits, 2));
            LogInfo(logMsg); 
         
            m_dSellCurrentProfits += profits;
            m_dSellMostProfits += m_sellOrder[i].m_MostProfits;
            m_dSellLeastProfits += m_sellOrder[i].m_LeastProfits;
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
   
   double CalcCurrentBuyOrderProfitsLastN(int n) {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       orders, nCount, dLots);
                                       
      double fProfits = 0;
      if(nCount > 0 && nCount >= n) {
         for(int i = nCount - n; i < nCount; i++)
         {
            fProfits += orders[i].m_Profits;
         }         
      }
      return fProfits;
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
   
   double CalcCurrentSellOrderProfitsLastN(int n) {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       orders, nCount, dLots);
      double fProfits = 0;
      if(nCount > 0 && nCount >= n) {
         for(int i = nCount - n; i < nCount; i++)
         {
            fProfits += orders[i].m_Profits;
         }         
      }
      return fProfits;
   }
   
   double CalcCurrentSellMartinOrderProfits() {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_SELL, m_sellMartinComment, m_nMagicNumMartin, 
                                       orders, nCount, dLots);
      return CalcTotalProfits(orders, nCount);
   }
   
   double CalcCurrentBuyMartinOrderProfitsForStage2() {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNumMartin, 
                                       orders, nCount, dLots);
      double profits = 0;
      if(nCount > 0) {
         profits += orders[0].m_Profits;
      }
      
      if(nCount > 1) {
         profits += orders[nCount - 1].m_Profits;
      }
      
      return profits;
   }
   
   double CalcCurrentSellMartinOrderProfitsForStage2() {
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNumMartin, 
                                       orders, nCount, dLots);
      double profits = 0;
      if(nCount > 0) {
         profits += orders[0].m_Profits;
      }
      
      if(nCount > 1) {
         profits += orders[nCount - 1].m_Profits;
      }
      
      return profits;
   }
   
   
   bool CheckForCloseBuyMartinOrders(double minTakeProfit, double dBackword) {
      bool bClose = false;
      double dPreProfits = m_dBuyCurrentProfits + m_dBuyMartinCurrentProfits;
      double dCurrentBuyOrderProfits = CalcCurrentBuyOrderProfits();
      
      // 计算反方向（空方）订单的盈利情况
      // COrderInfo tempOrders[MAX_ORDER_COUNT];
      // int nCount = 0;
      // double dLots = 0;
      // nCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
      //                                  tempOrders, nCount, dLots);
      // double dCurrentSellOrderProfits = CalcTotalProfits(tempOrders, nCount);
      
      // if(nCount > 0) {
      //    dCurrentSellOrderProfits -= tempOrders[nCount - 1].m_Profits;
      // }
       
      double dCurrentBuyMartinOrderProfits = CalcCurrentBuyMartinOrderProfits();
      double dMostProfits = m_dBuyMostProfits + m_dBuyMartinMostProfits;
      
      //double dCurrentProfits = dCurrentBuyOrderProfits + dCurrentBuyMartinOrderProfits + dCurrentSellOrderProfits;
      
      double dCurrentProfits = dCurrentBuyOrderProfits + dCurrentBuyMartinOrderProfits;
      
      double dRealStandardProfits = MathMax(minTakeProfit, dMostProfits * (1 - dBackword));
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos + 2;
      string strPriceDiff = StringFormat("获利:前值%s,当前%s,最高%s,至少%s,移动止盈%s", 
                           DoubleToString(dPreProfits, 2),
                           DoubleToString(dCurrentProfits, 2),DoubleToString(dMostProfits, 2),
                           DoubleToString(minTakeProfit, 2),DoubleToString(dRealStandardProfits, 2));
      
      ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      string logMsg = StringFormat("CheckForCloseBuyMartinOrders：standard = %s, Pre = %s, Current = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentProfits, 2) );
      LogInfo(logMsg);
      if(dCurrentProfits > minTakeProfit)
      {        
         if(dPreProfits > dRealStandardProfits && dCurrentProfits <= dRealStandardProfits)
         {
            logMsg = StringFormat("CheckForCloseBuyMartinOrders OK：standard = %s, Pre = %s, Current = %s", 
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
      if(m_dBuyCurrentProfits < m_dBuyLeastProfits) {
         m_dBuyLeastProfits = m_dBuyCurrentProfits;
      }
      
      m_dBuyMartinCurrentProfits = dCurrentBuyMartinOrderProfits;
      if(m_dBuyMartinCurrentProfits > m_dBuyMartinMostProfits ) {
         m_dBuyMartinMostProfits = m_dBuyMartinCurrentProfits;
      }
      
      if(m_dBuyMartinCurrentProfits < m_dBuyMartinLeastProfits ) {
         m_dBuyMartinLeastProfits = m_dBuyMartinCurrentProfits;
      }
      
      if(bClose) {
         CloseAllBuyOrders();
         CleanBuyOrders();
         
         CloseAllBuyMartinOrders();
         CleanBuyMartinOrders();
         
         CloseAllSellStopOrders(); // 平掉之前的空方挂单
         CleanSellStopOrders();
         
         // 反方向的订单仅保留最近一笔，之前的都平掉
         // for(int i = nCount - 2; i >= 0; i--)
         // {
         //    CloseOrder(tempOrders[i]);
         // }
         
         LoadAllOrders();
      }
      return bClose;
   }
   
   bool CheckForCloseBuyMartinOrdersStage2(double minTakeProfit, double dBackword, int checkLastN) {
      bool bClose = false;
      if(m_nBuyMartinOrderCount < 2) {
         return false;
      }
      double dPreProfits = m_buyMartinOrder[0].m_Profits + m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_Profits;
      
      // 计算当前马丁单第一笔和最后一笔的获利情况
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNumMartin, 
                                       orders, nCount, dLots);
      double profits0 = 0;
      double profitsN = 0;
      if(nCount > 0) {
         profits0 = orders[0].m_Profits;
      }
      
      if(nCount > 1) {
         profitsN = orders[nCount - 1].m_Profits;
      }
             
      double dCurrentBuyMartinOrderProfits = profits0 + profitsN;
      double dMostProfits = m_buyMartinOrder[0].m_MostProfits + m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_MostProfits;
      
      // 2020-04-25, 计算顺势单最近N笔的获利情况
      double profitsLastN = CalcCurrentBuyOrderProfitsLastN(checkLastN);
      
      double dRealStandardProfits = MathMax(minTakeProfit, dMostProfits * (1 - dBackword));
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos + 2;
      string strPriceDiff = StringFormat("获利:前值%s,当前%s,最高%s,至少%s,移动止盈%s", 
                           DoubleToString(dPreProfits, 2),
                           DoubleToString(dCurrentBuyMartinOrderProfits, 2),DoubleToString(dMostProfits, 2),
                           DoubleToString(minTakeProfit, 2),DoubleToString(dRealStandardProfits, 2));
      
      ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      string logMsg = StringFormat("多方马丁单(二阶段)平仓条件：standard = %s, Pre = %s, Current = %s, profitsLastN = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentBuyMartinOrderProfits, 2), DoubleToString(profitsLastN, 2));
      LogInfo(logMsg);
      if(dCurrentBuyMartinOrderProfits > minTakeProfit && profitsLastN + dCurrentBuyMartinOrderProfits > 0)
      {        
         if(dPreProfits > dRealStandardProfits && dCurrentBuyMartinOrderProfits <= dRealStandardProfits)
         {
            logMsg = StringFormat("多方马丁单(二阶段)平仓条件满足：standard = %s, Pre = %s, Current = %s, profitsLastN = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentBuyMartinOrderProfits, 2), DoubleToString(profitsLastN, 2));
            LogInfo(logMsg);
            bClose = true;
         }          
      }     
     
      m_buyMartinOrder[0].m_Profits = profits0;
      m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_Profits = profitsN;
      
      if(profits0 > m_buyMartinOrder[0].m_MostProfits) {
         m_buyMartinOrder[0].m_MostProfits = profits0;
      }
      
      if(profitsN > m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_MostProfits) {
         m_buyMartinOrder[m_nBuyMartinOrderCount - 1].m_MostProfits = profitsN;
      }
      
       
      if(bClose) {
         CloseOrder(m_buyMartinOrder[0]);
         CloseOrder(m_buyMartinOrder[m_nBuyMartinOrderCount - 1]);
         
         // 2020-04-25, 平掉顺势订单的最近N笔订单
         CloseBuyOrdersLastN(checkLastN);
         
         CleanBuyMartinOrders();
         
         CleanBuyOrders();
         LoadBuyOrders();
         LoadBuyMartinOrders();
      }
      return bClose;
   }
   
   bool CheckForCloseBuyMartinOrdersStage3(double minTakeProfit) {
      bool bClose = false;
      if(m_nBuyOrderCount < 2) {
         return false;
      }
      double dPreProfits = m_buyOrder[0].m_Profits + m_buyOrder[m_nBuyOrderCount - 1].m_Profits;
      
      // 计算当前马丁单第一笔和最后一笔的获利情况
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
                                       orders, nCount, dLots);
      double profits0 = 0;
      double profitsN = 0;
      if(nCount > 0) {
         profits0 = orders[0].m_Profits;
      }
      
      if(nCount > 1) {
         profitsN = orders[nCount - 1].m_Profits;
      }
             
      double dCurrentBuyMartinOrderProfits = profits0 + profitsN;
      double dMostProfits = m_buyOrder[0].m_MostProfits + m_buyOrder[m_nBuyOrderCount - 1].m_MostProfits;
      
      // 2020-04-25, 计算顺势单最近N笔的获利情况
      double profitsLastN = 0;//CalcCurrentBuyOrderProfitsLastN(checkLastN);
      
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos + 2;
      string strPriceDiff = StringFormat("获利:前值%s,当前%s,固定止盈%s", 
                           DoubleToString(dPreProfits, 2),
                           DoubleToString(dCurrentBuyMartinOrderProfits, 2),
                           DoubleToString(minTakeProfit, 2));
      
      ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      
      if(dCurrentBuyMartinOrderProfits > minTakeProfit)
      {        
         bClose = true;          
      }     
     
      m_buyOrder[0].m_Profits = profits0;
      m_buyOrder[m_nBuyOrderCount - 1].m_Profits = profitsN;
      
      if(profits0 > m_buyOrder[0].m_MostProfits) {
         m_buyOrder[0].m_MostProfits = profits0;
      }
      
      if(profitsN > m_buyOrder[m_nBuyOrderCount - 1].m_MostProfits) {
         m_buyOrder[m_nBuyOrderCount - 1].m_MostProfits = profitsN;
      }
      
       
      if(bClose) {
         CloseOrder(m_buyOrder[0]);
         CloseOrder(m_buyOrder[m_nBuyOrderCount - 1]);
         
         CleanBuyOrders();
         LoadBuyOrders();
        
      }
      return bClose;
   }
   
   bool CheckForCloseSellMartinOrders(double minTakeProfit, double dBackword) {
      bool bClose = false;
      double dPreProfits = m_dSellCurrentProfits + m_dSellMartinCurrentProfits;
      double dCurrentSellOrderProfits = CalcCurrentSellOrderProfits();
      double dCurrentSellMartinOrderProfits = CalcCurrentSellMartinOrderProfits();
     
      // 计算反方向（空方）订单的盈利情况
      // COrderInfo tempOrders[MAX_ORDER_COUNT];
      // int nCount = 0;
      // double dLots = 0;
      // nCount = LoadOrders(m_symbol, OP_BUY, m_buyComment, m_nMagicNum, 
      //                                  tempOrders, nCount, dLots);
      // double dCurrentBuyOrderProfits = CalcTotalProfits(tempOrders, nCount);
      
      // if(nCount > 0) {
         // dCurrentBuyOrderProfits -= tempOrders[nCount - 1].m_Profits;
      // }
      
      // double dCurrentProfits = dCurrentSellOrderProfits + dCurrentSellMartinOrderProfits + dCurrentBuyOrderProfits;
      
      double dCurrentProfits = dCurrentSellOrderProfits + dCurrentSellMartinOrderProfits;
      
      double dMostProfits = m_dSellMostProfits + m_dSellMartinMostProfits;
      double dRealStandardProfits = MathMax(minTakeProfit, dMostProfits * (1 - dBackword));
      int xPos = m_xBuyBasePos;
      int yPos = m_yBuyBasePos + 4;
      string strPriceDiff = StringFormat("获利:前值:%s,当前%s,最高%s,至少%s,移动止盈%s", 
                           DoubleToString(dPreProfits, 2),
                           DoubleToString(dCurrentProfits, 2),DoubleToString(dMostProfits, 2), 
                           DoubleToString(minTakeProfit, 2), DoubleToString(dRealStandardProfits, 2));
      
      ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos); 
      string logMsg = StringFormat("CheckForCloseSellMartinOrders：standard = %s, Pre = %s, Current = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentProfits, 2) );
      LogInfo(logMsg);
      if(dCurrentProfits > minTakeProfit)
      {        
         if(dPreProfits > dRealStandardProfits && dCurrentProfits <= dRealStandardProfits)
         {
            logMsg = StringFormat("CheckForCloseSellMartinOrders OK：standard = %s, Pre = %s, Current = %s", 
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
      
      if(m_dSellCurrentProfits < m_dSellLeastProfits) {
         m_dSellLeastProfits = m_dSellCurrentProfits;
      }
      
      m_dSellMartinCurrentProfits = dCurrentSellMartinOrderProfits;
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
         
         // 反方向的订单仅保留最近一笔，之前的都平掉
         // for(int i = nCount - 2; i >= 0; i--)
         // {
         //    CloseOrder(tempOrders[i]);
         // }
         
         LoadAllOrders();
      }
      
      return bClose;
   }
   
   bool CheckForCloseSellMartinOrdersStage2(double minTakeProfit, double dBackword, int checkLastN) {
      bool bClose = false;
      if(m_nSellMartinOrderCount < 2) {
         return false;
      }
      double dPreProfits = m_sellMartinOrder[0].m_Profits + m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_Profits;
      
      // 计算当前马丁单第一笔和最后一笔的获利情况
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNumMartin, 
                                       orders, nCount, dLots);
      double profits0 = 0;
      double profitsN = 0;
      if(nCount > 0) {
         profits0 = orders[0].m_Profits;
      }
      
      if(nCount > 1) {
         profitsN = orders[nCount - 1].m_Profits;
      }
             
      double dCurrentSellMartinOrderProfits = profits0 + profitsN;
      double dMostProfits = m_sellMartinOrder[0].m_MostProfits + m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_MostProfits;
      
      // 2020-04-25, 计算顺势单最近N笔的获利情况
      double profitsLastN = CalcCurrentSellOrderProfitsLastN(checkLastN);
      
      double dRealStandardProfits = MathMax(minTakeProfit, dMostProfits * (1 - dBackword));
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos + 2;
      string strPriceDiff = StringFormat("获利:前值%s,当前%s,最高%s,至少%s,移动止盈%s", 
                           DoubleToString(dPreProfits, 2),
                           DoubleToString(dCurrentSellMartinOrderProfits, 2),DoubleToString(dMostProfits, 2),
                           DoubleToString(minTakeProfit, 2),DoubleToString(dRealStandardProfits, 2));
      
      ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos); 
      string logMsg = StringFormat("空方马丁单(二阶段)平仓条件：standard = %s, Pre = %s, Current = %s, profitsLastN = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentSellMartinOrderProfits, 2), DoubleToString(profitsLastN, 2));
      LogInfo(logMsg);
      if(dCurrentSellMartinOrderProfits > minTakeProfit 
         && profitsLastN + dCurrentSellMartinOrderProfits > 0)
      {        
         if(dPreProfits > dRealStandardProfits && dCurrentSellMartinOrderProfits <= dRealStandardProfits)
         {
            logMsg = StringFormat("空方马丁单(二阶段)平仓条件满足：standard = %s, Pre = %s, Current = %s, profitsLastN = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(dPreProfits, 2), 
                     DoubleToString(dCurrentSellMartinOrderProfits, 2), DoubleToString(profitsLastN, 2));
            LogInfo(logMsg);
            bClose = true;
         }          
      }     
     
      m_sellMartinOrder[0].m_Profits = profits0;
      m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_Profits = profitsN;
      
      if(profits0 > m_sellMartinOrder[0].m_MostProfits) {
         m_sellMartinOrder[0].m_MostProfits = profits0;
      }
      
      if(profitsN > m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_MostProfits) {
         m_sellMartinOrder[m_nSellMartinOrderCount - 1].m_MostProfits = profitsN;
      }
      
       
      if(bClose) {
         CloseOrder(m_sellMartinOrder[0]);
         CloseOrder(m_sellMartinOrder[m_nSellMartinOrderCount - 1]);
         
         // 2020-04-25, 平掉顺势订单的最近N笔订单
         CloseSellOrdersLastN(checkLastN);
         
         CleanSellMartinOrders();
         
         CleanSellOrders();
         LoadSellOrders();
         LoadSellMartinOrders();
      }
      return bClose;
   }
   
   bool CheckForCloseSellMartinOrdersStage3(double minTakeProfit) {
      bool bClose = false;
      if(m_nSellOrderCount < 2) {
         return false;
      }
      double dPreProfits = m_sellOrder[0].m_Profits + m_sellOrder[m_nSellOrderCount - 1].m_Profits;
      
      // 计算当前马丁单第一笔和最后一笔的获利情况
      COrderInfo orders[MAX_ORDER_COUNT];
      int nCount = 0;
      double dLots = 0;
      nCount = LoadOrders(m_symbol, OP_SELL, m_sellComment, m_nMagicNum, 
                                       orders, nCount, dLots);
      double profits0 = 0;
      double profitsN = 0;
      if(nCount > 0) {
         profits0 = orders[0].m_Profits;
      }
      
      if(nCount > 1) {
         profitsN = orders[nCount - 1].m_Profits;
      }
             
      double dCurrentSellMartinOrderProfits = profits0 + profitsN;
      double dMostProfits = m_sellOrder[0].m_MostProfits + m_sellOrder[m_nSellOrderCount - 1].m_MostProfits;
      
      // 2020-04-25, 计算顺势单最近N笔的获利情况
      double profitsLastN = 0;//CalcCurrentSellOrderProfitsLastN(checkLastN);
      
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos;
      string strPriceDiff = StringFormat("获利:前值%s,当前%s,固定止盈%s", 
                           DoubleToString(dPreProfits, 2),
                           DoubleToString(dCurrentSellMartinOrderProfits, 2),
                           DoubleToString(minTakeProfit, 2));
      
      ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos); 
     
      if(dCurrentSellMartinOrderProfits > minTakeProfit)
      {        
         bClose = true;          
      }     
     
      m_sellOrder[0].m_Profits = profits0;
      m_sellOrder[m_nSellOrderCount - 1].m_Profits = profitsN;
      
      if(profits0 > m_sellOrder[0].m_MostProfits) {
         m_sellOrder[0].m_MostProfits = profits0;
      }
      
      if(profitsN > m_sellOrder[m_nSellOrderCount - 1].m_MostProfits) {
         m_sellOrder[m_nSellOrderCount - 1].m_MostProfits = profitsN;
      }
      
       
      if(bClose) {
         CloseOrder(m_sellOrder[0]);
         CloseOrder(m_sellOrder[m_nSellOrderCount - 1]);
         
         CleanSellOrders();
         LoadSellOrders();
      }
      return bClose;
   }
   
   bool CheckForWholeCloseOrders(double minProfits, bool enableMovableProfit, double dBackward) {
   
      m_dWholePreProfits = m_dWholeCurrentProfits;
      
      //计算所有多单的盈利情况
      double dBuyWholePreProfits = m_dBuyCurrentProfits + m_dBuyMartinCurrentProfits;
      double dCurrentBuyOrderProfits = CalcCurrentBuyOrderProfits();
      double dCurrentBuyMartinOrderProfits = CalcCurrentBuyMartinOrderProfits();
      double dCurrentBuyWholeProfits = dCurrentBuyOrderProfits + dCurrentBuyMartinOrderProfits;
      
      //计算所有空单的盈利情况
      double dSellWholePreProfits = m_dSellCurrentProfits + m_dSellMartinCurrentProfits;
      double dCurrentSellOrderProfits = CalcCurrentSellOrderProfits();
      double dCurrentSellMartinOrderProfits = CalcCurrentSellMartinOrderProfits();
      double dCurrentSellWholeProfits = dCurrentSellOrderProfits + dCurrentSellMartinOrderProfits;
      
      m_dWholeCurrentProfits = dCurrentBuyWholeProfits + dCurrentSellWholeProfits;
           
      double movableProfits = m_dWholeMostProfits * (1 - dBackward);
      string logMsg = StringFormat("CheckForWholeCloseOrders(%s): movable: %d, pre: %s, current: %s, most: %s, movable: %s",
                                  m_symbol, enableMovableProfit,
                                  DoubleToString(m_dWholePreProfits, 2), 
                                  DoubleToString(m_dWholeCurrentProfits, 2),
                                  DoubleToString(m_dWholeMostProfits, 2),
                                  DoubleToString(movableProfits, 2));
      LogInfo(logMsg); 
            
      if(enableMovableProfit) {
         if(m_dWholeCurrentProfits >= minProfits 
            && m_dWholePreProfits > movableProfits
            && m_dWholeCurrentProfits < movableProfits) {
               return true;
            }
            
      } else {
         if(m_dWholeCurrentProfits >= minProfits) {
            return true;
         }
      }
      
      return false;
   }
   
   bool CheckForAutoCloseAll(double baseBalance, double preEquity, double leaseEquity,
                            double mostEquity, double realTargetEquity) {
      double currentEquity = AccountEquity(); // 净值
      int xPos = m_xSellBasePos;
      int yPos = m_ySellBasePos + 1;
      string strAutoCloseAll = StringFormat("净值：本金:%s,当前:%s", 
               DoubleToString(baseBalance, 2),
               DoubleToString(currentEquity, 2));
      ShowText("AutoCloseAll1", strAutoCloseAll, clrYellow, xPos, yPos);   
      
      strAutoCloseAll = StringFormat("最低:%s,最高:%s,止盈:%s", 
               DoubleToString(leaseEquity, 2),
               DoubleToString(mostEquity, 2),
               DoubleToString(realTargetEquity, 2));
      ShowText("AutoCloseAll2", strAutoCloseAll, clrYellow, xPos, yPos + 1);     
           
      if(currentEquity > baseBalance && preEquity > realTargetEquity && currentEquity <= realTargetEquity) {
         return true;
      }
      return false;
    }
    
    bool CheckForAutoStopLossAll(double realTargetEquity) {
      double currentEquity = AccountEquity(); // 净值
           
      if(currentEquity < realTargetEquity) {
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
      
      CloseAllBuyStopOrders(); // 平掉之前的多方挂单
      CloseAllSellStopOrders(); // 平掉之前的空方挂单
      
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
    
    int CloseBuyOrdersLastN(int n)
    {
      int nRet = 0;
      if(m_nBuyOrderCount > 0 && m_nBuyOrderCount >= n) {
         for(int i = m_nBuyOrderCount - n; i < m_nBuyOrderCount; i++)
         {
            CloseOrder(m_buyOrder[i]);
         }
         m_dBuyMostProfits = 0.0;
         m_dBuyLeastProfits = 0.0;
         m_dBuyPreProfits = 0;
         m_dBuyCurrentProfits = 0;
      }
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
    
    int CloseSellOrdersLastN(int n)
    {
      int nRet = 0;
      if(m_nSellOrderCount > 0 && m_nSellOrderCount >= n) {
         for(int i = m_nSellOrderCount - n; i < m_nSellOrderCount; i++)
         {
            CloseOrder(m_sellOrder[i]);
         }
         
         m_dSellMostProfits = 0.0;
         m_dSellLeastProfits = 0.0;
         m_dSellPreProfits = 0;
         m_dSellCurrentProfits = 0;
      }
      
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