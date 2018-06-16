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

class CMartinOrder
{
public:
   int m_nTimeFrame;
   int m_nDirect;
   string m_strDirect;
   int m_nOrderCount;
   double m_dLots;
   string m_symbol; 
   string m_comment;
   int m_nMagicNum;
   double m_dBaseOpenLots;
   double m_dMultiple;
   double m_dMultipleFactor;
   int m_nMaxOrderCount;
   
   double m_dMostProfits;
   double m_dPreProfits;
   double m_dCurrentProfits;
   
   double m_dLeastProfits;
   
   int m_nLoopCount;
   
   COrderInfo m_orderInfo[MAX_ORDER_COUNT];
   
   int m_nOrderProtectingStartingPoint;
   bool m_bExistOrderProtecting;
   COrderInfo m_orderProtecting;
   string m_commentProtecting;
   double m_dPriceProtectingLine;
   double m_dPrePriceAfterProtecting;
   double m_dHiPriceAfterProtecting;
   double m_dLoPriceAfterProtecting;
     
private:
   int m_xBasePos;
   int m_yBasePos;
   
public:
   CMartinOrder(string symbol, int nDirect, 
               int nTimeFrame, double dBaseOpenLots, double dMultiple, double dMultipleFactor, int nMaxOrderCount,
               int nOrderProtectingStartingPoint) 
   {
      m_nDirect = nDirect;
      m_nOrderCount = 0;
      m_dLots = 0.0;
      m_symbol = symbol;
      m_nTimeFrame = nTimeFrame;
      m_dBaseOpenLots = dBaseOpenLots;
      m_dMultiple = dMultiple;
      m_dMultipleFactor = dMultipleFactor;
      m_nMaxOrderCount = nMaxOrderCount;
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      m_nLoopCount = 0;
      m_nOrderProtectingStartingPoint = nOrderProtectingStartingPoint;
      m_dPriceProtectingLine = 0;
      m_dPrePriceAfterProtecting = 0;
      m_bExistOrderProtecting = 0;
           
      if(nDirect == OP_BUY)
      {
         m_comment = "MBuy";
         m_commentProtecting = "MBuyP";
         m_strDirect = "MBuy";
         m_nMagicNum = 30000;
         m_xBasePos = 0;
         m_yBasePos = 0;
      }else
      {
         m_comment = "MSell";
         m_commentProtecting = "MSellP";
         m_strDirect = "MSell";
         m_nMagicNum = 40000;
         m_xBasePos = 0;
         m_yBasePos = 5;
      }
   }
   
   void CleanOrders() 
   {
      int i = 0;
      for(i = 0; i < m_nOrderCount; i++)
      {
         m_orderInfo[i].clear();
      }
      m_nOrderCount = 0;
   }
   
   int GetLoopCount() {
      return m_nLoopCount;
   }
   
