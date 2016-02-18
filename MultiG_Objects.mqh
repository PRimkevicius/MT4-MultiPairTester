//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "MultiG_10S_Settings.mqh"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class obj: public Settings
  {
public:
                     obj(void);
                    ~obj(void);
   void              CreateMainObj(void);
   void              CreateRect(string name,string txt,int X,int Y,int xsize,int ysize,int style);
   void              CreateLabel(string name,int x,int y,int window);
   void              CreateButtonCloseAll();
   void              CPCreate(int x,int y);
   void              RemoveCpanel(void);
   void              MoveTable(void);

private:

   void              CreateButton(string name,string txt,int X,int Y,int xsize,int ysize,int window,int fontsize,color c,int state);

  };
obj::obj(void) {}
obj::~obj(void) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
obj::CreateMainObj(void)
  {
   int X = 10;
   int Y = 20;


   string name=Name_ButtonStart();
   if(!CheckIfExist(Name_ButtonStart())) CreateButton(Name_ButtonStart(),"-",X+50,Y+5,45,20,0,8,clrDimGray,0);

   ObjectSetInteger(0,name,OBJPROP_STATE,0);
   if(!GlobalVariableCheck(Name_GlobalStatus())) { StringSet(name,"Start"); ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrGreen); }
   else { StringSet(name,"Stop"); ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrRed); }

   name=Name_ButtonAllow();
   if(!CheckIfExist(name)) CreateButton(name,"-",X+50,Y+30,45,20,0,8,clrGray,0);
   if(GlobalVariableCheck(Name_GlobalExeOrders())) { ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrGreen); StringSet(name,"Yep"); }
   else { ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrRed); StringSet(name,"Nope"); }

   name=Name_ButtonRefresh();
   if(!CheckIfExist(name)) { CreateButton(name,"R",X+20,Y+5,20,20,1,6,clrGray,0); }

   name=Name_ButtonCalcVlines();
   if(!CheckIfExist(name)) { CreateButton(name,"Calc VL",X+50,Y+30,45,20,1,7,clrGray,0); }

   name=Name_ButtonShowBreakPairs();
   if(!CheckIfExist(name)) { CreateButton(name,"Br Pairs",X+50,Y+55,45,20,1,7,clrGray,0); }

   name=Name_ButtonCheckPeaks();
   if(!CheckIfExist(name)) { CreateButton(name,"Peaks",X+50,Y+80,45,20,0,7,clrGray,0); }



   for(int i=0;i<PairCount;i++)
     {
      name=Name_Pairs(i);
      if(!CheckIfExist(name)) {  CreateLabel(name,X+50,Y+10+18*i,0); ObjectSetInteger(0,name,OBJPROP_CORNER,1); ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10); }
      StringSet(name,Pairs[i]);
 
       name=Name_Lots(i);
      if(!CheckIfExist(name)) { CreateLabel(name,X+85,Y+10+18*i,0);  ObjectSetInteger(0,name,OBJPROP_CORNER,1); ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9); }   
     }

   X = 250;
   Y = 50;
   int X_ = 50;
   int Y_ = 25;

   for(int g=0;g<LevelCount;g++)
     {
      for(int n=0;n<PairCount;n++)
        {
         int s=0;
         name=Name_LabelTime(g,n,s);
         if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y,0);
         Set_ToolTip(name,Pairs[n]+" "+(string)s);

         name=Name_LabelPrice(g,n,s);
         if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y,0);
         Set_ToolTip(name,Pairs[n]+" "+(string)s);

         name=Name_LabelBreak(g,n,s);
         if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y+30+Y_*n,0);
         Set_ToolTip(name,Pairs[n]+" "+(string)s);

         s=1;
         name=Name_LabelTime(g,n,s);
         if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y,0);
         Set_ToolTip(name,Pairs[n]+" "+(string)s);

         name=Name_LabelPrice(g,n,s);
         if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y,0);
         Set_ToolTip(name,Pairs[n]+" "+(string)s);

         name=Name_LabelBreak(g,n,s);
         if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y+40+Y_*n,0);
         Set_ToolTip(name,Pairs[n]+" "+(string)s);

         name=Name_LabelPips(g,n);
         if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y,0);
         Set_ToolTip(name,Pairs[n]+" "+(string)s);

        }
      name=Name_Level(g);
      if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y-15,0);

      name=Name_LastTime(g);
      if(!CheckIfExist(name)) CreateLabel(name,X+X_*g,Y-30,0);
     }

   for(int i=0;i<17;i++)
     {
      name=Name_LastBreaks(i);
      if(!CheckIfExist(name)) { CreateLabel(name,170,2+10*i,1); ObjectSetInteger(0,name,OBJPROP_CORNER,1); }

     }
   name=Name_Clock();
   if(!CheckIfExist(name)) { CreateLabel(name,70,150,0); ObjectSetInteger(0,name,OBJPROP_CORNER,3); ObjectSetInteger(0,name,OBJPROP_FONTSIZE,12); }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void obj::CreateButtonCloseAll()
  {
   if(CheckIfExist(Name_OrdersCloseAllButton())) return;
   string name=Name_OrdersCloseAllButton();
   CreateButton(name,"Close All",55,15,45,20,1,7,clrRed,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,1);
  }
//+------------------------------------------------------------------+
void obj::CreateButton(string name,string txt,int X,int Y,int xsize,int ysize,int window,int fontsize,color c,int state)
  {
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_BUTTON,window,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,Y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xsize);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ysize);
   ObjectSetInteger(0,name,OBJPROP_CORNER,3);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,c);
   ObjectSetInteger(0,name,OBJPROP_STATE,state);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void obj::CreateLabel(string name,int x,int y,int window)
  {
   if(ObjectFind(0,name) != -1) return;
   ObjectCreate(0,name,OBJ_LABEL,window,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,0);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,0);
   ObjectSetString(0,name,OBJPROP_TEXT,"--");
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,7);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,NULL);
// ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }
//+------------------------------------------------------------------+
void obj::CreateRect(string name,string txt,int X,int Y,int xsize,int ysize,int style)
  {

   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,Y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xsize);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ysize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrDarkGray);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetString(0,name,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);

  }
//+------------------------------------------------------------------+
void obj::CPCreate(int x,int y)
  {

   string cpo[]=
     {
      "R VLines",
      "R Text",
      "R Break l",
      "R Orders",
      "R Files",
      "New Pips",
      "B Table"
     };


   int X=50;
   int Y=(ArraySize(cpo))*18+5;
   CreateRect(Name_CPanel(),"CP",x,y,X,Y,STYLE_SOLID);

   for(int i=0;i<ArraySize(cpo);i++)
     {
      string name="CP"+(string)i;
      CreateButton(name,cpo[i],x+2,y+2+18*i,45,18,0,7,clrDimGray,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,0);
     }
//

  }

//+------------------------------------------------------------------+
void obj::RemoveCpanel(void)
  {
   ObjectDelete(0,Name_CPanel());
   string name;
   int i=0;
   while(true)
     {
      name="CP"+(string)i;
      if(CheckIfExist(name)) ObjectDelete(0,name);
      else break;
      i++;
     }
  }
//+------------------------------------------------------------------+
void obj::MoveTable(void)
  {
   for(int i=0;i<ObjectsTotal(0,0,OBJ_LABEL);i++)
     {
      string name=ObjectName(0,i,0,OBJ_LABEL);
      if(StringFind(name,"%")==-1) continue;
      
      int x=(int)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
      if(x>0) x+=-500;
      else x+=500;
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
     }
  }
//+------------------------------------------------------------------+
