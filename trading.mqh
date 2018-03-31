//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| �������� ��������                                                |
//+------------------------------------------------------------------+
class trading
  {
private:
   string            textcom;
   bool              useECNNDD;
   double            ND(double pr);
   int               NormE(int pr);
   double            NormL(double lo);
   bool              ChekPar(int tip,double oop,double osl,double otp,double op,double sl,double tp,int mod=0);
   int               SendOrd(int tip,double lo,double op,double sl,double tp,string com);
   bool              StopLev(double pr1,double pr2);
   bool              Freez(double pr1,double pr2);
   bool              FreeM(double lo);
   string            StrTip(int tip);
   string            Errors(int id);
   void              Err(int id);

public:
   bool              ruErr;
   int               Magic;
   string            Com;
   int               slipag;
   double            Lot;
   bool              Lot_const;
   double            Risk;
   int               NumTry;
   color             BayCol;
   color             SelCol;
   bool              ClosePosAll(int OrdType=-1);
   bool              OpnOrd(int tip,double op_l,double op_pr,int stop,int take);
   double            Lots();
   int               Dig();

  };
//+------------------------------------------------------------------+
//| OpnOrd                                                           |
//+------------------------------------------------------------------+
bool trading:: OpnOrd(int tip,double op_l,double op_pr,int stop,int take)
  {
   bool res=false;
   long stoplevel=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double sl=0.0,tp=0.0;
   if(MathMod(tip,2.0)==0.0)
     {
      if(!useECNNDD)
        {
         if(stop>0)
            sl=op_pr-NormE(stop)*Point;
         if(take>0)
            tp=op_pr+NormE(take)*Point;
        }
     }
   else{if(!useECNNDD){if(stop>0)sl=op_pr+NormE(stop)*Point;if(take>0)tp=op_pr-NormE(take)*Point;}}
   if(SendOrd(tip,op_l,op_pr,sl,tp,Com)>0)
      res=true;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| SendOrd                                                          |
//+------------------------------------------------------------------+
int trading:: SendOrd(int tip,double lo,double op,double sl,double tp,string com)
  {
   int i=0,tiket=0;
   if(!FreeM(lo))
      return(tiket);
   color col=SelCol;
   if(MathMod(tip,2.0)==0.0)
      col=BayCol;
   for(i=1;i<NumTry;i++)
     {
      switch(tip)
        {
         case 0:
            op=Ask;
            break;
         case 1:
            op=Bid;
            break;
        }
      if(!ChekPar(tip,0.0,0.0,0.0,op,sl,tp,0))
         break;
      tiket=OrderSend(_Symbol,tip,NormL(lo),ND(op),slipag,ND(sl),ND(tp),com,Magic,0,col);
      if(tiket>0)
         break;
      else
        {
         int er=GetLastError();
         textcom=StringConcatenate(textcom,"\n",__FUNCTION__,"������ �������� �������",StrTip(tip)," : ",
                                   Errors(er)," ,������� ",IntegerToString(i),"  ",TimeCurrent());
         Err(er);
        }
     }
   return(tiket);
  }
//+------------------------------------------------------------------+
//| ClosePosAll                                                      |
//+------------------------------------------------------------------+
bool trading::ClosePosAll(int OrdType=-1)
  {
   double price;
   int i;
   bool _Ans=true;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol || OrderMagicNumber()!=Magic)
         continue;
      int order_type=OrderType();
      if(order_type>1 || (OrdType>=0 && OrdType!=order_type))
         continue;
      RefreshRates();
      i=0;
      bool Ans=false;
      while(!Ans && i<NumTry)
        {
         if(order_type==OP_BUY)
            price=Bid;
         else
            price=Ask;
         Ans=OrderClose(OrderTicket(),OrderLots(),ND(price),slipag);
         if(!Ans)
           {
            int er=GetLastError();
            if(er>0)
               textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
           }
         i++;
        }
      if(!Ans)
         _Ans=false;
     }
   return(_Ans);
  }
