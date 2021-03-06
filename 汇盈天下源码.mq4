//EA交易     =>  ...\MT4\MQL4\Experts

#property  copyright "Copyright 2017, 金典套利."
#property version    "1.01"
#property strict


 enum 是否 {
      是 = 0,
      否 = 1,
          };
extern string g_mytag="金典套利)"  ;   //EA标题
extern int   InpDepth=12  ;    //Depth
extern int   InpDeviation=5  ;    //Deviation
extern int   InpBackstep=3  ;    //Backstep
extern int   BigMa=50  ;    //大均线周期
extern int   SmallMa=20  ;    //小均线周期
extern string 填写货币对时要注意跟MT4上的字符完全对应=""  ;  
extern string HBD1="EURUSD"  ;   //货币对1(字符完全对应)
extern string HBD2="GBPUSD"  ;   //货币对2(字符完全对应)
extern double Lots=0.1  ;    //手数
extern double IncLots=3  ;    //加仓倍数
extern int   BuyMagic=100011  ;    //多单标识
extern int   SellMagic=100021  ;    //空单标识
extern double LP=100  ;    //止损百分比为亏损金额到达余额的百分之多少平仓
extern double TP=100  ;    //盈利百分比为盈利金额到达余额的百分之多少平仓
extern double GDTP=0.3  ;    //固定止盈金额(当前显示的盈利总金额)
extern double 微利金额=0.03  ;   
extern int   最多加仓次数=5  ;   
extern double 最低加仓间隔=0.005  ;   
extern  是否  检查加仓间隔=0  ;   
extern int   开单多少分钟后启用微利平仓=360  ;   
extern  是否  允许均线平仓=1  ;   
extern  是否  允许加仓后微利平仓=0  ;   
extern int   开单多少分钟后每个单子获利都负时全部平仓=999999  ;   
extern string 每天微利平仓时段="23:00:00-23:59:59"  ;  
extern double 超过多少点差不开单不加仓=50  ;   
extern  是否  禁用按钮=0  ;   
extern  是否  自动识别货币对=0  ;   
extern double 帐号持仓总手数大于多少不开单不加仓=1  ;   
extern string SMB="以下时间均为平台时间"  ;   //以下时间均为平台时间
extern string DisableDayOfWeak="5"  ;   //周几不开单,用\',\'隔开如：1,2,3 0为周日 6为周6 空为全允许
extern string DisableHourOfDay="23"  ;   //每天几点不开单,用\',\'隔开如：1,2,3 24小时制 空为全允许
extern  是否  这一轮结束后不开单=1  ;   

 string    总_st_1 = "";
 bool      总_bo_2 = false;
 double    总_do_3 = 0.0;
 string    总_st_4 = "恭喜授权成功";
 double    总_do_5 = 0.0;
 bool      总_bo_6 = false;

#import   "Wininet.dll"
          int InternetOpenW(string  木_1,int  木_2,string  木_3,string  木_4,int  木_5);
          int InternetConnectW(int  木_1,string  木_2,int  木_3,string  木_4,string  木_5,int  木_6,int  木_7,int  木_8);
          int InternetOpenUrlW(int  木_1,string  木_2,string  木_3,int  木_4,int  木_5,int  木_6);
          int InternetReadFile(int  木_1,uchar&  木_2[],int  木_3,int&  木_4[]);
          int InternetCloseHandle(int  木_1);
#property  tester_indicator "ZigZagMaDiff"
#import     


//----------------------------

 int OnInit ()
 {
 string      子_st_1;
 double      子_do_2;
 int         子_in_3;

//----------------------------
 string     临_st_2;  //13

 switch(AccountInfoInteger(32))
  {
  case 0 :
   临_st_2 = "demo";
      break;
  case 1 :
   临_st_2 = "contest";
      break;
  default :
   临_st_2 = "real";
  }
 子_st_1 = 临_st_2 ;
 EventSetTimer(10); 
 //总_st_4 = lizong_16("MEA_PRO_EURUSDWINDOW_1") ;
 if ( 总_st_4 == "false" )
  {
//  Alert("未经授权!"); 
 // return(1); 
  }
 if ( TimeGMT() > StringToTime("2018.04.07 00:00") )
  {
 // Alert("已到期，请联系QQ229752560合作才能用!外汇套利商业合作群 209354553"); 
//  return(1); 
  }
 子_do_2 = Lots ;
 总_do_5 = Lots ;
 for (子_in_3 = 1 ; 子_in_3 < 最多加仓次数 ; 子_in_3 = 子_in_3 + 1)
  {
  子_do_2 = IncLots * 子_do_2 ;
  总_do_5 = 子_do_2 + 总_do_5 ;
  }
 if ( 检查加仓间隔 == 0 && 最低加仓间隔<Point() * 10.0 )
  {
  Alert("最低加仓间隔过低,请从新设置！！"); 
  return(1); 
  }
 return(0); 
 }
