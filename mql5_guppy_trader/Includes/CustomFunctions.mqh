#include <Trade/Trade.mqh>
CTrade trade; 

string CheckForNewStick(int CandleNumber){

     static int LastCandleNumber;
     string isNewCandle = "No new candle";
     
     if(CandleNumber>LastCandleNumber){
     
       isNewCandle = "New Candle Appeared";
       LastCandleNumber = CandleNumber;
     }
     
     return isNewCandle;
}

void SellTrailingTP(double bid,int increaseBy,int profitAmt,int bias){

     double TP= NormalizeDouble(bid-profitAmt*_Point,_Digits);
     double SL= NormalizeDouble(bid*_Point,_Digits);
     
     for(int i=PositionsTotal()-1; i >=0; i--){
          
          string symbol=PositionGetSymbol(i);
          
          if(_Symbol == symbol){
          
             if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL){
             
             ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
             double CurrentStopLoss = PositionGetDouble(POSITION_SL);
             double PositionTakeProfit = PositionGetDouble(POSITION_TP);
              
             if(SL < (PositionTakeProfit + bias)){
                  trade.PositionModify(PositionTicket,CurrentStopLoss,(PositionTakeProfit-increaseBy*_Point));
               }
             }
          }
     }
}

void BuyTrailingTP(double ask,int increaseBy,int profitAmt,int bias){

     double TP= NormalizeDouble(ask+profitAmt*_Point,_Digits);
     double SL= NormalizeDouble(ask*_Point,_Digits);
     
     for(int i=PositionsTotal()-1; i >=0; i--){
          
          string symbol=PositionGetSymbol(i);
          
          if(_Symbol == symbol){
          
             if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY){
             
             ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
             double CurrentStopLoss = PositionGetDouble(POSITION_SL);
             double PositionTakeProfit = PositionGetDouble(POSITION_TP);
              
             if(SL > (PositionTakeProfit - bias)){
                  trade.PositionModify(PositionTicket,CurrentStopLoss,(PositionTakeProfit+increaseBy*_Point));
               }
             }
          }
     }
}
 
void checkTrailingStopSell(double bid){
   
     double SL= NormalizeDouble(bid+150*_Point,_Digits);
     
     for(int i=PositionsTotal()-1; i >=0; i--){
          
          string symbol=PositionGetSymbol(i);
          
          if(_Symbol == symbol){
          
             if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL){
             
             ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
             double CurrentStopLoss = PositionGetDouble(POSITION_SL);
             double PositionTakeProfit = PositionGetDouble(POSITION_TP);
             
             if(CurrentStopLoss > SL){
                  trade.PositionModify(PositionTicket,(CurrentStopLoss-10*_Point),PositionTakeProfit);
               }
             }
          }
     }
}

void checkTrailingStopBuy(double ask){

     double SL= NormalizeDouble(ask-150*_Point,_Digits);
     
     for(int i=PositionsTotal()-1; i >=0; i--){
          
          string symbol=PositionGetSymbol(i);
          
          if(_Symbol == symbol){
          
             if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY){
             
             ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
             double CurrentStopLoss = PositionGetDouble(POSITION_SL);
             double PositionTakeProfit = PositionGetDouble(POSITION_TP);
              
             if(CurrentStopLoss < SL){
                  trade.PositionModify(PositionTicket,(CurrentStopLoss+10*_Point),PositionTakeProfit);
               }
             }
          }
     }
}
void checkBreakEvenStopSell(double bid){
      
      for(int i=PositionsTotal()-1; i >=0; i--){
          
          string symbol=PositionGetSymbol(i);
          
          if(_Symbol == symbol){
             
             ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
             double PositionBuyPrice = PositionGetDouble(POSITION_PRICE_OPEN);
             double PositionTakeProfit = PositionGetDouble(POSITION_TP);
             double PositionStopLoss = PositionGetDouble(POSITION_SL);
                     
             if(PositionStopLoss>PositionBuyPrice){       
             if(bid < (PositionBuyPrice -30 * _Point)){
                  trade.PositionModify(PositionTicket,PositionBuyPrice-15*_Point,PositionTakeProfit);
               }
             }
          }
     }
}

