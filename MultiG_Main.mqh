//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "MultiG_Objects.mqh"
#include "MultiG_CalcData.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class main : public data
  {
public:
   obj               OBJ;
   double            ahigh[][10];
   double            alow[][10];
   datetime          atime[];

                     main(void);
                    ~main(void);
   bool              LastTime(void);
   void              UpdateLevels(int altg);
   void              ShowObjectsComment(datetime time1,datetime time2);
   void              CheckPeaks(void);
   void              FindValidOrders(void);
   void              RemoveValidBox(string sparam);
   void              ShowOrderDetails(string sparam);
   void              ClearAllObjects(void);
   void              ShowLastBreaks(string txt);
   void              CheckOpenOrderProfit();
   void              RecalPips();

private:
   void              ChangeLevelsMain(int g,datetime stime);
   void              CreateEvent(int g,datetime time);
   void              ClearLabels(int g,int n);
   void              CreateHline(int g,datetime time,string name,double price);

   bool              CheckPosiblePeak(int g,int n,int s,datetime time2);
   int               Rev(int i) { if(i==1) return(0); else return(1); };
   void              CreateValidBox(int g,int n,int s);
   void              RemoveValidBox(int g,int n,int s);
   bool              CheckLevel(int g,int n,int s);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
main::main(void)
  {
   if(GlobalVariableCheck(Name_GlobalStatus())) LoadArrays(atime,alow,ahigh);
   else return;
  }
//+------------------------------------------------------------------+
main::~main(void){}
//+------------------------------------------------------------------+
void main::ShowLastBreaks(string txt)
  {
   for(int i=16;i>=1;i--)
     {
      string name1=Name_LastBreaks(i);
      string name2=Name_LastBreaks(i-1);
      StringSet(name1,Return_String(name2));
     }
   StringSet(Name_LastBreaks(0),TimeToStr(TimeCurrent(),TIME_SECONDS)+" "+txt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::ClearAllObjects(void)
  {

   for(int g=0;g<LevelCount;g++)
     {
      StringSet(Name_LastTime(g),"--");
      StringSet(Name_Level(g),"--");
      for(int n=0; n<PairCount; n++)
        {
         ClearLabels(g,n);
         StringSet(Name_LabelPips(g,n),"--");
        }
     }
   ObjectsDeleteAll(0,0,OBJ_TREND);
   ObjectsDeleteAll(0,0,OBJ_EVENT);
   for(int i=ObjectsTotal(0,0,OBJ_RECTANGLE_LABEL)-1;i>=0;i--)
     {
      string name=ObjectName(0,i,0,OBJ_RECTANGLE_LABEL);
      int g=(int)StringSubstr(name,0,1);
      int n=(int)StringSubstr(name,1,1);
      int s=(int)StringSubstr(name,2,1);

      RemoveValidBox(g,n,s);

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::FindValidOrders(void)
  {
   for(int n=0; n<PairCount; n++)
     {

      for(int g=0;g<LevelCount;g++)
        {
         for(int s=0;s<2;s++)
           {
            if(ObjectGetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR)==ValidOrderColor()) { CreateValidBox(g,n,s); }
            else { if(ObjectFind(0,Name_ValidRec(g,n,s))!=-1) RemoveValidBox(g,n,s); }

           }
            
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::CreateValidBox(int g,int n,int s)
  {
   int X=10+g*30+s*10;
   int Y=20+n*40+s*10;

   string name=Name_ValidRec(g,n,s);
   if(OBJ.CheckIfExist(name)) return;
   OBJ.CreateRect(name,(string)g+(string)n+(string)s,X,Y,85,18,STYLE_SOLID);
   color cc=clrGreen;
   if(s==1)cc=clrRed;
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,cc);
   name=Name_ValidMainLabel(g,n,s);
   OBJ.CreateLabel(name,X+5,Y+2,0);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   StringSet(name,Pairs[n]+" "+(string)Return_Level(g));
   Set_ToolTip(name,TimeToStr(Return_LevelTime(g,n,s),TIME_SECONDS));

   name=Name_ValidClose(g,n,s);
   OBJ.CreateRect(name,(string)g+(string)n+(string)s,X+70,Y+4,10,10,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::RemoveValidBox(int g,int n,int s)
  {
   string name=Name_ValidRec(g,n,s);
   ObjectDelete(0,name);
   name=Name_ValidMainLabel(g,n,s);
   ObjectDelete(0,name);
   name=Name_ValidClose(g,n,s);
   ObjectDelete(0,name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::RemoveValidBox(string sparam)
  {
   int g=(int)StringSubstr(sparam,0,1);
   int n=(int)StringSubstr(sparam,1,1);
   int s=(int)StringSubstr(sparam,2,1);
   RemoveValidBox(g,n,s);
   ObjectSetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR,clrBlack);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::ShowOrderDetails(string sparam)
  {
 
   int g=(int)StringSubstr(sparam,0,1);
   int n=(int)StringSubstr(sparam,1,1);
   int s=(int)StringSubstr(sparam,2,1);
   
   string name;
   if(s==0) name=Name_LevelHlineA(g,n);
   if(s==1) name=Name_LevelHlineB(g,n);

   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   name=Name_ValidOrderTime();
   ObjectDelete(0,name);
   CreateVL(name,"Stime",Return_LevelTime(g,n,s),1,clrBlue,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,true);
   if(Symbol()!=Pairs[n]) ChartSetSymbolPeriod(0,Pairs[n],Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool main::LastTime(void)
  {
   double ohigh[][10];
   double olow[][10];
   datetime otime[];
   MoveNewFiles();
   ReadFilesFromHistory(otime,olow,ohigh);

   double levelA,levelB;
   double pips;
   datetime LasTime[];
   ArrayResize(LasTime,LevelCount);

   for(int n=0; n<PairCount; n++)
     {
      levelA=0;
      levelB=0;

      for(int g=0;g<LevelCount;g++)
        {
         pips=GetPips(Pairs[n],TimeCurrent(),g*LevelGap+LevelStart)/TickValue(Pairs[n],TimeCurrent());
         datetime laikas=0;
         int i=ArraySize(otime)-1;
         while(true)
           {
            laikas=otime[i];
            double high=ohigh[i][n];
            double low=olow[i][n];

            if(levelB>low || levelB==0) levelB=low;
            if(levelA<high || levelA==0) levelA=high;

            double LPrice1 = levelB + pips;
            double LPrice2 = levelA - pips;

            if(low <= LPrice1 && high >= LPrice1)  break;
            if(low <= LPrice2 && high >= LPrice2) break;

            i--;
            if(i<0 || LasTime[g]>laikas) break;
           }
         if(LasTime[g]<laikas) LasTime[g]=laikas;
        }
     }
   ArrayCopy(atime,otime);
   ArrayCopy(alow,olow);
   ArrayCopy(ahigh,ohigh);
   for(int g=0;g<LevelCount;g++)
     {
      StringSet(Name_Level(g),string(g*LevelGap+LevelStart));
      StringSet(Name_LastTime(g),string(LasTime[g]+10));
      ChangeLevelsMain(g,LasTime[g]+10);
      CreateEvent(g,LasTime[g]+10);
     }
   SaveArrays(otime,olow,ohigh);
   SetLots();
   return(true);
  }
void main::ChangeLevelsMain(int g,datetime stime)
  {
   double gap=LevelStart+g*LevelGap;

   for(int n=0;n<PairCount;n++)
     {
      if(TimeCurrent()-stime<10)
        {
         ClearLabels(g,n);
         continue;
        }

      datetime timemin;
      datetime timemax;
      double min=FindMinimum(atime,alow,stime,TimeCurrent(),n,timemin);
      double max=FindMaximum(atime,ahigh,stime,TimeCurrent(),n,timemax);


      int digits=(int)MarketInfo(Pairs[n],MODE_DIGITS);

      double pips=Return_Pips(g,n);
      if(pips==0)
        {
         pips=GetPips(Pairs[n],stime,g*LevelGap+LevelStart)/TickValue(Pairs[n],stime);
         StringSet(Name_LabelPips(g,n),DoubleToStr(pips,digits));
        }

      int s=0;
      if(Return_LevelTime(g,n,s)!=timemin)
        {

         StringSet(Name_LabelTime(g,n,s),string(timemin));
         StringSet(Name_LabelPrice(g,n,s),DoubleToStr(min,digits));
         StringSet(Name_LabelBreak(g,n,s),DoubleToStr((min+pips),digits));
         //ObjectSetInteger(0,Name_LabelBreak(g,n,0),OBJPROP_COLOR,clrRed);
           if(TimeCurrent()-timemin<30 || ObjectGetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR)==ValidOrderColor())
           {
            if(!CheckLevel(g,n,s)) ObjectSetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR,clrBlack);
           }
        }
      CreateHline(g,timemin,Name_LevelHlineA(g,n),min+pips);

      s=1;
      if(Return_LevelTime(g,n,s)!=timemax)
        {
         StringSet(Name_LabelTime(g,n,s),string(timemax));
         StringSet(Name_LabelPrice(g,n,s),DoubleToStr(max,digits));
         StringSet(Name_LabelBreak(g,n,s),DoubleToStr((max-pips),digits));
         // ObjectSetInteger(0,Name_LabelBreak(g,n,1),OBJPROP_COLOR,clrRed);
           if(TimeCurrent()-timemax<30 || ObjectGetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR)==ValidOrderColor())
           {
            if(!CheckLevel(g,n,s)) ObjectSetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR,clrBlack);
           }
        }
      CreateHline(g,timemax,Name_LevelHlineB(g,n),max-pips);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::UpdateLevels(int ag)
  {
   if(ag!=-1)
     {
      CreateEvent(ag,Return_MainTime(ag));
      ChangeLevelsMain(ag,Return_MainTime(ag));
      return;
     }

   ArrayInitialize(ahigh,0);
   ArrayInitialize(alow,0);
   ArrayInitialize(atime,0);
   LoadArrays(atime,alow,ahigh);

   for(int g=0;g<LevelCount;g++)
     {
      ChangeLevelsMain(g,Return_MainTime(g));
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::ClearLabels(int g,int n)
  {
   StringSet(Name_LabelTime(g,n,0),"--");
   StringSet(Name_LabelBreak(g,n,0),"--");
   StringSet(Name_LabelPrice(g,n,0),"--");

   StringSet(Name_LabelTime(g,n,1),"--");
   StringSet(Name_LabelBreak(g,n,1),"--");
   StringSet(Name_LabelPrice(g,n,1),"--");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::CheckPeaks()
  {
/*
   for(int n=0; n<PairCount; n++)
     {
      for(int g=0;g<LevelCount;g++)
        {
         for(int s=0;s<2;s++)
           {
            if(ObjectGetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR)==clrRed)
              {
               if(!CheckLevel(g,n,s)) ObjectSetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR,clrBlack);
              }
           }
        }
     }
     */
   FindValidOrders();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool main::CheckLevel(int g,int n,int s)
  {
   datetime time=Return_LevelTime(g,n,s);

   if(time == 0) return(true);

   double price=Return_LevelPrice(g,n,s);

   int START=iBarShift(Pairs[n],Period(),time);
   double level=price;

   double pips=Return_Pips(g,n);
   double d=2.3;
   int i=START;
   while(i<Bars-10)
     {
      datetime buft=iTime(Pairs[n],Period(),i);
      if(buft>time) continue;
      if(time-buft>12000) break;
      double low=iLow(Pairs[n],PERIOD_M1,i);
      double high=iHigh(Pairs[n],PERIOD_M1,i);

      if(s==0)
        {
         if(low<price-(pips*0.2))  return(false);
         if(level==0 || level>low) { level=low; time=buft; }
         if((level+pips*d)<high) break;
        }
      if(s==1)
        {
         if((pips*0.2)+price<high)  return(false);
         if(level==0 || level<high) { level=high; time=buft; }
         if((level-pips*d)>low) break;
        }
      i++;
     }

   if(!CheckPosiblePeak(g,n,s,time+30)) return(false);

   ObjectSetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR,ValidOrderColor());
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool main::CheckPosiblePeak(int g,int n,int s,datetime time2)
  {

   datetime time1=time2-500;
   int START=0;

   string pp;
   string p1=StringConcatenate(StringSubstr(Pairs[n],0,3)+(string)Rev(s));
   string p2=StringConcatenate(StringSubstr(Pairs[n],3,3)+(string)s);

   int i=ObjectsTotal(0,1,OBJ_VLINE);
   while(true)
     {
      i--;
      if(i<0) break;
      if(ObjectFind(0,Name_VLines(i))==-1) continue;
      int t=VLT(i);
      if(t<time1) break;
      if(t>time2) continue;

      string txt=StringSubstr(VLS(i),0,7);

      int side=(int)StringSubstr(txt,0,1);
      string pair=StringSubstr(txt,1,6);
      string pa1=StringSubstr(pair,0,3)+(string)side;
      string pa2=StringSubstr(pair,3,3)+(string)Rev(side);

      if(pa1==p1 || pa1==p2 || pa2==p1 || pa2==p2)
        {

         if(Pairs[n]==pair)  return(false); 
         else { if(StringFind(pp,txt)==-1) pp=StringConcatenate(pp+txt); }
         if(StringLen(pp)/6>=3)  return(false); 
        }
     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::RecalPips()
  {
   for(int g=0;g<LevelCount;g++)
     {
      for(int n=0; n<PairCount; n++)
        {
         int digits=(int)MarketInfo(Pairs[n],MODE_DIGITS);
         double pips=GetPips(Pairs[n],TimeCurrent(),g*LevelGap+LevelStart)/TickValue(Pairs[n],TimeCurrent());
         StringSet(Name_LabelPips(g,n),DoubleToStr(pips,digits));
        }

     }
  }
//+------------------------------------------------------------------+
void main::CreateEvent(int g,datetime time)
  {
   string name=Name_Event(g);
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_EVENT,0,time,0);
   ObjectSetString(0,name,OBJPROP_TEXT,(string)g+" "+(string)time);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,(string)g+" "+(string)time);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }
//+------------------------------------------------------------------+
void main::CreateHline(int g,datetime time,string name,double price)
  {
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_TREND,0,time,price,TimeCurrent()+120,price);
   ObjectSetString(0,name,OBJPROP_TEXT,(string)g+"   "+(string)price);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,(string)g+"   "+(string)price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrGray);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void main::CheckOpenOrderProfit()
  {
   for(int i=0;i<5;i++)
     {
      if(ObjectFind(0,Name_OpenOrderSymbol(i))==-1) continue;
      if(!OrderSelect(Return_OrderTicket(i),SELECT_BY_TICKET,MODE_TRADES) || OrderCloseTime()!=0) RemoveOrderObjects(i);
      else StringSet(Name_OpenOrderProfit(i),(string)OrderProfit());
     }
  }
//+------------------------------------------------------------------+
void main::ShowObjectsComment(datetime time1,datetime time2)
  {
   string tcom=TimeToStr(time1)+" "+TimeToStr(time2)+"\n";
   int adas=int(ChartGetInteger(0,CHART_WINDOW_YDISTANCE,1)-90)/12;
   int z;
   string Comm[];
   string curr[];
   int curc[];
   ArrayResize(Comm,adas);
   for(int i=0;i<ObjectsTotal(0,1,OBJ_VLINE);i++)
     {
      string ObjName=Name_VLines(i);
      if(StringFind(ObjName,Name_ObjVLine())==-1) continue;
      datetime ot=(datetime)ObjectGetInteger(0,ObjName,OBJPROP_TIME);
      if(ot>=time1 && ot<=time2)
        {
         string cc=ObjectGetString(0,ObjName,OBJPROP_TEXT);
         Comm[z]=StringConcatenate(Comm[z]+TimeToStr((int)ObjectGet(ObjName,OBJPROP_TIME1),TIME_SECONDS)+" "+cc+"      ");
         z++;
         if(z>=adas) z=0;

         string str=StringSubstr(cc,0,7);
         int size=ArraySize(curr);
         if(size==0) { ArrayResize(curr,size+1); ArrayResize(curc,size+1); curr[size]=str; curc[size]=1; }
         else
           {
            int q=0;
            for(q=0;q<size;q++) { if(str==curr[q]) { curc[q]++; break; } }
            if(q==size) { ArrayResize(curr,size+1); ArrayResize(curc,size+1); curr[size]=str; curc[size]=1; }
           }
        }
     }
   for(int i=0;i<adas;i++) tcom=StringConcatenate(tcom+Comm[i]+"\n");
   for(int x=0;x<ArraySize(curr);x++) tcom=StringConcatenate(tcom+curr[x]+"  "+(string)curc[x]+"\n");
   tcom=StringConcatenate(tcom+"****");
   Comment(tcom);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
