
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 12;
#property indicator_plots 12;

#property indicator_color1 clrAliceBlue
#property indicator_label1 "MA1"
#property indicator_style1 STYLE_SOLID
#property indicator_type1  DRAW_LINE
#property indicator_width1 1 

#property indicator_color2 clrAliceBlue
#property indicator_label2 "MA2"
#property indicator_style2 STYLE_SOLID
#property indicator_type2  DRAW_LINE
#property indicator_width2 1

#property indicator_color3 clrAliceBlue
#property indicator_label3 "MA3"
#property indicator_style3 STYLE_SOLID
#property indicator_type3  DRAW_LINE
#property indicator_width3 1 

#property indicator_color4 clrAliceBlue
#property indicator_label4 "MA4"
#property indicator_style4 STYLE_SOLID
#property indicator_type4  DRAW_LINE
#property indicator_width4 1 

#property indicator_color5 clrAliceBlue
#property indicator_label5 "MA5"
#property indicator_style5 STYLE_SOLID
#property indicator_type5  DRAW_LINE
#property indicator_width5 1 

#property indicator_color6 clrAliceBlue
#property indicator_label6 "MA6"
#property indicator_style6 STYLE_SOLID
#property indicator_type6  DRAW_LINE
#property indicator_width6 1 

#property indicator_color7 clrAliceBlue
#property indicator_label7 "MA7"
#property indicator_style7 STYLE_SOLID
#property indicator_type7  DRAW_LINE
#property indicator_width7 1 

#property indicator_color8 clrAliceBlue
#property indicator_label8 "MA8"
#property indicator_style8 STYLE_SOLID
#property indicator_type8  DRAW_LINE
#property indicator_width8 1 

#property indicator_color9 clrAliceBlue
#property indicator_label9 "MA9"
#property indicator_style9 STYLE_SOLID
#property indicator_type9  DRAW_LINE
#property indicator_width9 1 

#property indicator_color10 clrAliceBlue
#property indicator_label10 "MA10"
#property indicator_style10 STYLE_SOLID
#property indicator_type10  DRAW_LINE
#property indicator_width10 1 

#property indicator_color11 clrAliceBlue
#property indicator_label11 "MA11"
#property indicator_style11 STYLE_SOLID
#property indicator_type11  DRAW_LINE
#property indicator_width11 1

#property indicator_color12 clrAliceBlue
#property indicator_label12 "MA12"
#property indicator_style12 STYLE_SOLID
#property indicator_type12  DRAW_LINE
#property indicator_width12 1 
 

#include <CustomFunctions.mqh>;

input int ProfitSize = 9;
input int StopSize = 3;
input int MaxSpreadAllowed = 30;

string currentTime;
double MinCandleSize;

//Pause Button
bool ButtonState = true;
const string ButtonName = "BUTTON_PAUSED";
const int ButtonXPosition = 120;
const int ButtonYPosition = 60;
const int ButtonWidth = 80;
const int ButtonHeight = 20;
const int ButtonCorner = CORNER_RIGHT_UPPER;
const string ButtonFont = "Arial Bold";
const int ButtonFontSize = 10;
const int ButtonTextColour = clrBlack;

//When Running
const string ButtonTextRunning = "Running";
const int ButtonColourRunning = clrGray;

//When Paused
const string ButtonTextPaused = "Paused";
const int ButtonColourPaused = clrAliceBlue;

int OnInit()
  {
   CreateButton();
   return(INIT_SUCCEEDED);
  }


void OnDeinit(const int reason)
  {
    ObjectDelete(0,ButtonName);
    Comment(""); 
  }