void checkBreakEvenStopBuy(double ask){
     
     for(int i=PositionsTotal()-1; i >=0; i--){
          
          string symbol=PositionGetSymbol(i);
          
          if(_Symbol == symbol){
             
             ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
             double PositionBuyPrice = PositionGetDouble(POSITION_PRICE_OPEN);
             double PositionTakeProfit = PositionGetDouble(POSITION_TP);
                     
             if(ask > (PositionBuyPrice + 30 * _Point)){
                  trade.PositionModify(PositionTicket,PositionBuyPrice+15*_Point,PositionTakeProfit);
             }
          }
     }
}

int FindPeak(int mode,int count,int startBar){

    if(mode != MODE_HIGH && mode != MODE_LOW){return (-1);}
    
    int currentBar = startBar;
    int foundBar = FindNextPeak(mode, count*2+1, currentBar-count);
    
    while(foundBar != currentBar) {
         currentBar = FindNextPeak(mode, count, currentBar+1);
         foundBar = FindNextPeak(mode, count*2+1, currentBar-count); 
    }
    return (currentBar);
}   

int FindNextPeak(int mode,int count,int startBar){
   
   if(startBar<0){
   count += startBar;
   startBar = 0;
   }
   return ((mode==MODE_HIGH) ?
          iHighest(Symbol(),Period(),(ENUM_SERIESMODE)mode,count,startBar):
          iLowest(Symbol(),Period(),(ENUM_SERIESMODE)mode,count,startBar));
}



string checkEntryChaikin(){

     string signal = "";
     
     double myPriceArray[];
     
     int ChaikinDefinition = iChaikin(_Symbol,_Period,3,10,MODE_EMA,VOLUME_TICK);
     
     ArraySetAsSeries(myPriceArray,true);
   
     CopyBuffer(ChaikinDefinition,0,0,3,myPriceArray);
     
     double ChaikinValue = myPriceArray[0];
     
     double PreviousChaikinValue = myPriceArray[1];
     
     if ((ChaikinValue>0)&&(PreviousChaikinValue<0))
     {
         signal = "buy";
     }
     
      if ((ChaikinValue<0)&&(PreviousChaikinValue>0))
     {
         signal = "sell";
     }
   
     return signal;
}

string checkEntryADX(){

   string signal = "";
   
   double myPriceArray[];
   
   int ADXDefinition = iADX(_Symbol,_Period,10);
   
   ArraySetAsSeries(myPriceArray,true);
   
   CopyBuffer(ADXDefinition,0,0,3,myPriceArray);
   
   double ADXValue = NormalizeDouble(myPriceArray[0],2);
   
   return signal; 
}

string checkEntryiTrix(){

   string signal = "";
   
   MqlRates PriceInfo[];
   
   ArraySetAsSeries(PriceInfo,true);
   
   int PriceData = CopyRates(Symbol(),Period(), 0 ,3 ,PriceInfo);
   
   double myPriceArray[];
   
   int iTrixDefinition = iTriX(_Symbol,_Period,50,PRICE_CLOSE);
   
   ArraySetAsSeries(myPriceArray,true);
   
   CopyBuffer(iTrixDefinition,0,0,3,myPriceArray);
   
   double iTrixValue = myPriceArray[0];
   
   if(iTrixValue>0){
   signal = "buy";}
   
   if(iTrixValue<0){
   signal = "sell";}
   
   return signal;
}

string checkEntryStdDev(){

   string signal = "";
    
   double StdDevArray[];
   int StdDevDefinition = iStdDev(_Symbol,_Period,900,0,MODE_SMA,PRICE_CLOSE); 
   
   ArraySetAsSeries(StdDevArray,true);
   CopyBuffer(StdDevDefinition,0,0,200,StdDevArray);
   
   int HighestCandleNumber = ArrayMaximum(StdDevArray,0,WHOLE_ARRAY);
   int LowestCandleNumber = ArrayMinimum(StdDevArray,0,WHOLE_ARRAY);
   
   double StdDevValue = NormalizeDouble(StdDevArray[0],6);
   
   if(LowestCandleNumber==0)
      signal = "buy";
      
   if(HighestCandleNumber==0)
      signal = "sell";
        
   return signal;
}

