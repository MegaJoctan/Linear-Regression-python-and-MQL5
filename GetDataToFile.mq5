//+------------------------------------------------------------------+
//|                                                GetDataToFile.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES   timeframe = PERIOD_H1;
input int               maperiod = 50;
input int               rsiperiod = 13;

int  total_data = 744;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string file_name = "NASDAQ_DATA.csv";
   string nasdaq_symbol = "#NQ100", s_p500_symbol ="#SP500";
   
//---
   int handle = FileOpen(file_name,FILE_CSV|FILE_READ|FILE_WRITE,",");
    if (handle == INVALID_HANDLE)
     {
      Print("data to work with is nowhere to be found Err=",GetLastError());
     }
//---
     MqlRates nasdaq[];
     ArraySetAsSeries(nasdaq,true);
     CopyRates(nasdaq_symbol,timeframe,1,total_data,nasdaq);
//---
     MqlRates s_p[];
     ArraySetAsSeries(s_p,true); 
     CopyRates(s_p500_symbol,timeframe,1,total_data,s_p);
     
//--- Moving Average Data

     int ma_handle = iMA(nasdaq_symbol,timeframe,maperiod,0,MODE_SMA,PRICE_CLOSE);
     double ma_values[];
     ArraySetAsSeries(ma_values,true);
     CopyBuffer(ma_handle,0,1,total_data,ma_values);
     
//--- Rsi values data

    int rsi_handle = iRSI(nasdaq_symbol,timeframe,rsiperiod,PRICE_CLOSE);
    double rsi_values[];
    ArraySetAsSeries(rsi_values,true);
    CopyBuffer(rsi_handle,0,1,total_data,rsi_values);

//---

     if (handle>0)
       {  
         FileWrite(handle,"S&P500","NASDAQ","50SMA","13RSI"); 
            for (int i=0; i<total_data; i++)
              {  
                string str1 = DoubleToString(s_p[i].close,Digits());
                string str2 = DoubleToString(nasdaq[i].close,Digits());
                string str3 = DoubleToString(ma_values[i],Digits());
                string str4 = DoubleToString(rsi_values[i],Digits());
                FileWrite(handle,str1,str2,str3,str4); 
              }
       }
     FileClose(handle); 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