   int LoadAllOrders()
   {
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos;
      if(m_nDirect == OP_BUY) {
         string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
         ShowText("Version", strVersion, clrYellow, xPos, yPos);
      }
          
      CleanOrders();
        
      m_nOrderCount = LoadOrders(m_symbol, m_nDirect, m_comment, m_nMagicNum, 
                                       m_orderInfo, m_nOrderCount, m_dLots );
      if(m_nOrderCount > 0)
      {
         logMsg = StringFormat("%s => Symbo = %s, orderType = %d(%s), comment = %s, orderCount = %d, Lots = %s ",
                                  __FUNCTION__, m_symbol, m_nDirect, m_strDirect,
                                  m_comment, m_nOrderCount, DoubleToString(m_dLots, 2));
         //OutputLog(logMsg);
         
            
         logMsg = StringFormat("%s => SubSymbo = %s, lastOrderPrice = %s, lastLots = %s ",
                                     __FUNCTION__, m_symbol, DoubleToString(m_orderInfo[m_nOrderCount - 1].m_Prices, 5), 
                                     DoubleToString(m_orderInfo[m_nOrderCount - 1].m_Lots, 2));
         //OutputLog(logMsg);
         double  dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
         
         m_dPreProfits = m_dCurrentProfits;
         m_dCurrentProfits = dProfits;
         if(m_dCurrentProfits > m_dMostProfits) 
         {
            m_dMostProfits = m_dCurrentProfits;
         }
         
         if(m_dCurrentProfits < m_dLeastProfits) 
         {
            m_dLeastProfits = m_dCurrentProfits;
         }  
           
         // 获取保护仓订单信息
         COrderInfo orderInfo[MAX_ORDER_COUNT];
         int nDirect = OP_BUY;
         if(m_nDirect == OP_BUY) {
            nDirect = OP_SELL;
         }
         int nOrderCount = 0;
         double lots = 0;
         int nProtectingOrderCount = 0;
         LoadOrders(m_symbol, nDirect, m_comment, m_nMagicNum, 
                                          orderInfo, nProtectingOrderCount, lots );
         if(nProtectingOrderCount > 0) {
             m_bExistOrderProtecting = true;
             m_orderProtecting.m_Symbol = orderInfo[0].m_Symbol;
             m_orderProtecting.m_Ticket =orderInfo[0].m_Ticket;
             m_orderProtecting.m_OrderType = orderInfo[0].m_OrderType;
             m_orderProtecting.m_Lots = orderInfo[0].m_Lots;
             m_orderProtecting.m_Prices = orderInfo[0].m_Prices;
             m_orderProtecting.m_StopLoss = orderInfo[0].m_StopLoss;
             m_orderProtecting.m_TakeProfit = orderInfo[0].m_TakeProfit;
             m_orderProtecting.m_Comment = orderInfo[0].m_Comment;
             m_orderProtecting.m_Magic = orderInfo[0].m_Magic;
             m_orderProtecting.m_TradeTime = orderInfo[0].m_Magic;
             m_orderProtecting.m_Profits = orderInfo[0].m_Profits;
         }
                
         yPos++;
         string strProfits;
         if(m_nDirect == OP_BUY)
         {
            strProfits = StringFormat("【多方】订单数：%d，手数：%s，轮数：%d", 
                     m_nOrderCount, DoubleToString(m_dLots, 2), m_nLoopCount);
            ShowText("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
            
            strProfits = StringFormat("【保护】手数：%s", 
                     m_orderProtecting.m_Lots);
            ShowText("OrderStatisticsBuyProtecting", strProfits, clrYellow, xPos, yPos);
         }else
         {
            strProfits = StringFormat("【空方】订单数：%d，手数：%s，轮数：%d", 
                     m_nOrderCount, DoubleToString(m_dLots, 2), m_nLoopCount);
            ShowText("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
            
            strProfits = StringFormat("【保护】手数：%s", 
                     m_orderProtecting.m_Lots);
            ShowText("OrderStatisticsSellProtecting", strProfits, clrYellow, xPos, yPos);
          }
                 
      }
      return m_nOrderCount;
   }
   
   bool isInProtectingMode() {
      return m_nOrderCount >= m_nOrderProtectingStartingPoint;
   }
   
   int Fib(int n)
   {
      return n < 2 ? 1 : (Fib(n-1) + Fib(n-2));
   }
   
   int OpenOrdersMicro()
   {
       double accMargin =  AccountMargin();//AccountMargin();
       double equity = AccountEquity();
         
       if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
       
       double dLots = 0.01;//NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, nOrderCnt) * MathPow(m_dMultipleFactor, nOrderCnt), 2);
                 
      // 当现有的订单数超过5时，不在做指数级加仓，仅仅做等量加仓
      // if(nOrderCnt >= 5) {
      //   dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, 5) * MathPow(m_dMultipleFactor, 5), 2);
      //}
      
      double dCurrentPrice = 0;
      RefreshRates();
      if(m_nDirect == OP_BUY)
      {
         dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
      } else {
         dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
      }
      string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPrice, 4));
      OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
      
      return 0;
   }
   
   int OpenOrders()
   {
      double accMargin = AccountMargin();
      double equity = AccountEquity();
      if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
       
      if(m_nOrderCount < m_nMaxOrderCount)
      {
         int fib = Fib(m_nOrderCount + 1);
         double dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nOrderCount) * MathPow(m_dMultipleFactor, m_nOrderCount), 2);
         
