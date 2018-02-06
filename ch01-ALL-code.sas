/*
   CHAPTER 01:  All SAS Code combined into single file ===========================
*/


/* ------------------------------------------------------------------------------*/


/* ch01-constructed-example-04jan18.sas

Directory:  C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01
Author:   John Bailer
Purpose:  Illustrate learning from constructed, artificial data
   * 
Need to extract variable names from a column of an input data set

Linear mixed effects models

Sampling distribution of means


*/

/* template code that defines a style for output produced ... */
%let tdir=C:\Users\baileraj\Documents\book-SPiS-2nd-ed\new-examples;
%include "&tdir\book_template_and_options.sas";

%let dir=C:\Users\baileraj\Documents\book-SPiS-2nd-ed\;
%let subdir=chapter01;


/*
Need to extract variable names from a column of an input data set
*/

data colvarname;
  input country $ variableName $ YR1960 YR1961;
datalines;
C1 a 10 15
C2 a 12 17
C3 a 14 19
C1 b 20 25
C2 b 22 27
C3 b 24 29
;
run;
title 'data set where reshaping was needed';

ods rtf file="&dir.&subdir.\ch01-reshape-fig.rtf"
        image_dpi=300
        style=sasuser.customAnalysis;

proc print data=colvarname;
run;

/* First:  get the YR variables in a column with year and a column with variable value
           (gather operation from Wickham and Grolemund) */
proc sort data=colvarname;
  by country variableName;
run;

proc transpose data=colvarname out=test let;
  by country variableName;
  var yr1960 yr1961;
run;

/* Second:  extract the year (e.g. 1960) from the character value (e.g. YR1960) and make it numeric  */
data test2;
  set test;
  year = 1.*substr(_NAME_,3); * makes this variable numeric;
  drop _NAME_;
run;

proc print data=test2;
run;

/* Third:  move the variableName column to separate distinct columns
           (spread operation from Wickham  and Grolemund)
*/
proc sort data=test2;
  by country year;
run;

proc transpose data=test2 out=test3;
  by country year;
  var col1;
run;

proc print data=test3;
run;

/* Fourth: rename columns with variable names and remove unneeded column */
data test4;
  set test3 (rename=(COL1=a COL2=b));
  drop _NAME_;
run;

proc print data=test4;
run;
ods rtf close;

/*
Linear mixed effects models
*/
title "Linear Mixed Effects Model illustration";
call streaminit(450561641);  * set the seed for the pseudorandom variable generation;
data randomint;
  beta0=20;
  beta1= 4;
  sigma = 4;
  do subject = 1 to 50;
	   b0 = rand('normal',0,2);   * random intercept;
    do time = 1 to 5;
       response = beta0 + b0 + beta1*time + rand('normal',0,sigma);
	   output;
	end;
  end;
run;

ods rtf file="&dir.&subdir.\ch01-LME-fig.rtf"
        image_dpi=300
        style=sasuser.customAnalysis;

proc print data=randomint;
run;

proc sgplot data=randomint noborder;
  series x=time y=response / group=subject;
run;

/* not estimating the variance components */
proc mixed data=randomint;
  class subject ;
  model response = time / SOLUTION;
  random Int / SUBJECT=subject type=UN;
run;

ods rtf close;

/*
Sampling distribution of means

SAS Help
http://support.sas.com/documentation/cdl/en/grstatproc/69716/HTML/default/viewer.htm#n0j7m77qd6d03ln1l4bk301h2imo.htm
*/
title 'Poisson (mu=0.5) distribution';

data PoissonDistrib;
   mu=0.5;
   do x=0 to 10;
     ProbX = PDF("Poisson",x,mu);
	 output;
   end;
run;

ods rtf file="&dir.&subdir.\ch01-Poisson-CLT-fig.rtf"
        image_dpi=300
        style=sasuser.customAnalysis;

proc sgplot data=PoissonDistrib noborder;  * remove box around plot;
  needle x=x y=ProbX;
  xaxis offsetmin =.1;  * create space between first tick mark and x-axis;
run;

data RanPoi;
  mu = 0.5;
  do nsize = 10, 30, 50;
    do sample = 1 to 1000;
       sumobs = 0;
       do obs = 1 to nsize;
          sumobs = sumobs + rand("Poisson",mu);
	   end;
	   xbar = sumobs/nsize;
	   output;
    end;
  end;
run;

proc sgpanel data=RanPoi;
  title2 'Sampling Distribution of Xbar for different sample sizes';
  panelby nsize / layout=panel columns=1 noborder;
  histogram xbar / binwidth=.1;
  density xbar;
  density xbar / type=kernel;
run;

ods rtf close;

/* ------------------------------------------------------------------------------*/


/*     mreg-country-17jan18.sas
Directory: C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01

Modified from: mreg-country-20may09.sas
 Directory:  C:\baileraj\Classes\Spring09\programs\regression-examples\

Author:   John Bailer
Purpose:  multiple regression example where average life expectancy 
          of women is modeled as a function of country 
          characteristics
Last Revised:  17 Jan. 2018 - read data from web and output directory changed

Input data file -------------------------------------
   country.data

Directories:
   C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01

Input variables -------------------------------------
   Name = country name (Character variable)
   Area = country area
   Popnsize = population size
   Pcturban = % residents in urban setting
   Lang = primary language
   Liter = % literate
   Lifemen = average life expectancy men
   Lifewom = average life expectancy women
   PcGNP = per capita gross national product

Created Variables -----------------------------------
   logarea = log10(area);
   logpopn = log10(popnsize);
   loggnp  = log10(pcGNP);
   ienglish = (lang="English");

Data Source:  Extracted from World Almanac
*/