string checkEntryCCI(){

    string signal = "";
    
    MqlRates PriceInfo[];
    double myPriceArray[];
   
    ArraySetAsSeries(PriceInfo,true);
    
    int PriceData = CopyRates(_Symbol,_Period,0,3,PriceInfo);
    int CCIDefinition = iCCI(_Symbol,_Period,1440,PRICE_CLOSE);
     
    ArraySetAsSeries(myPriceArray,true);
    CopyBuffer(CCIDefinition,0,0,3,myPriceArray);
    
    double CCIValue = (myPriceArray[0]);
    
    if(CCIValue> 100)
    signal = "sell";
      
    if(CCIValue < -100)
    signal = "buy";
        
    return signal;
}

string checkEntryRVI(){
  
    string signal = "";
    
    double myPriceArray0[];
    double myPriceArray1[];
        
    int RVIDefinition = iRVI(_Symbol,_Period,1400);
    
    ArraySetAsSeries(myPriceArray0,true);
    ArraySetAsSeries(myPriceArray1,true);
     
    CopyBuffer(RVIDefinition,0,0,3,myPriceArray0);
    CopyBuffer(RVIDefinition,1,0,3,myPriceArray1);
      
    double RVIValue0 = NormalizeDouble(myPriceArray0[0],3);
    double RVIValue1 = NormalizeDouble(myPriceArray1[0],3);
    
    // if(RVIValue0 < RVIValue1)
    //    if((RVIValue0<0) && (RVIValue1<0))
    //        signal = "buy";
    
    // if(RVIValue0 > RVIValue1)
    //    if((RVIValue0>0) && (RVIValue1>0))
    //        signal = "sell";
    
    return signal;
}

string checkEntrySFI(){

      string signal = "";
      
      double myPriceArray[];
      
      int FIDefinition = iForce(_Symbol,_Period,1440,MODE_SMA,VOLUME_TICK);
      
      ArraySetAsSeries(myPriceArray,true);
      
      CopyBuffer(FIDefinition,0,0,3,myPriceArray);
      
      double FIValue = NormalizeDouble(myPriceArray[0],6);
      
   //   if(FIValue > 0) //Trending upwards;
  //    if(FIValue < 0) // Trending downwards;
      
      return signal;
}

string checkSimpleWilliams(){
  
    string signal = "";
    double WPRArray[];
    
    int WPRDefinition = iWPR(_Symbol,_Period,100);
    
    ArraySetAsSeries(WPRArray,true);
    
    CopyBuffer(WPRDefinition,0,0,3,WPRArray);
    
    double WPRValue = NormalizeDouble(WPRArray[0],2);
    
    return signal;
}

string checkEntryMaCrossover(){

     string signal = "";
     
     static int handleslowMa = iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_SMA,PRICE_CLOSE);
     double slowMaArray[];
     CopyBuffer(handleslowMa,0,1,2,slowMaArray);
     ArraySetAsSeries(slowMaArray , true);
  
     static int handlefastMa = iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);
     double fastMaArray[];
     CopyBuffer(handlefastMa,0,1,2,fastMaArray);
     ArraySetAsSeries(fastMaArray , true);
     
      if(fastMaArray[0] > slowMaArray[0] && fastMaArray [1] < slowMaArray[1]){
         signal = "buy";
       }
     
      if(fastMaArray[0] < slowMaArray[0] && fastMaArray [1] > slowMaArray[1]){
         signal = "sell";
       }
     return signal;
}

// DoubleExponentialMovingAverage
string checkEntrySimpleDEMA(){
     
     string signal ="";
     
     MqlRates PriceInformation[];
     ArraySetAsSeries(PriceInformation,true);
     
     int Data = CopyRates(Symbol(),Period(),0,3,PriceInformation);
     double myMovingAverageArray[];
     
     int movingAverageDefinition = iDEMA(_Symbol,_Period,14,0,PRICE_CLOSE);
     
     ArraySetAsSeries(myMovingAverageArray,true);
     CopyBuffer(movingAverageDefinition,0,0,3,myMovingAverageArray);
     
     double myMovingAverageValue = myMovingAverageArray[1];
     
     if(myMovingAverageValue>PriceInformation[1].close){
               signal = "sell";
     }
     if(myMovingAverageValue<PriceInformation[1].close){
               signal = "buy";
     }
     
     return signal;
}

