//+------------------------------------------------------------------+
//|                                                MartinHedging.mqh |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property strict

#include "PubVar.mqh"
#include "TridentOrder.mqh"
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

CTridentOrder * pTridentOrder = NULL;
   
void Main()
{  
   bool bIsNewBar = IsNewBar();
   if(!gIsNewBar && bIsNewBar)
   {
      gIsNewBar = bIsNewBar;
   }else
   {
      gIsNewBar = false;
   }
   
   if(gIsNewBar) {
      LogInfo("--------------- New Bar -----------------");
   }
   
   string symbol = Symbol();
   // 1. 检查持仓情况
   if(!pTridentOrder) {
      pTridentOrder = new CTridentOrder(symbol, OP_BUY, MAGIC_NUM);
   }
   
   // 装入当前持仓
   pTridentOrder.LoadAllOrders();
   bool bBaseOrderExist = pTridentOrder.IsBaseOrderExist();
   bool bAppendingOrderExist = pTridentOrder.IsAppendingOrderExist();
   bool bProtectingOrderExist = pTridentOrder.IsProtectingOrderExist();
   
   if(!bBaseOrderExist) {
       // 还没有开基础仓，开基础仓
       pTridentOrder.OpenBaseOrder(BASE_OPEN_LOTS);
   }else {
       if(bProtectingOrderExist) {
         // 1. 如果保护仓存在，先处理保护仓
         if(pTridentOrder.CheckForCloseProtectingOrder()) {
            // 1.1. 如果满足保护仓的平仓条件，则平掉保护仓
            pTridentOrder.CloseProtectingOrder();
         }else {
            // 1.2 否则，处理持有保护仓的逻辑
            pTridentOrder.ProcessProtectingOrder();
         }
       }else {
          // 保护仓不存在，有两种情况
          // 1. 加仓和基础仓同时存在
          // 2. 只有基础仓存在，见下面的逻辑
          if(bAppendingOrderExist) {
            // 2. 加仓存在，则处理加仓情况
            // 2.1 如果尚未开保护仓，则检查保护仓开仓条件
            if(pTridentOrder.CheckForOpenProtectingOrder()) {
               // 满足开保护仓的条件，则开保护仓
               pTridentOrder.OpenProtectingOrder();
            }else {
                // 2.2 如果不满足开保护仓的条件，则检查平仓条件
                if(pTridentOrder.CheckForCloseAppendingOrder(APPEND_CLOSE_MIN_OFFSET, APPEND_CLOSE_BACKWORD_OFFSET)) {
                  // 满足平加仓的条件，则平掉加仓
                  pTridentOrder.CloseAppendingOrder();
                }
            }
            
          } else {
            // 3. 最后处理只有基础仓的情况
            // 3.1 检查是否需要开加仓
            if(pTridentOrder.CheckForOpenAppendingOrder(BASE_APPEND_OFFSET, BASE_APPEND_BACKWORD_OFFSET)) {
               // 满足开加仓的条件，则开加仓
               double dLotAppending = BASE_OPEN_LOTS * APPEND_MULTIPLE;
               pTridentOrder.OpenAppendingOrder(dLotAppending);
            }else {
                // 2.2 如果没有加仓，则检查基础仓的平仓条件
                if(pTridentOrder.CheckForCloseBaseOrder(BASE_CLOSE_MIN_OFFSET, BASE_CLOSE_BACKWORD_OFFSET)) {
                  // 满足平加仓的条件，则平掉加仓
                  pTridentOrder.CloseBaseOrder();
                }
            }
          }
       }      
   }  
   
   pTridentOrder.UpdateCache();
   gTickCount++;
}

void Destroy()
{
   if(pTridentOrder) {
      delete pTridentOrder; 
      pTridentOrder = NULL;
   }
}