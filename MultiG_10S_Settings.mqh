//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
class Settings
  {
public:
   string            Pairs[10];
   int               PairCount;
   int               LevelCount;
   int               LevelStart;
   int               LevelGap;
   double            Lots;
   string            NAME;

                     Settings(void);
                    ~Settings(void);
   void              StringSet(string name,string value) { ObjectSetString(0,name,OBJPROP_TEXT,value); };
   void              Set_ToolTip(string name,string value) { ObjectSetString(0,name,OBJPROP_TOOLTIP,value); };
   string            Return_String(string name) { return(ObjectGetString(0,name,OBJPROP_TEXT)); };

   //--- Names Button
   string            Name_ButtonStart(void) { return("Button_START"); };
   string            Name_ButtonAllow(void) { return("Button_ALLOW"); };
   string            Name_ButtonRefresh(void) { return("Button_REFRESH"); };
   string            Name_ButtonCheckPeaks(void) { return("Button_CHECKPEAKS"); };
   string            Name_ButtonCalcVlines(void) { return("Button_CALCVLINES"); };
   string            Name_ButtonShowBreakPairs(void) { return("Button_SHOWBREAKPAIRS"); };
   //--- Names Obj
   string            Name_Pairs(int n) { return("Pairs#"+(string)n); };
   string            Name_Lots(int n) { return("Lots"+(string)n); };
   string            Name_Level(int g) { return("GN% "+(string)g); };
   string            Name_LastTime(int g) { return("GT% "+(string)g); };
   string            Name_LabelTime(int g,int n,int s) { return("LT% G"+(string)g+" N"+(string)n+" S"+(string)s); };
   string            Name_LabelPrice(int g,int n,int s) { return("LP% G"+(string)g+" N"+(string)n+" S"+(string)s); };
   string            Name_LabelPips(int g,int n) { return("PP% G"+(string)g+" N"+(string)n); };
   string            Name_LabelBreak(int g,int n,int s) { return("LB% G"+(string)g+" N"+(string)n+" S"+(string)s); };

   

   string            Name_Event(int g) { return("LastTimeEvent"+(string)g); };

   string            Name_LevelHlineA(int g,int n) { return("HlineA"+(string)g+" "+(string)n); };
   string            Name_LevelHlineB(int g,int n) { return("HlineB"+(string)g+" "+(string)n); };

   string            Name_LastBreaks(int i) { return("LastBreaks"+(string)i); };

   //--- Names Global
   string            Name_GlobalStatus(void) { return(NAME+"STATUS_ACTIVE"); };
   string            Name_GlobalExeOrders(void) { return(NAME+"ALLOW_ORDERS"); };
   string            Name_GlobalLots(void) { return(NAME+"LOTS"); };

   string            Name_ObjVLine(void) { return("VLINE"); };
   string            Name_VLines(int n) { return(Name_ObjVLine()+(string)n); };
   string            Name_Clock(void) { return("Clock"); };

   //--- Name Custom Panel
   string            Name_CPanel(void) { return("CPanel"); };

   //--- Names For Valid
   string            Name_ForValid() { return("ValidOrd"); };
   string            Name_ValidRec(int g,int n,int s) { return((string)g+(string)n+(string)s+Name_ForValid()+"Rect"); };
   string            Name_ValidMainLabel(int g,int n,int s) { return((string)g+(string)n+(string)s+Name_ForValid()+"MainLabel"); };
   string            Name_ValidClose(int g,int n,int s) { return((string)g+(string)n+(string)s+Name_ForValid()+"Close"); };
   string            Name_ValidOrderTime() { return("ValidOrderTime"); };

   //--- Names Order
   string            Name_OpenOrderSymbol(int n) { return("OrderSymbol"+(string)n); };
   string            Name_OpenOrderInfo(int n) { return("OrderInfo"+(string)n); };
   string            Name_OpenOrderTicket(int n) { return("OrderTicket"+(string)n); };
   string            Name_OrderCloseButton(int i) { return("OrderClose"+(string)i); };
   string            Name_OpenOrderProfit(int i) { return("OrderProfit"+(string)i); };
   string            Name_OrdersCloseAllButton() { return("CloseAllOrder"); };

   //--- Return Object Value
   datetime          Return_LevelTime(int g,int n,int s) { return((datetime)StringToTime(Return_String(Name_LabelTime(g,n,s)))); };
   datetime          Return_MainTime(int g) { return((datetime)StringToTime(Return_String(Name_LastTime(g)))); };
   int               Return_Level(int g) { return((int)Return_String(Name_Level(g))); };
   double            Return_LevelPrice(int g,int n,int s) { return(StringToDouble(Return_String(Name_LabelPrice(g,n,s)))); }
   double            Return_LevelBreak(int g,int n,int s) { return(StringToDouble(Return_String(Name_LabelBreak(g,n,s)))); }
   double            Return_Pips(int g,int n) { return((double)Return_String(Name_LabelPips(g,n))); };
   
   //--- Return Order Values
   string            Return_OrderPair(int n) { return(Return_String(Name_OpenOrderSymbol(n))); };
   int               Return_OrderTicket(int n) { return((int)Return_String(Name_OpenOrderTicket(n))); };
   double            Return_Lots(int i) { return((double)Return_String(Name_Lots(i))); };

   color             ValidOrderColor(void) { return(clrDarkOrange); };
   bool              CheckTimeColor(int g,int n,int s) {  if(ObjectGetInteger(0,Name_LabelBreak(g,n,s),OBJPROP_COLOR)==ValidOrderColor()) return(true); return(false); };
   bool              CheckIfExist(string name) { if(ObjectFind(0,name)!=-1) return(true); else return(false); }
   void              WriteLog(string txt);
   void              RemoveOrderObjects(int i);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Settings::Settings(void)
  {
   NAME="qw";
   Lots=0;
   LevelCount=4;
   LevelStart=100;
   LevelGap=25;
   PairCount=10;
   Pairs[0]="AUDJPY";
   Pairs[1]="AUDUSD";
   Pairs[2]="EURAUD";
   Pairs[3]="EURGBP";
   Pairs[4]="EURJPY";
   Pairs[5]="EURUSD";
   Pairs[6]="GBPAUD";
   Pairs[7]="GBPJPY";
   Pairs[8]="GBPUSD";
   Pairs[9]="USDJPY";
   if(!GlobalVariableCheck(Name_GlobalLots())) GlobalVariableSet(Name_GlobalLots(),0.1);
   else Lots=GlobalVariableGet(Name_GlobalLots());

  }
//+------------------------------------------------------------------+
Settings::~Settings(void) {}
//+------------------------------------------------------------------+
void Settings::WriteLog(string txt)
  {
   int handle=FileOpen(NAME+"_EAlog.txt",FILE_READ|FILE_WRITE);
   FileSeek(handle,0,SEEK_END);
   FileWrite(handle,TimeToStr(TimeCurrent(),TIME_SECONDS)+" "+txt);
   FileClose(handle);
  }
//+------------------------------------------------------------------+
void Settings::RemoveOrderObjects(int i)
  {
   ObjectDelete(0,Name_OpenOrderSymbol(i));
   ObjectDelete(0,Name_OpenOrderInfo(i));
   ObjectDelete(0,Name_OpenOrderTicket(i));
   ObjectDelete(0,Name_OrderCloseButton(i));
   ObjectDelete(0,Name_OpenOrderProfit(i));
  }
//+------------------------------------------------------------------+
