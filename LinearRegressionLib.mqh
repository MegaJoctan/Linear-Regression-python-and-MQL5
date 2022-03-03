//+------------------------------------------------------------------+
//|                                          CSimpleLinearRegression.mqh |
//|                                     Copyright 2021, Omega Joctan |
//|                        https://www.mql5.com/en/users/omegajoctan |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Omega Joctan"
#property link      "https://www.mql5.com/en/users/omegajoctan"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSimpleLinearRegression
  {
    private:
                        int     m_handle;
                        string  m_filename;
                        string  m_delimiter; 
                        double  m_ypredicted[];
                        double  x_values[];
                        double  y_values[];
    
    protected:          
                        int     m_rows, m_columns;
                        double  mean(double& data[]);
                        void    fileopen();
                       
    public: 
                        CSimpleLinearRegression(void);
                       ~CSimpleLinearRegression(void);
                       //---
                        void   GetDataToArray(double& array[],string filename, string delimiter, int column_number);
                        void   Init(double& x[], double & y[]);
                        void   PrintFileDetails();
                        double y_intercept();
                        double coefficient_of_X();
                        void   LinearRegressionMain(double& predict_y[]);
                        double r_squared(); //also known as coefficient of determinant
                        double corrcoef(double& x[], double &y[]); //also known as correlation coefficient
                        double corrcoef(); //also known as correlation coefficient 
                       
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSimpleLinearRegression::CSimpleLinearRegression(void)
 { 
 
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSimpleLinearRegression::~CSimpleLinearRegression(void)
 { 
   Print(" Simple Linear Regression Library ");
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSimpleLinearRegression::fileopen(void)
 {
   m_handle = FileOpen(m_filename,FILE_READ|FILE_WRITE|FILE_CSV,m_delimiter);      
   
   if (m_handle==INVALID_HANDLE) 
       {   
         Print("Data to work with is nowhere to be found, Error = ",GetLastError()," ", __FUNCTION__);
       }
//---
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSimpleLinearRegression::GetDataToArray(double &array[],string file_name,string delimiter,int column_number)
 {
   m_filename = file_name;
   m_delimiter = delimiter; 
   
   int column=0, columns_total=0;
   int rows=0;
   
   fileopen();
   while (!FileIsEnding(m_handle))
     {
        string data = FileReadString(m_handle);
          if (rows==0) 
            {
              columns_total++; 
            }
         column++;
         
       //Get data by each Column 
       
        if (column==column_number) //if we are on the specific column that we want 
          { 
            ArrayResize(array,rows+1);
            if (rows==0)
             { 
              if ((double(data))!=0) //Just in case the first line of our CSV column has a name of the column 
                 { 
                   array[rows]= NormalizeDouble((double)data,Digits());
                 }
              else { ArrayRemove(array,0,1); }
             }
            else 
              { 
               array[rows-1]= StringToDouble(data);
              }
            //Print("column ",column," "," Value ",(double)data);
          }
//---
        if (FileIsLineEnding(m_handle))
         {
           rows++;
           column=0;
         }
     }  
    FileClose(m_handle);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSimpleLinearRegression::Init(double& x[], double& y[])
 {
   ArrayCopy(x_values,x);
   ArrayCopy(y_values,y);
//---

   if (ArraySize(x_values)!=ArraySize(y_values))
     Print(" Two of your Arrays seems to vary In Size, This could lead to inaccurate calculations ",__FUNCTION__);
   
   int columns=0, columns_total=0;
   int rows=0;
   
   fileopen();
   while (!FileIsEnding(m_handle))
     {
        string data = FileReadString(m_handle);
          if (rows==0) 
            {
              columns_total++;
            }
         columns++;
         
        if (FileIsLineEnding(m_handle))
         {
           rows++;
           columns=0;
         }
     }
     
   m_rows = rows;
   m_columns = columns; 
   FileClose(m_handle);
//---    
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSimpleLinearRegression::PrintFileDetails()
 {
   Print("Lines Total ", m_rows," Columns Total ",m_columns);  
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSimpleLinearRegression::LinearRegressionMain(double &predict_y[])
 {
   double slope = coefficient_of_X();
   double constant_y_intercept= y_intercept();
   
   Print("The Linear Regression Model is "," Y =",DoubleToString(slope,5),"x+",DoubleToString(constant_y_intercept,5));
   
   ArrayResize(predict_y,ArraySize(y_values));                  
   for (int i=0; i<ArraySize(x_values); i++)
       predict_y[i] = coefficient_of_X()*x_values[i]+y_intercept();
//---
// Copy the predicted values to m_ypredicted[], to be Accessed inside the library
   ArrayCopy(m_ypredicted,predict_y);
 }
//+------------------------------------------------------------------+
//|                     Slope of our model                           |
//+------------------------------------------------------------------+
double CSimpleLinearRegression::coefficient_of_X()
 { 
   double m=0;
   double x_mean=mean(x_values);
   double y_mean=mean(y_values);;
//---  
    {
      double x__x=0, y__y=0;
      double numerator=0, denominator=0; 
      
      for (int i=0; i<(ArraySize(x_values)+ArraySize(y_values))/2; i++)
       {
         x__x = x_values[i] - x_mean; //right side of the numerator (x-side)
         y__y = y_values[i] - y_mean; //left side of the numerator  (y-side)
        
         
         numerator += x__x * y__y;  //summation of the product two sides of the numerator
         denominator += MathPow(x__x,2); 
       }
      m = numerator/denominator;
    }
   return (m);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSimpleLinearRegression::y_intercept()
 {
   // c = y - mx
   return (mean(y_values)-coefficient_of_X()*mean(x_values));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSimpleLinearRegression::r_squared()
 {
   double error=0;
   double numerator =0, denominator=0;
   double y_mean = mean(y_values);
//---
  if (ArraySize(m_ypredicted)==0)
    Print("The Predicted values Array seems to have no values, Call the main Simple Linear Regression Funtion before any use of this function = ",__FUNCTION__);
  else
    {
      for (int i=0; i<ArraySize(y_values); i++)
        {
          numerator += MathPow((y_values[i]-m_ypredicted[i]),2);
          denominator += MathPow((y_values[i]-y_mean),2);
        }
      error = 1 - (numerator/denominator);
    }
   return(error);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSimpleLinearRegression::corrcoef(void)
 {
   double r=0;
   double numerator =0, denominator =0;
   double x__x =0, y__y=0;
   
   for(int i=0; i<ArraySize(x_values); i++)
     {
         numerator += (x_values[i]-mean(x_values))*(y_values[i]-mean(y_values));
         x__x += MathPow((x_values[i]-mean(x_values)),2);    //summation of x values minus it's mean squared 
         y__y += MathPow((y_values[i]-mean(y_values)),2);    //summation of y values minus it's mean squared
     }
     denominator = MathSqrt(x__x)*MathSqrt(y__y);   //left x side of the equation squared times right side of the equation squared
     r = numerator/denominator;
    return(r);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSimpleLinearRegression::corrcoef(double &x[],double &y[])
 {
   double r=0;
   double numerator =0, denominator =0;
   double x__x =0, y__y=0;
   
   for(int i=0; i<ArraySize(x); i++)
     {
         numerator += (x[i]-mean(x))*(y[i]-mean(y));
         x__x += MathPow((x[i]-mean(x)),2);  //summation of x values minus it's mean squared 
         y__y += MathPow((y[i]-mean(y)),2);  //summation of y values minus it's mean squared   
     }
     denominator = MathSqrt(x__x)*MathSqrt(y__y);  //left x side of the equation squared times right side of the equation squared
     r = numerator/denominator;   
    return(r);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSimpleLinearRegression::mean(double &data[])
 {
   double x_y__bar=0;
   
   for (int i=0; i<ArraySize(data); i++)
     {
      x_y__bar += data[i]; // all values summation
     }
           
    x_y__bar = x_y__bar/ArraySize(data); //total value after summation divided by total number of elements
   
   return(x_y__bar); 
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMultipleLinearRegression: public CSimpleLinearRegression
  { 
      private:
                          int m_independent_vars;
      public:
                           CMultipleLinearRegression(void);
                          ~CMultipleLinearRegression(void);
                          
                          double coefficient_of_X(double& x_arr[],double& y_arr[]);
                          void   MultipleRegressionMain(double& predicted_y[],double& Y[],double& A[],double& B[]);
                          double y_interceptforMultiple(double& Y[],double& A[],double& B[]);
                          void   MultipleRegressionMain(double& predicted_y[],double& Y[],double& A[],double& B[],double& C[],double& D[]);
                          double y_interceptforMultiple(double& Y[],double& A[],double& B[],double& C[],double& D[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultipleLinearRegression::CMultipleLinearRegression(void) 
 {
 
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultipleLinearRegression::~CMultipleLinearRegression(void)
 {
 
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultipleLinearRegression::MultipleRegressionMain(double &predicted_y[],double &Y[],double &A[],double &B[])
 {
// Multiple regression formula =  y = M1X1+M2X2+M3X3+...+C

  double constant_y_intercept=y_interceptforMultiple(Y,A,B);
  double slope1 = coefficient_of_X(A,Y);
  double slope2 = coefficient_of_X(B,Y);
  
   Print("Multiple Regression Model is ","Y="+DoubleToString(slope1,2)+"A+"+DoubleToString(slope2,2)+"B+"+
         DoubleToString(constant_y_intercept,2));
         
   int ArrSize = (ArraySize(A)+ArraySize(B))/2;
   ArrayResize(predicted_y,ArrSize);
   for (int i=0; i<ArrSize; i++)
       predicted_y[i] = slope1*A[i]+slope2*B[i]+constant_y_intercept;
       
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMultipleLinearRegression::coefficient_of_X(double &x_arr[],double &y_arr[])
 { 
   double m=0;
   double x_mean=mean(x_arr);
   double y_mean=mean(y_arr);;
//--- 
   //Print("mean x ",x_mean," y_mean ",y_mean," x arraysize ",ArraySize(x_arr));
  
   if (ArraySize(x_arr)!=ArraySize(y_arr))
     Print(" Two of your datasets seems to vary In Size, This could lead to inacurate results ",__FUNCTION__);
   else 
    {
      double x__x=0, y__y=0;
      double numerator=0, denominator=0; 
      
      for (int i=0; i<(ArraySize(x_arr)+ArraySize(y_arr))/2; i++)
       {
         x__x = x_arr[i] - x_mean;
         y__y = y_arr[i] - y_mean;
        
         
         numerator += x__x * y__y;
         denominator += MathPow(x__x,2); 
       }
      m = numerator/denominator;
    }
   return (m);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMultipleLinearRegression::y_interceptforMultiple(double &Y[],double &A[],double &B[])
 {
   //formula c=Y-M1X1-M2X2-....;
   return(mean(Y)-coefficient_of_X(A,Y)*mean(A)-coefficient_of_X(B,Y)*mean(B));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultipleLinearRegression::MultipleRegressionMain(double &predicted_y[],double &Y[],double &A[],double &B[],double &C[],double &D[])
 {
   double constant_y_intercept = y_interceptforMultiple(Y,A,B,C,D);
   double slope1 = coefficient_of_X(A,Y);
   double slope2 = coefficient_of_X(B,Y);
   double slope3 = coefficient_of_X(C,Y);
   double slope4 = coefficient_of_X(D,Y);
//---
   Print("Multiple Regression Model is ","Y="+DoubleToString(slope1,2),"A+"+DoubleToString(slope2,2)+"B+"+
         DoubleToString(slope3,2)+"C"+DoubleToString(slope4,2)+"D"+DoubleToString(constant_y_intercept,2));
//---
   int ArrSize = (ArraySize(A)+ArraySize(B))/2;
   ArrayResize(predicted_y,ArrSize);
   for (int i=0; i<ArrSize; i++)
       predicted_y[i] = slope1*A[i]+slope2*B[i]+slope3*C[i]+slope4*D[i]+constant_y_intercept;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMultipleLinearRegression::y_interceptforMultiple(double &Y[],double &A[],double &B[],double &C[],double &D[])
 {
   return (mean(Y)-coefficient_of_X(A,Y)*mean(A)-coefficient_of_X(B,Y)*mean(B)-coefficient_of_X(C,Y)*mean(C)-coefficient_of_X(D,Y)*mean(D));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+