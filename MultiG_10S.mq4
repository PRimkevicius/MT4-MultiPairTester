//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers  1
#property strict
#include "MultiG_Main.mqh"


bool allowdraging=true;
bool mouseflag=0;
string box_name;
int  Drag_X=0,Drag_Y=0;

main C();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//  ObjectsDeleteAll(0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0);
   IndicatorSetDouble(INDICATOR_MINIMUM,-10);
   IndicatorSetDouble(INDICATOR_MAXIMUM,10);
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,0,true);
   C.OBJ.CreateMainObj();
   EventSetTimer(2);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0,true);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime timer1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!GlobalVariableCheck(C.Name_GlobalStatus())) return;
   if(C.LookForNewFiles()) C.UpdateLevels(-1);

   if(TimeCurrent()>timer1)
     {
      timer1=TimeCurrent()+30;
      C.CheckPeaks();
     }
   if(OrdersTotal()>0) C.CheckOpenOrderProfit();
   
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int xx=0;
int yy=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam==C.Name_ButtonStart())
        {
         string name=sparam;
         ObjectSetInteger(0,name,OBJPROP_STATE,0);

         if(!GlobalVariableCheck(C.Name_GlobalStatus())) { ExeStart();  return; }
         else { ExeStop(); return; }
         return;
        }
      if(sparam==C.Name_ButtonAllow())
        {
         string name=sparam;
         if(GlobalVariableCheck(C.Name_GlobalExeOrders()))
           {
            ObjectSetString(0,name,OBJPROP_TEXT,"Nope");
            ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrRed);
            GlobalVariableDel(C.Name_GlobalExeOrders());
            ObjectSetInteger(0,name,OBJPROP_STATE,0);
            return;
           }
         else
           {
            ObjectSetString(0,name,OBJPROP_TEXT,"Yep");
            ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrGreen);
            GlobalVariableSet(C.Name_GlobalExeOrders(),0);
            ObjectSetInteger(0,name,OBJPROP_STATE,0);
            return;
           }

        }
      if(sparam==C.Name_ButtonRefresh()) { ChartSetSymbolPeriod(0,Symbol(),Period()); return; }
      if(sparam==C.Name_ButtonCalcVlines()) { C.CalcPrevVLines();  }
      if(sparam==C.Name_ButtonShowBreakPairs()) { C.ShowBreakPairs();  }
      if(sparam==C.Name_ButtonCheckPeaks()) { C.CheckPeaks(); }

      if(StringFind(sparam,"Pairs")!=-1)
        {
         int poz=(int)StringFind(sparam,"#");
         ChartSetSymbolPeriod(0,C.Pairs[(int)StringSubstr(sparam,poz+1,StringLen(sparam)-poz)],Period());
        }

      if(StringFind(sparam,C.Name_ForValid())!=-1 && StringFind(sparam,"Close")==-1)
        {
         C.ShowOrderDetails(sparam);
         return;
        }
      if(sparam=="CP0") { ObjectsDeleteAll(0,1,OBJ_VLINE); C.OBJ.RemoveCpanel(); }
      if(sparam=="CP1") { ObjectsDeleteAll(0,1,OBJ_TEXT); C.OBJ.RemoveCpanel(); }
      if(sparam=="CP2") { ObjectsDeleteAll(0,1,OBJ_LABEL); C.OBJ.RemoveCpanel();  ChartSetSymbolPeriod(0,Symbol(),Period()); }
      if(sparam=="CP3") { EventChartCustom(0,33,0,0,""); }
      if(sparam=="CP4") { C.MoveFiles(); C.OBJ.RemoveCpanel(); }
      if(sparam=="CP5") { C.RecalPips(); C.OBJ.RemoveCpanel(); }
      if(sparam=="CP6") { C.OBJ.MoveTable(); C.OBJ.RemoveCpanel(); }

      return;
     }
   if(id==CHARTEVENT_KEYDOWN && lparam==49) { C.OBJ.CPCreate(xx,yy); return; }

   if(id==CHARTEVENT_KEYDOWN && lparam==50)
     {
      int g=2;
      int n=1;
      int s=1;
      // Print(C.Return_LevelTime(g,n,s)+"  "+C.CheckLevel(g,n,s));
     }
   if(id==CHARTEVENT_KEYDOWN && lparam==51)
     {
      ObjectsDeleteAll(0,0,OBJ_RECTANGLE_LABEL);
      for(int i=ObjectsTotal(0,0,OBJ_LABEL)-1;i>=0;i--)
        {
         string name=ObjectName(0,i,0,OBJ_LABEL);
         if(StringFind(name,C.Name_ForValid())!=-1) ObjectDelete(0,name);
        }
     }

   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      if(ObjectGetString(0,sparam,OBJPROP_TEXT)!="" || ObjectType(sparam) != OBJ_TREND) return;

      int time1=0;
      int time2=0;
      if(ObjectGet(sparam,OBJPROP_TIME1)<=ObjectGet(sparam,OBJPROP_TIME2))
        {
         time1=(int)ObjectGetInteger(0,sparam,OBJPROP_TIME1);
         time2=(int)ObjectGetInteger(0,sparam,OBJPROP_TIME2);
        }
      else
        {
         time2=(int)ObjectGetInteger(0,sparam,OBJPROP_TIME1);
         time1=(int)ObjectGetInteger(0,sparam,OBJPROP_TIME2);
        }

      C.ShowObjectsComment(time1,time2);
      ObjectsDeleteAll(0,1,OBJ_TREND);

      return;
     }
   if(id==CHARTEVENT_CUSTOM+117)
     {
      string name=C.Name_VLines(ObjectsTotal(0,1,OBJ_VLINE));
      C.CreateVL(name,sparam,TimeCurrent(),1,clrOrange,1);
      C.ShowLastBreaks(sparam);
      IndicatorShortName(sparam);
      C.UpdateLevels((int)lparam);
      //  C.FastCheckPeaks((int)lparam);
     }
   if(id==CHARTEVENT_CUSTOM+221) C.RemoveValidBox(sparam);
   if(id==CHARTEVENT_CUSTOM+222) C.OBJ.CreateButtonCloseAll();

   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      xx=(int)lparam;
      yy=(int)dparam;
      if(!allowdraging) { if((int)sparam==0) allowdraging=true; else return; }
      if((int)sparam==1 && !mouseflag && allowdraging)
        {
         box_name=CheckCordinates((int)lparam,(int)dparam);
         if(box_name=="") { allowdraging=false; return; }
         ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
         mouseflag=true;
        }
      if((int)sparam==0 && mouseflag && box_name!="")
        {
         mouseflag= false;
         box_name = "";
         ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
         ChartRedraw(0);
         return;
        }
      if(mouseflag && box_name!="")
        {
         MoveObjects((int)lparam,(int)dparam,box_name);
         ChartRedraw(0);
        }
      return;
     }
   if(C.CheckIfExist(C.Name_CPanel()) && (id==CHARTEVENT_CLICK || id==CHARTEVENT_KEYDOWN)) C.OBJ.RemoveCpanel();
  }
