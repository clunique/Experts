//+------------------------------------------------------------------+
//|                                                      双品种双向套利.mq4 |
//|                                                          Cuilong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cuilong"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define SHOW_COMMENT

#include "Martin3/Martin.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+



int OnInit()
  {
       LogLevel = LOG_INFO;
       gbShowComment = true;
       gbShowText = true;
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Destroy();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Main();
   
  }
//+------------------------------------------------------------------+
