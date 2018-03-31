//+------------------------------------------------------------------+
//|                                                    3MAPubVar.mqh |
//|                                                         Cui Long |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cui Long"
#property link      "https://www.mql5.com"
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
input int TimeFrame = PERIOD_M15;
input bool CheckFreeMargin = false;
input int OrderMax = 5;
input double MaxHoldingLots = 1.0;
input double BaseOpenLots = 0.01;
input double Overweight_Multiple = 2.0;
input bool MonitorCheckForClose = false;

#define DEFAULT_OPEN_LOW 30
#define DEFAULT_OPEN_HIGH 70
#define DEFAULT_CLOSE_LOW 25
#define DEFAULT_CLOSE_HIGH 75

#define DEFAULT_RSI_PERIOD 15


int RSI_Period = DEFAULT_RSI_PERIOD;
int RSI_LowForOpen = DEFAULT_OPEN_LOW;
int RSI_HighForOpen = DEFAULT_OPEN_HIGH;
int RSI_LowForClose = DEFAULT_CLOSE_LOW;
int RSI_HighForClose = DEFAULT_CLOSE_HIGH;