void OnTick()
  {

   if(!CanTrade())return;
   
   // remove when running live (Only for strategy tester)
   if((bool)MQLInfoInteger(MQL_TESTER) && (bool)MQLInfoInteger(MQL_VISUAL_MODE)){
      SetButtonState(ObjectGetInteger(0,ButtonName,OBJPROP_STATE,0));
   }
   
   if(!ButtonState)return;
   
   int CandleNumber = Bars(_Symbol,_Period);
   string NewCandleAppeared = "";
   NewCandleAppeared = CheckForNewStick(CandleNumber);
  
   static string NewDay        = "YES";
   static string MASignal      = "BUY";
   
   double ask           = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double bid           = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   double Equity        = AccountInfoDouble(ACCOUNT_EQUITY);
   double FreeMargin    = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   
   double Balance       = AccountInfoDouble(ACCOUNT_BALANCE);
   long   currentSpread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   double MaxVolume     = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double MinVolume     = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   
   double DynamicPositionSize = NormalizeDouble((Equity/1000),2);
   double DynamicProfitSize   = Balance*ProfitSize;
   double DynamicStopSize     = Balance*StopSize;
   
   int    CountSellLosses = CountSellLoss();
   int    CountBuyLosses  = CountBuyLoss();
   
   if(DynamicPositionSize >= MaxVolume) DynamicPositionSize = MaxVolume;
   if(DynamicPositionSize <= MinVolume) DynamicPositionSize = MinVolume;
   
   if(DynamicProfitSize >= 2500) DynamicProfitSize = 2500;
   if(DynamicStopSize <= 500) DynamicStopSize = 500;
  
   double profit = 0;
   string SpreadFilter = "";
   string DayFilter = "";
   string RandomSignal="";
   string AccountLimit = "";
   string LossFilter = "";
   double ATRDiff = 0;
  
   if(MarginRequired(Symbol(),DynamicPositionSize,0) < FreeMargin){
      AccountLimit = "tradingAllowed";
   }
   
   if(MarginRequired(Symbol(),DynamicPositionSize,0) > FreeMargin){
      AccountLimit = "tradingNotAllowed";
   } 
   
   if(CountSellLosses >= 2)LossFilter = "tradingNotAllowed";
   if(CountBuyLosses  >= 2)LossFilter = "tradingNotAllowed";
   
   if(CountSellLosses <= 2)LossFilter = "tradingAllowed";
   if(CountBuyLosses  <= 2)LossFilter = "tradingAllowed";
   
  
   datetime time = TimeLocal();
   currentTime   = TimeToString(time,TIME_MINUTES);
   
   string HoursAndMinutes = TimeToString(time,TIME_MINUTES);
   string YearAndDate     = TimeToString(time,TIME_DATE);
   MqlDateTime DateTimeStructure;
   
   TimeToStruct(time,DateTimeStructure);
   int DayOfTheWeek = DateTimeStructure.day_of_week;
   
   string WeekDay = "";
   
   if(DayOfTheWeek==1) WeekDay="Monday";
   if(DayOfTheWeek==2) WeekDay="Tuesday";
   if(DayOfTheWeek==3) WeekDay="Wednesday";
   if(DayOfTheWeek==4) WeekDay="Thursday";
   if(DayOfTheWeek==5) WeekDay="Friday";
   if(DayOfTheWeek==6) WeekDay="Saturday";
   if(DayOfTheWeek==0) WeekDay="Sunday";
   
   
   if(currentSpread >= MaxSpreadAllowed){
      SpreadFilter = "tradingNotAllowed";
   }
   
   if(currentSpread <= MaxSpreadAllowed){
      SpreadFilter = "tradingAllowed";
   }
   
   if(WeekDay=="Monday" || WeekDay=="Tuesday" || WeekDay=="Wednesday" || WeekDay=="Thursday" || WeekDay=="Friday"){
      DayFilter = "tradingAllowed";
   }
   
   if(HoursAndMinutes == "22:00"){
      CloseAllPositions();
      CancelOrder();
      NewDay = "NO";
   }
   
   if(HoursAndMinutes == "01:00"){
      NewDay = "YES";
   }
  
   if(Balance > 10){
      for(int i=PositionsTotal()-1; i >=0; i--){
        ulong ticket=PositionGetTicket(i);
        double PositionProfit = PositionGetDouble(POSITION_PROFIT);
        if(PositionProfit <= -DynamicStopSize){  
           trade.PositionClose(ticket); 
        } 
     }
   }
   
   for(int i=PositionsTotal();i>=0;i--){
   
        long magic= PositionGetInteger(POSITION_MAGIC);
        profit = TotalProfit(magic);     
       
        if(profit >= DynamicProfitSize){
         CloseAllPositions();
         CancelOrder();
        }
    }
    
   // Moving Average
   
   // Fast blue averages
   double myMovingAverageArray[];
   SetIndexBuffer(0,myMovingAverageArray,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   
   int movingAverageDefinition = iMA(_Symbol,_Period,3,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray,true);
   CopyBuffer(movingAverageDefinition,0,0,10,myMovingAverageArray);
   double myMovingAverageValue = myMovingAverageArray[0] - myMovingAverageArray[9];
   
   double myMovingAverageArray2[];
   int movingAverageDefinition2 = iMA(_Symbol,_Period,5,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray2,true);
   CopyBuffer(movingAverageDefinition2,0,0,10,myMovingAverageArray2);
   double myMovingAverageValue2 = myMovingAverageArray2[0] - myMovingAverageArray2[9];
   
   double myMovingAverageArray3[];
   int movingAverageDefinition3 = iMA(_Symbol,_Period,8,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray3,true);
   CopyBuffer(movingAverageDefinition3,0,0,10,myMovingAverageArray3);
   double myMovingAverageValue3 = myMovingAverageArray3[0] - myMovingAverageArray3[9];
   
   double myMovingAverageArray4[];
   int movingAverageDefinition4 = iMA(_Symbol,_Period,10,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray4,true);
   CopyBuffer(movingAverageDefinition4,0,0,10,myMovingAverageArray4);
   double myMovingAverageValue4 = myMovingAverageArray4[0] - myMovingAverageArray4[9];
   
   double myMovingAverageArray5[];
   int movingAverageDefinition5 = iMA(_Symbol,_Period,12,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray5,true);
   CopyBuffer(movingAverageDefinition5,0,0,10,myMovingAverageArray5);
   double myMovingAverageValue5 = myMovingAverageArray5[0] - myMovingAverageArray5[9];
   
   double myMovingAverageArray6[];
   int movingAverageDefinition6 = iMA(_Symbol,_Period,15,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray6,true);
   CopyBuffer(movingAverageDefinition6,0,0,10,myMovingAverageArray6);
   double myMovingAverageValue6 = myMovingAverageArray6[0] - myMovingAverageArray6[9];
   
   
   //Slow red averages
   double myMovingAverageArray7[];
   int movingAverageDefinition7 = iMA(_Symbol,_Period,30,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray7,true);
   CopyBuffer(movingAverageDefinition7,0,0,10,myMovingAverageArray7);
   double myMovingAverageValue7 = myMovingAverageArray7[0] - myMovingAverageArray7[9];
   
   double myMovingAverageArray8[];
   int movingAverageDefinition8 = iMA(_Symbol,_Period,35,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray8,true);
   CopyBuffer(movingAverageDefinition8,0,0,10,myMovingAverageArray8);
   double myMovingAverageValue8 = myMovingAverageArray8[0] - myMovingAverageArray8[9];
   
   double myMovingAverageArray9[];
   int movingAverageDefinition9 = iMA(_Symbol,_Period,40,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray9,true);
   CopyBuffer(movingAverageDefinition9,0,0,10,myMovingAverageArray9);
   double myMovingAverageValue9 = myMovingAverageArray9[0] - myMovingAverageArray9[9];
   
   double myMovingAverageArray10[];
   int movingAverageDefinition10 = iMA(_Symbol,_Period,45,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray10,true);
   CopyBuffer(movingAverageDefinition10,0,0,10,myMovingAverageArray10);
   double myMovingAverageValue10 = myMovingAverageArray10[0] - myMovingAverageArray10[9];
   
   double myMovingAverageArray11[];
   int movingAverageDefinition11 = iMA(_Symbol,_Period,50,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray11,true);
   CopyBuffer(movingAverageDefinition11,0,0,10,myMovingAverageArray11);
   double myMovingAverageValue11 = myMovingAverageArray11[0] - myMovingAverageArray11[9];
   
   double myMovingAverageArray12[];
   int movingAverageDefinition12 = iMA(_Symbol,_Period,55,0,MODE_EMA,PRICE_CLOSE);
   ArraySetAsSeries(myMovingAverageArray12,true);
   CopyBuffer(movingAverageDefinition12,0,0,10,myMovingAverageArray12);
   double myMovingAverageValue12 = myMovingAverageArray12[0] - myMovingAverageArray12[9];
   
   
   if( 
       (myMovingAverageArray[0]>myMovingAverageArray12[0])  &&
       (myMovingAverageArray2[0]>myMovingAverageArray12[0]) &&
       (myMovingAverageArray3[0]>myMovingAverageArray12[0]) &&
       (myMovingAverageArray4[0]>myMovingAverageArray12[0]) &&
       (myMovingAverageArray5[0]>myMovingAverageArray12[0]) &&
       (myMovingAverageArray6[0]>myMovingAverageArray12[0]) 
     )
     {
           
        if(MASignal == "SELL"){
          MASignal = "BUY";
        }
     }
     
    if( 
       (myMovingAverageArray[1]<myMovingAverageArray12[1]) && 
       (myMovingAverageArray[1]<myMovingAverageArray11[1]) && 
       (myMovingAverageArray[1]<myMovingAverageArray10[1]) && 
       (myMovingAverageArray[1]<myMovingAverageArray9[1])  && 
       (myMovingAverageArray[1]<myMovingAverageArray8[1])  && 
       (myMovingAverageArray[1]<myMovingAverageArray7[1]) 
     
     {
          
        if(MASignal == "BUY"){
          MASignal = "SELL";
        }
     }
     
  
   if((SpreadFilter == "tradingAllowed")&&(NewCandleAppeared=="New Candle Appeared") 
   &&(DayFilter == "tradingAllowed")&&(NewDay=="YES")&&(AccountLimit=="tradingAllowed")){
        
         if(MASignal == "SELL") { 
         
           trade.SellStop(DynamicPositionSize,bid-5*_Point,_Symbol,bid+(100*_Point),bid-(500*_Point),ORDER_TIME_GTC,0,NULL); 
        
          }
      
         if(MASignal == "BUY") {  

           trade.BuyStop(DynamicPositionSize,ask+5*_Point,_Symbol,ask-(100*_Point),ask+(500*_Point),ORDER_TIME_GTC,0,NULL);

         }
       
     }   
   
    Comment("AllProfits: ",profit,"\n",
            "Today is: ", WeekDay,"\n",
            "Time is: ", HoursAndMinutes,"\n",
            "DynamicPositionSize: ", DynamicPositionSize,"\n",
            "CurrentSpread: ",currentSpread,"\n",
            "MASignal: ",MASignal,"\n");
   
  }

int CountBuyLoss(){

     uint    TotalNumberOfDeals = HistoryDealsTotal();
     ulong   TicketNumber = 0;
     long    OrderType , DealEntry;
     double  OrderProfit=0;
     string  MySymbol="";
     string  PositionDirection="";
     string  MyResult="";
     int     Count = 0;
     
     
     HistorySelect(0,TimeCurrent());
     
     for(uint i=0;i<TotalNumberOfDeals;i++){
       
         if((TicketNumber=HistoryDealGetTicket(i))>0){
         
            OrderProfit=HistoryDealGetDouble(TicketNumber,DEAL_PROFIT);
            
            OrderType=HistoryDealGetInteger(TicketNumber,DEAL_TYPE);
            
            MySymbol= HistoryDealGetString(TicketNumber,DEAL_SYMBOL);
            
            DealEntry = HistoryDealGetInteger(TicketNumber, DEAL_ENTRY);
            
            if(MySymbol == _Symbol)
            
            if(OrderType == ORDER_TYPE_SELL)
            
            if(DealEntry == 1){
            
               if(OrderType == ORDER_TYPE_SELL)
               PositionDirection = "BUY";
               
               if(OrderProfit < 0.0)
               Count++;
            }
               
         }
     }
     
     return Count;
}

int CountSellLoss(){

     uint    TotalNumberOfDeals = HistoryDealsTotal();
     ulong   TicketNumber = 0;
     long    OrderType , DealEntry;
     double  OrderProfit=0;
     string  MySymbol="";
     string  PositionDirection="";
     string  MyResult="";
     int     Count = 0;
     
     
     HistorySelect(0,TimeCurrent());
     
     for(uint i=0;i<TotalNumberOfDeals;i++){
       
         if((TicketNumber=HistoryDealGetTicket(i))>0){
         
            OrderProfit=HistoryDealGetDouble(TicketNumber,DEAL_PROFIT);
            
            OrderType=HistoryDealGetInteger(TicketNumber,DEAL_TYPE);
            
            MySymbol= HistoryDealGetString(TicketNumber,DEAL_SYMBOL);
            
            DealEntry = HistoryDealGetInteger(TicketNumber, DEAL_ENTRY);
            
            if(MySymbol == _Symbol)
            
            if(OrderType == ORDER_TYPE_BUY)
            
            if(DealEntry == 1){
            
               if(OrderType == ORDER_TYPE_BUY)
               PositionDirection = "SELL";
               
               if(OrderProfit < 0.0)
               Count++;
            }
               
         }
     }
     
     return Count;
}

void OnChartEvent(const int id,const long& lparam,const double& dparam, const string& sparam){

     if(id != CHARTEVENT_OBJECT_CLICK) return;
     
     if(sparam == ButtonName)
     {
     SetButtonState(ObjectGetInteger(0,ButtonName,OBJPROP_STATE,0));  
     }
    
}

void CreateButton(){

    ObjectDelete(0,ButtonName);
    ObjectCreate(0,ButtonName,OBJ_BUTTON,0,0,0);
    ObjectSetInteger(0,ButtonName,OBJPROP_XDISTANCE,ButtonXPosition);
    ObjectSetInteger(0,ButtonName,OBJPROP_YDISTANCE,ButtonYPosition);
    ObjectSetInteger(0,ButtonName,OBJPROP_XSIZE,ButtonWidth);
    ObjectSetInteger(0,ButtonName,OBJPROP_YSIZE,ButtonHeight);
    ObjectSetInteger(0,ButtonName,OBJPROP_CORNER,ButtonCorner);
    ObjectSetString(0,ButtonName,OBJPROP_FONT,ButtonFont);
    ObjectSetInteger(0,ButtonName,OBJPROP_FONTSIZE,ButtonFontSize);
    ObjectSetInteger(0,ButtonName,OBJPROP_COLOR,ButtonTextColour);
    
    SetButtonState(ButtonState); 
}

void SetButtonState(bool buttonState){

     ButtonState = buttonState;
     
     ObjectSetInteger(0,ButtonName,OBJPROP_STATE,ButtonState);
     ObjectSetString(0,ButtonName,OBJPROP_TEXT,ButtonText());
     ObjectSetInteger(0,ButtonName,OBJPROP_BGCOLOR,ButtonColour());
     ChartRedraw(0);
     
     string msg = StringFormat("%s - %s",__FUNCSIG__,ButtonText());
} 

string ButtonText(){

   return( ButtonState ? ButtonTextRunning : ButtonTextPaused);
}

int ButtonColour(){

   return( ButtonState ? ButtonColourRunning : ButtonColourPaused );
}