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
#define MAX_ORDER_COUNT 200

string OpName [] = 
{
   "买单",
   "卖单"
};

enum { PM_HEAVY = 0, PM_LIGHT = 1};

enum { RES_NOTHING = 0, RES_H2L = 1, RES_L2H = 2, RES_CLOSE_ALL = 3 };

#define LIGHT_LOTS 0.01

struct OptParam
{
   double m_BaseOpenLots;  //基础开仓手数
   double m_MultipleForAppend;//加仓倍数
   double m_MulipleFactorForAppend; //加仓倍数调整系数
   int m_AppendMax;          // 最大加仓次数
   double m_PointOffsetForStage; //加仓条件：与上阶段相比最低价格差变化幅度
   double m_PointOffsetForAppend; //加仓条件：本阶段内最低价格差变化幅度
   double m_PointOffsetFactorForAppend; //加仓条件：最低价格差变化的调整系数
   double m_AppendBackword; // 加仓条件：加仓回调系数
   double m_TakeProfitsPerLot; //平仓条件：每手止盈获利金额
   double m_TakeProfitsFacor; // 阶段三平仓条件：动态计算止盈金额调整系数
   double m_Backword; // 平仓条件：移动止盈回调系数
};

class CMartinOrder
{
public:
   int m_nDirect;
   string m_strDirect;
   int m_nOrderCount;
   int m_nPreOrderCount;
   double m_dLots;
   string m_symbol; 
   string m_comment;
   int m_nMagicNum;
  
   double m_dMostProfits;
   double m_dPreProfits;
   double m_dCurrentProfits;
   
   double m_dLeastProfits;
   
   int m_nLoopCount;
   
   COrderInfo m_orderInfo[MAX_ORDER_COUNT];
   
