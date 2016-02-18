//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "MultiG_10S_Settings.mqh"

#property   strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LoadFiles : public Settings
  {
public:
   struct candle
     {
      int               time;
      double            open;
      double            low;
      double            high;
      double            close;
     };

                     LoadFiles(void);
                    ~LoadFiles(void);
   void              ReadFilesFromHistory(datetime &atime[],double &alow[][10],double &ahigh[][10]);
   void              SaveArrays(datetime &atime[],double &alow[][10],double &ahigh[][10]);
   void              LoadArrays(datetime &atime[],double &alow[][10],double &ahigh[][10]);
   void              UpdateArrays(datetime &atime[],double &alow[][10],double &ahigh[][10]);
   void              MoveFiles(void);

   bool              CheckForNewCandle(void);
   bool              LookForNewFiles(void);
   void              MoveNewFiles();
   string            Return_Location(void) { return("DATA/"); };
   string            Return_HistoryLocation(void) { return(Return_Location()+"History/"); };
   string            Return_NewDataLocation(void) { return(Return_Location()+"New/"); };
   string            Return_FileTime(void) { return(Return_Location()+"Times.bin"); };
   string            Return_FileLow(void) { return(Return_Location()+"Lows.bin"); };
   string            Return_FileHigh(void) { return(Return_Location()+"Highs.bin"); };

   double            Return_OpenFromStruct(datetime time,int n);

private:
   void              ReadFile(string name,datetime &atime[],double &alow[][10],double &ahigh[][10]);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LoadFiles::LoadFiles(void)
  {

  }
LoadFiles::~LoadFiles(void) {}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadFiles::SaveArrays(datetime &otime[],double &olow[][10],double &ohigh[][10])
  {

   double ahigh[][10];
   double alow[][10];
   datetime atime[];

   if(Return_MainTime(LevelCount-1)-60>otime[0])
     {
      datetime ltime=Return_MainTime(LevelCount-1)-60;

      int j=0;
      for(j=0;j<ArraySize(otime);j++)
        {
         if(otime[j]>=ltime) break;
        }
int rem=j;
      //ArrayCopy(atime,otime,0,i,ArraySize(otime)-i);
      // ArrayCopy(alow,olow,0,i*10,ArraySize(otime)-i*10);
      //ArrayCopy(ahigh,ohigh,0,i*10,ArraySize(otime)-i*10);
      ArrayResize(atime,ArraySize(otime)-j);
      ArrayResize(alow,ArraySize(otime)-j);
      ArrayResize(ahigh,ArraySize(otime)-j);

      for(int i=0;i<ArraySize(atime);i++)
        {
         atime[i]=otime[j];
         for(int n=0;n<10;n++)
           {
            alow[i][n]=olow[j][n];
            ahigh[i][n]=ohigh[j][n];
            if(alow[i][n]==0 || ahigh[i][n]==0) Alert((string)atime[i]+"  "+(string)ArraySize(otime)+"  "+(string)ArraySize(atime)+"  "+(string)j);
           }
         j++;
        }
    //  Print("removing lines "+(string)ArraySize(otime)+"  "+(string)ArraySize(atime)+"  "+(string)rem+"   "+alow[0][1]+"  "+olow[rem][1]);
     }
   else
     {
      ArrayCopy(atime,otime);
      ArrayCopy(alow,olow);
      ArrayCopy(ahigh,ohigh);
     }

   int handle=FileOpen(Return_FileTime(),FILE_WRITE|FILE_BIN);
   FileWriteArray(handle,atime);
   FileClose(handle);

   int handle1=FileOpen(Return_FileLow(),FILE_WRITE|FILE_BIN);
   int handle2=FileOpen(Return_FileHigh(),FILE_WRITE|FILE_BIN);
   for(int i=0;i<ArraySize(atime);i++)
     {
      for(int n=0;n<10;n++)
        {
         FileWriteDouble(handle1,alow[i][n],DOUBLE_VALUE);
         FileWriteDouble(handle2,ahigh[i][n],DOUBLE_VALUE);

        }
     }
   FileClose(handle1);
   FileClose(handle2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadFiles::LoadArrays(datetime &atime[],double &alow[][10],double &ahigh[][10])
  {
   double ohigh[][10];
   double olow[][10];
   datetime otime[];
   int handle=FileOpen(Return_FileTime(),FILE_READ|FILE_BIN);
   FileReadArray(handle,otime);
   FileClose(handle);

   int handle1=FileOpen(Return_FileLow(),FILE_READ|FILE_BIN);
   int handle2=FileOpen(Return_FileHigh(),FILE_READ|FILE_BIN);
   ArrayResize(olow,ArraySize(otime));
   ArrayResize(ohigh,ArraySize(otime));
   for(int i=0;i<ArraySize(otime);i++)
     {
      for(int n=0;n<10;n++)
        {
         olow[i][n]=FileReadDouble(handle1,DOUBLE_VALUE);
         ohigh[i][n]=FileReadDouble(handle2,DOUBLE_VALUE);
        }
     }
   FileClose(handle1);
   FileClose(handle2);

   ArrayCopy(atime,otime);
   ArrayCopy(alow,olow);
   ArrayCopy(ahigh,ohigh);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadFiles::ReadFilesFromHistory(datetime &atime[],double &alow[][10],double &ahigh[][10])
  {
   string InpFilter=Return_HistoryLocation()+"*";
   string file_name;
   long search_handle=FileFindFirst(InpFilter,file_name);
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         ReadFile(Return_HistoryLocation()+file_name,atime,alow,ahigh);
        }
      while(FileFindNext(search_handle,file_name));
      FileFindClose(search_handle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LoadFiles::LookForNewFiles(void)
  {
   double ahigh[][10];
   double alow[][10];
   datetime atime[];

   string InpFilter=Return_NewDataLocation()+"*";
   string file_name;
   long search_handle=FileFindFirst(InpFilter,file_name);
   bool find=false;
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         find=true;
         ReadFile(Return_NewDataLocation()+file_name,atime,alow,ahigh);
         FileMove(Return_NewDataLocation()+file_name,0,Return_HistoryLocation()+file_name,FILE_REWRITE);
        }
      while(FileFindNext(search_handle,file_name));
      FileFindClose(search_handle);
     }
   if(find) UpdateArrays(atime,alow,ahigh);
   return(find);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadFiles::MoveNewFiles()
  {
   string InpFilter=Return_NewDataLocation()+"*";
   string file_name;
   long search_handle=FileFindFirst(InpFilter,file_name);
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         FileMove(Return_NewDataLocation()+file_name,0,Return_HistoryLocation()+file_name,FILE_REWRITE);
        }
      while(FileFindNext(search_handle,file_name));
      FileFindClose(search_handle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadFiles::UpdateArrays(datetime &atime[],double &alow[][10],double &ahigh[][10])
  {
   double ohigh[][10];
   double olow[][10];
   datetime otime[];
   LoadArrays(otime,olow,ohigh);
   int s=ArraySize(atime);
   int size=ArraySize(otime);
   int newsize=size+s;
   ArrayResize(otime,newsize);
   ArrayResize(olow,newsize);
   ArrayResize(ohigh,newsize);
   int j=0;
   for(int i=size;i<size+s;i++)
     {
      otime[i]=atime[j];
      for(int n=0;n<PairCount;n++)
        {
         olow[i][n]=alow[j][n];
         ohigh[i][n]=ahigh[j][n];
         if(olow[i][n]==0 || ohigh[i][n]==0) Alert("struct zero");
        }
      j++;
     }

   SaveArrays(otime,olow,ohigh);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadFiles::ReadFile(string name,datetime &atime[],double &alow[][10],double &ahigh[][10])
  {
   candle array[10];
   array[0].time=0;
   int handle=FileOpen(name,FILE_READ|FILE_BIN);
   int i=0;
   if(handle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(handle))
        {
         FileReadStruct(handle,array[i]);
         i++;
        }
      FileClose(handle);
     }
   int size=ArraySize(atime);
   if(size>0)
     {
      if(atime[size-1]>array[0].time) { Print("Wrong time "+TimeToStr((int)atime[size-1],TIME_SECONDS)+"   gg "+TimeToStr(array[0].time,TIME_SECONDS)+" "+name); return; }
     }
   ArrayResize(atime,size+1);
   ArrayResize(alow,size+1);
   ArrayResize(ahigh,size+1);

   atime[size]=array[0].time;

   for(int j=0;j<PairCount;j++)
     {
      ahigh[size][j]=array[j].high;
      alow[size][j]=array[j].low;
     }
  }
//+------------------------------------------------------------------+
double LoadFiles::Return_OpenFromStruct(datetime time,int n)
  {
   candle array[10];
   array[n].open=0;
   int handle=FileOpen("writedata/"+(string)time+"testaa.txt",FILE_READ|FILE_BIN);
   int i=0;
   if(handle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(handle))
        {
         FileReadStruct(handle,array[i]);
         i++;
        }
      FileClose(handle);
     }
   return(array[n].open);

  }
//+------------------------------------------------------------------+
void LoadFiles::MoveFiles(void)
  {
   datetime time=0;
   for(int i=0;i<ObjectsTotal(0,0,OBJ_VLINE);i++)
     {
      string name=ObjectName(0,i,0,OBJ_VLINE);
      if(ObjectGetString(0,name,OBJPROP_TEXT)=="") { time=(datetime)ObjectGetInteger(0,name,OBJPROP_TIME); ObjectDelete(0,name); break; }
     }
   if(time==0) return;


   string InpFilter=Return_HistoryLocation()+"*";
   string file_name;
   long search_handle=FileFindFirst(InpFilter,file_name);
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         int t=(int)StringSubstr(file_name,0,10);
         if(t<time)
           {
            FileMove(Return_HistoryLocation()+file_name,0,Return_Location()+(string)TimeDayOfYear(t)+"/"+file_name,FILE_REWRITE);
           }
        }
      while(FileFindNext(search_handle,file_name));
      FileFindClose(search_handle);
     }

  }
//+------------------------------------------------------------------+