         // 当现有的订单数超过保护起点时，不在做指数级加仓，仅仅做等量加仓
         if(m_nOrderCount >= m_nOrderProtectingStartingPoint) {
            dLots = NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, m_nOrderProtectingStartingPoint) * MathPow(m_dMultipleFactor, m_nOrderProtectingStartingPoint), 2);
         }
         
         if(m_nOrderCount > 0)
         {
           string logMsg = StringFormat("Append: Direct = %s, lots = %s",
                               OpName[m_nDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }else 
         {
            string logMsg = StringFormat("New: Direct = %s, lots = %s",
                               OpName[m_nDirect], DoubleToString(dLots, 2));
            LogInfo(logMsg);
         }
         
         double dCurrentPrice = 0;
         RefreshRates();
         if(m_nDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价          
           dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
         }else {
            // 此时需要获取两种货币对的卖价          
           dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
         }
         string comment = StringFormat("%s(%s)", m_comment, DoubleToString(dCurrentPrice, 4));
         OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
         
         OpenProtectingOrder(dLots + m_dLots);
         
      }
      return 0;
   }

   void OpenProtectingOrder(double dLots) {
      if(m_nOrderCount >= m_nOrderProtectingStartingPoint && !m_bExistOrderProtecting) {
            // 启动保护仓模式
            int nDirect = OP_BUY;
            if(m_nDirect == OP_BUY)
            {
              nDirect = OP_SELL;
            }
            double dCurrentPrice = 0;            
            if(nDirect == OP_BUY)
            {
               // 此时需要获取两种货币对的卖价          
               dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
            }else {
               // 此时需要获取两种货币对的卖价          
               dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
            }
            m_dPrePriceAfterProtecting = dCurrentPrice;
                       
            string comment = StringFormat("%s(%s)", m_commentProtecting, DoubleToString(dCurrentPrice, 4));
            OpenOrder(m_symbol, nDirect, dLots, m_commentProtecting, m_nMagicNum);
            m_bExistOrderProtecting = true;            
       }
   }
   
   void CloseProtectingOrder() {
      CloseOrder(m_orderProtecting);
      m_bExistOrderProtecting = false;    
   }
   
   void ProcessProtectingOrder() {
      int nDirect = OP_BUY;
      RefreshRates();
      double dCurrentPrice = Close[0];
      if(m_nDirect == OP_BUY)
      {
        // dCurrentPriceForMain = MarketInfo(m_symbol, MODE_BID);
        
        // 保护仓的方向与主方向相反
        nDirect = OP_SELL;
        // 这时，需要获取保护仓所SELL订单的ASK价格          
        // dCurrentPriceForProtecting = MarketInfo(m_symbol, MODE_ASK);
      }else {
        // dCurrentPriceForMain = MarketInfo(m_symbol, MODE_ASK);
        // 保护仓的方向与主方向相反
        nDirect = OP_BUY; 
        // 这时，需要获取保护仓所SELL订单的BID价格
        // dCurrentPriceForProtecting = MarketInfo(m_symbol, MODE_BID);
      }
         
      if(m_bExistOrderProtecting) {        
          m_dHiPriceAfterProtecting = MathMax(m_dHiPriceAfterProtecting, dCurrentPrice);
          m_dLoPriceAfterProtecting = MathMin(m_dLoPriceAfterProtecting, dCurrentPrice);
          
          if(m_nDirect == OP_BUY) {
             // 主订单方向为多方
             if(m_dPriceProtectingLine > 0) {
                // 价格保护线已经存在（说明以前经历过反转行情，已经平掉过保护仓）
                if(dCurrentPrice > m_dPriceProtectingLine) {
                   // 当前的价格与价格保护线相比，高，那么平掉保护仓
                   CloseProtectingOrder();
                 }
             } else {
                // 价格保护线不存在（说明以前没有经历过反转行情，从未平掉过保护仓）
                if(dCurrentPrice > GetPriceLastOrder()) {
                    // 当前价格与最近一次订单的价格比较，高，那么平掉保护仓
                    CloseProtectingOrder();
                } else { 
                    double dCloseProtectingPriceStd = m_dLoPriceAfterProtecting + 0.001;
                    if(dCurrentPrice > dCloseProtectingPriceStd) {
                         // 行情反转，达到平掉保护仓的条件
                         CloseProtectingOrder();
                         
                         // 设置新的价格保护线                      
                         m_dPriceProtectingLine = dCloseProtectingPriceStd;
                     }  
                 }                
            } 
          } else {
               // 主订单方向为空方
             if(m_dPriceProtectingLine > 0) {
                // 价格保护线已经存在（说明以前经历过反转行情，已经平掉过保护仓）
                if(dCurrentPrice < m_dPriceProtectingLine) {
                   // 当前的价格与价格保护线相比，低，那么平掉保护仓
                   CloseProtectingOrder();
                 }
             } else {
                // 价格保护线不存在（说明以前没有经历过反转行情，从未平掉过保护仓）
                if(dCurrentPrice < GetPriceLastOrder()) {
                    // 当前价格与最近一次订单的价格比较，低，那么平掉保护仓
                    CloseProtectingOrder();
                } else { 
                    double dCloseProtectingPriceStd = m_dHiPriceAfterProtecting - 0.001;
                    if(dCurrentPrice < dCloseProtectingPriceStd) {
                         // 行情反转，达到平掉保护仓的条件
                         CloseProtectingOrder();
                         
                         // 设置新的价格保护线                      
                         m_dPriceProtectingLine = dCloseProtectingPriceStd;
                     }  
                 }                
            } 
         }
      } else {
         if(isInProtectingMode()) {
            // 有两种情况：
            // 1. 价格跨越了最近一次订单的价格
            // 2. 价格跨越了价格保护线的价格
            if(m_nDirect == OP_BUY) {
               if(m_dPriceProtectingLine > 0) {
                   // 价格保护线已经存在（说明以前经历过反转行情，已经平掉过保护仓）
                   if(dCurrentPrice < m_dPriceProtectingLine) {
                      // 从上往下穿过价格保护线，当前的价格与价格保护线相比，低，那么开保护仓
                      OpenProtectingOrder(m_dLots);
                   }
               }else {
                   // 价格保护线不存在（说明以前没有经历过反转行情，从未平掉过保护仓）
                   if(dCurrentPrice < GetPriceLastOrder()) {
                       // 从上往下穿过最近一次订单的价格，当前价格与最近一次订单的价格比较，低，那么开保护仓
                       OpenProtectingOrder(m_dLots);
                   }
                  
               }
            }else {
               if(m_dPriceProtectingLine > 0) {
                   // 价格保护线已经存在（说明以前经历过反转行情，已经平掉过保护仓）
                   if(dCurrentPrice > m_dPriceProtectingLine) {
                      // 从下往上穿过价格保护线，当前的价格与价格保护线相比，高，那么开保护仓
                      OpenProtectingOrder(m_dLots);
                   }
               }else {
                   // 价格保护线不存在（说明以前没有经历过反转行情，从未平掉过保护仓）
                   if(dCurrentPrice > GetPriceLastOrder()) {
                       // 从下往上穿过最近一次订单的价格，当前价格与最近一次订单的价格比较，高，那么开保护仓
                       OpenProtectingOrder(m_dLots);
                   }               
               }            
            }      
         }
      }
   }
   
   // 双向套利平仓条件
   bool CheckForClose(double dOffset, double dProfitsSetting, double dBackword)
   {
      if(m_nOrderCount <= 1)
      {
         // return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
         // 单笔订单，只检查价格差
         // CheckForCloseByProfits(0, dBackword);
         
         // 2018-06-11, 改为既检查价格差，也检查获利情况 
         // return CheckForCloseByOffset(dOffset)
         return CheckForCloseByOffset(dOffset) && CheckForCloseByProfits(0, dBackword);
      }else
      {
         return  CheckForCloseByProfits(dProfitsSetting, dBackword);
      }
      
   }
   
   bool CheckForCloseByProfits(double dProfitsSetting, double dBackword)
   {
      bool bRet = false;
      double dRealStandardProfits = MathMax(dProfitsSetting, m_dMostProfits * (1 - dBackword));
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 2;
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s, 移动止盈 %s", 
                           DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dMostProfits, 2), 
                           DoubleToString(dRealStandardProfits, 2));
      if(m_nDirect == OP_BUY) {
         ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      }else
      {
         ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos);  
      }
      if(m_dCurrentProfits > dProfitsSetting)
      {        
         if(m_dPreProfits > dRealStandardProfits && m_dCurrentProfits <= dRealStandardProfits)
         {
            string logMsg = StringFormat("CheckForCloseByProfits：standard = %s, Pre = %s, Current = %s", 
                     DoubleToString(dRealStandardProfits, 2), DoubleToString(m_dPreProfits, 2), 
                     DoubleToString(m_dCurrentProfits, 2) );
            LogInfo(logMsg);
            bRet = true;
         }          
      }     
           
      return bRet;
   }
   
   double GetPriceLastOrder() {
      double dPriceLastOrder = 0;
      if(m_nOrderCount > 0) {
         // 获取最近一次订单的货币对的价格
         dPriceLastOrder = m_orderInfo[m_nOrderCount - 1].m_Prices;
      }
      return dPriceLastOrder;
   }
   
   bool CheckForCloseByOffset(double dOffset)
   {
      bool bRet = false;
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 2;
      
      string strPriceDiff = StringFormat("获利：当前 %s， 最高 %s", 
                           DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dMostProfits, 2));
      if(m_nDirect == OP_BUY) {
         ShowText("ProfitsBuy", strPriceDiff, clrYellow, xPos, yPos); 
      }else
      {
         ShowText("ProfitsSell", strPriceDiff, clrYellow, xPos, yPos);  
      }
      
      if(m_nOrderCount > 0)
      {
         // 获取最近一次订单的货币对的价格
         double dPriceLastOrder = m_orderInfo[m_nOrderCount - 1].m_Prices;
         if(m_nDirect == OP_BUY)
         {
           // 此时需要获取本种货币对的卖价
           RefreshRates();
           double dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
           
           
           // 用现在的价格减去以前的价格，看差值是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
           if(dCurrentOffset >= dOffset)
           {
              // 如果当前的价格差扩大到大于设置的获利点位，则满足平仓条件
              LogInfo("====================== Close Buy Orders Condition OK ===========================");
              logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4),  
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));
              LogInfo(logMsg);
              
              double  dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
              logMsg = StringFormat("Profits: %s->%s, Most: %s", 
                        m_symbol, DoubleToString(dProfits, 2), DoubleToString(m_dMostProfits, 2));
              LogInfo(logMsg);
              bRet = true;
           }
             
         }else
         {
           // 此时需要获取两种货币对的买价
           RefreshRates();
           double dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
                     
           // 用以前的价格差减去现在的价格差，看缩小的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) >= dOffset)
           {
              // 如果当前的价格缩小到小于设置的获利点位，则满足平仓条件
              LogInfo("====================== Close Sell Orders Condition OK ===========================");
              logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4),  
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));
              LogInfo(logMsg);
                               
              double  dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
              logMsg = StringFormat("Profits: %s->%s, Most: %s", 
                        m_symbol, DoubleToString(dProfits, 2), DoubleToString(m_dMostProfits, 2));
              LogInfo(logMsg);
              bRet = true;
           }
         }
      }
      
      return bRet;
   }
   
   int CloseOrders()
   {
      int nRet = 0;
      
      for(int i = m_nOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_orderInfo[i]);
        
      }
      
      if(m_nOrderCount == 1) {
         m_nLoopCount++;
      } else {
         m_nLoopCount = -1;
      }
      
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      
      m_dPriceProtectingLine = 0;
         
      return nRet;
   }
   
    bool CheckForAppend(double dOffset, double dFactor, double dBackword)
    {
       // 检查亏损值是否达到最大并反弹10%
       bool bByDeficit = CheckForAppendByDeficit(dBackword);
        
       // 检查点位差是否超过预设的值（如0.003）
       // 第一次加仓条件是基础加仓价格差，如果已有订单，后面的加仓条件以此累加       
       double dOffsetAdjust = dOffset;
       if(m_nOrderCount > 0) {
            //  dOffsetAdjust = dOffset + dFactor * (m_nSymbol2OrderCount - 1);
            
            // 2018-05-20, 重新改回按比例计算加仓价格差
            dOffsetAdjust = dOffset * MathPow(dFactor, m_nOrderCount - 1);
       } 
       
       
       
       bool bByOffset = CheckForAppendByOffset(dOffsetAdjust);
       return bByDeficit && bByOffset;
    }
    
    bool CheckForAppendByDeficit(double dBackword)
    {
      bool bRet = false;
      // double dRealAppendLevel = MathMin(-MathAbs(dDeficitSetting), m_dLeastProfits * (1 - dBackword));
      double dRealAppendLevel = m_dLeastProfits * (1 - dBackword);
      
      if(dRealAppendLevel < 0) {      
         int xPos = m_xBasePos;
         int yPos = m_yBasePos + 4;
         string strPriceDiff = StringFormat("亏损：当前 %s， 最低 %s, 移动加仓 %s", 
                              DoubleToString(m_dCurrentProfits, 2),DoubleToString(m_dLeastProfits, 2), 
                              DoubleToString(dRealAppendLevel, 2));
         if(m_nDirect == OP_BUY) {
            ShowText("DeficitBuy", strPriceDiff, clrYellow, xPos, yPos); 
         }else
         {
            ShowText("DeficitSell", strPriceDiff, clrYellow, xPos, yPos);  
         }
         
         if(m_dPreProfits < dRealAppendLevel && m_dCurrentProfits >= dRealAppendLevel)
         {
            LogInfo("++++++++++++++++++++++ CheckForAppendByDeficit Condition1 OK ++++++++++++++++++++++++++++++");
            LogInfo(strPriceDiff);
            bRet = true;
         }
      }
         
      return bRet;
    }
    
    bool CheckForAppendByOffset(double dOffset)
    {
      bool bRet = false;
      string logMsg;
 
      if(m_nOrderCount > 0)
      {
         // 获取最近一次订单的货币对的价格
         double dPriceLastOrder = m_orderInfo[m_nOrderCount - 1].m_Prices;
        
         if(m_nDirect == OP_BUY)
         {
           // 此时需要获取两种货币对的卖价
           RefreshRates();
           double dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
                     
           // 用现在的价格差减去以前的价格差，看扩大的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
           logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4), 
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));    
           //OutputLog(logMsg); 
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                                 DoubleToString(dCurrentPrice, 4),DoubleToString(dPriceLastOrder, 4), 
                                 DoubleToString(dCurrentOffset, 4));
           ShowText("PriceDiffBuy", strPriceDiff, clrYellow, xPos, yPos);     
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) > dOffset)
           {
              // 如果当前的价格跌了，并且跌的幅度超过设置的点位，则满足加仓条件
              LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
              LogInfo(logMsg);
              bRet = true;
           }
             
         }else
         {
           // 此时需要获取两种货币对的买价
           RefreshRates();
           double  dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
          
                 
           // 用以前的价格差减去现在的价格差，看缩小的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
          logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4),
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));     
           //OutputLog(logMsg);
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           string strPriceDiff = StringFormat("价格差：%s - %s = %s", 
                                 DoubleToString(dCurrentPrice, 4),DoubleToString(dPriceLastOrder, 4), 
                                 DoubleToString(dCurrentOffset, 4));
           ShowText("PriceDiffSell", strPriceDiff, clrYellow, xPos, yPos);    
           if(dCurrentOffset >= dOffset)
           {
              // 如果当前的价格缩小到小于设置的获利点位，则满足平仓条件
              LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
              LogInfo(logMsg);
              bRet = true;
           }
         }
       }
       return bRet;
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
   
   int LoadOrders(string symbol, int nDirect, string comment, int nMagicNum, 
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