string checkEntryBollingerBands(){
    
    string signal = "";
    
    MqlRates PriceInfo[];
    ArraySetAsSeries(PriceInfo,true);
    
    int priceData = CopyRates(Symbol(),Period(),0,3,PriceInfo);
    
    double UpperBandArray[];
    double LowerBandArray[];
    
    ArraySetAsSeries(UpperBandArray,true);
    ArraySetAsSeries(LowerBandArray,true);
    
    int bollingerBandsDefinition = iBands(_Symbol,_Period,20,0,2,PRICE_CLOSE);
    
    CopyBuffer(bollingerBandsDefinition,1,0,3,UpperBandArray);
    CopyBuffer(bollingerBandsDefinition,2,0,3,LowerBandArray);
    
     double myUpperBandValue = UpperBandArray[0];
     double myLowerBandValue = LowerBandArray[0];
     
     double myLastUpperBandValue = UpperBandArray[1];
     double myLastLowerBandValue = LowerBandArray[1];
     
     if((PriceInfo[0].close>myLowerBandValue) && (PriceInfo[1].close<myLastLowerBandValue)){
     
               signal = "buy";
     }
     
     if((PriceInfo[0].close>myUpperBandValue) && (PriceInfo[1].close<myLastUpperBandValue)){
     
               signal = "sell";
     }
     
     return signal;
}

string checkEntryMomentum(){

  string signal = "";

  double myPriceArray[];
  
  int iMomentumDefinition = iMomentum(_Symbol,_Period,140,PRICE_CLOSE);
  
  ArraySetAsSeries(myPriceArray,true);
  
  CopyBuffer(iMomentumDefinition,0,0,3,myPriceArray);
  
  double myMomentumValue = NormalizeDouble(myPriceArray[0],2);
  
  if(myMomentumValue < 100.0) {
  
       signal = "buy";
  }
  
  if(myMomentumValue > 100.0){
  
       signal = "sell";
  }
  
  return signal;
  
}

string checkEntryMACD(){

    
     string signal = "";
     double MyPriceArray[];
     
     int MacDDefiniation = iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE);
     CopyBuffer(MacDDefiniation,0,0,3,MyPriceArray);
     
     double MacDValue=(MyPriceArray[0]);
     
     if (MacDValue>0){
        signal = "sell";
     }
     
     if(MacDValue<0){
        signal = "buy";
     }
     
     return signal;
}

string checkEntryTripleSMA(){
    
      string signal = "";
      double SMA10Array[],SMA50Array[],SMA100Array[];
      
      int SMA10Definition = iMA(_Symbol,_Period,10,0,MODE_SMA,PRICE_CLOSE);
      int SMA50Definition = iMA(_Symbol,_Period,150,0,MODE_SMA,PRICE_CLOSE);
      int SMA100Definition = iMA(_Symbol,_Period,250,0,MODE_SMA,PRICE_CLOSE);
      
      ArraySetAsSeries(SMA10Array,true);
      ArraySetAsSeries(SMA50Array,true);
      ArraySetAsSeries(SMA100Array,true);
      
      CopyBuffer(SMA10Definition,0,0,10,SMA10Array);
      CopyBuffer(SMA50Definition,0,0,10,SMA50Array);
      CopyBuffer(SMA100Definition,0,0,10,SMA100Array);
      
      if(SMA10Array[0] > SMA50Array[0]){
         if(SMA50Array[0] > SMA100Array[0]){
            signal = "buy" ;
         }
      }
      
      if(SMA10Array[0] < SMA50Array[0]){
         if(SMA50Array[0] < SMA100Array[0]){
            signal = "sell" ;
         }
      }
      
      return signal;
}

