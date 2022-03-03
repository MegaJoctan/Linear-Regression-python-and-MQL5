//+------------------------------------------------------------------+
//|                                       Index_correlation spot.mq5 |
//|                                     Copyright 2021, Omega Joctan |
//|                        https://www.mql5.com/en/users/omegajoctan |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Omega Joctan"
#property link      "https://www.mql5.com/en/users/omegajoctan"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "LinearRegressionLib.mqh";
LinearRegressionLib lr;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //GetData();
   GetLinearRegressionData();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetLinearRegressionData()
 {
   double x[];
   double y[];
   double predicted_y[];
   
    lr.Init("S&P_vs_NASDAQ.csv",",");
   
    lr.GetDataToArray(x,1);
    lr.GetDataToArray(y,2);
    
    lr.FileDataDetails();
   
    lr.LinearRegressionMain(predicted_y,x,y);
    //for (int i=0; i<(ArraySize(predicted_y)+ArraySize(y))/2; i++)
    Print("R squared ",lr.r_squared(predicted_y,y));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetData()
 {
//---
   int handle = FileOpen("S&P_vs_NASDAQ.csv",FILE_CSV|FILE_READ|FILE_WRITE,",");
    if (handle == INVALID_HANDLE)
     {
      Print("data to work with is nowhere to be found Err=",GetLastError());
     }
//---
     MqlRates nasdaq[];
     ArraySetAsSeries(nasdaq,true);
     CopyRates("#NQ100",PERIOD_H1,1,744,nasdaq);
//---
     MqlRates s_p[];
     ArraySetAsSeries(s_p,true); 
     CopyRates("#SP500",PERIOD_H1,1,744,s_p);
//---
     if (handle>0)
       {  
         FileWrite(handle,"S&P500","NASDAQ"); 
            for (int i=0; i<ArraySize(nasdaq); i++)
              {  
                string str1 = DoubleToString(s_p[i].close,Digits());
                string str2 = DoubleToString(nasdaq[i].close,Digits());
                FileWrite(handle,str1,str2); 
              }
       }
     FileClose(handle);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