   OptParam optParam[3];
     
private:
   int m_xBasePos;
   int m_yBasePos;
   bool m_bShowText;
   bool m_bShowComment;
   
public:
   CMartinOrder(string symbol, int nDirect, int magicNum) 
   {
      m_bShowText = gbShowText;
      m_bShowComment = gbShowComment;
      m_nDirect = nDirect;
      m_nOrderCount = 0;
      m_nPreOrderCount = 0;
      m_dLots = 0.0;
      m_symbol = symbol;
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      m_nLoopCount = 0;
                
      if(nDirect == OP_BUY)
      {
         m_comment = "MBuy";
         m_strDirect = "MBuy";
         m_nMagicNum = magicNum;
         m_xBasePos = 0;
         m_yBasePos = 0;
      }else
      {
         m_comment = "MSell";
         m_strDirect = "MSell";
         m_nMagicNum = magicNum;
         m_xBasePos = 0;
         m_yBasePos = 4;
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
   
   int LoadAllOrders(OptParam &optParam[], int optMax)
   {
      string logMsg;
      int xPos = m_xBasePos;
      int yPos = m_yBasePos;
      if(m_nDirect == OP_BUY) {
         string strVersion = StringFormat("版本号：%s, Tick: %d", EA_VERSION, gTickCount);
         ShowVersion("Version", strVersion, clrYellow, xPos, yPos);
      }
          
      CleanOrders();
      
      m_nOrderCount = LoadOrders(m_symbol, m_nDirect, m_comment, m_nMagicNum, 
                                       m_orderInfo, m_nOrderCount, m_dLots );
                                       
      if(m_nPreOrderCount != m_nOrderCount) {
         // 订单数量有变化时（如，人工平仓），重新计算盈利和亏损值 
         m_dMostProfits = 0.0;
         m_dLeastProfits = 0.0;
         m_dPreProfits = 0;
         m_dCurrentProfits = 0;
      }
      m_nPreOrderCount = m_nOrderCount;  
      
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
         double  dProfits = 0;         
         int nStage = CalcStageNumber(m_nOrderCount, optParam, optMax);
         int nAppendNumber = CalcAppendNumber(nStage, m_nOrderCount, optParam, optMax);
         if(nStage == 0) {
            dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
         }else {
            // 当当前的阶段数大于1或小于max时，仅计算本阶段的获利值               
            dProfits = CalcTotalProfits2(m_orderInfo, m_nOrderCount, nAppendNumber);        
         }
         
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
                        
         yPos++;
         string strProfits;
         if(m_nDirect == OP_BUY)
         {
            strProfits = StringFormat("【多方】订单数：%d，手数：%s，阶段：%d，轮数：%d", 
                     m_nOrderCount, DoubleToString(m_dLots, 2),  nStage + 1, nAppendNumber);
            ShowText("OrderStatisticsBuy", strProfits, clrYellow, xPos, yPos);
            
         }else
         {
            strProfits = StringFormat("【空方】订单数：%d，手数：%s，阶段：%d，轮数：%d",
                     m_nOrderCount, DoubleToString(m_dLots, 2),  nStage + 1, nAppendNumber);
            ShowText("OrderStatisticsSell", strProfits, clrYellow, xPos, yPos);
          }
                 
      }
      return m_nOrderCount;
   }
   
   int Fib(int n)
   {
      return n < 2 ? 1 : (Fib(n-1) + Fib(n-2));
   }
   
   // 计算第1阶段到第（optCount-1）阶段订单的总数
   int CalcMaxOrderCount( OptParam &optParam[], int optCount) {
      int nMaxCount = 0;
      for(int i = 0; i < optCount; i++) {
         nMaxCount += optParam[i].m_AppendMax;
      }
      return nMaxCount;
   }
   
   // 计算当前所处的阶段数索引
   int CalcStageNumber(int nOrderCount, OptParam &optParam[], int optCount) {
      int nStage = 0;
      int nMaxCount = 0;
      for(int i = 0; i < optCount; i++) {
         nMaxCount += optParam[i].m_AppendMax;
         if(nOrderCount > nMaxCount) {
            nStage = i + 1;
         }
      }
      return nStage;
   }
   
    // 为开仓计算阶段数索引
   int CalcStageNumberForOpenOrder(int nOrderCount, OptParam &optParam[], int optCount) {
      int nStage = 0;
      int nMaxCount = 0;
      for(int i = 0; i < optCount; i++) {
         nMaxCount += optParam[i].m_AppendMax;
         if(nOrderCount >= nMaxCount) {
            nStage = i + 1;
         }
      }
      return nStage;
   }
   
   // 计算所传入阶段的订单数，即索引数为nStage的阶段已经有多少订单了
   int CalcAppendNumber(int nStage, int nOrderCount, OptParam &optParam[], int optCount) {
      int nAppendNumber = 0;
      if(nStage == 0) {
         nAppendNumber = nOrderCount;
      }else {
         int nCount = CalcMaxOrderCount(optParam, nStage);
         nAppendNumber = nOrderCount - nCount;
      }      
      return nAppendNumber;
   }
   
   int OpenOrdersMicro(OptParam &optParam[], int optCount)
   {
       double accMargin =  AccountMargin();//AccountMargin();
       double equity = AccountEquity();
         
       if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
      int nStage = CalcStageNumberForOpenOrder(m_nOrderCount, optParam, optCount); 
      double dLots = 0.01;//NormalizeDouble(m_dBaseOpenLots * MathPow(m_dMultiple, nOrderCnt) * MathPow(m_dMultipleFactor, nOrderCnt), 2);
                 
      double dCurrentPrice = 0;
      RefreshRates();
      if(m_nDirect == OP_BUY)
      {
         dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
      } else {
         dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
      }
      string comment = "";            
      if(m_bShowComment) {
         comment = StringFormat("%s(%d)-%d-%d(%s)", m_comment, m_nMagicNum, nStage + 1, 0, DoubleToString(dCurrentPrice, 4));
      }
      OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
      
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
      
      return 0;
   }
   
   int OpenOrders(OptParam &optParam[], int optCount)
   {
      double accMargin = AccountMargin();
      double equity = AccountEquity();
      if(CheckFreeMargin && accMargin != 0 && (equity / accMargin) < (AdvanceRate / 100) ) {
              string logMsg = StringFormat("%s => Free margin not enouth: margin = %s, equity = %s.",
                              __FUNCTION__, DoubleToString(accMargin, 3), DoubleToString(equity,3));
              LogWarn(logMsg); 
              return -1; 
       }
      int nMaxOrderCount = CalcMaxOrderCount(optParam, optCount); 
      if(m_nOrderCount < nMaxOrderCount)
      {
         int nStage = CalcStageNumberForOpenOrder(m_nOrderCount, optParam, optCount);
         if(nStage < optCount) {
            int nAppendTime = CalcAppendNumber(nStage, m_nOrderCount, optParam, optCount);
            OptParam param = optParam[nStage];
             
            double dLots = NormalizeDouble(param.m_BaseOpenLots * MathPow(param.m_MultipleForAppend, nAppendTime) * MathPow(param.m_MulipleFactorForAppend, nAppendTime), 2);
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
            // string comment = StringFormat("S%d-%s(%s)", nStage + 1, m_comment, DoubleToString(dCurrentPrice, 4));
            string comment = "";            
            if(m_bShowComment) {
               comment = StringFormat("%s(%d)-%d-%d(%s)", m_comment, m_nMagicNum, nStage + 1, nAppendTime + 1, DoubleToString(dCurrentPrice, 4));   
            }
            OpenOrder(m_symbol, m_nDirect, dLots, comment, m_nMagicNum);
            
            m_dMostProfits = 0.0;
            m_dLeastProfits = 0.0;
            m_dPreProfits = 0;
            m_dCurrentProfits = 0;
         }    
      }
      return 0;
   }

   double GetPriceDiff() {
      double dPriceDiff = 0;
      if(m_nOrderCount > 1) {
         dPriceDiff = MathAbs(m_orderInfo[0].m_Prices - m_orderInfo[m_nOrderCount - 1].m_Prices);
      }
      return dPriceDiff;
   }
   
   double GetPriceDiff(int nAppendCnt) {
      double dPriceDiff = 0;
      if(m_nOrderCount > 0 && nAppendCnt <= m_nOrderCount) {
         dPriceDiff = MathAbs(m_orderInfo[m_nOrderCount - nAppendCnt].m_Prices - m_orderInfo[m_nOrderCount - 1].m_Prices);
      }
      return dPriceDiff;
   }
   
   double GetLots(int nAppendCnt) {
      double dLots = 0;
      if(m_nOrderCount > 0 && nAppendCnt <= m_nOrderCount) {
         for(int i = m_nOrderCount - nAppendCnt; i < m_nOrderCount; i++) {
            dLots += m_orderInfo[i].m_Lots;
         }
      }
      return dLots;
   }
   
   
   // 双向套利平仓条件
   bool CheckForClose(double dOffset, double dProfitsSetting, double dBackword)
   {
      if(dProfitsSetting == 0.0)
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
           // 买单平仓时，需要使用BID价格
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
           // 卖单平仓时，需要使用ASK价格
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
      
      return nRet;
   }
   
   int CloseOrders(int nLatestCnt)
   {
   
      int nRet = 0;
      int nCnt = 0;
      for(int i = m_nOrderCount - 1; i >= 0; i--)
      {
         CloseOrder(m_orderInfo[i]);
         nCnt++;
         if(nCnt >= nLatestCnt) {
            break;
         }       
      }   
      
      m_dMostProfits = 0.0;
      m_dLeastProfits = 0.0;
      m_dPreProfits = 0;
      m_dCurrentProfits = 0;
         
      return nRet;
   }
   
    bool CheckForAppend(double dOffset, double dFactor, double dBackword, int nAppendTime, bool bFactor)
    {
       // 检查亏损值是否达到最大并反弹10%
       bool bByDeficit = CheckForAppendByDeficit(dBackword);
        
       // 检查点位差是否超过预设的值（如0.003）
       // 第一次加仓条件是基础加仓价格差，如果已有订单，后面的加仓条件以此累加       
       double dOffsetAdjust = dOffset;
       if(bFactor) {
            //  dOffsetAdjust = dOffset + dFactor * (m_nSymbol2OrderCount - 1);
            
            // 2018-05-20, 重新改回按比例计算加仓价格差
            dOffsetAdjust = dOffset * MathPow(dFactor, nAppendTime - 1);
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
           // 买单加仓时，需要使用ASK价格
           RefreshRates();
           double dCurrentPrice = MarketInfo(m_symbol, MODE_ASK);
                     
           // 用现在的价格差减去以前的价格差，看扩大的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
           logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4), 
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));    
           //OutputLog(logMsg); 
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           double dSpread = GetSpread(m_symbol);
           string strPriceDiff = StringFormat("价格差：%s - %s = %s, 点差：%s", 
                                 DoubleToString(dCurrentPrice, 4),DoubleToString(dPriceLastOrder, 4), 
                                 DoubleToString(dCurrentOffset, 4), DoubleToString(dSpread, 5));
           ShowText("PriceDiffBuy", strPriceDiff, clrYellow, xPos, yPos);     
           if(dCurrentOffset < 0 &&  MathAbs(dCurrentOffset) > dOffset)
           {             
              if(dSpread > SpreadMax) {
                  string strSpreadTooBig = StringFormat("Buy: Spread is too big, %s, %s",
                                 m_symbol, DoubleToString(dCurrentOffset, 4));
                  LogImportant(strSpreadTooBig);
              }else {
                   // 如果当前的价格跌了，并且跌的幅度超过设置的点位，则满足加仓条件
                   LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
                   LogInfo(logMsg);
                   bRet = true;
              }
           }
             
         }else
         {
           // 卖单加仓时，需要使用BDI价格
           RefreshRates();
           double  dCurrentPrice = MarketInfo(m_symbol, MODE_BID);
          
                 
           // 用以前的价格差减去现在的价格差，看缩小的幅度是否超过设置的点位
           double dCurrentOffset = dCurrentPrice - dPriceLastOrder;
          logMsg = StringFormat("Direct = %d, Offset = %s, Order Price = %s, Current Price = %s",
                               m_nDirect, DoubleToString(dCurrentOffset, 4),
                               DoubleToString(dPriceLastOrder, 5), DoubleToString(dCurrentPrice, 5));     
           //OutputLog(logMsg);
           int xPos = m_xBasePos;
           int yPos = m_yBasePos + 3;
           double dSpread = GetSpread(m_symbol);
           string strPriceDiff = StringFormat("价格差：%s - %s = %s,  点差：%s", 
                                 DoubleToString(dCurrentPrice, 4),DoubleToString(dPriceLastOrder, 4), 
                                 DoubleToString(dCurrentOffset, 4),  DoubleToString(dSpread, 5));
           ShowText("PriceDiffSell", strPriceDiff, clrYellow, xPos, yPos);    
           if(dCurrentOffset >= dOffset)
           {
              if(dSpread > SpreadMax) {
                  string strSpreadTooBig = StringFormat("Sell: Spread is too big, %s, %s",
                                 m_symbol, DoubleToString(dCurrentOffset, 4));
                  LogImportant(strSpreadTooBig);
              }else {
                   // 如果当前的价格涨了，并且涨的幅度超过设置的点位，则满足加仓条件
                   LogInfo("++++++++++++++++++++++ CheckForAppendByOffset Condition2 OK ++++++++++++++++++++++++++++++");
                   LogInfo(logMsg);
                   bRet = true;
              }
              
           }
         }
       }
       return bRet;
    }
    
    bool CheckForAutoCloseAll(double baseBalance, double preEquity, double mostEquity, double realTargetEquity) {
      double currentEquity = AccountEquity(); // 净值
      int xPos = m_xBasePos;
      int yPos = m_yBasePos + 5;
      string strAutoCloseAll = StringFormat("净值：本金: %s, 当前：%s，最大：%s，止盈：%s", 
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
    
    double CalsUnrealizedLoss() {
      double currentBalance = AccountBalance(); // 余额
      double currentEquity = AccountEquity(); // 净值
      return currentBalance - currentEquity; // 浮亏
    }
    
    bool CheckStopLoss(double dStopLossRete) {
      bool ret = false;
      double balance = AccountBalance(); // 余额                 
      double endity = AccountEquity(); // 净值      
      double dProfits = CalcTotalProfits(m_orderInfo, m_nOrderCount);
      if(dProfits < 0 &&  MathAbs(dProfits) / balance > dStopLossRete) {
         ret = true;
      }
      return ret;
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
   
   double CalcTotalProfits(const COrderInfo & orderInfo [], int orderCnt)
   {
      double fProfits = 0;
      for(int i = 0; i < orderCnt; i++)
      {
         fProfits += orderInfo[i].m_Profits;
      }         
         
      return fProfits;
   }
   
    double CalcTotalProfits2(const COrderInfo & orderInfo [], int orderCnt, int nLatestCnt)
   {
      double fProfits = 0;
      int nCnt = 0;
      for(int i = orderCnt - 1; i >= 0; i--)
      {
         fProfits += orderInfo[i].m_Profits;
         nCnt++;
         if(nCnt >= nLatestCnt) {
            break;
         }
      }         
         
      return fProfits;
   }
   
    void ShowText(string label, string text, color clr, int x, int y)
   {
      string labelInternal = StringFormat("%s-%d", label, m_nMagicNum);
      if(m_bShowText && gTickCount % 4 == 0) {
         DisplayText(labelInternal, text, clr, x, y);
      }
   }
   
   void ShowWarning(string label, string text, color clr, int x, int y)
   {
      string labelInternal = StringFormat("%s-%d", label, m_nMagicNum);
      if(gTickCount % 4 == 0) {
         DisplayText(labelInternal, text, clr, x, y);
      }
   }
   
   void ShowVersion(string label, string text, color clr, int x, int y)
   {
      if(gTickCount % 4 == 0) {
         DisplayText(label, text, clr, x, y);
      }
   }
   
   double GetSpread(string symbol) {
      RefreshRates();
      double dBid = MarketInfo(Symbol(), MODE_BID);
      double dAsk = MarketInfo(Symbol(), MODE_ASK);
  
      double dSpread =  dAsk - dBid;
      return dSpread;
   }
   
};