string CheckEntryPSAR(){

     string signal = "";

     MqlRates PriceArray[];
     double mySARArray[];
     
     ArraySetAsSeries(PriceArray,true);
     int data = CopyRates(_Symbol,_Period,0,3,PriceArray);
     
     int SARDefinition = iSAR(_Symbol,_Period,0.02,0.2);
     ArraySetAsSeries(mySARArray,true);
     
     CopyBuffer(SARDefinition,0,0,3,mySARArray);
     
     double LastSARValue = NormalizeDouble(mySARArray[1],5);
     
     if(LastSARValue < PriceArray[1].low){
           signal = "buy" ;
     }
     
     if(LastSARValue > PriceArray[1].high){
           signal = "sell" ;
     }
    
     return signal;
}

string checkFilterVolume(int ConsolidationVal){
     
     string signal = "";
     
     double myPriceArray[];
     
     int VolumesDefinition = iVolumes(_Symbol,_Period,VOLUME_TICK);
     
     ArraySetAsSeries(myPriceArray,true);
     
     CopyBuffer(VolumesDefinition,0,0,3,myPriceArray);
     
     double CurrentVolumesValue = (myPriceArray[0]);
     double LastVolumesValue = (myPriceArray[1]);
     
     if(CurrentVolumesValue>LastVolumesValue)
     {
      signal = "positive";
     }
     
     if(CurrentVolumesValue<LastVolumesValue)
     {
      signal = "negative";
     }
     
     if(LastVolumesValue < ConsolidationVal)
     {
      signal = "consolidation";
     }
     
     return signal;
}

double TradingRange(){
   
    double tradingRange=0;
    int HighestCandle,LowestCandle;
     
    double High[],Low[];
    
    ArraySetAsSeries(High,true);
    ArraySetAsSeries(Low,true); 
    
    //100 reps number of candles.
    CopyHigh(_Symbol,_Period,0,200,High);
    CopyLow(_Symbol,_Period,0,200,Low);
    
    HighestCandle= ArrayMaximum(High,0,200);
    LowestCandle = ArrayMinimum(Low,0,200);
    
    MqlRates PriceInformation[];
    
    ArraySetAsSeries(PriceInformation,true);
    
    int data = CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInformation);
    
    ObjectCreate(_Symbol,"Line1",OBJ_HLINE,0,0,PriceInformation[HighestCandle].high);
    ObjectGetInteger(0,"Line1",OBJPROP_COLOR,clrAquamarine);
    ObjectGetInteger(0,"Line1",OBJPROP_WIDTH,3);
    ObjectMove(_Symbol,"Line1",0,0,PriceInformation[HighestCandle].high);
    
    ObjectCreate(_Symbol,"Line2",OBJ_HLINE,0,0,PriceInformation[LowestCandle].low);
    ObjectGetInteger(0,"Line2",OBJPROP_COLOR,clrAquamarine);
    ObjectGetInteger(0,"Line2",OBJPROP_WIDTH,3);
    ObjectMove(_Symbol,"Line2",0,0,PriceInformation[LowestCandle].low);
     
    tradingRange = PriceInformation[HighestCandle].high - PriceInformation[LowestCandle].low;
    
    return tradingRange;
}

double TotalProfit(long magic){
 
     double pft = 0; 
     for(int i=PositionsTotal()-1;i>=0;i--){
     
        ulong ticket=PositionGetTicket(i);
        if(ticket>0){
          if(PositionGetInteger(POSITION_MAGIC)==magic && PositionGetString(POSITION_SYMBOL)==Symbol()){
             pft += PositionGetDouble(POSITION_PROFIT);
          }
        }
     }
     return(pft);
 }
 
double TotalVolume(long magic){
 
     double pft = 0; 
     for(int i=PositionsTotal()-1;i>=0;i--){
     
        ulong ticket=PositionGetTicket(i);
        if(ticket>0){
          if(PositionGetInteger(POSITION_MAGIC)==magic && PositionGetString(POSITION_SYMBOL)==Symbol()){
             pft += PositionGetDouble(POSITION_VOLUME);
          }
        }
     }
     return(pft);
 } 
 