//OnInit
//---------------------  ----------------------------------------

 void OnTick ()
 {
 string      子_st_1[100];;
 int         子_in_2;
 string      子_st_3;
 double      子_do_4;
 double      子_do_5;
 double      子_do_6;
 double      子_do_7;
 double      子_do_8;
 double      子_do_9;
 double      子_do_10;
 double      子_do_11;
 double      子_do_12;
 double      子_do_13;
 double      子_do_14;
 double      子_do_15;
 double      子_do_16;
 double      子_do_17;
 double      子_do_18;
 double      子_do_19[];
 int         子_in_20;
 int         子_in_21;
 double      子_do_22;
 double      子_do_23;
 double      子_do_24;
 double      子_do_25;
 double      子_do_26;
 double      子_do_27;
 int         子_in_28;
 bool        子_bo_29;
 bool        子_bo_30;
 string      子_st_31[];
 string      子_st_32[];
 int         子_in_33;
 int         子_in_34;
 double      子_do_35;
 double      子_do_36;
 int         子_in_37;
 double      子_do_38;
 double      子_do_39;
 int         子_in_40;
 double      子_do_41;
 double      子_do_42;
 int         子_in_43;
 int         子_in_44;
 int         子_in_45;
 int         子_in_46;
 int         子_in_47;
 int         子_in_48;
 int         子_in_49;
 int         子_in_50;
 double      子_do_51;
 double      子_do_52;
 string      子_st_53;
 string      子_st_54;
 string      子_st_55;
 string      子_st_56[];
 int         子_in_57;
 int         子_in_58;

//----------------------------
 int        临_in_1;  //230
 uint       临_ui_2;  //231
 int        临_in_3;  //232
 int        临_in_4;  //233
 string     临_st_7;  //237
 int        临_in_9;  //279
 uint       临_ui_10;  //280
 int        临_in_11;
 int        临_in_12;  //284
 string     临_st_14;
 int        临_in_15;  //351
 uint       临_ui_16;  //352
 int        临_in_17;  //353
 int        临_in_18;  //354
 string     临_st_20;  //358
 string     临_st_21;  //359
 int        临_in_22;  //399
 uint       临_ui_23;  //400
 int        临_in_24;  //401
 int        临_in_25;  //402
 string     临_st_19;
 string     临_st_26;  //404
 int        临_in_27;  //444
 uint       临_ui_28;  //445
 int        临_in_29;  //446
 int        临_in_30;  //447
 string     临_st_31;  //448
 int        临_in_33;  //487
 uint       临_ui_34;  //488
 int        临_in_35;  //489
 int        临_in_36;  //490
 string     临_st_37;  //491
 string     临_st_38;  //492
 int        临_in_50;  //871
 int        临_in_49;
 double     临_do_53;  //897
 int        临_in_55;  //900
 string     临_st_61;  //1059
 double     临_do_62;  //1060
 double     临_do_63;  //1061
 bool       临_bo_64;  //1062
 double     临_do_66;  //1078
 string     临_st_70;  //1093
 double     临_do_69;
 double     临_do_71;  //1095
 bool       临_bo_72;  //1096
 double     临_do_74;  //1112
 double     临_do_76;
 int        临_in_77;  //1134
 int        临_in_83;
 double     临_do_97;  //1328
 int        临_in_96;
 int        临_in_99;  //1358
 double     临_do_101;  //1360
 int        临_in_100;
 int        临_in_105;  //1410
 int        临_in_106;
 int        临_in_115;
 int        临_in_117;
 int        临_in_126;
 int        临_in_128;
 int        临_in_137;
 int        临_in_139;
 int        临_in_148;
 int        临_in_150;
 int        临_in_159;
 int        临_in_161;
 int        临_in_170;
 int        临_in_172;
 int        临_in_182;  //1870
 int        临_in_181;
 int        临_in_183;
 int        临_in_185;
 int        临_in_194;
 int        临_in_195;
 int        临_in_204;
 int        临_in_206;
 int        临_in_215;
 int        临_in_217;
 int        临_in_226;
 uint       临_ui_227;  //2142
 int        临_in_228;  //2143
 int        临_in_229;  //2144
 string     临_st_232;  //2155
 string     临_st_233;  //2156
 int        临_in_235;  //2214
 uint       临_ui_236;  //2215
 int        临_in_237;  //2216
 int        临_in_238;  //2217
 string     临_st_239;  //2220
 string     临_st_240;  //2221
 int        临_in_241;  //2266
 uint       临_ui_242;  //2267
 int        临_in_243;  //2268
 int        临_in_244;  //2269
 string     临_st_246;  //2293
 string     临_st_247;  //2294
 int        临_in_249;  //2354
 uint       临_ui_250;  //2355
 int        临_in_251;  //2356
 int        临_in_252;  //2357
 string     临_st_254;  //2362
 string     临_st_255;  //2363
 int        临_in_253;
 bool       临_bo_256;
 int        临_in_257;  //2433
 int        临_in_258;
 int        临_in_266;
 int        临_in_267;
 int        临_in_276;
 int        临_in_278;
 int        临_in_287;
 int        临_in_288;
 int        临_in_297;
 int        临_in_299;
 int        临_in_308;
 int        临_in_310;
 int        临_in_320;  //2798
 int        临_in_319;
 int        临_in_321;
 uint       临_ui_322;  //2822
 int        临_in_323;  //2823
 int        临_in_324;  //2824
 string     临_st_325;  //2825
 int        临_in_327;  //2865
 uint       临_ui_328;  //2866
 int        临_in_329;  //2867
 int        临_in_330;  //2868
 string     临_st_332;  //2871
 string     临_st_333;  //2872
 uint       临_ui_334;  //2913
 uint       临_ui_335;  //2914
 int        临_in_336;  //2915
 int        临_in_337;  //2916
 int        临_in_338;  //2917
 int        临_in_339;  //2918
 int        临_in_340;  //2919
 string     临_st_341;  //2926
 string     临_st_343;  //2933
 uint       临_ui_346;  //3036
 uint       临_ui_347;  //3037
 int        临_in_348;  //3038
 int        临_in_349;  //3039
 int        临_in_350;  //3040
 int        临_in_351;  //3041
 int        临_in_352;  //3042
 string     临_st_354;  //3050
 string     临_st_356;  //3061
 uint       临_ui_359;  //3164
 uint       临_ui_360;  //3165
 int        临_in_361;  //3166
 int        临_in_362;  //3167
 int        临_in_363;  //3168
 int        临_in_364;  //3169
 int        临_in_365;  //3170
 string     临_st_367;  //3178
 string     临_st_369;  //3189
 int        临_in_372;  //3299
 int        临_in_373;
 int        临_in_382;
 int        临_in_383;
 double     临_do_390;  //3398
 double     临_do_391;  //3400
 int        临_in_393;  //3414
 int        临_in_392;

 RefreshRates(); 
 ChartRedraw(0); 
 if ( 总_bo_6  !=  true )
  {
  if ( IsTesting() == false && IsOptimization() == false && ( IsTradeAllowed() == false || IsExpertEnabled() == false || IsStopped() ) )
   {
   子_st_1[0] = "     不允许智能交易";
   子_st_1[1] = "1.需保证主图右上角为笑脸";
   子_st_1[2] = "2.请检查并按下了\"EA交易\"开关";
   子_st_1[3] = "3.请检查\"EA属性\"--\"常用\"--\"允许实时自动交易\"需勾选";
   子_st_1[4] = "4.如右上角为笑脸依旧不支持智能交易,请联系平台客服";
   子_st_1[5] = "   4-1.平台某些服务器可能不支持智能交易";
   子_st_1[6] = "   4-2.平台服务器支持但是当前货币对可能不支持智能交易";
   临_in_1 = 0;
   临_ui_2 = Red;
   临_in_3 = 20;
   临_in_4 = 10;
   临_st_7 = "标签0";
   if ( 子_st_1[0]  !=  "" )
    {
    if ( ObjectFind(临_st_7) == -1 )
     {
     ObjectDelete(临_st_7); 
     ObjectCreate(临_st_7,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
     }
    ObjectSet(临_st_7,OBJPROP_XDISTANCE,临_in_4); 
    ObjectSet(临_st_7,OBJPROP_YDISTANCE,临_in_3); 
    ObjectSetText(临_st_7,子_st_1[0],10,"微软雅黑",临_ui_2); 
    ObjectSet(临_st_7,OBJPROP_CORNER,临_in_1); 
    }
   for (子_in_2 = 1 ; 子_in_2 <= 7 ; 子_in_2 = 子_in_2 + 1)
    {
    临_in_9 = 0;
    临_ui_10 = Yellow;
    临_in_11 = 子_in_2 * 25 + 30;
    临_in_12 = 10;
    临_st_14 = "标签" + string(子_in_2);
    if ( 子_st_1[子_in_2]  !=  "" )
     {
     if ( ObjectFind(临_st_14) == -1 )
      {
      ObjectDelete(临_st_14); 
      ObjectCreate(临_st_14,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
      }
     ObjectSet(临_st_14,OBJPROP_XDISTANCE,临_in_12); 
     ObjectSet(临_st_14,OBJPROP_YDISTANCE,临_in_11); 
     ObjectSetText(临_st_14,子_st_1[子_in_2],10,"微软雅黑",临_ui_10); 
     ObjectSet(临_st_14,OBJPROP_CORNER,临_in_9); 
     }
    }
   ChartRedraw(0); 
   ArrayFree(子_st_1);
   return;
   }
  子_st_3 = Symbol() ;
  if ( 自动识别货币对 == 0 )
   {
   自动识别货币对 = 1 ;
   if ( HBD1  !=  Symbol() )
    {
    StringReplace(子_st_3,HBD1,""); 
    HBD1 = Symbol() ;
    HBD2=HBD2 + 子_st_3;
   }}
   //Print("1="+HBD1+"  2="+HBD2);
  if ( Symbol()  !=  HBD1 )
   {
   临_in_15 = 0;
   临_ui_16 = Red;
   临_in_17 = 205;
   临_in_18 = 10;
   临_st_20 = "错误:请你把EA加载到" + HBD1 + "图表上,因为您设置的货币对1是" + HBD1;
   临_st_21 = "标签7";
   if ( "错误:请你把EA加载到" + HBD1 + "图表上,因为您设置的货币对1是" + HBD1  !=  "" )
    {
    if ( ObjectFind(临_st_21) == -1 )
     {
     ObjectDelete(临_st_21); 
     ObjectCreate(临_st_21,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
     }
    ObjectSet(临_st_21,OBJPROP_XDISTANCE,临_in_18); 
    ObjectSet(临_st_21,OBJPROP_YDISTANCE,临_in_17); 
    ObjectSetText(临_st_21,临_st_20,10,"微软雅黑",临_ui_16); 
    ObjectSet(临_st_21,OBJPROP_CORNER,临_in_15); 
   }}
  临_in_22 = 0;
  临_ui_23 = Yellow;
  临_in_24 = 30;
  临_in_25 = 10;
  临_st_19 = g_mytag;
  临_st_26 = "标签0";
  if ( g_mytag  !=  "" )
   {
   if ( ObjectFind(临_st_26) == -1 )
    {
    ObjectDelete(临_st_26); 
    ObjectCreate(临_st_26,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
    }
   ObjectSet(临_st_26,OBJPROP_XDISTANCE,临_in_25); 
   ObjectSet(临_st_26,OBJPROP_YDISTANCE,临_in_24); 
   ObjectSetText(临_st_26,临_st_19,10,"微软雅黑",临_ui_23); 
   ObjectSet(临_st_26,OBJPROP_CORNER,临_in_22); 
   }
  临_in_27 = 0;
  临_ui_28 = Yellow;
  临_in_29 = 55;
  临_in_30 = 10;
  临_st_31 = "未来行情无人可知，使用该EA请自担风险，开发者不承担责任！";
  if ( ObjectFind("标签1") == -1 )
   {
   ObjectDelete("标签1"); 
   ObjectCreate("标签1",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
   }
  ObjectSet("标签1",OBJPROP_XDISTANCE,临_in_30); 
  ObjectSet("标签1",OBJPROP_YDISTANCE,临_in_29); 
  ObjectSetText("标签1",临_st_31,10,"微软雅黑",临_ui_28); 
  ObjectSet("标签1",OBJPROP_CORNER,临_in_27); 
  临_in_33 = 0;
  临_ui_34 = Yellow;
  临_in_35 = 80;
  临_in_36 = 10;
  临_st_37 = 总_st_4;
  临_st_38 = "标签2";
  if ( 总_st_4  !=  "" )
   {
   if ( ObjectFind(临_st_38) == -1 )
    {
    ObjectDelete(临_st_38); 
    ObjectCreate(临_st_38,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
    }
   ObjectSet(临_st_38,OBJPROP_XDISTANCE,临_in_36); 
   ObjectSet(临_st_38,OBJPROP_YDISTANCE,临_in_35); 
   ObjectSetText(临_st_38,临_st_37,10,"微软雅黑",临_ui_34); 
   ObjectSet(临_st_38,OBJPROP_CORNER,临_in_33); 
   }
  子_do_4 = lizong_13(NULL,0,0,InpDepth,InpDeviation,InpBackstep) ;
  子_do_5 = lizong_13(NULL,0,1,InpDepth,InpDeviation,InpBackstep) ;
  子_do_6 = lizong_13(NULL,0,2,InpDepth,InpDeviation,InpBackstep) ;
  子_do_7 = lizong_13(NULL,0,3,InpDepth,InpDeviation,InpBackstep) ;
  子_do_8 = lizong_13(NULL,0,4,InpDepth,InpDeviation,InpBackstep) ;
  子_do_9 = lizong_13(NULL,0,5,InpDepth,InpDeviation,InpBackstep) ;
  子_do_10 = lizong_13(NULL,0,6,InpDepth,InpDeviation,InpBackstep) ;
  子_do_11 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,2,0) ;
  子_do_12 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,3,0) ;
  子_do_13 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,2,1) ;
  子_do_14 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,3,1) ;
  子_do_15 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,2,2) ;
  子_do_16 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,3,2) ;
  子_do_17 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,1,0) ;
  子_do_18 = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,1,1) ;
  ArrayResize(子_do_19,400,0); 
  for (子_in_21=0 ; 子_in_21 <= 399 ; 子_in_21 = 子_in_21 + 1)
   {
   子_do_19[子_in_21] = iCustom(NULL,0,"ZigZagMaDiff",InpDepth,InpDeviation,InpBackstep,BigMa,SmallMa,HBD1,HBD2,1,子_in_21);
   }
  子_do_22 = 子_do_19[ArrayMaximum(子_do_19,0,0)] ;
  子_do_23 = 子_do_19[ArrayMinimum(子_do_19,0,0)] ;
  子_do_24 = 子_do_22 - 子_do_23 ;
  子_do_25 = 子_do_24 / 3.0 ;
  子_do_26 = 子_do_22 - 子_do_25 ;
  子_do_27 = 子_do_26 - 子_do_25 ;
  临_in_50 = 0;
  for (临_in_49 = 0 ; 临_in_49 < OrdersTotal() ; 临_in_49=临_in_49 + 1)
   {
   if ( OrderSelect(临_in_49,SELECT_BY_POS,MODE_TRADES) == true && ( OrderMagicNumber() == SellMagic || OrderMagicNumber() == BuyMagic ) )
    {
    临_in_50 = 临_in_50 + 1;
    }
   }
  子_in_28 = 临_in_50 ;
  if ( 总_do_3==0.0 && 子_in_28 != 0 )
   {
   临_do_53 = 0.0;
   for (临_in_55 = OrdersTotal() - 1 ; 临_in_55 >= 0 ; 临_in_55=临_in_55 - 1)
    {
    if ( OrderSelect(临_in_55,SELECT_BY_POS,MODE_TRADES) == true && ( OrderMagicNumber() == SellMagic || OrderMagicNumber() == BuyMagic ) )
     {
     string s=OrderComment();
     StringReplace(s,"MEA_PRO_H02_",""); 
     StringReplace(s,"SELL_",""); 
     StringReplace(s,"BUY_",""); 
     临_do_53 = StringToDouble(s);
     break;
     }
    }
   总_do_3 = 临_do_53 ;
   }
  if ( 子_in_28 == 0 )
   {
   总_do_3 = 0.0 ;
   }
  子_bo_29 = false ;
  子_bo_30 = false ;
  StringSplit(DisableDayOfWeak,44,子_st_31); 
  StringSplit(DisableHourOfDay,44,子_st_32); 
  for (子_in_33=0 ; 子_in_33 < ArraySize(子_st_31) ; 子_in_33 = 子_in_33 + 1)
   {
   if ( DayOfWeek() == StringToInteger(子_st_31[子_in_33]) )
    {
    子_bo_30 = true ;
    break;
    }
   }
  for (子_in_34=0 ; 子_in_34 < ArraySize(子_st_32) ; 子_in_34 = 子_in_34 + 1)
   {
   if ( Hour() == StringToInteger(子_st_32[子_in_34]) )
    {
    子_bo_30 = true ;
    break;
    }
   }
  for (子_in_37 = OrdersTotal() - 1 ; 子_in_37 >= 0 ; 子_in_37 = 子_in_37 - 1)
   {
   if ( OrderSelect(子_in_37,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == SellMagic )
    {
    子_do_35 = OrderLots() ;
    break;
    }
   }
  if ( 子_do_35==0.0 )
   {
   子_do_35 = Lots ;
   子_do_36 = Lots ;
   }
  else
   {
   子_do_36 = 子_do_35 * IncLots ;
   }
  子_do_36 = NormalizeDouble(子_do_36,2) ;
  for (子_in_40 = OrdersTotal() - 1 ; 子_in_40 >= 0 ; 子_in_40 = 子_in_40 - 1)
   {
   if ( OrderSelect(子_in_40,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == BuyMagic )
    {
    子_do_38 = OrderLots() ;
    break;
    }
   }
  if ( 子_do_38==0.0 )
   {
   子_do_38 = Lots ;
   子_do_39 = Lots ;
   }
  else
   {
   子_do_39 = 子_do_38 * IncLots ;
   }
  子_do_39 = NormalizeDouble(子_do_39,2) ;
  临_st_61 = HBD1;
  临_do_62 = 0.0;
  临_do_63 = 1.0;
  临_bo_64 = false;
  if ( Point()==1e-005 )
   {
   临_do_62 = 0.0001;
   }
  else
   {
   if ( Point()==0.001 )
    {
    临_do_62 = 0.01;
    }
   else
    {
    临_do_62 = Point();
   }}
  临_do_66 = MarketInfo(临_st_61,13);
  if ( 临_do_62>Point() && 临_bo_64 )
   {
   临_do_63 = 10.0;
   }
  子_do_41 = NormalizeDouble(临_do_66 / 临_do_63,1) ;
  临_st_70 = HBD2;
  临_do_69 = 0.0;
  临_do_71 = 1.0;
  临_bo_72 = false;
  if ( Point()==1e-005 )
   {
   临_do_69 = 0.0001;
   }
  else
   {
   if ( Point()==0.001 )
    {
    临_do_69 = 0.01;
    }
   else
    {
    临_do_69 = Point();
   }}
  临_do_74 = MarketInfo(临_st_70,13);
  if ( 临_do_69>Point() && 临_bo_72 )
   {
   临_do_71 = 10.0;
   }
  子_do_42 = NormalizeDouble(临_do_74 / 临_do_71,1) ;
  if ( 子_do_41 + 子_do_42>超过多少点差不开单不加仓 )
   {
   子_bo_29 = true ;
   }
  临_do_76 = 0.0;
  for (临_in_77 = 0 ; 临_in_77 < OrdersTotal() ; 临_in_77=临_in_77 + 1)
   {
   if ( OrderSelect(临_in_77,SELECT_BY_POS,MODE_TRADES) == true )
    {
    临_do_76 = 临_do_76 + OrderLots();
    }
   }
  if ( 临_do_76>帐号持仓总手数大于多少不开单不加仓 )
   {
   子_bo_29 = true ;
   }
  // Print(" 1="+(子_do_4>子_do_6)+"  2="+(子_do_4>子_do_8)+"  3="+(子_do_17<子_do_18));
  if ( 子_do_4>子_do_6 && 子_do_4>子_do_8 && 子_do_17<子_do_18 && 子_do_18==子_do_4 && 子_do_17>子_do_26 && 子_bo_29 == false )
   {//Print("单1数="+子_in_28+"  子_do_17="+子_do_17+"  总_do_3="+总_do_3);
   if ( 子_in_28 == 0 && 子_bo_30 == false )
    {if(这一轮结束后不开单 == 1){
      do{子_in_43 = lizong_15(HBD2,子_do_36,0.0,0.0,"金典套利_SELL_" + DoubleToString(子_do_17,5),SellMagic) ; }while(子_in_43 < 0);
      do{子_in_44 = lizong_14(HBD1,子_do_36,0.0,0.0,"金典套利_BUY_" + DoubleToString(子_do_17,5),SellMagic) ;  }while(子_in_44 < 0);     
      总_do_3 = 子_do_17 ;}
    }
   else
    {if(子_do_17 - 总_do_3>=最低加仓间隔 && 子_in_28 <  最多加仓次数 * 2 ){
      do{ 子_in_45 = lizong_15(HBD2,子_do_36,0.0,0.0,"金典套利_SELL_" + DoubleToString(子_do_17,5),SellMagic) ; } while(子_in_45 < 0);
      do{ 子_in_46 = lizong_14(HBD1,子_do_36,0.0,0.0,"金典套利_BUY_" + DoubleToString(子_do_17,5),SellMagic) ;  }while(子_in_46 < 0);     
      总_do_3 = 子_do_17 ;}
   }}
  if ( 子_do_4<子_do_6 && 子_do_4<子_do_8 && 子_do_17>子_do_18 && 子_do_18==子_do_4 && 子_do_17<子_do_27 && 子_bo_29 == false )
   {//Print("单2数="+子_in_28+"  子_do_17="+子_do_17+"  总_do_3="+总_do_3);
   if ( 子_in_28 == 0 && 子_bo_30 == false )
    {
     if(这一轮结束后不开单 == 1){
       do{子_in_47 = lizong_15(HBD1,子_do_39,0.0,0.0,"金典套利_SELL_" + DoubleToString(子_do_17,5),BuyMagic) ;}while(子_in_47 < 0);
       do{子_in_48 = lizong_14(HBD2,子_do_39,0.0,0.0,"金典套利_BUY_" + DoubleToString(子_do_17,5),BuyMagic) ; }while(子_in_48 < 0); 
       总_do_3 = 子_do_17 ;}
    }
   else
    {
    if(总_do_3 - 子_do_17>=最低加仓间隔 && 子_in_28 <  最多加仓次数 * 2 ){
      do{子_in_49 = lizong_15(HBD1,子_do_39,0.0,0.0,"金典套利_SELL_" + DoubleToString(子_do_17,5),BuyMagic) ; }while(子_in_49 < 0);     
      do{子_in_50 = lizong_14(HBD2,子_do_39,0.0,0.0,"金典套利_BUY_" + DoubleToString(子_do_17,5),BuyMagic) ;  }while(子_in_50 < 0); 
      总_do_3 = 子_do_17 ;
   }}}
  临_in_83 = BuyMagic;
  临_do_97 = 0.0;
  for (临_in_96 = 0 ; 临_in_96 < OrdersTotal() ; 临_in_96=临_in_96 + 1)
   {
   if ( OrderSelect(临_in_96,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_83 )
    {
    临_do_97 = 临_do_97 + OrderProfit() + OrderCommission() + OrderSwap();
    }
   }
  子_do_51 = 临_do_97 ;
  临_in_99 = SellMagic;
  临_do_101 = 0.0;
  for (临_in_100 = 0 ; 临_in_100 < OrdersTotal() ; 临_in_100=临_in_100 + 1)
   {
   if ( OrderSelect(临_in_100,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_99 )
    {
    临_do_101 = 临_do_101 + OrderProfit() + OrderCommission() + OrderSwap();
    }
   }
  子_do_52 = 临_do_101 ;
  if ( AccountBalance()!=0.0 )
   {
   if ( AccountProfit() / AccountBalance() * 100.0<= -(LP) && AccountProfit()<0.0 )
    {
    总_bo_6 = true ;
    临_in_105 = BuyMagic;
    for (临_in_106 = OrdersTotal() - 1 ; 临_in_106 >= 0 ; 临_in_106=临_in_106 - 1)
     {
     if ( OrderSelect(临_in_106,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_105 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    }
   if ( 允许均线平仓 == 0 && ( ( 子_do_15>子_do_16 && 子_do_13<子_do_14 && 子_do_11<子_do_12 ) || (子_do_15<子_do_16 && 子_do_13>子_do_14 && 子_do_11>子_do_12) ) && 子_do_51>1.0 )
    {
    临_in_115 = BuyMagic;
    for (临_in_117 = OrdersTotal() - 1 ; 临_in_117 >= 0 ; 临_in_117=临_in_117 - 1)
     {
     if ( OrderSelect(临_in_117,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_115 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    }
   if ( 允许均线平仓 == 0 && ( ( 子_do_15>子_do_16 && 子_do_13<子_do_14 && 子_do_11<子_do_12 ) || (子_do_15<子_do_16 && 子_do_13>子_do_14 && 子_do_11>子_do_12) ) && 子_do_52>1.0 )
    {
    临_in_126 = SellMagic;
    for (临_in_128 = OrdersTotal() - 1 ; 临_in_128 >= 0 ; 临_in_128=临_in_128 - 1)
     {
     if ( OrderSelect(临_in_128,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_126 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    }
   if ( 子_do_51 / AccountBalance() * 100.0>=TP && 子_do_51>0.0 )
    {
    临_in_137 = BuyMagic;
    for (临_in_139 = OrdersTotal() - 1 ; 临_in_139 >= 0 ; 临_in_139=临_in_139 - 1)
     {
     if ( OrderSelect(临_in_139,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_137 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    }
   if ( 子_do_52 / AccountBalance() * 100.0>=TP && 子_do_52>0.0 )
    {
    临_in_148 = SellMagic;
    for (临_in_150 = OrdersTotal() - 1 ; 临_in_150 >= 0 ; 临_in_150=临_in_150 - 1)
     {
     if ( OrderSelect(临_in_150,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_148 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
   }}
  if ( 子_do_51>=GDTP )
   {
   临_in_159 = BuyMagic;
   for (临_in_161 = OrdersTotal() - 1 ; 临_in_161 >= 0 ; 临_in_161=临_in_161 - 1)
    {
    if ( OrderSelect(临_in_161,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_159 )
     {
     if ( OrderType() == 1 )
      {
      RefreshRates(); 
      OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
      }
     if ( OrderType() == 0 )
      {
      RefreshRates(); 
      OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
     }}
    }
   }
  if ( 子_do_52>=GDTP )
   {
   临_in_170 = SellMagic;
   for (临_in_172 = OrdersTotal() - 1 ; 临_in_172 >= 0 ; 临_in_172=临_in_172 - 1)
    {
    if ( OrderSelect(临_in_172,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_170 )
     {
     if ( OrderType() == 1 )
      {
      RefreshRates(); 
      OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
      }
     if ( OrderType() == 0 )
      {
      RefreshRates(); 
      OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
     }}
    }
   }
  临_in_182 = 0;
  for (临_in_181 = 0 ; 临_in_181 < OrdersTotal() ; 临_in_181=临_in_181 + 1)
   {
   if ( OrderSelect(临_in_181,SELECT_BY_POS,MODE_TRADES) == true && ( OrderMagicNumber() == SellMagic || OrderMagicNumber() == BuyMagic ) )
    {
    临_in_182 = 临_in_182 + 1;
    }
   }
  if ( 临_in_182 >= 4 && 允许加仓后微利平仓 == 0 )
   {
   if ( 子_do_52 + 子_do_51>微利金额 )
    {
    临_in_183 = SellMagic;
    for (临_in_185 = OrdersTotal() - 1 ; 临_in_185 >= 0 ; 临_in_185=临_in_185 - 1)
     {
     if ( OrderSelect(临_in_185,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_183 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    临_in_194 = BuyMagic;
    for (临_in_195 = OrdersTotal() - 1 ; 临_in_195 >= 0 ; 临_in_195=临_in_195 - 1)
     {
     if ( OrderSelect(临_in_195,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_194 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    }
   if ( 子_do_51>微利金额 )
    {
    临_in_204 = BuyMagic;
    for (临_in_206 = OrdersTotal() - 1 ; 临_in_206 >= 0 ; 临_in_206=临_in_206 - 1)
     {
     if ( OrderSelect(临_in_206,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_204 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    }
   if ( 子_do_52>微利金额 )
    {
    临_in_215 = SellMagic;
    for (临_in_217 = OrdersTotal() - 1 ; 临_in_217 >= 0 ; 临_in_217=临_in_217 - 1)
     {
     if ( OrderSelect(临_in_217,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_215 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
   }}
  子_st_53 = "" ;
  子_st_54 = "" ;
  子_st_55 = "" ;
  StringSplit(每天微利平仓时段,45,子_st_56); 
  临_in_226 = 0;
  临_ui_227 = Yellow;
  临_in_228 = 180;
  临_in_229 = 10;
  临_st_232 = "每天微利平仓时段:[" + 每天微利平仓时段 + "][现在" + TimeToString(TimeCurrent(),TIME_SECONDS) + "]";
  临_st_233 = "标签6";
  if ( "每天微利平仓时段:[" + 每天微利平仓时段 + "][现在" + TimeToString(TimeCurrent(),TIME_SECONDS) + "]"  !=  "" )
   {
   if ( ObjectFind(临_st_233) == -1 )
    {
    ObjectDelete(临_st_233); 
    ObjectCreate(临_st_233,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
    }
   ObjectSet(临_st_233,OBJPROP_XDISTANCE,临_in_229); 
   ObjectSet(临_st_233,OBJPROP_YDISTANCE,临_in_228); 
   ObjectSetText(临_st_233,临_st_232,10,"微软雅黑",临_ui_227); 
   ObjectSet(临_st_233,OBJPROP_CORNER,临_in_226); 
   }
  if ( StringToTime(子_st_56[0]) <= TimeCurrent() && TimeCurrent() <= StringToTime(子_st_56[1]) )
   {
   临_in_235 = 0;
   临_ui_236 = Yellow;
   临_in_237 = 180;
   临_in_238 = 10;
   临_st_239 = "现在处于每天微利平仓时段:[" + 每天微利平仓时段 + "]";
   临_st_240 = "标签6";
   if ( "现在处于每天微利平仓时段:[" + 每天微利平仓时段 + "]"  !=  "" )
    {
    if ( ObjectFind(临_st_240) == -1 )
     {
     ObjectDelete(临_st_240); 
     ObjectCreate(临_st_240,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
     }
    ObjectSet(临_st_240,OBJPROP_XDISTANCE,临_in_238); 
    ObjectSet(临_st_240,OBJPROP_YDISTANCE,临_in_237); 
    ObjectSetText(临_st_240,临_st_239,10,"微软雅黑",临_ui_236); 
    ObjectSet(临_st_240,OBJPROP_CORNER,临_in_235); 
    }
   子_st_55 = "Ⅱ.现在处于每天微利平仓时段" ;
   }
  else
   {
   子_st_55 = "" ;
   }
  临_in_241 = 0;
  临_ui_242 = Yellow;
  临_in_243 = 105;
  临_in_244 = 10;
  临_st_246 = "加仓设置总手:[" + DoubleToString(总_do_5,4) + "]点差总和:[" + DoubleToString(子_do_41 + 子_do_42,0) + "] 获利:[" + DoubleToString(子_do_51,5) + "] [" + DoubleToString(子_do_52,5) + "]";
  临_st_247 = "标签3";
  if ( "加仓设置总手:[" + DoubleToString(总_do_5,4) + "]点差总和:[" + DoubleToString(子_do_41 + 子_do_42,0) + "] 获利:[" + DoubleToString(子_do_51,5) + "] [" + DoubleToString(子_do_52,5) + "]"  !=  "" )
   {
   if ( ObjectFind(临_st_247) == -1 )
    {
    ObjectDelete(临_st_247); 
    ObjectCreate(临_st_247,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
    }
   ObjectSet(临_st_247,OBJPROP_XDISTANCE,临_in_244); 
   ObjectSet(临_st_247,OBJPROP_YDISTANCE,临_in_243); 
   ObjectSetText(临_st_247,临_st_246,10,"微软雅黑",临_ui_242); 
   ObjectSet(临_st_247,OBJPROP_CORNER,临_in_241); 
   }
  for ( ; 子_in_57 < OrdersTotal() ; 子_in_57 = 子_in_57 + 1)
   {
   if ( OrderSelect(子_in_57,SELECT_BY_POS,MODE_TRADES) == true && ( OrderMagicNumber() == SellMagic || OrderMagicNumber() == BuyMagic ) )
    {
    子_in_58 = TimeCurrent() - OrderOpenTime() ;
    临_in_249 = 0;
    临_ui_250 = Yellow;
    临_in_251 = 130;
    临_in_252 = 10;
    临_st_254 = "第一单开单到现在历时:[" + string(子_in_58 / 60) + "分钟]";
    临_st_255 = "标签4";
    if ( "第一单开单到现在历时:[" + string(子_in_58 / 60) + "分钟]"  !=  "" )
     {
     if ( ObjectFind(临_st_255) == -1 )
      {
      ObjectDelete(临_st_255); 
      ObjectCreate(临_st_255,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
      }
     ObjectSet(临_st_255,OBJPROP_XDISTANCE,临_in_252); 
     ObjectSet(临_st_255,OBJPROP_YDISTANCE,临_in_251); 
     ObjectSetText(临_st_255,临_st_254,10,"微软雅黑",临_ui_250); 
     ObjectSet(临_st_255,OBJPROP_CORNER,临_in_249); 
     }
    if ( 子_in_58 / 60 > 开单多少分钟后每个单子获利都负时全部平仓 )
     {
     子_st_53 = "Ⅱ.已启动每个单子获利都负时全部平仓(时间到)" ;
     临_bo_256=true; 
     for (临_in_253 = 0 ; 临_in_253 < OrdersTotal() ; 临_in_253=临_in_253 + 1)
      {
      if ( OrderSelect(临_in_253,SELECT_BY_POS,MODE_TRADES) == true && ( OrderMagicNumber() == SellMagic || OrderMagicNumber() == BuyMagic ) && OrderProfit()>0.0 )
       {
       临_bo_256 = false;
       break;
       }
      }
     if ( 临_bo_256 == true )
      {
      临_in_257 = SellMagic;
      for (临_in_258 = OrdersTotal() - 1 ; 临_in_258 >= 0 ; 临_in_258=临_in_258 - 1)
       {
       if ( OrderSelect(临_in_258,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_257 )
        {
        if ( OrderType() == 1 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
         }
        if ( OrderType() == 0 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
        }}
       }
      临_in_266 = BuyMagic;
      for (临_in_267 = OrdersTotal() - 1 ; 临_in_267 >= 0 ; 临_in_267=临_in_267 - 1)
       {
       if ( OrderSelect(临_in_267,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_266 )
        {
        if ( OrderType() == 1 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
         }
        if ( OrderType() == 0 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
        }}
       }
     }}
    else
     {
     子_st_53 = "" ;
     }
    if ( 子_in_58 / 60 > 开单多少分钟后启用微利平仓 )
     {
     子_st_54 = "Ⅱ.已启动微利平仓(时间到)" ;
     if ( 子_do_52 + 子_do_51>微利金额 )
      {
      临_in_276 = SellMagic;
      for (临_in_278 = OrdersTotal() - 1 ; 临_in_278 >= 0 ; 临_in_278=临_in_278 - 1)
       {
       if ( OrderSelect(临_in_278,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_276 )
        {
        if ( OrderType() == 1 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
         }
        if ( OrderType() == 0 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
        }}
       }
      临_in_287 = BuyMagic;
      for (临_in_288 = OrdersTotal() - 1 ; 临_in_288 >= 0 ; 临_in_288=临_in_288 - 1)
       {
       if ( OrderSelect(临_in_288,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_287 )
        {
        if ( OrderType() == 1 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
         }
        if ( OrderType() == 0 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
        }}
       }
      }
     if ( 子_do_51>微利金额 )
      {
      临_in_297 = BuyMagic;
      for (临_in_299 = OrdersTotal() - 1 ; 临_in_299 >= 0 ; 临_in_299=临_in_299 - 1)
       {
       if ( OrderSelect(临_in_299,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_297 )
        {
        if ( OrderType() == 1 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
         }
        if ( OrderType() == 0 )
         {
         RefreshRates(); 
         OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
        }}
       }
      }
     if ( !(子_do_52>微利金额) )   break;
     临_in_308 = SellMagic;
     for (临_in_310 = OrdersTotal() - 1 ; 临_in_310 >= 0 ; 临_in_310=临_in_310 - 1)
      {
      if ( OrderSelect(临_in_310,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_308 )
       {
       if ( OrderType() == 1 )
        {
        RefreshRates(); 
        OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
        }
       if ( OrderType() == 0 )
        {
        RefreshRates(); 
        OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
       }}
      }
     break;
     }
    子_st_54 = "" ;
    break;
    }
   }
  临_in_320 = 0;
  for (临_in_319 = 0 ; 临_in_319 < OrdersTotal() ; 临_in_319=临_in_319 + 1)
   {
   if ( OrderSelect(临_in_319,SELECT_BY_POS,MODE_TRADES) == true && ( OrderMagicNumber() == SellMagic || OrderMagicNumber() == BuyMagic ) )
    {
    临_in_320 = 临_in_320 + 1;
    }
   }
  if ( 临_in_320 == 0 )
   {
   临_in_321 = 0;
   临_ui_322 = Yellow;
   临_in_323 = 130;
   临_in_324 = 10;
   临_st_325 = "第一单开单到现在历时:[持仓为空]";
   if ( ObjectFind("标签4") == -1 )
    {
    ObjectDelete("标签4"); 
    ObjectCreate("标签4",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
    }
   ObjectSet("标签4",OBJPROP_XDISTANCE,临_in_324); 
   ObjectSet("标签4",OBJPROP_YDISTANCE,临_in_323); 
   ObjectSetText("标签4",临_st_325,10,"微软雅黑",临_ui_322); 
   ObjectSet("标签4",OBJPROP_CORNER,临_in_321); 
   }
  临_in_327 = 0;
  临_ui_328 = Yellow;
  临_in_329 = 155;
  临_in_330 = 10;
  临_st_332 = 子_st_53 + 子_st_54 + 子_st_55;
  临_st_333 = "标签5";
  if ( 子_st_53 + 子_st_54 + 子_st_55  !=  "" )
   {
   if ( ObjectFind(临_st_333) == -1 )
    {
    ObjectDelete(临_st_333); 
    ObjectCreate(临_st_333,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
    }
   ObjectSet(临_st_333,OBJPROP_XDISTANCE,临_in_330); 
   ObjectSet(临_st_333,OBJPROP_YDISTANCE,临_in_329); 
   ObjectSetText(临_st_333,临_st_332,10,"微软雅黑",临_ui_328); 
   ObjectSet(临_st_333,OBJPROP_CORNER,临_in_327); 
   }
  if ( 禁用按钮 == 1 )
   {
   临_ui_334 = 0;
   临_ui_335 = Red;
   临_in_336 = 3;
   临_in_337 = 30;
   临_in_338 = 300;
   临_in_339 = 40;
   临_in_340 = 300;
   临_st_341 = "全平按钮(" + string(BuyMagic) + "," + string(SellMagic) + ")";
   临_st_343 = "全平按钮(" + string(BuyMagic) + "," + string(SellMagic) + ")";
   if ( ObjectFind(0,"标签全平按钮") == -1 )
    {
    ObjectCreate(0,"标签全平按钮",OBJ_BUTTON,0,0,0.0); 
    }
   ObjectSetInteger(0,"标签全平按钮",OBJPROP_XDISTANCE,临_in_340); 
   ObjectSetInteger(0,"标签全平按钮",OBJPROP_YDISTANCE,临_in_339); 
   ObjectSetInteger(0,"标签全平按钮",OBJPROP_XSIZE,临_in_338); 
   ObjectSetInteger(0,"标签全平按钮",OBJPROP_YSIZE,临_in_337); 
   ObjectSetString(0,"标签全平按钮",OBJPROP_FONT,"微软雅黑"); 
   ObjectSetInteger(0,"标签全平按钮",OBJPROP_FONTSIZE,10); 
   ObjectSetInteger(0,"标签全平按钮",OBJPROP_CORNER,临_in_336); 
   if ( ObjectGetInteger(0,"标签全平按钮",1018,0) == 1 )
    {
    ObjectSetInteger(0,"标签全平按钮",OBJPROP_COLOR,临_ui_335); 
    ObjectSetInteger(0,"标签全平按钮",OBJPROP_BGCOLOR,临_ui_334); 
    ObjectSetString(0,"标签全平按钮",OBJPROP_TEXT,临_st_343); 
    }
   else
    {
    ObjectSetInteger(0,"标签全平按钮",OBJPROP_COLOR,临_ui_334); 
    ObjectSetInteger(0,"标签全平按钮",OBJPROP_BGCOLOR,临_ui_335); 
    ObjectSetString(0,"标签全平按钮",OBJPROP_TEXT,临_st_341); 
    }
   临_ui_346 = White;
   临_ui_347 = Green;
   临_in_348 = 3;
   临_in_349 = 30;
   临_in_350 = 300;
   临_in_351 = 80;
   临_in_352 = 300;
   临_st_354 = "一键开多" + HBD1 + "空" + HBD2 + "各 " + string(子_do_36) + " 手";
   临_st_356 = "一键开 多" + HBD1 + " 空" + HBD2 + "各" + string(子_do_36) + "(" + string(子_do_39) + ")手";
   if ( ObjectFind(0,"标签一键开仓1") == -1 )
    {
    ObjectCreate(0,"标签一键开仓1",OBJ_BUTTON,0,0,0.0); 
    }
   ObjectSetInteger(0,"标签一键开仓1",OBJPROP_XDISTANCE,临_in_352); 
   ObjectSetInteger(0,"标签一键开仓1",OBJPROP_YDISTANCE,临_in_351); 
   ObjectSetInteger(0,"标签一键开仓1",OBJPROP_XSIZE,临_in_350); 
   ObjectSetInteger(0,"标签一键开仓1",OBJPROP_YSIZE,临_in_349); 
   ObjectSetString(0,"标签一键开仓1",OBJPROP_FONT,"微软雅黑"); 
   ObjectSetInteger(0,"标签一键开仓1",OBJPROP_FONTSIZE,10); 
   ObjectSetInteger(0,"标签一键开仓1",OBJPROP_CORNER,临_in_348); 
   if ( ObjectGetInteger(0,"标签一键开仓1",1018,0) == 1 )
    {
    ObjectSetInteger(0,"标签一键开仓1",OBJPROP_COLOR,临_ui_347); 
    ObjectSetInteger(0,"标签一键开仓1",OBJPROP_BGCOLOR,临_ui_346); 
    ObjectSetString(0,"标签一键开仓1",OBJPROP_TEXT,临_st_356); 
    }
   else
    {
    ObjectSetInteger(0,"标签一键开仓1",OBJPROP_COLOR,临_ui_346); 
    ObjectSetInteger(0,"标签一键开仓1",OBJPROP_BGCOLOR,临_ui_347); 
    ObjectSetString(0,"标签一键开仓1",OBJPROP_TEXT,临_st_354); 
    }
   临_ui_359 = White;
   临_ui_360 = Green;
   临_in_361 = 3;
   临_in_362 = 30;
   临_in_363 = 300;
   临_in_364 = 120;
   临_in_365 = 300;
   临_st_367 = "一键开空" + HBD1 + "多" + HBD2 + "各 " + string(子_do_36) + " 手";
   临_st_369 = "一键开 空" + HBD1 + " 多" + HBD2 + "各" + string(子_do_36) + "(" + string(子_do_39) + ")手";
   if ( ObjectFind(0,"标签一键开仓2") == -1 )
    {
    ObjectCreate(0,"标签一键开仓2",OBJ_BUTTON,0,0,0.0); 
    }
   ObjectSetInteger(0,"标签一键开仓2",OBJPROP_XDISTANCE,临_in_365); 
   ObjectSetInteger(0,"标签一键开仓2",OBJPROP_YDISTANCE,临_in_364); 
   ObjectSetInteger(0,"标签一键开仓2",OBJPROP_XSIZE,临_in_363); 
   ObjectSetInteger(0,"标签一键开仓2",OBJPROP_YSIZE,临_in_362); 
   ObjectSetString(0,"标签一键开仓2",OBJPROP_FONT,"微软雅黑"); 
   ObjectSetInteger(0,"标签一键开仓2",OBJPROP_FONTSIZE,10); 
   ObjectSetInteger(0,"标签一键开仓2",OBJPROP_CORNER,临_in_361); 
   if ( ObjectGetInteger(0,"标签一键开仓2",1018,0) == 1 )
    {
    ObjectSetInteger(0,"标签一键开仓2",OBJPROP_COLOR,临_ui_360); 
    ObjectSetInteger(0,"标签一键开仓2",OBJPROP_BGCOLOR,临_ui_359); 
    ObjectSetString(0,"标签一键开仓2",OBJPROP_TEXT,临_st_369); 
    }
   else
    {
    ObjectSetInteger(0,"标签一键开仓2",OBJPROP_COLOR,临_ui_359); 
    ObjectSetInteger(0,"标签一键开仓2",OBJPROP_BGCOLOR,临_ui_360); 
    ObjectSetString(0,"标签一键开仓2",OBJPROP_TEXT,临_st_367); 
   }}
  if ( 禁用按钮 == 1 )
   {
   if ( ObjectGetInteger(0,"标签全平按钮",1018,0) == 1 )
    {
    临_in_372 = SellMagic;
    for (临_in_373 = OrdersTotal() - 1 ; 临_in_373 >= 0 ; 临_in_373=临_in_373 - 1)
     {
     if ( OrderSelect(临_in_373,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_372 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),100,0xFFFFFFFF); 
      }}
     }
    临_in_382 = BuyMagic;
    for (临_in_383 = OrdersTotal() - 1 ; 临_in_383 >= 0 ; 临_in_383=临_in_383 - 1)
     {
     if ( OrderSelect(临_in_383,SELECT_BY_POS,MODE_TRADES) == true && OrderMagicNumber() == 临_in_382 )
      {
      if ( OrderType() == 1 )
       {
       RefreshRates(); 
       OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),100,0xFFFFFFFF); 
       }
      if ( OrderType() == 0 )
       {
       RefreshRates(); 
       临_do_390 = MarketInfo(OrderSymbol(),9);
       临_do_391 = OrderLots();
       OrderClose(OrderTicket(),临_do_391,临_do_390,100,0xFFFFFFFF); 
      }}
     }
    }
   临_in_393 = 0;
   for (临_in_392 = 0 ; 临_in_392 < OrdersTotal() ; 临_in_392=临_in_392 + 1)
    {
    if ( OrderSelect(临_in_392,SELECT_BY_POS,MODE_TRADES) == true && ( OrderMagicNumber() == SellMagic || OrderMagicNumber() == BuyMagic ) )
     {
     临_in_393 = 临_in_393 + 1;
     }
    }
   if ( 临_in_393 == 0 )
    {
    ObjectSetInteger(0,"标签全平按钮",OBJPROP_STATE,0); 
   }}
  else
   {
   ObjectSetInteger(0,"标签全平按钮",OBJPROP_STATE,0); 
   ObjectSetInteger(0,"标签一键开仓1",OBJPROP_STATE,0); 
   ObjectSetInteger(0,"标签一键开仓2",OBJPROP_STATE,0); 
   }
  ArrayFree(子_st_56);
  ArrayFree(子_st_32);
  ArrayFree(子_st_31);
  ArrayFree(子_do_19);
  ArrayFree(子_st_1);
  }
 }
//OnTick
//---------------------  ----------------------------------------

 void OnTimer ()
 {

//----------------------------

 if ( IsConnected() == false )
  {
  SendMail(string(AccountNumber()) + "-已经断线，请检查！！！",string(AccountNumber()) + "以断线，请检查！！！"); 
  }
 }
//OnTimer
//---------------------  ----------------------------------------

 void OnChartEvent (const int 木_0, const long &木_1, const double &木_2, const string &木_3)
 {

//----------------------------

 OnTick(); 
 }
//OnChartEvent
//---------------------  ----------------------------------------

 void OnDeinit (const int 木_0)
 {

//----------------------------
 int        临_in_1;  //3642

 for (临_in_1 = ObjectsTotal(-1) ; 临_in_1 >= 0 ; 临_in_1=临_in_1 - 1)
  {
  if ( StringFind(ObjectName(临_in_1),"标签",0) == 0 )
   {
   ObjectDelete(ObjectName(临_in_1)); 
   临_in_1 = ObjectsTotal(-1);
   }
  }
 EventKillTimer(); 
 }
//OnDeinit
//---------------------  ----------------------------------------


//----------------------------


//----------------------------

 double lizong_13 (string   木_0,int 木_1,int 木_2,int 木_3,int 木_4,int 木_5)
 {
 double      子_do_1;
 int         子_in_2;
 int         子_in_3;
 int         子_in_4;

//----------------------------
 int        临_in_1;
 uint       临_ui_2;  //3734
 int        临_in_3;  //3735
 int        临_in_4;  //3736
 string     临_st_5;  //3737
 int        临_in_9;  //3789
 uint       临_ui_10;  //3790
 int        临_in_11;  //3791
 int        临_in_12;  //3792
 string     临_st_14;  //3797
 string     临_st_15;  //3798

 if ( ( 木_0 == "" || 木_0 == "0" ) )
  {
  木_0 = Symbol() ;
  }
 子_in_3 = iBars(NULL, ) ;
 for (子_in_2 = 0 ; 子_in_2 < 子_in_3 ; 子_in_2 = 子_in_2 + 1)
  {
  子_do_1 = iCustom(木_0,木_1,"ZigZagMaDiff",木_3,木_4,木_5,BigMa,SmallMa,HBD1,HBD2,0,子_in_2) ;
  if ( GetLastError() == 4072 )
   {
   临_in_1 = 0;
   临_ui_2 = Red;
   临_in_3 = 205;
   临_in_4 = 10;
   临_st_5 = "错误:指标没有正确安装，请把 ZigZagMaDiff.ex4 安装到指标目录下！";
   if ( ObjectFind("标签7") == -1 )
    {
    ObjectDelete("标签7"); 
    ObjectCreate("标签7",OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
    }
   ObjectSet("标签7",OBJPROP_XDISTANCE,临_in_4); 
   ObjectSet("标签7",OBJPROP_YDISTANCE,临_in_3); 
   ObjectSetText("标签7",临_st_5,10,"微软雅黑",临_ui_2); 
   ObjectSet("标签7",OBJPROP_CORNER,临_in_1); 
   return(0.0); 
   }
  if ( 子_do_1!=0.0 )
   {
   子_in_4 = 子_in_4 + 1;
   if ( 子_in_4 > 木_2 )
    {
    return(子_do_1); 
   }}
  }
 临_in_9 = 0;
 临_ui_10 = Red;
 临_in_11 = 205;
 临_in_12 = 10;
 临_st_14 = "错误:K线数不够，请在 " + HBD1 + " 和 " + HBD2 + " 图表上向左拉！";
 临_st_15 = "标签7";
 if ( "错误:K线数不够，请在 " + HBD1 + " 和 " + HBD2 + " 图表上向左拉！"  !=  "" )
  {
  if ( ObjectFind(临_st_15) == -1 )
   {
   ObjectDelete(临_st_15); 
   ObjectCreate(临_st_15,OBJ_LABEL,0,0,0.0,0,0.0,0,0.0); 
   }
  ObjectSet(临_st_15,OBJPROP_XDISTANCE,临_in_12); 
  ObjectSet(临_st_15,OBJPROP_YDISTANCE,临_in_11); 
  ObjectSetText(临_st_15,临_st_14,10,"微软雅黑",临_ui_10); 
  ObjectSet(临_st_15,OBJPROP_CORNER,临_in_9); 
  }
 return(0.0); 
 }
//lizong_13
//---------------------  ----------------------------------------

 int lizong_14 (string 木_0,double 木_1,double 木_2,double 木_3,string 木_4,int 木_5)
 {
 int         子_in_1;
 bool        子_bo_2;
 int         子_in_3;
 string      子_st_4;
 int         子_in_5;
 double      子_do_6;

//----------------------------

 for ( ; 子_in_3 < OrdersTotal() ; 子_in_3 = 子_in_3 + 1)
  {
  if ( OrderSelect(子_in_3,SELECT_BY_POS,MODE_TRADES) == true )
   {
   子_st_4 = OrderComment() ;
   子_in_5 = OrderMagicNumber() ;
   if ( OrderSymbol() == 木_0 && OrderType() == 0 && 子_st_4 == 木_4 && 子_in_5 == 木_5 )
    {
    子_bo_2 = true ;
    break;
    }
   }
  }
 if ( 子_bo_2 == false )
  {
  RefreshRates(); 
  子_do_6 = NormalizeDouble(MarketInfo(木_0,10),5) ;
  if ( 木_2!=0.0 && 木_3==0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_BUY,木_1,子_do_6,50,子_do_6 - 木_2 * Point(),0.0,木_4,木_5,0,White) ;
   }
  if ( 木_2==0.0 && 木_3!=0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_BUY,木_1,子_do_6,50,0.0,木_3 * Point() + 子_do_6,木_4,木_5,0,White) ;
   }
  if ( 木_2==0.0 && 木_3==0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_BUY,木_1,子_do_6,50,0.0,0.0,木_4,木_5,0,White) ;
   }
  if ( 木_2!=0.0 && 木_3!=0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_BUY,木_1,子_do_6,50,子_do_6 - 木_2 * Point(),木_3 * Point() + 子_do_6,木_4,木_5,0,White) ;
  }}
 return(子_in_1); 
 }
//lizong_14
//---------------------  ----------------------------------------

 int lizong_15 (string 木_0,double 木_1,double 木_2,double 木_3,string 木_4,int 木_5)
 {
 int         子_in_1;
 bool        子_bo_2;
 int         子_in_3;
 string      子_st_4;
 int         子_in_5;
 double      子_do_6;

//----------------------------

 for ( ; 子_in_3 < OrdersTotal() ; 子_in_3 = 子_in_3 + 1)
  {
  if ( OrderSelect(子_in_3,SELECT_BY_POS,MODE_TRADES) == true )
   {
   子_st_4 = OrderComment() ;
   子_in_5 = OrderMagicNumber() ;
   if ( OrderSymbol() == 木_0 && OrderType() == 1 && 子_st_4 == 木_4 && 子_in_5 == 木_5 )
    {
    子_bo_2 = true ;
    break;
    }
   }
  }
 if ( 子_bo_2 == false )
  {
  RefreshRates(); 
  子_do_6 = NormalizeDouble(MarketInfo(木_0,9),5) ;
  if ( 木_2==0.0 && 木_3!=0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_SELL,木_1,子_do_6,50,0.0,子_do_6 - 木_3 * Point(),木_4,木_5,0,Red) ;
   }
  if ( 木_2!=0.0 && 木_3==0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_SELL,木_1,子_do_6,50,木_2 * Point() + 子_do_6,0.0,木_4,木_5,0,Red) ;
   }
  if ( 木_2==0.0 && 木_3==0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_SELL,木_1,子_do_6,50,0.0,0.0,木_4,木_5,0,Red) ;
   }
  if ( 木_2!=0.0 && 木_3!=0.0 )
   {
   子_in_1 = OrderSend(木_0,OP_SELL,木_1,子_do_6,50,木_2 * Point() + 子_do_6,子_do_6 - 木_3 * Point(),木_4,木_5,0,Red) ;
  }}
 return(子_in_1); 
 }
//lizong_15
//---------------------  ----------------------------------------

 bool lizong_16 (string 木_0)
 {
 int         子_in_1;
 string      子_st_2;
 string      子_st_3;
 int         子_in_4[1];
 string      子_st_5;
 uchar       子_uc_6[1024];
 string      子_st_7;
 string      子_st_8;
 int         子_in_9;
 int         子_in_10;
 int         子_in_11;

//----------------------------

 子_in_1 = AccountInfoInteger(32) ;
 switch(子_in_1)
  {
  case 0 :
   子_st_2 = "demo" ;
      break;
  case 1 :
   子_st_2 = "contest" ;
      break;
  default :
   子_st_2 = "real" ;
  }
 子_st_3 = AccountNumber() ;
 子_st_5 = "" ;
 子_st_7 = lizong_17(总_st_1 + "|" + 子_st_3 + "|" + 子_st_2) ;
 子_st_8 = lizong_17(总_st_1 + "|" + 子_st_3 + "|" + 子_st_2 + "|ABCC") ;
 子_in_9 = InternetOpenW(" ",0," "," ",0) ;
 子_in_10 = InternetConnectW(子_in_9,"",80,"","",3,0,1) ;
 子_in_11 = InternetOpenUrlW(子_in_9,"http://www.jinrongjiaoyizhe.com/forex/check.php?a=" + 子_st_3 + "&u=" + 总_st_1 + "&t=" + 子_st_2 + "&c=" + 子_st_7 + "&s=" + 木_0,NULL,0,0,0) ;
 while (!(IsStopped()))
  {
  InternetReadFile(子_in_11,子_uc_6,1024,子_in_4); 
  if ( !(子_in_4[0] > 0) )   break;
  子_st_5 = 子_st_5 + CharArrayToString(子_uc_6,0,子_in_4[0],0x3A8);
  }
 ArrayFree(子_uc_6);
 if ( 子_in_11 > 0 )
  {
  InternetCloseHandle(子_in_11); 
  }
 if ( 子_in_10 > 0 )
  {
  InternetCloseHandle(子_in_10); 
  }
 if ( 子_in_9 > 0 )
  {
  InternetCloseHandle(子_in_9); 
  }
 if ( 子_st_5 == 子_st_8 )
  {
  return(true); 
  ArrayFree(子_uc_6);
  ArrayFree(子_in_4);
  }
 return(false); 
 ArrayFree(子_uc_6);
 ArrayFree(子_in_4);
 }
//lizong_16
//---------------------  ----------------------------------------

 string lizong_17 (string 木_0)
 {
 int         子_in_1;
 int         子_in_2;
 int         子_in_3;
 int         子_in_4;
 int         子_in_5;
 int         子_in_6;
 int         子_in_7;
 int         子_in_8[16];
 int         子_in_9[16];
 int         子_in_10;
 int         子_in_11;
 int         子_in_12[4];
 int         子_in_13;
 string      子_st_14;
 int         子_in_15;

//----------------------------
 string     临_st_2;  //4356
 int        临_in_3;  //4358
 int        临_in_4;  //4359
 int        临_in_1;
 string     临_st_9;  //4437
 int        临_in_10;  //4439
 int        临_in_11;  //4440
 int        临_in_8;

 子_in_1=StringLen(木_0); 
 子_in_2 = 子_in_1 % 64;
 子_in_3 = (子_in_1 - 子_in_2) / 64;
 子_in_4 = 1732584193 ;
 子_in_5 = -271733879 ;
 子_in_6 = -1732584194 ;
 子_in_7 = 271733878 ;
 for (子_in_10 = 0 ; 子_in_10 < 子_in_3 ; 子_in_10 = 子_in_10 + 1)
  {
  子_st_14 = StringSubstr(木_0,子_in_10 * 64,64) ;
  临_st_2 = 子_st_14;
  临_in_3 = 0;
  临_in_4 = 0;
  临_in_1 = StringLen(子_st_14) ;
  if ( StringLen(子_st_14)  % 4 != 0 )
   {
   临_in_1 = StringLen(子_st_14)  - StringLen(子_st_14)  % 4;
   }
  if ( ArraySize(子_in_8) <  临_in_1 / 4 )
   {
   ArrayResize(子_in_8,临_in_1 / 4,0); 
   }
  临_in_3 = 0;
  临_in_4 = 0;
   for (临_in_4 = 0 ; 临_in_4 < 临_in_1 ; 临_in_4 = 临_in_4 + 4)
   {
   子_in_8[临_in_3] = (StringGetCharacter(临_st_2,临_in_4) | (StringGetCharacter(临_st_2,临_in_4 + 1) << 8)) | (StringGetCharacter(临_st_2,临_in_4 + 2) << 16) | (StringGetCharacter(临_st_2,临_in_4 + 3) << 24);
   临_in_3=临_in_3 + 1; 
   }   
  lizong_19(子_in_4,子_in_5,子_in_6,子_in_7,子_in_8); 
  }
 ArrayInitialize(子_in_9,0); 
 ArrayInitialize(子_in_12,0); 
 子_in_13 = 0 ;
 if ( 子_in_2 > 0 )
  {
  子_in_15 = 子_in_2 % 4;
  子_in_3 = 子_in_2 - 子_in_15;
  if ( 子_in_3 > 0 )
   {
   子_st_14 = StringSubstr(木_0,子_in_10 * 64,子_in_3) ;
   临_st_9 = 子_st_14;
   临_in_10 = 0;
   临_in_11 = 0;
   临_in_8 = StringLen(子_st_14) ;
   if ( StringLen(子_st_14)  % 4 != 0 )
    {
    临_in_8 = StringLen(子_st_14)  - StringLen(子_st_14)  % 4;
    }
   if ( ArraySize(子_in_9) <  临_in_8 / 4 )
    {
    ArrayResize(子_in_9,临_in_8 / 4,0); 
    }
   临_in_10 = 0;
   临_in_11 = 0;
   for (临_in_11 = 0 ; 临_in_11 < 临_in_8 ; 临_in_11 = 临_in_11 + 4)   

    {
    子_in_9[临_in_10] = (StringGetCharacter(临_st_9,临_in_11) | (StringGetCharacter(临_st_9,临_in_11 + 1) << 8)) | (StringGetCharacter(临_st_9,临_in_11 + 2) << 16) | (StringGetCharacter(临_st_9,临_in_11 + 3) << 24);
    临_in_10=临_in_10 + 1; 
    }
   子_in_13 = 临_in_8 / 4;
   }
  for (子_in_11 = 0 ; 子_in_11 < 子_in_15 ; 子_in_11 = 子_in_11 + 1)
   {
   子_in_12[子_in_11] = StringGetCharacter(木_0,子_in_10 * 64 + 子_in_3 + 子_in_11);
   }
  }
 子_in_12[子_in_11] = 128;
 子_in_9[子_in_13] = 子_in_12[0] | (子_in_12[1] << 8) | (子_in_12[2] << 16) | (子_in_12[3] << 24);
 if ( 子_in_2 >= 56 )
  {
  lizong_19(子_in_4,子_in_5,子_in_6,子_in_7,子_in_9); 
  ArrayInitialize(子_in_9,0); 
  }
 子_in_9[14] = 子_in_1 << 3;
 子_in_9[15] = ((子_in_1 >> 1) & 0x7FFFFFFF) >> 28;
 lizong_19(子_in_4,子_in_5,子_in_6,子_in_7,子_in_9); 
 ArrayFree(子_in_12);
 ArrayFree(子_in_9);
 ArrayFree(子_in_8);
 return(StringConcatenate(lizong_18(子_in_4),lizong_18(子_in_5),lizong_18(子_in_6),lizong_18(子_in_7)));
 }
//lizong_17
//---------------------  ----------------------------------------

 string lizong_18 (int 木_0)
 {
 string      子_st_1;
 string      子_st_2;
 int         子_in_3[4];
 int         子_in_4;
 int         子_in_5;

//----------------------------
 int        临_in_3;
 int        临_in_5;  //4657
 int        临_in_6;  //4659
 int        临_in_8;
 string     临_st_9;  //4667
 int        临_in_10;  //4668
 string     临_st_13;  //4689

 子_st_1 = "" ;
 子_in_3[0] = 木_0 & Red;
 for (子_in_4 = 1 ; 子_in_4 < 4 ; 子_in_4 = 子_in_4 + 1)
  {
  临_in_3=子_in_4 * 8 - 1; 
  子_in_3[子_in_4] = (((木_0 >> 1) & 0x7FFFFFFF) >> 临_in_3) & Red;
  }
 for ( ; 子_in_5 < 4 ; 子_in_5 = 子_in_5 + 1)
  {
  临_in_5 = 子_in_3[子_in_5];
  for (临_in_6 = 0 ; 临_in_6 < 2 ; 临_in_6=临_in_6 + 1)
   {
   临_in_5 = (临_in_5 - 临_in_5 % 16) / 16;
   临_in_8 = 临_in_5 % 16;
   临_st_9 = "0";
   临_in_10 = 0;
   if ( 临_in_5 % 16 <  10 )
    {
    临_in_10 = 临_in_5 % 16 + 48;
    }
   else
    {
    临_in_10 = 临_in_8 + 97 - 10;
    }
   临_st_13 = StringConcatenate(StringSetChar(临_st_9,0,临_in_10));
   }
  子_st_2 = StringConcatenate(StringSetChar(临_st_9,0,临_in_10)) ;
  子_st_1 = StringConcatenate(子_st_1,子_st_2) ;
  }
 ArrayFree(子_in_3);
 return(子_st_1);
 }
//lizong_18
//---------------------  ----------------------------------------

 void lizong_19 (int  & 木_0,int  & 木_1,int  & 木_2,int  & 木_3,int  & 木_4[])
 {
 int         子_in_1;
 int         子_in_2;
 int         子_in_3;
 int         子_in_4;
 int         子_in_5;
 int         子_in_6;
 int         子_in_7;
 int         子_in_8;
 int         子_in_9;
 int         子_in_10;
 int         子_in_11;
 int         子_in_12;
 int         子_in_13;
 int         子_in_14;
 int         子_in_15;
 int         子_in_16;
 int         子_in_17;
 int         子_in_18;
 int         子_in_19;
 int         子_in_20;

//----------------------------
 int        临_in_5;
 int        临_in_17;
 int        临_in_20;  //4783
 int        临_in_21;  //4784
 int        临_in_22;  //4785
 int        临_in_19;
 int        临_in_33;
 int        临_in_36;  //4817
 int        临_in_37;  //4818
 int        临_in_38;  //4819
 int        临_in_35;
 int        临_in_49;
 int        临_in_52;  //4851
 int        临_in_53;  //4852
 int        临_in_54;  //4853
 int        临_in_51;
 int        临_in_58;
 int        临_in_65;
 int        临_in_68;  //4885
 int        临_in_69;  //4886
 int        临_in_70;  //4887
 int        临_in_67;
 int        临_in_81;
 int        临_in_84;  //4919
 int        临_in_85;  //4920
 int        临_in_86;  //4921
 int        临_in_83;
 int        临_in_97;
 int        临_in_100;  //4953
 int        临_in_101;  //4954
 int        临_in_102;  //4955
 int        临_in_99;
 int        临_in_113;
 int        临_in_116;  //4987
 int        临_in_117;  //4988
 int        临_in_118;  //4989
 int        临_in_115;
 int        临_in_129;
 int        临_in_132;  //5021
 int        临_in_133;  //5022
 int        临_in_134;  //5023
 int        临_in_131;
 int        临_in_145;
 int        临_in_148;  //5055
 int        临_in_149;  //5056
 int        临_in_150;  //5057
 int        临_in_147;
 int        临_in_161;
 int        临_in_164;  //5089
 int        临_in_165;  //5090
 int        临_in_166;  //5091
 int        临_in_163;
 int        临_in_177;
 int        临_in_180;  //5123
 int        临_in_181;  //5124
 int        临_in_182;  //5125
 int        临_in_179;
 int        临_in_193;
 int        临_in_196;  //5157
 int        临_in_197;  //5158
 int        临_in_198;  //5159
 int        临_in_195;
 int        临_in_209;
 int        临_in_212;  //5191
 int        临_in_213;  //5192
 int        临_in_214;  //5193
 int        临_in_211;
 int        临_in_225;
 int        临_in_228;  //5225
 int        临_in_229;  //5226
 int        临_in_230;  //5227
 int        临_in_227;
 int        临_in_241;
 int        临_in_244;  //5259
 int        临_in_245;  //5260
 int        临_in_246;  //5261
 int        临_in_243;
 int        临_in_257;
 int        临_in_260;  //5293
 int        临_in_261;  //5294
 int        临_in_262;  //5295
 int        临_in_259;
 int        临_in_273;
 int        临_in_276;  //5327
 int        临_in_277;  //5328
 int        临_in_278;  //5329
 int        临_in_275;
 int        临_in_289;
 int        临_in_292;  //5361
 int        临_in_293;  //5362
 int        临_in_294;  //5363
 int        临_in_291;
 int        临_in_305;
 int        临_in_308;  //5395
 int        临_in_309;  //5396
 int        临_in_310;  //5397
 int        临_in_307;
 int        临_in_321;
 int        临_in_324;  //5429
 int        临_in_325;  //5430
 int        临_in_326;  //5431
 int        临_in_323;
 int        临_in_337;
 int        临_in_340;  //5463
 int        临_in_341;  //5464
 int        临_in_342;  //5465
 int        临_in_339;
 int        临_in_353;
 int        临_in_356;  //5497
 int        临_in_357;  //5498
 int        临_in_358;  //5499
 int        临_in_355;
 int        临_in_369;
 int        临_in_372;  //5531
 int        临_in_373;  //5532
 int        临_in_374;  //5533
 int        临_in_371;
 int        临_in_385;
 int        临_in_388;  //5565
 int        临_in_389;  //5566
 int        临_in_390;  //5567
 int        临_in_387;
 int        临_in_401;
 int        临_in_404;  //5599
 int        临_in_405;  //5600
 int        临_in_406;  //5601
 int        临_in_403;
 int        临_in_417;
 int        临_in_420;  //5633
 int        临_in_421;  //5634
 int        临_in_422;  //5635
 int        临_in_419;
 int        临_in_433;
 int        临_in_436;  //5667
 int        临_in_437;  //5668
 int        临_in_438;  //5669
 int        临_in_435;
 int        临_in_449;
 int        临_in_452;  //5701
 int        临_in_453;  //5702
 int        临_in_454;  //5703
 int        临_in_451;
 int        临_in_465;
 int        临_in_468;  //5735
 int        临_in_469;  //5736
 int        临_in_470;  //5737
 int        临_in_467;
 int        临_in_481;
 int        临_in_484;  //5769
 int        临_in_485;  //5770
 int        临_in_486;  //5771
 int        临_in_483;
 int        临_in_497;
 int        临_in_500;  //5803
 int        临_in_501;  //5804
 int        临_in_502;  //5805
 int        临_in_499;
 int        临_in_513;
 int        临_in_515;  //5835
 int        临_in_516;  //5836
 int        临_in_517;  //5837
 int        临_in_514;
 int        临_in_528;
 int        临_in_530;  //5867
 int        临_in_531;  //5868
 int        临_in_532;  //5869
 int        临_in_529;
 int        临_in_543;
 int        临_in_545;  //5899
 int        临_in_546;  //5900
 int        临_in_547;  //5901
 int        临_in_544;
 int        临_in_558;
 int        临_in_560;  //5931
 int        临_in_561;  //5932
 int        临_in_562;  //5933
 int        临_in_559;
 int        临_in_573;
 int        临_in_575;  //5963
 int        临_in_576;  //5964
 int        临_in_577;  //5965
 int        临_in_574;
 int        临_in_588;
 int        临_in_590;  //5995
 int        临_in_591;  //5996
 int        临_in_592;  //5997
 int        临_in_589;
 int        临_in_603;
 int        临_in_605;  //6027
 int        临_in_606;  //6028
 int        临_in_607;  //6029
 int        临_in_604;
 int        临_in_611;
 int        临_in_618;
 int        临_in_620;  //6059
 int        临_in_621;  //6060
 int        临_in_622;  //6061
 int        临_in_619;
 int        临_in_633;
 int        临_in_635;  //6091
 int        临_in_636;  //6092
 int        临_in_637;  //6093
 int        临_in_634;
 int        临_in_648;
 int        临_in_650;  //6123
 int        临_in_651;  //6124
 int        临_in_652;  //6125
 int        临_in_649;
 int        临_in_663;
 int        临_in_665;  //6155
 int        临_in_666;  //6156
 int        临_in_667;  //6157
 int        临_in_664;
 int        临_in_678;
 int        临_in_680;  //6187
 int        临_in_681;  //6188
 int        临_in_682;  //6189
 int        临_in_679;
 int        临_in_693;
 int        临_in_695;  //6219
 int        临_in_696;  //6220
 int        临_in_697;  //6221
 int        临_in_694;
 int        临_in_708;
 int        临_in_710;  //6251
 int        临_in_711;  //6252
 int        临_in_712;  //6253
 int        临_in_709;
 int        临_in_723;
 int        临_in_725;  //6283
 int        临_in_726;  //6284
 int        临_in_727;  //6285
 int        临_in_724;
 int        临_in_738;
 int        临_in_740;  //6315
 int        临_in_741;  //6316
 int        临_in_742;  //6317
 int        临_in_739;
 int        临_in_753;
 int        临_in_755;  //6348
 int        临_in_756;  //6349
 int        临_in_757;  //6350
 int        临_in_754;
 int        临_in_768;
 int        临_in_770;  //6381
 int        临_in_771;  //6382
 int        临_in_772;  //6383
 int        临_in_769;
 int        临_in_783;
 int        临_in_785;  //6414
 int        临_in_786;  //6415
 int        临_in_787;  //6416
 int        临_in_784;
 int        临_in_798;
 int        临_in_800;  //6447
 int        临_in_801;  //6448
 int        临_in_802;  //6449
 int        临_in_799;
 int        临_in_813;
 int        临_in_815;  //6480
 int        临_in_816;  //6481
 int        临_in_817;  //6482
 int        临_in_814;
 int        临_in_828;
 int        临_in_830;  //6513
 int        临_in_831;  //6514
 int        临_in_832;  //6515
 int        临_in_829;
 int        临_in_843;
 int        临_in_845;  //6546
 int        临_in_846;  //6547
 int        临_in_847;  //6548
 int        临_in_844;
 int        临_in_858;
 int        临_in_860;  //6579
 int        临_in_861;  //6580
 int        临_in_862;  //6581
 int        临_in_859;
 int        临_in_873;
 int        临_in_875;  //6612
 int        临_in_876;  //6613
 int        临_in_877;  //6614
 int        临_in_874;
 int        临_in_888;
 int        临_in_890;  //6645
 int        临_in_891;  //6646
 int        临_in_892;  //6647
 int        临_in_889;
 int        临_in_903;
 int        临_in_905;  //6678
 int        临_in_906;  //6679
 int        临_in_907;  //6680
 int        临_in_904;
 int        临_in_918;
 int        临_in_920;  //6711
 int        临_in_921;  //6712
 int        临_in_922;  //6713
 int        临_in_919;
 int        临_in_933;
 int        临_in_935;  //6744
 int        临_in_936;  //6745
 int        临_in_937;  //6746
 int        临_in_934;
 int        临_in_948;
 int        临_in_950;  //6777
 int        临_in_951;  //6778
 int        临_in_952;  //6779
 int        临_in_949;
 int        临_in_963;
 int        临_in_965;  //6810
 int        临_in_966;  //6811
 int        临_in_967;  //6812
 int        临_in_964;
 int        临_in_978;
 int        临_in_980;  //6843
 int        临_in_981;  //6844
 int        临_in_982;  //6845
 int        临_in_979;

 子_in_5 = 7 ;
 子_in_6 = 12 ;
 子_in_7 = 17 ;
 子_in_8 = 22 ;
 子_in_9 = 5 ;
 子_in_10 = 9 ;
 子_in_11 = 14 ;
 子_in_12 = 20 ;
 子_in_13 = 4 ;
 子_in_14 = 11 ;
 子_in_15 = 16 ;
 子_in_16 = 23 ;
 子_in_17 = 6 ;
 子_in_18 = 10 ;
 子_in_19 = 15 ;
 子_in_20 = 21 ;
 子_in_1 = 木_0 ;
 子_in_2 = 木_1 ;
 子_in_3 = 木_2 ;
 子_in_4 = 木_3 ;
 临_in_5 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[0] + -680876936;
 木_0 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[0] + -680876936 << 7 | 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[0] + -680876936 >> 1 & 0x7FFFFFFF >> 31 - 7 + 木_1 ;
 临_in_17 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[1] + -389564586;
 临_in_20 = 木_0;
 临_in_21 = 子_in_6;
 临_in_22 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[1] + -389564586;
 if ( 子_in_6 == 32 )
  {
  临_in_19 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[1] + -389564586;
  }
 else
  {
  临_in_19 = (临_in_22 << 临_in_21) | ((临_in_22 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_21;
  }
 木_3 = 临_in_19 + 临_in_20 ;
 临_in_33 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[2] + 606105819;
 临_in_36 = 木_3;
 临_in_37 = 子_in_7;
 临_in_38 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[2] + 606105819;
 if ( 子_in_7 == 32 )
  {
  临_in_35 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[2] + 606105819;
  }
 else
  {
  临_in_35 = (临_in_38 << 临_in_37) | ((临_in_38 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_37;
  }
 木_2 = 临_in_35 + 临_in_36 ;
 临_in_49 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[3] + -1044525330;
 临_in_52 = 木_2;
 临_in_53 = 子_in_8;
 临_in_54 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[3] + -1044525330;
 if ( 子_in_8 == 32 )
  {
  临_in_51 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[3] + -1044525330;
  }
 else
  {
  临_in_58 = (临_in_54 << 临_in_53) | ((临_in_54 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_53;
  临_in_51 = 临_in_58;
  }
 木_1 = 临_in_51 + 临_in_52 ;
 临_in_65 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[4] + -176418897;
 临_in_68 = 木_1;
 临_in_69 = 子_in_5;
 临_in_70 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[4] + -176418897;
 if ( 子_in_5 == 32 )
  {
  临_in_67 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[4] + -176418897;
  }
 else
  {
  临_in_67 = (临_in_70 << 临_in_69) | ((临_in_70 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_69;
  }
 木_0 = 临_in_67 + 临_in_68 ;
 临_in_81 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[5] + 1200080426;
 临_in_84 = 木_0;
 临_in_85 = 子_in_6;
 临_in_86 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[5] + 1200080426;
 if ( 子_in_6 == 32 )
  {
  临_in_83 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[5] + 1200080426;
  }
 else
  {
  临_in_83 = (临_in_86 << 临_in_85) | ((临_in_86 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_85;
  }
 木_3 = 临_in_83 + 临_in_84 ;
 临_in_97 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[6] + -1473231341;
 临_in_100 = 木_3;
 临_in_101 = 子_in_7;
 临_in_102 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[6] + -1473231341;
 if ( 子_in_7 == 32 )
  {
  临_in_99 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[6] + -1473231341;
  }
 else
  {
  临_in_99 = (临_in_102 << 临_in_101) | ((临_in_102 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_101;
  }
 木_2 = 临_in_99 + 临_in_100 ;
 临_in_113 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[7] + -45705983;
 临_in_116 = 木_2;
 临_in_117 = 子_in_8;
 临_in_118 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[7] + -45705983;
 if ( 子_in_8 == 32 )
  {
  临_in_115 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[7] + -45705983;
  }
 else
  {
  临_in_115 = (临_in_118 << 临_in_117) | ((临_in_118 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_117;
  }
 木_1 = 临_in_115 + 临_in_116 ;
 临_in_129 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[8] + 1770035416;
 临_in_132 = 木_1;
 临_in_133 = 子_in_5;
 临_in_134 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[8] + 1770035416;
 if ( 子_in_5 == 32 )
  {
  临_in_131 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[8] + 1770035416;
  }
 else
  {
  临_in_131 = (临_in_134 << 临_in_133) | ((临_in_134 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_133;
  }
 木_0 = 临_in_131 + 临_in_132 ;
 临_in_145 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[9] + -1958414417;
 临_in_148 = 木_0;
 临_in_149 = 子_in_6;
 临_in_150 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[9] + -1958414417;
 if ( 子_in_6 == 32 )
  {
  临_in_147 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[9] + -1958414417;
  }
 else
  {
  临_in_147 = (临_in_150 << 临_in_149) | ((临_in_150 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_149;
  }
 木_3 = 临_in_147 + 临_in_148 ;
 临_in_161 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[10] + -42063;
 临_in_164 = 木_3;
 临_in_165 = 子_in_7;
 临_in_166 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[10] + -42063;
 if ( 子_in_7 == 32 )
  {
  临_in_163 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[10] + -42063;
  }
 else
  {
  临_in_163 = (临_in_166 << 临_in_165) | ((临_in_166 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_165;
  }
 木_2 = 临_in_163 + 临_in_164 ;
 临_in_177 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[11] + -1990404162;
 临_in_180 = 木_2;
 临_in_181 = 子_in_8;
 临_in_182 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[11] + -1990404162;
 if ( 子_in_8 == 32 )
  {
  临_in_179 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[11] + -1990404162;
  }
 else
  {
  临_in_179 = (临_in_182 << 临_in_181) | ((临_in_182 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_181;
  }
 木_1 = 临_in_179 + 临_in_180 ;
 临_in_193 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[12] + 1804603682;
 临_in_196 = 木_1;
 临_in_197 = 子_in_5;
 临_in_198 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[12] + 1804603682;
 if ( 子_in_5 == 32 )
  {
  临_in_195 = 木_0 + 木_1 & 木_2 |  ~木_1 & 木_3 + 木_4[12] + 1804603682;
  }
 else
  {
  临_in_195 = (临_in_198 << 临_in_197) | ((临_in_198 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_197;
  }
 木_0 = 临_in_195 + 临_in_196 ;
 临_in_209 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[13] + -40341101;
 临_in_212 = 木_0;
 临_in_213 = 子_in_6;
 临_in_214 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[13] + -40341101;
 if ( 子_in_6 == 32 )
  {
  临_in_211 = 木_3 + 木_0 & 木_1 |  ~木_0 & 木_2 + 木_4[13] + -40341101;
  }
 else
  {
  临_in_211 = (临_in_214 << 临_in_213) | ((临_in_214 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_213;
  }
 木_3 = 临_in_211 + 临_in_212 ;
 临_in_225 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[14] + -1502002290;
 临_in_228 = 木_3;
 临_in_229 = 子_in_7;
 临_in_230 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[14] + -1502002290;
 if ( 子_in_7 == 32 )
  {
  临_in_227 = 木_2 + 木_3 & 木_0 |  ~木_3 & 木_1 + 木_4[14] + -1502002290;
  }
 else
  {
  临_in_227 = (临_in_230 << 临_in_229) | ((临_in_230 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_229;
  }
 木_2 = 临_in_227 + 临_in_228 ;
 临_in_241 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[15] + 1236535329;
 临_in_244 = 木_2;
 临_in_245 = 子_in_8;
 临_in_246 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[15] + 1236535329;
 if ( 子_in_8 == 32 )
  {
  临_in_243 = 木_1 + 木_2 & 木_3 |  ~木_2 & 木_0 + 木_4[15] + 1236535329;
  }
 else
  {
  临_in_243 = (临_in_246 << 临_in_245) | ((临_in_246 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_245;
  }
 木_1 = 临_in_243 + 临_in_244 ;
 临_in_257 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[1] + -165796510;
 临_in_260 = 木_1;
 临_in_261 = 子_in_9;
 临_in_262 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[1] + -165796510;
 if ( 子_in_9 == 32 )
  {
  临_in_259 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[1] + -165796510;
  }
 else
  {
  临_in_259 = (临_in_262 << 临_in_261) | ((临_in_262 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_261;
  }
 木_0 = 临_in_259 + 临_in_260 ;
 临_in_273 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[6] + -1069501632;
 临_in_276 = 木_0;
 临_in_277 = 子_in_10;
 临_in_278 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[6] + -1069501632;
 if ( 子_in_10 == 32 )
  {
  临_in_275 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[6] + -1069501632;
  }
 else
  {
  临_in_275 = (临_in_278 << 临_in_277) | ((临_in_278 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_277;
  }
 木_3 = 临_in_275 + 临_in_276 ;
 临_in_289 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[11] + 643717713;
 临_in_292 = 木_3;
 临_in_293 = 子_in_11;
 临_in_294 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[11] + 643717713;
 if ( 子_in_11 == 32 )
  {
  临_in_291 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[11] + 643717713;
  }
 else
  {
  临_in_291 = (临_in_294 << 临_in_293) | ((临_in_294 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_293;
  }
 木_2 = 临_in_291 + 临_in_292 ;
 临_in_305 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[0] + -373897302;
 临_in_308 = 木_2;
 临_in_309 = 子_in_12;
 临_in_310 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[0] + -373897302;
 if ( 子_in_12 == 32 )
  {
  临_in_307 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[0] + -373897302;
  }
 else
  {
  临_in_307 = (临_in_310 << 临_in_309) | ((临_in_310 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_309;
  }
 木_1 = 临_in_307 + 临_in_308 ;
 临_in_321 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[5] + -701558691;
 临_in_324 = 木_1;
 临_in_325 = 子_in_9;
 临_in_326 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[5] + -701558691;
 if ( 子_in_9 == 32 )
  {
  临_in_323 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[5] + -701558691;
  }
 else
  {
  临_in_323 = (临_in_326 << 临_in_325) | ((临_in_326 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_325;
  }
 木_0 = 临_in_323 + 临_in_324 ;
 临_in_337 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[10] + 38016083;
 临_in_340 = 木_0;
 临_in_341 = 子_in_10;
 临_in_342 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[10] + 38016083;
 if ( 子_in_10 == 32 )
  {
  临_in_339 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[10] + 38016083;
  }
 else
  {
  临_in_339 = (临_in_342 << 临_in_341) | ((临_in_342 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_341;
  }
 木_3 = 临_in_339 + 临_in_340 ;
 临_in_353 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[15] + -660478335;
 临_in_356 = 木_3;
 临_in_357 = 子_in_11;
 临_in_358 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[15] + -660478335;
 if ( 子_in_11 == 32 )
  {
  临_in_355 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[15] + -660478335;
  }
 else
  {
  临_in_355 = (临_in_358 << 临_in_357) | ((临_in_358 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_357;
  }
 木_2 = 临_in_355 + 临_in_356 ;
 临_in_369 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[4] + -405537848;
 临_in_372 = 木_2;
 临_in_373 = 子_in_12;
 临_in_374 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[4] + -405537848;
 if ( 子_in_12 == 32 )
  {
  临_in_371 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[4] + -405537848;
  }
 else
  {
  临_in_371 = (临_in_374 << 临_in_373) | ((临_in_374 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_373;
  }
 木_1 = 临_in_371 + 临_in_372 ;
 临_in_385 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[9] + 568446438;
 临_in_388 = 木_1;
 临_in_389 = 子_in_9;
 临_in_390 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[9] + 568446438;
 if ( 子_in_9 == 32 )
  {
  临_in_387 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[9] + 568446438;
  }
 else
  {
  临_in_387 = (临_in_390 << 临_in_389) | ((临_in_390 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_389;
  }
 木_0 = 临_in_387 + 临_in_388 ;
 临_in_401 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[14] + -1019803690;
 临_in_404 = 木_0;
 临_in_405 = 子_in_10;
 临_in_406 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[14] + -1019803690;
 if ( 子_in_10 == 32 )
  {
  临_in_403 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[14] + -1019803690;
  }
 else
  {
  临_in_403 = (临_in_406 << 临_in_405) | ((临_in_406 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_405;
  }
 木_3 = 临_in_403 + 临_in_404 ;
 临_in_417 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[3] + -187363961;
 临_in_420 = 木_3;
 临_in_421 = 子_in_11;
 临_in_422 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[3] + -187363961;
 if ( 子_in_11 == 32 )
  {
  临_in_419 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[3] + -187363961;
  }
 else
  {
  临_in_419 = (临_in_422 << 临_in_421) | ((临_in_422 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_421;
  }
 木_2 = 临_in_419 + 临_in_420 ;
 临_in_433 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[8] + 1163531501;
 临_in_436 = 木_2;
 临_in_437 = 子_in_12;
 临_in_438 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[8] + 1163531501;
 if ( 子_in_12 == 32 )
  {
  临_in_435 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[8] + 1163531501;
  }
 else
  {
  临_in_435 = (临_in_438 << 临_in_437) | ((临_in_438 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_437;
  }
 木_1 = 临_in_435 + 临_in_436 ;
 临_in_449 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[13] + -1444681467;
 临_in_452 = 木_1;
 临_in_453 = 子_in_9;
 临_in_454 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[13] + -1444681467;
 if ( 子_in_9 == 32 )
  {
  临_in_451 = 木_0 + 木_1 & 木_3 | 木_2 &  ~木_3 + 木_4[13] + -1444681467;
  }
 else
  {
  临_in_451 = (临_in_454 << 临_in_453) | ((临_in_454 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_453;
  }
 木_0 = 临_in_451 + 临_in_452 ;
 临_in_465 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[2] + -51403784;
 临_in_468 = 木_0;
 临_in_469 = 子_in_10;
 临_in_470 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[2] + -51403784;
 if ( 子_in_10 == 32 )
  {
  临_in_467 = 木_3 + 木_0 & 木_2 | 木_1 &  ~木_2 + 木_4[2] + -51403784;
  }
 else
  {
  临_in_467 = (临_in_470 << 临_in_469) | ((临_in_470 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_469;
  }
 木_3 = 临_in_467 + 临_in_468 ;
 临_in_481 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[7] + 1735328473;
 临_in_484 = 木_3;
 临_in_485 = 子_in_11;
 临_in_486 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[7] + 1735328473;
 if ( 子_in_11 == 32 )
  {
  临_in_483 = 木_2 + 木_3 & 木_1 | 木_0 &  ~木_1 + 木_4[7] + 1735328473;
  }
 else
  {
  临_in_483 = (临_in_486 << 临_in_485) | ((临_in_486 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_485;
  }
 木_2 = 临_in_483 + 临_in_484 ;
 临_in_497 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[12] + -1926607734;
 临_in_500 = 木_2;
 临_in_501 = 子_in_12;
 临_in_502 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[12] + -1926607734;
 if ( 子_in_12 == 32 )
  {
  临_in_499 = 木_1 + 木_2 & 木_0 | 木_3 &  ~木_0 + 木_4[12] + -1926607734;
  }
 else
  {
  临_in_499 = (临_in_502 << 临_in_501) | ((临_in_502 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_501;
  }
 木_1 = 临_in_499 + 临_in_500 ;
 临_in_513 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[5] + -378558;
 临_in_515 = 木_1;
 临_in_516 = 子_in_13;
 临_in_517 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[5] + -378558;
 if ( 子_in_13 == 32 )
  {
  临_in_514 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[5] + -378558;
  }
 else
  {
  临_in_514 = (临_in_517 << 临_in_516) | ((临_in_517 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_516;
  }
 木_0 = 临_in_514 + 临_in_515 ;
 临_in_528 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[8] + -2022574463;
 临_in_530 = 木_0;
 临_in_531 = 子_in_14;
 临_in_532 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[8] + -2022574463;
 if ( 子_in_14 == 32 )
  {
  临_in_529 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[8] + -2022574463;
  }
 else
  {
  临_in_529 = (临_in_532 << 临_in_531) | ((临_in_532 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_531;
  }
 木_3 = 临_in_529 + 临_in_530 ;
 临_in_543 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[11] + 1839030562;
 临_in_545 = 木_3;
 临_in_546 = 子_in_15;
 临_in_547 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[11] + 1839030562;
 if ( 子_in_15 == 32 )
  {
  临_in_544 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[11] + 1839030562;
  }
 else
  {
  临_in_544 = (临_in_547 << 临_in_546) | ((临_in_547 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_546;
  }
 木_2 = 临_in_544 + 临_in_545 ;
 临_in_558 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[14] + -35309556;
 临_in_560 = 木_2;
 临_in_561 = 子_in_16;
 临_in_562 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[14] + -35309556;
 if ( 子_in_16 == 32 )
  {
  临_in_559 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[14] + -35309556;
  }
 else
  {
  临_in_559 = (临_in_562 << 临_in_561) | ((临_in_562 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_561;
  }
 木_1 = 临_in_559 + 临_in_560 ;
 临_in_573 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[1] + -1530992060;
 临_in_575 = 木_1;
 临_in_576 = 子_in_13;
 临_in_577 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[1] + -1530992060;
 if ( 子_in_13 == 32 )
  {
  临_in_574 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[1] + -1530992060;
  }
 else
  {
  临_in_574 = (临_in_577 << 临_in_576) | ((临_in_577 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_576;
  }
 木_0 = 临_in_574 + 临_in_575 ;
 临_in_588 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[4] + 1272893353;
 临_in_590 = 木_0;
 临_in_591 = 子_in_14;
 临_in_592 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[4] + 1272893353;
 if ( 子_in_14 == 32 )
  {
  临_in_589 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[4] + 1272893353;
  }
 else
  {
  临_in_589 = (临_in_592 << 临_in_591) | ((临_in_592 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_591;
  }
 木_3 = 临_in_589 + 临_in_590 ;
 临_in_603 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[7] + -155497632;
 临_in_605 = 木_3;
 临_in_606 = 子_in_15;
 临_in_607 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[7] + -155497632;
 if ( 子_in_15 == 32 )
  {
  临_in_604 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[7] + -155497632;
  }
 else
  {
  临_in_611 = (临_in_607 << 临_in_606) | ((临_in_607 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_606;
  临_in_604 = 临_in_611;
  }
 木_2 = 临_in_604 + 临_in_605 ;
 临_in_618 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[10] + -1094730640;
 临_in_620 = 木_2;
 临_in_621 = 子_in_16;
 临_in_622 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[10] + -1094730640;
 if ( 子_in_16 == 32 )
  {
  临_in_619 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[10] + -1094730640;
  }
 else
  {
  临_in_619 = (临_in_622 << 临_in_621) | ((临_in_622 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_621;
  }
 木_1 = 临_in_619 + 临_in_620 ;
 临_in_633 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[13] + 681279174;
 临_in_635 = 木_1;
 临_in_636 = 子_in_13;
 临_in_637 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[13] + 681279174;
 if ( 子_in_13 == 32 )
  {
  临_in_634 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[13] + 681279174;
  }
 else
  {
  临_in_634 = (临_in_637 << 临_in_636) | ((临_in_637 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_636;
  }
 木_0 = 临_in_634 + 临_in_635 ;
 临_in_648 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[0] + -358537222;
 临_in_650 = 木_0;
 临_in_651 = 子_in_14;
 临_in_652 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[0] + -358537222;
 if ( 子_in_14 == 32 )
  {
  临_in_649 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[0] + -358537222;
  }
 else
  {
  临_in_649 = (临_in_652 << 临_in_651) | ((临_in_652 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_651;
  }
 木_3 = 临_in_649 + 临_in_650 ;
 临_in_663 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[3] + -722521979;
 临_in_665 = 木_3;
 临_in_666 = 子_in_15;
 临_in_667 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[3] + -722521979;
 if ( 子_in_15 == 32 )
  {
  临_in_664 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[3] + -722521979;
  }
 else
  {
  临_in_664 = (临_in_667 << 临_in_666) | ((临_in_667 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_666;
  }
 木_2 = 临_in_664 + 临_in_665 ;
 临_in_678 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[6] + 76029189;
 临_in_680 = 木_2;
 临_in_681 = 子_in_16;
 临_in_682 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[6] + 76029189;
 if ( 子_in_16 == 32 )
  {
  临_in_679 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[6] + 76029189;
  }
 else
  {
  临_in_679 = (临_in_682 << 临_in_681) | ((临_in_682 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_681;
  }
 木_1 = 临_in_679 + 临_in_680 ;
 临_in_693 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[9] + -640364487;
 临_in_695 = 木_1;
 临_in_696 = 子_in_13;
 临_in_697 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[9] + -640364487;
 if ( 子_in_13 == 32 )
  {
  临_in_694 = 木_0 + 木_1 ^ 木_2 ^ 木_3 + 木_4[9] + -640364487;
  }
 else
  {
  临_in_694 = (临_in_697 << 临_in_696) | ((临_in_697 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_696;
  }
 木_0 = 临_in_694 + 临_in_695 ;
 临_in_708 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[12] + -421815835;
 临_in_710 = 木_0;
 临_in_711 = 子_in_14;
 临_in_712 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[12] + -421815835;
 if ( 子_in_14 == 32 )
  {
  临_in_709 = 木_3 + 木_0 ^ 木_1 ^ 木_2 + 木_4[12] + -421815835;
  }
 else
  {
  临_in_709 = (临_in_712 << 临_in_711) | ((临_in_712 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_711;
  }
 木_3 = 临_in_709 + 临_in_710 ;
 临_in_723 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[15] + 530742520;
 临_in_725 = 木_3;
 临_in_726 = 子_in_15;
 临_in_727 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[15] + 530742520;
 if ( 子_in_15 == 32 )
  {
  临_in_724 = 木_2 + 木_3 ^ 木_0 ^ 木_1 + 木_4[15] + 530742520;
  }
 else
  {
  临_in_724 = (临_in_727 << 临_in_726) | ((临_in_727 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_726;
  }
 木_2 = 临_in_724 + 临_in_725 ;
 临_in_738 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[2] + -995338651;
 临_in_740 = 木_2;
 临_in_741 = 子_in_16;
 临_in_742 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[2] + -995338651;
 if ( 子_in_16 == 32 )
  {
  临_in_739 = 木_1 + 木_2 ^ 木_3 ^ 木_0 + 木_4[2] + -995338651;
  }
 else
  {
  临_in_739 = (临_in_742 << 临_in_741) | ((临_in_742 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_741;
  }
 木_1 = 临_in_739 + 临_in_740 ;
 临_in_753 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[0] + -198630844;
 临_in_755 = 木_1;
 临_in_756 = 子_in_17;
 临_in_757 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[0] + -198630844;
 if ( 子_in_17 == 32 )
  {
  临_in_754 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[0] + -198630844;
  }
 else
  {
  临_in_754 = (临_in_757 << 临_in_756) | ((临_in_757 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_756;
  }
 木_0 = 临_in_754 + 临_in_755 ;
 临_in_768 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[7] + 1126891415;
 临_in_770 = 木_0;
 临_in_771 = 子_in_18;
 临_in_772 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[7] + 1126891415;
 if ( 子_in_18 == 32 )
  {
  临_in_769 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[7] + 1126891415;
  }
 else
  {
  临_in_769 = (临_in_772 << 临_in_771) | ((临_in_772 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_771;
  }
 木_3 = 临_in_769 + 临_in_770 ;
 临_in_783 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[14] + -1416354905;
 临_in_785 = 木_3;
 临_in_786 = 子_in_19;
 临_in_787 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[14] + -1416354905;
 if ( 子_in_19 == 32 )
  {
  临_in_784 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[14] + -1416354905;
  }
 else
  {
  临_in_784 = (临_in_787 << 临_in_786) | ((临_in_787 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_786;
  }
 木_2 = 临_in_784 + 临_in_785 ;
 临_in_798 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[5] + -57434055;
 临_in_800 = 木_2;
 临_in_801 = 子_in_20;
 临_in_802 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[5] + -57434055;
 if ( 子_in_20 == 32 )
  {
  临_in_799 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[5] + -57434055;
  }
 else
  {
  临_in_799 = (临_in_802 << 临_in_801) | ((临_in_802 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_801;
  }
 木_1 = 临_in_799 + 临_in_800 ;
 临_in_813 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[12] + 1700485571;
 临_in_815 = 木_1;
 临_in_816 = 子_in_17;
 临_in_817 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[12] + 1700485571;
 if ( 子_in_17 == 32 )
  {
  临_in_814 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[12] + 1700485571;
  }
 else
  {
  临_in_814 = (临_in_817 << 临_in_816) | ((临_in_817 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_816;
  }
 木_0 = 临_in_814 + 临_in_815 ;
 临_in_828 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[3] + -1894986606;
 临_in_830 = 木_0;
 临_in_831 = 子_in_18;
 临_in_832 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[3] + -1894986606;
 if ( 子_in_18 == 32 )
  {
  临_in_829 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[3] + -1894986606;
  }
 else
  {
  临_in_829 = (临_in_832 << 临_in_831) | ((临_in_832 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_831;
  }
 木_3 = 临_in_829 + 临_in_830 ;
 临_in_843 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[10] + -1051523;
 临_in_845 = 木_3;
 临_in_846 = 子_in_19;
 临_in_847 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[10] + -1051523;
 if ( 子_in_19 == 32 )
  {
  临_in_844 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[10] + -1051523;
  }
 else
  {
  临_in_844 = (临_in_847 << 临_in_846) | ((临_in_847 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_846;
  }
 木_2 = 临_in_844 + 临_in_845 ;
 临_in_858 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[1] + -2054922799;
 临_in_860 = 木_2;
 临_in_861 = 子_in_20;
 临_in_862 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[1] + -2054922799;
 if ( 子_in_20 == 32 )
  {
  临_in_859 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[1] + -2054922799;
  }
 else
  {
  临_in_859 = (临_in_862 << 临_in_861) | ((临_in_862 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_861;
  }
 木_1 = 临_in_859 + 临_in_860 ;
 临_in_873 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[8] + 1873313359;
 临_in_875 = 木_1;
 临_in_876 = 子_in_17;
 临_in_877 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[8] + 1873313359;
 if ( 子_in_17 == 32 )
  {
  临_in_874 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[8] + 1873313359;
  }
 else
  {
  临_in_874 = (临_in_877 << 临_in_876) | ((临_in_877 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_876;
  }
 木_0 = 临_in_874 + 临_in_875 ;
 临_in_888 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[15] + -30611744;
 临_in_890 = 木_0;
 临_in_891 = 子_in_18;
 临_in_892 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[15] + -30611744;
 if ( 子_in_18 == 32 )
  {
  临_in_889 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[15] + -30611744;
  }
 else
  {
  临_in_889 = (临_in_892 << 临_in_891) | ((临_in_892 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_891;
  }
 木_3 = 临_in_889 + 临_in_890 ;
 临_in_903 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[6] + -1560198380;
 临_in_905 = 木_3;
 临_in_906 = 子_in_19;
 临_in_907 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[6] + -1560198380;
 if ( 子_in_19 == 32 )
  {
  临_in_904 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[6] + -1560198380;
  }
 else
  {
  临_in_904 = (临_in_907 << 临_in_906) | ((临_in_907 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_906;
  }
 木_2 = 临_in_904 + 临_in_905 ;
 临_in_918 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[13] + 1309151649;
 临_in_920 = 木_2;
 临_in_921 = 子_in_20;
 临_in_922 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[13] + 1309151649;
 if ( 子_in_20 == 32 )
  {
  临_in_919 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[13] + 1309151649;
  }
 else
  {
  临_in_919 = (临_in_922 << 临_in_921) | ((临_in_922 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_921;
  }
 木_1 = 临_in_919 + 临_in_920 ;
 临_in_933 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[4] + -145523070;
 临_in_935 = 木_1;
 临_in_936 = 子_in_17;
 临_in_937 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[4] + -145523070;
 if ( 子_in_17 == 32 )
  {
  临_in_934 = 木_0 + 木_2 ^ 木_1 |  ~木_3 + 木_4[4] + -145523070;
  }
 else
  {
  临_in_934 = (临_in_937 << 临_in_936) | ((临_in_937 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_936;
  }
 木_0 = 临_in_934 + 临_in_935 ;
 临_in_948 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[11] + -1120210379;
 临_in_950 = 木_0;
 临_in_951 = 子_in_18;
 临_in_952 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[11] + -1120210379;
 if ( 子_in_18 == 32 )
  {
  临_in_949 = 木_3 + 木_1 ^ 木_0 |  ~木_2 + 木_4[11] + -1120210379;
  }
 else
  {
  临_in_949 = (临_in_952 << 临_in_951) | ((临_in_952 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_951;
  }
 木_3 = 临_in_949 + 临_in_950 ;
 临_in_963 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[2] + 718787259;
 临_in_965 = 木_3;
 临_in_966 = 子_in_19;
 临_in_967 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[2] + 718787259;
 if ( 子_in_19 == 32 )
  {
  临_in_964 = 木_2 + 木_0 ^ 木_3 |  ~木_1 + 木_4[2] + 718787259;
  }
 else
  {
  临_in_964 = (临_in_967 << 临_in_966) | ((临_in_967 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_966;
  }
 木_2 = 临_in_964 + 临_in_965 ;
 临_in_978 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[9] + -343485551;
 临_in_980 = 木_2;
 临_in_981 = 子_in_20;
 临_in_982 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[9] + -343485551;
 if ( 子_in_20 == 32 )
  {
  临_in_979 = 木_1 + 木_3 ^ 木_2 |  ~木_0 + 木_4[9] + -343485551;
  }
 else
  {
  临_in_979 = (临_in_982 << 临_in_981) | ((临_in_982 >> 1) & 0x7FFFFFFF) >> 31 - 临_in_981;
  }
 木_1 = 临_in_979 + 临_in_980 ;
 木_0 = 木_0 + 子_in_1 ;
 木_1 = 木_1 + 子_in_2 ;
 木_2 = 木_2 + 子_in_3 ;
 木_3 = 木_3 + 子_in_4 ;
 }
//lizong_19
//---------------------  ----------------------------------------