/* read file from web 
   REF: http://support.sas.com/resources/papers/proceedings12/121-2012.pdf
*/

filename onweb url "http://www.users.miamioh.edu/baileraj/classes/sta402/data/country.data";
data country; 
  title "country data analysis";
  infile onweb;

  input  name $ area popnsize pcturban lang $ liter lifemen
         lifewom pcGNP;
  logarea = log10(area);
  logpopn = log10(popnsize);
  loggnp  = log10(pcGNP);
  ienglish = (lang="English");
  drop area popnsize pcgnp;
run;

proc print data=country;
run;

proc reg data=country;
  title "LITER and LOGGNP as predictors of Life expectancy of women";
  model lifewom = liter loggnp/ tol vif collinoint;      
  output out=new p=yhat r=resid;
run;

* setting up macro variable for directories;  
%let DIR1 = C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01;

/* plot life expectancy of women vs. log(GNP) with a linear regression
   fit and LOESS fit superimposed
*/
ods rtf file="&dir.&subdir.\ch01-display-1.1-fig.rtf"
        image_dpi=300
        style=sasuser.customAnalysis;
title "";
proc sgplot data=country;
  reg y=lifewom x=loggnp;
  loess y=lifewom x=loggnp;
run;
ods rtf close;

/* ------------------------------------------------------------------------------*/


/* 
   ch01-linregsim-17jan18.sas
   Directory:  C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01

   Author:  John Bailer

   generate a data set of 10 (X,Y) pairs where
   X = 1, 2, ..., 10
   Y ~ N(mu= 3 + 2X, sigma=2)
*/

data lin_reg_data;
   call streaminit(32123);
   do x = 1 to 10 by 1;
      y = 3+2*x+2*RAND('NORMAL');
     output;
   end;
run;

ods rtf file="C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01\ch1-display-1.2-fig.rtf"
        image_dpi=300
        style=sasuser.customAnalysis;
ods graphics on;
proc print data=lin_reg_data;  * check data generation;
run;

proc reg data=lin_reg_data plots(only)=FitPlot(nolimits);
   model y=x;
run;
quit;
ods graphics off;
ods rtf close;

/* ------------------------------------------------------------------------------*/
* SECTION 1.7 - code to debug example ;

data junk; 
  do kk = 0 to 10 by 0.01; 
     x = kk 
     y = 3 + 2*kk + RAND(0); 
  output; 
end; 
run; 
proc plot data=junk; 
   scatter x=x y=y; 
   reg x=x y=y; 
   loess x=x y=y; 
run; 
proc reg data=junk; 
   model y=x; 
run; 

/* ------------------------------------------------------------------------------*/
/* HOMEWORK PROBLEMS                                                             */
/* ------------------------------------------------------------------------------*/

/*  PROBLEM 2    */
OPTIONS LS=75;
   DATA EXAMPLE1; INPUT Y X Z; DATALINES;
   77	447	13
   78	460	21
   79	481	24
   80	498	16
   81	513	24
   82	512	20
   83	526	15
   84	559	34
   85	585	33
   86	614	33
   87	645	39
   88	675	43
   89	711	50
   90	719	47
   ;
   PROC REG; MODEL Z = X / P R CLI CLM;
   PLOT Z*X P.*X / OVERLAY;
   PLOT R.*X R.*P.; RUN;

/* ------------------------------------------------------------------------------*/

/*  PROBLEM 3    */
   data SimSAT;
   call streaminit(2016);
   do isim=1 to 1500
     SAT = RAND('Normal', 500, 100);
     output;   
   end;
run;
proc means data=SimSAT
   var SAT;
run;
proc sgplot data=SimSAT;
loess x=isim y=y;
run;

/* ------------------------------------------------------------------------------*/

/* Problem 5 Data - Fitness data from 

SAS online Help (Help
 ? Getting Started with SAS Software 
  ? Learning to Use SAS 
   ? Sample SAS Programs
    ? SAS/STAT 
     ? Sample and select Example 2 for PROC REG
*/

44 89.47 44.609 11.37 62 178 182  40 75.07 45.313 10.07 62 185 185 
44 85.84 54.297  8.65 45 156 168  42 68.15 59.571  8.17 40 166 172 
38 89.02 49.874  9.22 55 178 180  47 77.45 44.811 11.63 58 176 176 
40 75.98 45.681 11.95 70 176 180  43 81.19 49.091 10.85 64 162 170 
44 81.42 39.442 13.08 63 174 176  38 81.87 60.055  8.63 48 170 186 
44 73.03 50.541 10.13 45 168 168  45 87.66 37.388 14.03 56 186 192 
45 66.45 44.754 11.12 51 176 176  47 79.15 47.273 10.60 47 162 164 
54 83.12 51.855 10.33 50 166 170  49 81.42 49.156  8.95 44 180 185 
51 69.63 40.836 10.95 57 168 172  51 77.91 46.672 10.00 48 162 168 
48 91.63 46.774 10.25 48 162 164  49 73.37 50.388 10.08 67 168 168 
57 73.37 39.407 12.63 58 174 176  54 79.38 46.080 11.17 62 156 165 
52 76.32 45.441  9.63 48 164 166  50 70.87 54.625  8.92 48 146 155 
51 67.25 45.118 11.08 48 172 172  54 91.63 39.203 12.88 44 168 172 
51 73.71 45.790 10.47 59 186 188  57 59.08 50.545  9.93 49 148 155 
49 76.32 48.673  9.40 56 186 188  48 61.24 47.920 11.50 52 170 176 
52 82.78 47.467 10.50 53 170 172 


/* ------------------------------------------------------------------------------*/