string checkEntryRSI(){
 
     string signal = "";
     
     double myRSIArray[];
     
     int myRSIDefinition = iRSI(_Symbol,_Period,10,PRICE_CLOSE);
     
     ArraySetAsSeries(myRSIArray,true);
     
     CopyBuffer(myRSIDefinition,0,0,3,myRSIArray);
     
     double myRSIValue = NormalizeDouble(myRSIArray[0],2);
     
     if(myRSIValue>80) signal="sell";
     if(myRSIValue<20) signal="buy";
    // if(!(myRSIValue<30) && !(myRSIValue>70)) signal="neutral";
     
     return signal;
     
}

string checkEntryATR(){
 
    string signal = "";
    
    double priceArray[];
    
    int ATRDefinition = iATR(_Symbol,_Period,900); 
    
    ArraySetAsSeries(priceArray,true);
    
    CopyBuffer(ATRDefinition,0,0,3,priceArray);
    
    double ATRValue = NormalizeDouble(priceArray[0],5);
    
    static double OldValue;
    
    if(OldValue == 0){
      OldValue = ATRValue;
    }
   if(ATRValue > (OldValue+5)) signal="buy";
   if(ATRValue < (OldValue+5)) signal="sell";
   
    OldValue=ATRValue;
    
    return signal;
}

string checkEntryStoch(){
  
    string signal = "";
    
    double KArray[];
    double DArray[];
    
    ArraySetAsSeries(KArray,true);
    ArraySetAsSeries(DArray,true);
    
    int StochasticDefinition = iStochastic(_Symbol,_Period,3,2,7,MODE_SMA,STO_CLOSECLOSE);
    
    CopyBuffer(StochasticDefinition,0,0,3,KArray);
    CopyBuffer(StochasticDefinition,1,0,3,DArray);
    
    double KValue0=KArray[0];
    double DValue0=DArray[0];
    
    double KValue1=KArray[1];
    double DValue1=DArray[1];
    
    //Just for example but over 80 should be sell and under 20 should be buy
    if(KValue0<20 && DValue0<20){
       
      // if((KValue0>DValue0) && (KValue1<DValue1))
      // {
         signal="sell";
     //  }
    }
    
    if(KValue0>80 && DValue0>80){
       
      // if((KValue0<DValue0) && (KValue1>DValue1))
      // {
         signal="buy";
      // }
    }
    
    return signal;
}

int NumberOfOpenPositions(){

   int PositionsForThisCurrencyPair=0;
  
   for(int i=PositionsTotal()-1;i>=0;i--){
       
       string symbol = PositionGetSymbol(i);
       if(Symbol() == symbol){
         PositionsForThisCurrencyPair +=1;
       }
   }
   
   return PositionsForThisCurrencyPair;
}

int NumberOfOpenBuyPositions(){

   int OpenPositions=0;
   
   for(int i=PositionsTotal()-1;i>=0;i--){
   
      long PositionDirection =PositionGetInteger(POSITION_TYPE);
      string symbol = PositionGetSymbol(i);
      double PositionProfit = PositionGetDouble(POSITION_PROFIT);
      
      if(Symbol() == symbol && PositionDirection == POSITION_TYPE_BUY){
        OpenPositions+=1;
      }
   }
   
   return OpenPositions;
}

int NumberOfLosingBuyPositions(){

   int OpenPositions=0;
   
   for(int i=PositionsTotal()-1;i>=0;i--){
   
      long PositionDirection =PositionGetInteger(POSITION_TYPE);
      string symbol = PositionGetSymbol(i);
      double PositionProfit = PositionGetDouble(POSITION_PROFIT);
      
      if(Symbol() == symbol && PositionDirection == POSITION_TYPE_BUY && PositionProfit <= -2.5){
        OpenPositions+=1;
      }
   }
   
   return OpenPositions;
}
 
int NumberOfOpenSellPositions(){

   int OpenPositions=0;
   
   for(int i=PositionsTotal()-1;i>=0;i--){
   
      long PositionDirection =PositionGetInteger(POSITION_TYPE);
      string symbol = PositionGetSymbol(i);
      double PositionProfit = PositionGetDouble(POSITION_PROFIT);
      
      if(Symbol() == symbol && PositionDirection == POSITION_TYPE_SELL){
        OpenPositions+=1;
      }
   }
   
   return OpenPositions;
}

