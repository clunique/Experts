//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Торговые операции                                                |
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
         textcom=StringConcatenate(textcom,"\n",__FUNCTION__,"Ошибка открытие позиции",StrTip(tip)," : ",
                                   Errors(er)," ,попытка ",IntegerToString(i),"  ",TimeCurrent());
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
         case 0:    res=" Нет ошибок. ";break;
         case 1:    res=" Нет ошибки, но результат неизвестен. ";break;
         case 2:    res=" Общая ошибка. ";break;
         case 3:    res=" Неправильные параметры. ";break;
         case 4:    res=" Торговый сервер занят. ";break;
         case 5:    res=" Старая версия клиентского терминала. ";break;
         case 6:    res=" Нет связи с торговым сервером. ";break;
         case 7:    res=" Недостаточно прав. ";break;
         case 8:    res=" Слишком частые запросы. ";break;
         case 9:    res=" Недопустимая операция нарушающая функционирование сервера. ";break;
         case 64:   res=" Счет заблокирован. ";break;
         case 65:   res=" Неправильный номер счета. ";break;
         case 128:  res=" Истек срок ожидания совершения сделки. ";break;
         case 129:  res=" Неправильная цена. ";break;
         case 130:  res=" Неправильные стопы. ";break;
         case 131:  res=" Неправильный объем. ";break;
         case 132:  res=" Рынок закрыт. ";break;
         case 133:  res=" Торговля запрещена. ";break;
         case 134:  res=" Недостаточно денег для совершения операции. ";break;
         case 135:  res=" Цена изменилась. ";break;
         case 136:  res=" Нет цен. ";break;
         case 137:  res=" Брокер занят. ";break;
         case 138:  res=" Новые цены. ";break;
         case 139:  res=" Ордер заблокирован и уже обрабатывается. ";break;
         case 140:  res=" Разрешена только покупка. ";break;
         case 141:  res=" Слишком много запросов. ";break;
         case 145:  res=" Модификация запрещена, так как ордер слишком близок к рынку. ";break;
         case 146:  res=" Подсистема торговли занята. ";break;
         case 147:  res=" Использование даты истечения ордера запрещено брокером. ";break;
         case 148:  res=" Количество открытых и отложенных ордеров достигло предела, установленного брокером. ";break;
         case 149:  res=" Хеджирование запрещено ";break;
         case 150:  res=" Запрещено правилами FIFO ";break;
         case 4000: res=" Нет ошибки. ";break;
         case 4001: res=" Неправильный указатель функции. ";break;
         case 4002: res=" Индекс массива - вне диапазона. ";break;
         case 4003: res=" Нет памяти для стека функций. ";break;
         case 4004: res=" Переполнение стека после рекурсивного вызова. ";break;
         case 4005: res=" На стеке нет памяти для передачи параметров. ";break;
         case 4006: res=" Нет памяти для строкового параметра. ";break;
         case 4007: res=" Нет памяти для временной строки. ";break;
         case 4008: res=" Неинициализированная строка. ";break;
         case 4009: res=" Неинициализированная строка в массиве. ";break;
         case 4010: res=" Нет памяти для строкового массива. ";break;
         case 4011: res=" Слишком длинная строка. ";break;
         case 4012: res=" Остаток от деления на ноль. ";break;
         case 4013: res=" Деление на ноль. ";break;
         case 4014: res=" Неизвестная команда. ";break;
         case 4015: res=" Неправильный переход. ";break;
         case 4016: res=" Неинициализированный массив. ";break;
         case 4017: res=" Вызовы DLL не разрешены. ";break;
         case 4018: res=" Невозможно загрузить библиотеку. ";break;
         case 4019: res=" Невозможно вызвать функцию. ";break;
         case 4020: res=" Вызовы внешних библиотечных функций не разрешены. ";break;
         case 4021: res=" Недостаточно памяти для строки, возвращаемой из функции. ";break;
         case 4022: res=" Система занята. ";break;
         case 4023: res=" Критическая ошибка вызова DLL-функции ";break;
         case 4024: res=" Внутренняя ошибка ";break;
         case 4025: res=" Нет памяти ";break;
         case 4026: res=" Неверный указатель ";break;
         case 4027: res=" Слишком много параметров форматирования строки ";break;
         case 4028: res=" Число параметров превышает число параметров форматирования строки ";break;
         case 4029: res=" Неверный массив ";break;
         case 4030: res=" График не отвечает ";break;
         case 4050: res=" Неправильное количество параметров функции. ";break;
         case 4051: res=" Недопустимое значение параметра функции. ";break;
         case 4052: res=" Внутренняя ошибка строковой функции. ";break;
         case 4053: res=" Ошибка массива. ";break;
         case 4054: res=" Неправильное использование массива-таймсерии. ";break;
         case 4055: res=" Ошибка пользовательского индикатора. ";break;
         case 4056: res=" Массивы несовместимы. ";break;
         case 4057: res=" Ошибка обработки глобальныех переменных. ";break;
         case 4058: res=" Глобальная переменная не обнаружена. ";break;
         case 4059: res=" Функция не разрешена в тестовом режиме. ";break;
         case 4060: res=" Функция не разрешена. ";break;
         case 4061: res=" Ошибка отправки почты. ";break;
         case 4062: res=" Ожидается параметр типа string. ";break;
         case 4063: res=" Ожидается параметр типа integer. ";break;
         case 4064: res=" Ожидается параметр типа double. ";break;
         case 4065: res=" В качестве параметра ожидается массив. ";break;
         case 4066: res=" Запрошенные исторические данные в состоянии обновления. ";break;
         case 4067: res=" Ошибка при выполнении торговой операции. ";break;
         case 4068: res=" Ресурс не найден ";break;
         case 4069: res=" Ресурс не поддерживается ";break;
         case 4070: res=" Дубликат ресурса ";break;
         case 4071: res=" Ошибка инициализации пользовательского индикатора ";break;
         case 4099: res=" Конец файла. ";break;
         case 4100: res=" Ошибка при работе с файлом. ";break;
         case 4101: res=" Неправильное имя файла. ";break;
         case 4102: res=" Слишком много открытых файлов. ";break;
         case 4103: res=" Невозможно открыть файл. ";break;
         case 4104: res=" Несовместимый режим доступа к файлу. ";break;
         case 4105: res=" Ни один ордер не выбран. ";break;
         case 4106: res=" Неизвестный символ. ";break;
         case 4107: res=" Неправильный параметр цены для торговой функции. ";break;
         case 4108: res=" Неверный номер тикета. ";break;
         case 4109:res=" Торговля не разрешена. Необходимо включить опцию Разрешить советнику торговать в свойствах эксперта. ";break;
         case 4110: res=" Длинные позиции не разрешены. Необходимо проверить свойства эксперта. ";break;
         case 4111: res=" Короткие позиции не разрешены. Необходимо проверить свойства эксперта. ";break;
         case 4200: res=" Объект уже существует. ";break;
         case 4201: res=" Запрошено неизвестное свойство объекта. ";break;
         case 4202: res=" Объект не существует. ";break;
         case 4203: res=" Неизвестный тип объекта. ";break;
         case 4204: res=" Нет имени объекта. ";break;
         case 4205: res=" Ошибка координат объекта. ";break;
         case 4206: res=" Не найдено указанное подокно. ";break;
         case 4207: res=" Ошибка при работе с объектом ";break;
         case 4210: res=" Неизвестное свойство графика ";break;
         case 4211: res=" График не найден ";break;
         case 4212: res=" Не найдено подокно графика ";break;
         case 4213: res=" Индикатор не найден ";break;
         case 4220: res=" Ошибка выбора инструмента ";break;
         case 4250: res=" Ошибка отправки push-уведомления ";break;
         case 4251: res=" Ошибка параметров push-уведомления ";break;
         case 4252: res=" Уведомления запрещены ";break;
         case 4253: res=" Слишком частые запросы отсылки push-уведомлений ";break;
         case 5001: res=" Слишком много открытых файлов ";break;
         case 5002: res=" Неверное имя файла ";break;
         case 5003: res=" Слишком длинное имя файла ";break;
         case 5004: res=" Ошибка открытия файла ";break;
         case 5005: res=" Ошибка размещения буфера текстового файла ";break;
         case 5006: res=" Ошибка удаления файла ";break;
         case 5007: res=" Неверный хендл файла (файл закрыт или не был открыт) ";break;
         case 5008: res=" Неверный хендл файла (индекс хендла отсутствует в таблице) ";break;
         case 5009: res=" Файл должен быть открыт с флагом FILE_WRITE ";break;
         case 5010: res=" Файл должен быть открыт с флагом FILE_READ ";break;
         case 5011: res=" Файл должен быть открыт с флагом FILE_BIN ";break;
         case 5012: res=" Файл должен быть открыт с флагом FILE_TXT ";break;
         case 5013: res=" Файл должен быть открыт с флагом FILE_TXT или FILE_CSV ";break;
         case 5014: res=" Файл должен быть открыт с флагом FILE_CSV ";break;
         case 5015: res=" Ошибка чтения файла ";break;
         case 5016: res=" Ошибка записи файла ";break;
         case 5017: res=" Размер строки должен быть указан для двоичных файлов ";break;
         case 5018: res=" Неверный тип файла (для строковых массивов-TXT, для всех других-BIN)";break;
         case 5019: res=" Файл является директорией ";break;
         case 5020: res=" Файл не существует ";break;
         case 5021: res=" Файл не может быть перезаписан ";break;
         case 5022: res=" Неверное имя директории ";break;
         case 5023: res=" Директория не существует ";break;
         case 5024: res=" Указанный файл не является директорией ";break;
         case 5025: res=" Ошибка удаления директории ";break;
         case 5026: res=" Ошибка очистки директории ";break;
         case 5027: res=" Ошибка изменения размера массива ";break;
         case 5028: res=" Ошибка изменения размера строки ";break;
         case 5029: res=" Структура содержит строки или динамические массивы ";break;
         default :  res=" Неизвестная ошибка. ";
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
