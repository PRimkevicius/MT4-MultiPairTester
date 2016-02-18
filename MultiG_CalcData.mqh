//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "MultiG_LoadFiles.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class data: public LoadFiles
  {
public:
                     data(void);
                    ~data(void);

   bool              CalcPrevVLines(void);
   void              ShowBreakPairs(void);

   double            GetPips(string pair,datetime laikas,double gap);
   double            TickValue(string pair,datetime laikas);
   double            FindMinimum(datetime &atime[],double &alow[][10],datetime stime,datetime etime,int n,datetime  &returntime);
   double            FindMaximum(datetime &atime[],double &ahigh[][10],datetime stime,datetime etime,int n,datetime  &returntime);
   void              CreateVL(string name,string txt,datetime laikas,int width,color c,int window);
   int               VLT(int i) { return((int)ObjectGetInteger(0,Name_VLines(i),OBJPROP_TIME)); }
   string            VLS(int i) { return(ObjectGetString(0,Name_VLines(i),OBJPROP_TEXT)); }
   int               VLC(int i) { return((int)ObjectGetInteger(0,Name_VLines(i),OBJPROP_COLOR)); }
   void              SetLots(void);
private:

   struct sLevels
     {
      double            levelMin;
      double            levelMax;
      datetime          timeMin;
      datetime          timeMax;
      double            pips;
     };
   struct HighLow
     {
      double            low;
      double            high;
     };
   sLevels           Level[];

   double            CalcBal(datetime laikas,int n,double price);
   void              ResetLevelsTime(datetime &atime[],double &alow[][10],double &ahigh[][10],int i,int s,datetime laikas,int g);

   double            GetOpenPrice(string pair,datetime laikas);
   double            GetKoef(string pair,datetime time);

   int               ReturnPairId(string pair) { for(int i=0;i<PairCount;i++){ if(Pairs[i]==pair) return(i); } return(0); }
   void              CreateText(string name,datetime time,double price,string txt,string tooltip,color c,int anchor);
   void              ChangeLevel(datetime &atime[],double &alow[][10],double &ahigh[][10],datetime stime,datetime etime,int g);

  };

