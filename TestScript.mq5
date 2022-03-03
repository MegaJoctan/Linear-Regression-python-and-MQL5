//+------------------------------------------------------------------+
//|                                                   TestScript.mq5 |
//|                                     Copy_nasdaqright 2021, Omega Joctan |
//|                        https://www.mql5.com/en/users/omegajoctan |
//+------------------------------------------------------------------+
#property copyright "Copy_nasdaqright 2021, Omega Joctan"
#property link      "https://www.mql5.com/en/users/omegajoctan"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "LinearRegressionLib.mqh";

CSimpleLinearRegression lr;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+  
void OnStart()
  {
//---
    string file_name = "NASDAQ_DATA.csv";
    double s_p[];
    double y_nasdaq[];
    double ma[];
    double rsi[];
    double y_nasdaq_predicted[];
     
    lr.GetDataToArray(s_p,file_name,",",1);
    lr.GetDataToArray(y_nasdaq,file_name,",",2);
    lr.GetDataToArray(ma,file_name,",",3);
    lr.GetDataToArray(rsi,file_name,",",4);
    
//---
      lr.Init(s_p,y_nasdaq);        
        { 
         lr.LinearRegressionMain(y_nasdaq_predicted);
           
           Print(" R_SQUARED = ",lr.r_squared());
           Print("slope of a line ",lr.coefficient_of_X());
          
           //Print("coefficient of Nasdaq vs s&p ", lr.coefficient_of_X()," correlation coefficient ",lr.corrcoef(),"\n corrcoef(s_p[],y_nasdaq[]) ",lr.corrcoef(s_p,y_nasdaq));
           
           
           //Print("Correlation Coefficient NASDAQ vs S&P 500 = ",lr.corrcoef(s_p,y_nasdaq));
           //Print("Correlation Coefficient NASDAQ vs 50SMA = ",lr.corrcoef(ma,y_nasdaq));
           //Print("Correlation Coefficient NASDAQ Vs rsi = ",lr.corrcoef(rsi,y_nasdaq));
        }             
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+