int NumberOfLosingSellPositions(){

   int OpenPositions=0;
   
   for(int i=PositionsTotal();i>=0;i--){
   
      long PositionDirection =PositionGetInteger(POSITION_TYPE);
      string symbol = PositionGetSymbol(i);
      double PositionProfit = PositionGetDouble(POSITION_PROFIT);
      
      if(Symbol() == symbol && PositionDirection == POSITION_TYPE_SELL && PositionProfit <= -2.5){
        OpenPositions+=1;
      }
   }
   
   return OpenPositions;
}


//Will Only Work for the same trade date.It wont wrk if the trade goes into the next day.

void CheckCloseTimer(){

     for(int i=PositionsTotal()-1;i>=0;i--){
     
        ulong ticket = PositionGetTicket(i);
        
        long PositionOpenTime = PositionGetInteger(POSITION_TIME);
        
        MqlDateTime MyOpenTime;
        
        TimeToStruct(PositionOpenTime,MyOpenTime);
        
        int OpenHour = MyOpenTime.hour;
        
        datetime LocalTime = TimeLocal();
        
         MqlDateTime MyLocalTime;
        
        TimeToStruct(LocalTime,MyLocalTime);
        
        int CurrentHour = MyLocalTime.hour;
        
        int TimeDiff = CurrentHour - OpenHour;
        
        
        //Close position if x time has elapsed.
        
        if(TimeDiff > 5){
          trade.PositionClose(ticket);
        }
          
     }
}

void CloseAllBuyPositions(){

    for(int i=PositionsTotal()-1; i >=0; i--){
        
        ulong ticket=PositionGetTicket(i);
        long PositionDirection = PositionGetInteger(POSITION_TYPE);
        if(PositionDirection == POSITION_TYPE_BUY){
           trade.PositionClose(ticket);
        }
     }
}

void CloseAllSellPositions(){

    for(int i=PositionsTotal()-1; i >=0; i--){
        
        ulong ticket=PositionGetTicket(i);
        long PositionDirection = PositionGetInteger(POSITION_TYPE);
        if(PositionDirection == POSITION_TYPE_SELL){
           trade.PositionClose(ticket);
        }
        
     }
}

void CloseAllPositions(){

    for(int i=PositionsTotal()-1; i >=0; i--){
        
        ulong ticket=PositionGetTicket(i);
        trade.PositionClose(ticket);
        
     }
}

void CancelOrder(){
    
    for(int i=OrdersTotal()-1; i>=0;i--){
    
        ulong OrderTicket = OrderGetTicket(i);
        trade.OrderDelete(OrderTicket);
    }
}

int NumberOfOrderSellPositions(){

   int OpenPositions=0;
   
   for(int i=OrdersTotal()-1;i>=0;i--){
   
      long PositionDirection =OrderGetInteger(ORDER_TYPE);
     
      if(PositionDirection == ORDER_TYPE_SELL){
        OpenPositions+=1;
      }
   }
   
   return OpenPositions;
}

int NumberOfOrderBuyPositions(){

   int OpenPositions=0;
   
   for(int i=OrdersTotal()-1;i>=0;i--){
   
      long PositionDirection =OrderGetInteger(ORDER_TYPE);
    
      if(PositionDirection == ORDER_TYPE_BUY){
        OpenPositions+=1;
      }
   }
   
   return OpenPositions;
}

bool CanTrade(){

   return(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && MQLInfoInteger(MQL_TRADE_ALLOWED)
   && AccountInfoInteger(ACCOUNT_TRADE_EXPERT) && AccountInfoInteger(ACCOUNT_TRADE_ALLOWED));
}

double MarginRequired(string symbol,double lotSize,double Opened){
      
      double rate = 0;
      ENUM_ORDER_TYPE type = ORDER_TYPE_BUY;
      double price = SymbolInfoDouble(symbol,SYMBOL_ASK);
      double newLots = lotSize - Opened;
      if(!OrderCalcMargin(type,symbol,newLots,price,rate)){
      return (0.0);
      }
      return(rate);
}