//+------------------------------------------------------------------+
//| ND                                                               |
//+------------------------------------------------------------------+
double trading:: ND(double pr)
  {
   double res=NormalizeDouble(pr,_Digits);
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| NormE                                                            |
//+------------------------------------------------------------------+
int trading:: NormE(int pr)
  {
   long res=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   res++;
   if(pr>res)
      res=pr;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(int(res));
  }
//+------------------------------------------------------------------+
//| NormL                                                            |
//+------------------------------------------------------------------+
double trading:: NormL(double lo)
  {
   double res=lo;
   int mf=int(MathCeil(lo/SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)));
   res=mf*SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   res=MathMax(res,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   res=MathMin(res,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Errors                                                           |
//+------------------------------------------------------------------+
string trading:: Errors(int id)
  {
   string res="";
   if(ruErr)
     {
      switch(id)
        {
         case 0:    res=" ��� ������. ";break;
         case 1:    res=" ��� ������, �� ��������� ����������. ";break;
         case 2:    res=" ����� ������. ";break;
         case 3:    res=" ������������ ���������. ";break;
         case 4:    res=" �������� ������ �����. ";break;
         case 5:    res=" ������ ������ ����������� ���������. ";break;
         case 6:    res=" ��� ����� � �������� ��������. ";break;
         case 7:    res=" ������������ ����. ";break;
         case 8:    res=" ������� ������ �������. ";break;
         case 9:    res=" ������������ �������� ���������� ���������������� �������. ";break;
         case 64:   res=" ���� ������������. ";break;
         case 65:   res=" ������������ ����� �����. ";break;
         case 128:  res=" ����� ���� �������� ���������� ������. ";break;
         case 129:  res=" ������������ ����. ";break;
         case 130:  res=" ������������ �����. ";break;
         case 131:  res=" ������������ �����. ";break;
         case 132:  res=" ����� ������. ";break;
         case 133:  res=" �������� ���������. ";break;
         case 134:  res=" ������������ ����� ��� ���������� ��������. ";break;
         case 135:  res=" ���� ����������. ";break;
         case 136:  res=" ��� ���. ";break;
         case 137:  res=" ������ �����. ";break;
         case 138:  res=" ����� ����. ";break;
         case 139:  res=" ����� ������������ � ��� ��������������. ";break;
         case 140:  res=" ��������� ������ �������. ";break;
         case 141:  res=" ������� ����� ��������. ";break;
         case 145:  res=" ����������� ���������, ��� ��� ����� ������� ������ � �����. ";break;
         case 146:  res=" ���������� �������� ������. ";break;
         case 147:  res=" ������������� ���� ��������� ������ ��������� ��������. ";break;
         case 148:  res=" ���������� �������� � ���������� ������� �������� �������, �������������� ��������. ";break;
         case 149:  res=" ������������ ��������� ";break;
         case 150:  res=" ��������� ��������� FIFO ";break;
         case 4000: res=" ��� ������. ";break;
         case 4001: res=" ������������ ��������� �������. ";break;
         case 4002: res=" ������ ������� - ��� ���������. ";break;
         case 4003: res=" ��� ������ ��� ����� �������. ";break;
         case 4004: res=" ������������ ����� ����� ������������ ������. ";break;
         case 4005: res=" �� ����� ��� ������ ��� �������� ����������. ";break;
         case 4006: res=" ��� ������ ��� ���������� ���������. ";break;
         case 4007: res=" ��� ������ ��� ��������� ������. ";break;
         case 4008: res=" �������������������� ������. ";break;
         case 4009: res=" �������������������� ������ � �������. ";break;
         case 4010: res=" ��� ������ ��� ���������� �������. ";break;
         case 4011: res=" ������� ������� ������. ";break;
         case 4012: res=" ������� �� ������� �� ����. ";break;
         case 4013: res=" ������� �� ����. ";break;
         case 4014: res=" ����������� �������. ";break;
         case 4015: res=" ������������ �������. ";break;
         case 4016: res=" �������������������� ������. ";break;
         case 4017: res=" ������ DLL �� ���������. ";break;
         case 4018: res=" ���������� ��������� ����������. ";break;
         case 4019: res=" ���������� ������� �������. ";break;
         case 4020: res=" ������ ������� ������������ ������� �� ���������. ";break;
         case 4021: res=" ������������ ������ ��� ������, ������������ �� �������. ";break;
         case 4022: res=" ������� ������. ";break;
         case 4023: res=" ����������� ������ ������ DLL-������� ";break;
         case 4024: res=" ���������� ������ ";break;
         case 4025: res=" ��� ������ ";break;
         case 4026: res=" �������� ��������� ";break;
         case 4027: res=" ������� ����� ���������� �������������� ������ ";break;
         case 4028: res=" ����� ���������� ��������� ����� ���������� �������������� ������ ";break;
         case 4029: res=" �������� ������ ";break;
         case 4030: res=" ������ �� �������� ";break;
         case 4050: res=" ������������ ���������� ���������� �������. ";break;
         case 4051: res=" ������������ �������� ��������� �������. ";break;
         case 4052: res=" ���������� ������ ��������� �������. ";break;
         case 4053: res=" ������ �������. ";break;
         case 4054: res=" ������������ ������������� �������-���������. ";break;
         case 4055: res=" ������ ����������������� ����������. ";break;
         case 4056: res=" ������� ������������. ";break;
         case 4057: res=" ������ ��������� ����������� ����������. ";break;
         case 4058: res=" ���������� ���������� �� ����������. ";break;
         case 4059: res=" ������� �� ��������� � �������� ������. ";break;
         case 4060: res=" ������� �� ���������. ";break;
         case 4061: res=" ������ �������� �����. ";break;
         case 4062: res=" ��������� �������� ���� string. ";break;
         case 4063: res=" ��������� �������� ���� integer. ";break;
         case 4064: res=" ��������� �������� ���� double. ";break;
         case 4065: res=" � �������� ��������� ��������� ������. ";break;
         case 4066: res=" ����������� ������������ ������ � ��������� ����������. ";break;
         case 4067: res=" ������ ��� ���������� �������� ��������. ";break;
         case 4068: res=" ������ �� ������ ";break;
         case 4069: res=" ������ �� �������������� ";break;
         case 4070: res=" �������� ������� ";break;
         case 4071: res=" ������ ������������� ����������������� ���������� ";break;
         case 4099: res=" ����� �����. ";break;
         case 4100: res=" ������ ��� ������ � ������. ";break;
         case 4101: res=" ������������ ��� �����. ";break;
         case 4102: res=" ������� ����� �������� ������. ";break;
         case 4103: res=" ���������� ������� ����. ";break;
         case 4104: res=" ������������� ����� ������� � �����. ";break;
         case 4105: res=" �� ���� ����� �� ������. ";break;
         case 4106: res=" ����������� ������. ";break;
         case 4107: res=" ������������ �������� ���� ��� �������� �������. ";break;
         case 4108: res=" �������� ����� ������. ";break;
         case 4109:res=" �������� �� ���������. ���������� �������� ����� ��������� ��������� ��������� � ��������� ��������. ";break;
         case 4110: res=" ������� ������� �� ���������. ���������� ��������� �������� ��������. ";break;
         case 4111: res=" �������� ������� �� ���������. ���������� ��������� �������� ��������. ";break;
         case 4200: res=" ������ ��� ����������. ";break;
         case 4201: res=" ��������� ����������� �������� �������. ";break;
         case 4202: res=" ������ �� ����������. ";break;
         case 4203: res=" ����������� ��� �������. ";break;
         case 4204: res=" ��� ����� �������. ";break;
         case 4205: res=" ������ ��������� �������. ";break;
         case 4206: res=" �� ������� ��������� �������. ";break;
         case 4207: res=" ������ ��� ������ � �������� ";break;
         case 4210: res=" ����������� �������� ������� ";break;
         case 4211: res=" ������ �� ������ ";break;
         case 4212: res=" �� ������� ������� ������� ";break;
         case 4213: res=" ��������� �� ������ ";break;
         case 4220: res=" ������ ������ ����������� ";break;
         case 4250: res=" ������ �������� push-����������� ";break;
         case 4251: res=" ������ ���������� push-����������� ";break;
         case 4252: res=" ����������� ��������� ";break;
         case 4253: res=" ������� ������ ������� ������� push-����������� ";break;
         case 5001: res=" ������� ����� �������� ������ ";break;
         case 5002: res=" �������� ��� ����� ";break;
         case 5003: res=" ������� ������� ��� ����� ";break;
         case 5004: res=" ������ �������� ����� ";break;
         case 5005: res=" ������ ���������� ������ ���������� ����� ";break;
         case 5006: res=" ������ �������� ����� ";break;
         case 5007: res=" �������� ����� ����� (���� ������ ��� �� ��� ������) ";break;
         case 5008: res=" �������� ����� ����� (������ ������ ����������� � �������) ";break;
         case 5009: res=" ���� ������ ���� ������ � ������ FILE_WRITE ";break;
         case 5010: res=" ���� ������ ���� ������ � ������ FILE_READ ";break;
         case 5011: res=" ���� ������ ���� ������ � ������ FILE_BIN ";break;
         case 5012: res=" ���� ������ ���� ������ � ������ FILE_TXT ";break;
         case 5013: res=" ���� ������ ���� ������ � ������ FILE_TXT ��� FILE_CSV ";break;
         case 5014: res=" ���� ������ ���� ������ � ������ FILE_CSV ";break;
         case 5015: res=" ������ ������ ����� ";break;
         case 5016: res=" ������ ������ ����� ";break;
         case 5017: res=" ������ ������ ������ ���� ������ ��� �������� ������ ";break;
         case 5018: res=" �������� ��� ����� (��� ��������� ��������-TXT, ��� ���� ������-BIN)";break;
         case 5019: res=" ���� �������� ����������� ";break;
         case 5020: res=" ���� �� ���������� ";break;
         case 5021: res=" ���� �� ����� ���� ����������� ";break;
         case 5022: res=" �������� ��� ���������� ";break;
         case 5023: res=" ���������� �� ���������� ";break;
         case 5024: res=" ��������� ���� �� �������� ����������� ";break;
         case 5025: res=" ������ �������� ���������� ";break;
         case 5026: res=" ������ ������� ���������� ";break;
         case 5027: res=" ������ ��������� ������� ������� ";break;
         case 5028: res=" ������ ��������� ������� ������ ";break;
         case 5029: res=" ��������� �������� ������ ��� ������������ ������� ";break;
         default :  res=" ����������� ������. ";
        }
     }
   else
      res= StringConcatenate(GetLastError());
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Lots                                                             |
//+------------------------------------------------------------------+
double trading:: Lots()
  {
   double res;
   if(!Lot_const)
      res=Lot;
   else
   if(Risk>0.0)
      res=(AccountBalance()/(100.0/Risk))/MarketInfo(_Symbol,MODE_MARGINREQUIRED);
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| ChekPar                                                          |
//+------------------------------------------------------------------+
bool trading:: ChekPar(int tip,double oop,double osl,double otp,double op,double sl,double tp,int mod=0)
  {
   bool res=true;
   double pro=0.0,prc=0.0;
   if(MathMod(tip,2.0)==0.0)
     {pro=Ask;prc=Bid;}
   else
     {pro=Bid;prc=Ask;}
   switch(mod)
     {
      case 0:
         switch(tip)
           {
            case 0:
            if(sl>0.0 && !StopLev(prc,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,prc)){res=false;break;}
            break;
            case 1:
            if(sl>0.0 && !StopLev(sl,prc)){res=false;break;}
            if(tp>0.0 && !StopLev(prc,tp)){res=false;break;}
            break;
            case 2:
            if(!StopLev(pro,op)){res=false;break;}
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            break;
            case 3:
            if(!StopLev(op,pro)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            break;
            case 4:
            if(!StopLev(op,pro)){res=false;break;}
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            break;
            case 5:
            if(!StopLev(pro,op)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            break;
           }
         break;
      case 1:
         switch(tip)
           {
            case 0:
            if(osl>0.0 && !Freez(prc,osl)){res=false;break;}
            if(otp>0.0 && !Freez(otp,prc)){res=false;break;}
            break;
            case 1:
            if(osl>0.0 && !Freez(osl,prc)){res=false;break;}
            if(otp>0.0 && !Freez(prc,otp)){res=false;break;}
            break;
           }
         break;
      case 2:
      if(prc>oop){if(!Freez(prc,oop)){res=false;break;}}
      else{if(!Freez(oop,prc)){res=false;break;}}
      break;
      case 3:
         switch(tip)
           {
            case 0:
            if(osl>0.0 && !Freez(prc,osl)){res=false;break;}
            if(otp>0.0 && !Freez(otp,prc)){res=false;break;}
            if(sl>0.0 && !StopLev(prc,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,prc)){res=false;break;}
            break;
            case 1:
            if(osl>0.0 && !Freez(osl,prc)){res=false;break;}
            if(otp>0.0 && !Freez(prc,otp)){res=false;break;}
            if(sl>0.0 && !StopLev(sl,prc)){res=false;break;}
            if(tp>0.0 && !StopLev(prc,tp)){res=false;break;}
            break;
            case 2:
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            if(!StopLev(pro,op) || !Freez(pro,op)){res=false;break;}
            break;
            case 3:
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            if(!StopLev(op,pro) || !Freez(op,pro)){res=false;break;}
            break;
            case 4:
            if(sl>0.0 && !StopLev(op,sl)){res=false;break;}
            if(tp>0.0 && !StopLev(tp,op)){res=false;break;}
            if(!StopLev(op,pro) || !Freez(op,pro)){res=false;break;}
            break;
            case 5:
            if(sl>0.0 && !StopLev(sl,op)){res=false;break;}
            if(tp>0.0 && !StopLev(op,tp)){res=false;break;}
            if(!StopLev(pro,op) || !Freez(pro,op)){res=false;break;}
            break;
           }
         break;
     }
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| StopLev                                                          |
//+------------------------------------------------------------------+
bool trading:: StopLev(double pr1,double pr2)
  {
   bool res=true;
   long par=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(long(MathCeil((pr1-pr2)/Point))<=par)res=false;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Freez                                                            |
//+------------------------------------------------------------------+
bool trading:: Freez(double pr1,double pr2)
  {
   bool res=true;
   long par=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   if(long(MathCeil((pr1-pr2)/Point))<=par)res=false;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| StrTip                                                           |
//+------------------------------------------------------------------+
string trading:: StrTip(int tip)
  {
   string name;
   switch(tip)
     {
      case 1:name=" Sell ";
      break;
      case 2:name=" BuyLimit ";
      break;
      case 3:name=" SellLimit ";
      break;
      case 4:name=" BuyStop ";
      break;
      case 5:name=" SellStop ";
      break;default:name=" Buy ";
     }
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(name);
  }
//+------------------------------------------------------------------+
//| Err                                                              |
//+------------------------------------------------------------------+
void trading:: Err(int id)
  {
   if(id==6 || id==129 || id==130 || id==136)
      Sleep(5000);
   if(id==128 || id==142 || id==143 || id==4 || id==132)
      Sleep(60000);
   if(id==145)
      Sleep(15000);
   if(id==146)
      Sleep(10000);
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
  }
//+------------------------------------------------------------------+
//| FreeM                                                            |
//+------------------------------------------------------------------+
bool trading:: FreeM(double lot)
  {
   bool res=true;
   if(lot*SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_INITIAL)>AccountFreeMargin())
      res=false;
   if(!res)
      Alert("Not enough money to open a position");
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(res);
  }
//+------------------------------------------------------------------+
//| Dig                                                              |
//+------------------------------------------------------------------+
int trading:: Dig()
  {
   int dig;
   if(_Digits==5 || _Digits==3 || _Digits==1)
      dig=10;
   else
      dig=1;
   int er=GetLastError();
   if(er>0)textcom=StringConcatenate(textcom,"\n",__FUNCTION__,Errors(er),"  ",TimeCurrent());
   return(dig);
  }
//+------------------------------------------------------------------+