//+------------------------------------------------------------------+

void ExeStop()
  {
   string name=C.Name_ButtonStart();
   ObjectSetString(0,name,OBJPROP_TEXT,"Start");
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrGreen);
   GlobalVariableDel(C.Name_GlobalStatus());
   C.ClearAllObjects();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExeStart()
  {
   string name=C.Name_ButtonStart();
   ObjectSetString(0,name,OBJPROP_TEXT,"Stop");
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrRed);
   C.LastTime();
   GlobalVariableSet(C.Name_GlobalStatus(),0);
  }
//+------------------------------------------------------------------+
string CheckCordinates(int x,int y)
  {
   for(int i=0;i<ObjectsTotal(0,0,OBJ_RECTANGLE_LABEL);i++)
     {
      string name=ObjectName(0,i,0,OBJ_RECTANGLE_LABEL);
      int XStart  = (int)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
      int YStart  = (int)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
      int XEnd    = XStart + (int)ObjectGetInteger(0,name,OBJPROP_XSIZE);
      int YEnd    = YStart + (int)ObjectGetInteger(0,name,OBJPROP_YSIZE);

      if(x>XStart && x<XEnd && y>YStart && y<YEnd)
        {
         Drag_X = x;
         Drag_Y = y;
         return(name);
        }
     }

   return("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MoveObjects(int x,int y,string name)
  {
   string st = StringSubstr(name,0,3)+C.Name_ForValid();
   int X_dif = x - Drag_X;
   int Y_dif = y - Drag_Y;
   for(int i = 0; i < ObjectsTotal(0,0); i++)
     {
      string ObjName=ObjectName(i);
      if(StringFind(ObjName,st)!=-1)
        {
         int objx = (int)ObjectGetInteger(0,ObjName,OBJPROP_XDISTANCE);
         int objy = (int)ObjectGetInteger(0,ObjName,OBJPROP_YDISTANCE);
         ObjectSetInteger(0,ObjName,OBJPROP_XDISTANCE,objx+X_dif);
         ObjectSetInteger(0,ObjName,OBJPROP_YDISTANCE,objy+Y_dif);
         // if(ObjName == IndName+"Background") { SetArray[0] = objx+X_dif; SetArray[1] =objy+Y_dif; } 
        }
     }
   Drag_X = x;
   Drag_Y = y;

  }
//+------------------------------------------------------------------+
