//+------------------------------------------------------------------+
//|                                                       PubVar.mqh |
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
#define DEFAULT_OPEN_LOW 30
#define DEFAULT_OPEN_HIGH 70
#define DEFAULT_CLOSE_LOW 20
#define DEFAULT_CLOSE_HIGH 80

#define DEFAULT_RSI_PERIOD 5

input bool MonitorCheckForOpen = false;
input bool MonitorCheckForClose = false;
input bool MonitorTrend = false;
input int TimeFrame = PERIOD_M5;
input int TrendThreshold = 4;
input int OrderMax = 5;
input double BaseOpenLots = 0.01;
input double Overweight_Multiple = 2.0;
input double MaxHoldingLots = 1.0;
input int BollPeriod = 15;
input bool CheckFreeMargin = false;

int RSI_Period = DEFAULT_RSI_PERIOD;
int RSI_LowForOpen = DEFAULT_OPEN_LOW;
int RSI_HighForOpen = DEFAULT_OPEN_HIGH;
int RSI_LowForClose = DEFAULT_CLOSE_LOW;
int RSI_HighForClose = DEFAULT_CLOSE_HIGH;
int gTickCount = 0;
datetime gCurrentBarTime = 0;