data::data(void) {}
data::~data(void) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool data::CalcPrevVLines(void)
  {

   double ahigh[][10];
   double alow[][10];
   datetime atime[];
   ReadFilesFromHistory(atime,alow,ahigh);

   int vcount=0;
   ArrayResize(Level,PairCount*LevelCount);
   for(int n=0;n<PairCount;n++)
     {
      for(int g=0;g<LevelCount;g++)
        {
         int nr=g*PairCount+n;
         Level[nr].levelMax=ahigh[0][n];
         Level[nr].levelMin=alow[0][n];
         Level[nr].timeMax=atime[0];
         Level[nr].timeMin=atime[0];
         Level[nr].pips=GetPips(Pairs[n],atime[0],g*LevelGap+LevelStart)/TickValue(Pairs[n],atime[0]);
        }
     }
   ObjectsDeleteAll(0,1,OBJ_VLINE);
   ObjectsDeleteAll(0,1,OBJ_TEXT);

   for(int i=1;i<ArraySize(atime);i++)
     {

      datetime laikas=atime[i];
      HighLow lev[];
      ArrayResize(lev,PairCount);
      for(int nn=0; nn<PairCount; nn++)
        {
         lev[nn].low=alow[i][nn];
         lev[nn].high=ahigh[i][nn];
        }

      for(int g=0;g<LevelCount;g++)
        {
         int abc=0;
         double dif;
         while(true)
           {

            abc++;
            bool ord=false;
            double odif=-1;
            int on=0,os=0;

            for(int n=0; n<PairCount; n++)
              {
               if(lev[n].high==0 || lev[n].low==0) continue;
               int nr=g*PairCount+n;

               double levela=Level[nr].levelMin;
               double LPrice1=levela+Level[nr].pips;

               if(levela!=0)
                  if((lev[n].low<=LPrice1 && lev[n].high>=LPrice1) || lev[n].low>=LPrice1)
                    {
                     dif=CalcBal(laikas,n,LPrice1);
                     if(odif==-1 || odif>dif) { ord=true; odif=dif; on=n; os=0; }
                    }

               double levelb=Level[nr].levelMax;
               double LPrice2=levelb-Level[nr].pips;

               if(levelb!=0)
                  if((lev[n].low<=LPrice2 && lev[n].high>=LPrice2) || lev[n].high<=LPrice2)
                    {
                     dif=CalcBal(laikas,n,LPrice2);
                     if(odif==-1 || odif>dif) { ord=true; odif=dif; on=n; os=1; }
                    }
              }
            if(ord)
              {
               CreateVL(Name_VLines(vcount),(string)os+Pairs[on]+" "+(string)(LevelStart+g*LevelGap),laikas,1,clrOrange,1);
               vcount++;
               ResetLevelsTime(atime,alow,ahigh,on,os,laikas,g);
              }
            else break;

            if(abc>50) { Print("order check breakas "+TimeToStr(laikas)+"  "+Pairs[on]+"  "+(string)i); break; }
            //if(abc>50)  Print(TimeToStr(mLevelsTime[og*paircount+on][os]));
           }
        }

      for(int n=0; n<PairCount; n++)
        {
         if(lev[n].high==0 || lev[n].low==0) continue;
         for(int g=0;g<LevelCount;g++)
           {
            int nr=g*PairCount+n;
            if(Level[nr].levelMin<lev[n].low && Level[nr].levelMax>lev[n].high && Level[nr].levelMin!=0 && Level[nr].levelMax!=0) break;
            if(Level[nr].levelMin>lev[n].low || Level[nr].levelMin==0) { Level[nr].levelMin=lev[n].low; Level[nr].timeMin=laikas; }
            if(Level[nr].levelMax<lev[n].high || Level[nr].levelMax==0) { Level[nr].levelMax=lev[n].high; Level[nr].timeMax=laikas; }
           }
        }

     }
   ArrayResize(Level,0);
   return(true);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void data::SetLots(void)
  {
   for(int i=0;i<PairCount;i++)
     {
      double lots=GetKoef(Pairs[i],(int)TimeCurrent());
      StringSet(Name_Lots(i),DoubleToStr(lots*Lots,2));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void data::ResetLevelsTime(datetime &atime[],double &alow[][10],double &ahigh[][10],int i,int s,datetime laikas,int g)
  {
   int nr=g*PairCount+i;
   datetime LasTime=0;
   if(s==0) LasTime=Level[nr].timeMin;
   else LasTime=Level[nr].timeMax;

   datetime time=LasTime+10;

   ChangeLevel(atime,alow,ahigh,time,laikas,g);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void data::ChangeLevel(datetime &atime[],double &alow[][10],double &ahigh[][10],datetime stime,datetime etime,int g)
  {

   for(int n=0;n<PairCount;n++)
     {
      int nr=g*PairCount+n;
      int START=0;
      int END=0;

      if(stime==etime)
        {
         Level[nr].levelMax=0;
         Level[nr].levelMin=0;
         Level[nr].timeMax=0;
         Level[nr].timeMin=0;
         continue;
        }
      Level[nr].pips=GetPips(Pairs[n],etime,g*LevelGap+LevelStart)/TickValue(Pairs[n],etime);

      Level[nr].levelMin=FindMinimum(atime,alow,stime,etime,n,Level[nr].timeMin);
      Level[nr].levelMax=FindMaximum(atime,ahigh,stime,etime,n,Level[nr].timeMax);



     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double data::FindMinimum(datetime &atime[],double &alow[][10],datetime stime,datetime etime,int n,datetime  &returntime)
  {
   returntime=0;
   double level=0;
   for(int i=0;i<ArraySize(atime);i++)
     {
      if(stime>atime[i]) continue;
      if(atime[i]>etime) break;
      if(level==0 || level>alow[i][n]) { level=alow[i][n]; returntime=atime[i]; }

     }

   return(level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double data::FindMaximum(datetime &atime[],double &ahigh[][10],datetime stime,datetime etime,int n,datetime  &returntime)
  {
   double level=0;
   for(int i=0;i<ArraySize(atime);i++)
     {
      if(stime>atime[i]) continue;
      if(atime[i]>etime) break;
      if(level==0 || level<ahigh[i][n]) { level=ahigh[i][n]; returntime=atime[i]; }
     }
   return(level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double data::CalcBal(datetime laikas,int n,double price)
  {

   double open=Return_OpenFromStruct((int)laikas,n);
//  if(open==0) Alert("neveikia calc bal");
   double d=1000;
   if(MarketInfo(Pairs[n],MODE_DIGITS)==5) d=100000;
   double tickvalue=TickValue(Pairs[n],laikas);
   return(MathAbs(tickvalue * (price - open) * 0.1 * GetKoef(Pairs[n],(int)laikas) * d));
  }
//+------------------------------------------------------------------+
double data::GetPips(string pair,datetime laikas,double gap)
  {
   double Points=100000;
   int dig=(int)MarketInfo(pair,MODE_DIGITS);
   if(dig==3) Points=1000;

   double Koef=GetKoef(pair,laikas);
   if(Koef==0) { Print(pair+" Koef error "+(string)Koef); Koef=1; }
   return(NormalizeDouble((gap / Koef) / Points,dig));
  }
//+------------------------------------------------------------------+
double data::TickValue(string pair,datetime laikas)
  {
   if(TimeCurrent()-laikas<3000)
     {
      double value=MarketInfo(pair,MODE_TICKVALUE);
      if(value>0) return(value);
     }
   string rs=StringSubstr(pair,3,3);
   double open=1;
   if(rs=="USD") return(1);
   if(rs=="JPY") return(100/GetOpenPrice("USDJPY",laikas));
   if(rs=="AUD") return(GetOpenPrice("AUDUSD",laikas));
   if(rs=="CHF") return(1/GetOpenPrice("USDCHF",laikas));
   if(rs=="GBP") return(GetOpenPrice("GBPUSD",laikas));
   if(rs=="NZD") return(GetOpenPrice("NZDUSD",laikas));
   if(rs=="CAD") return(1/GetOpenPrice("USDCAD",laikas));
   return(1);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double data::GetOpenPrice(string pair,datetime laikas)
  {
   if(StringLen(Symbol())>6) pair=StringConcatenate(pair+"-Pro");
   int shift=iBarShift(pair,Period(),laikas);
   if(shift<0) shift=0;
   double open=iOpen(pair,Period(),shift);
   return(open);
  }
//+------------------------------------------------------------------+
double data::GetKoef(string pair,datetime time)
  {
   string ls=StringSubstr(pair,0,3);
   if(ls == "EUR") return(1);
   string p="";
   if(ls == "AUD") p = "EURAUD";
   if(ls == "CHF") p = "EURCHF";
   if(ls == "GBP") p = "EURGBP";
   if(ls == "USD") p = "EURUSD";
   if(StringLen(Symbol())>6) p=StringConcatenate(p+"-Pro");
   int shift=iBarShift(pair,Period(),time);
   return(iClose(p,Period(),shift));
  }
//+------------------------------------------------------------------+
void data::CreateVL(string name,string txt,datetime laikas,int width,color c,int window)
  {
   ObjectCreate(0,name,OBJ_VLINE,window,laikas,0);
   ObjectSetInteger(0,name,OBJPROP_COLOR,c);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DASH);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);

  }
//+------------------------------------------------------------------+
void data::ShowBreakPairs()
  {
   datetime time1=0;
   datetime time2=0;
   string sbuf[];
   int ibuf[];
   for(int i=ObjectsTotal(0,1,OBJ_VLINE)-1;i>=0;i--)
     {
      if(ObjectFind(0,Name_VLines(i))==-1) continue;
      int ot=VLT(i);

      if(time1>ot)
        {
         for(int q=0;q<ArraySize(sbuf);q++)
           {
            int side=(int)StringSubstr(sbuf[q],0,1);

            string pair=StringSubstr(sbuf[q],1,6);
            string p1=StringSubstr(sbuf[q],1,1);
            string p2=StringSubstr(sbuf[q],4,1);
            if(side==0)
              {
               string name=(string)time1+p1+pair+"Poz";
               if(CheckIfExist(name) && TimeCurrent()-ot>1500) return;
               CreateText(name,time1,0.3+ReturnPairId(pair)*1,p1,pair+" "+(string)ibuf[q],clrGreen,ANCHOR_RIGHT);
               CreateText((string)time1+p2+pair+"Poz",time1,0.3+ReturnPairId(pair)*1,p2,pair+" "+(string)ibuf[q],clrRed,ANCHOR_LEFT);
              }
            if(side==1)
              {
               string name=(string)time1+p1+pair+"Ned";
               if(CheckIfExist(name) && TimeCurrent()-ot>1500) return;
               CreateText(name,time1,-0.5-ReturnPairId(pair)*1,p1,pair+" "+(string)ibuf[q],clrRed,ANCHOR_RIGHT);
               CreateText((string)time1+p2+pair+"Neg",time1,-0.5-ReturnPairId(pair)*1,p2,pair+" "+(string)ibuf[q],clrGreen,ANCHOR_LEFT);
              }
           }
         ArrayResize(sbuf,0);
         ArrayResize(ibuf,0);
         time1=0;
         time2=0;

        }
      if(time1==0 && time2==0)
        {
         time1=ot-TimeSeconds(ot);
         time2=time1+60;
        }

      string str=StringSubstr(VLS(i),0,7);

      int size=ArraySize(sbuf);
      if(size==0) { ArrayResize(sbuf,size+1); ArrayResize(ibuf,size+1); sbuf[size]=str; ibuf[size]=1; }
      else
        {
         int q=0;
         for(q=0;q<size;q++) { if(str==sbuf[q]) { ibuf[q]++; break; } }
         if(q==size) { ArrayResize(sbuf,size+1); ArrayResize(ibuf,size+1); sbuf[size]=str; ibuf[size]=1; }
        }
     }

   for(int q=0;q<ArraySize(sbuf);q++)
     {
      int side=(int)StringSubstr(sbuf[q],0,1);

      string pair=StringSubstr(sbuf[q],1,6);
      string p1=StringSubstr(sbuf[q],1,1);
      string p2=StringSubstr(sbuf[q],4,1);
      if(side==0)
        {

         CreateText((string)time1+p1+pair+"Poz",time1,0.3+ReturnPairId(pair)*1,p1,pair+" "+(string)ibuf[q],clrGreen,ANCHOR_RIGHT);
         CreateText((string)time1+p2+pair+"Poz",time1,0.3+ReturnPairId(pair)*1,p2,pair+" "+(string)ibuf[q],clrRed,ANCHOR_LEFT);
        }
      if(side==1)
        {
         CreateText((string)time1+p1+pair+"Ned",time1,-0.5-ReturnPairId(pair)*1,p1,pair+" "+(string)ibuf[q],clrRed,ANCHOR_RIGHT);
         CreateText((string)time1+p2+pair+"Neg",time1,-0.5-ReturnPairId(pair)*1,p2,pair+" "+(string)ibuf[q],clrGreen,ANCHOR_LEFT);
        }
     }

  }
//+------------------------------------------------------------------+
void data::CreateText(string name,datetime time,double price,string txt,string tooltip,color c,int anchor)
  {
   ObjectDelete(0,name);

   if(txt=="E") c=clrNavy;
   if(txt=="A") c=clrTan;
   if(txt=="G") c=clrMediumPurple;
   if(txt=="U") c=clrGreen;
   if(txt=="J") c=clrYellowGreen;

   ObjectCreate(0,name,OBJ_TEXT,1,time,price);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Black");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
