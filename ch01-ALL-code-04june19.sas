/*
   CHAPTER 01:  All SAS Code combined into single file ===========================
   ch01-ALL-code-04june19.sas
   REV:  04 June 2019
*/


/* ------------------------------------------------------------------------------*/


/* ch01-constructed-example-28feb18.sas

Folder:  C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01
Author:   John Bailer
Purpose:  Illustrate learning from constructed, artificial data
   * 
Need to extract variable names from a column of an input data set

Linear mixed effects models

Sampling distribution of means


*/

/* template code that defines a style for output produced ... */

/* Program 1.1 ------------------------------------------------------ */

%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed\;
%include "&Folder\book_template_and_options.sas"; * page options and CustomSaphire specification;
%let subFolder=chapter01;

/* need to use this so graphics embedded in ODS RTF are PNG and not WMF */ 
*ods graphics on / imagefmt=png;

/* use this to produce TIFF graphics 
   - also turns off border to graph

*/
ods graphics on / imagefmt=jpeg border=OFF;
 
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

ods rtf file="&Folder.&subFolder.\ch01-fig1.1-and-2.rtf"
        image_dpi=600
        style=sasuser.customSapphire;

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

/* ======================================================================
Program 1.2:  Generating linear relationship with a random intercept  
               Linear mixed effects models
   ======================================================================*/
title "Linear Mixed Effects Model illustration";
data randomint;
  call streaminit(450561641);  * set the seed for the pseudorandom variable generation;
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

proc print data=randomint;
run;

ods rtf file="&Folder.&subFolder.\ch01-fig1.3.rtf"
        image_dpi=300
        style=sasuser.customSapphire;

/* Fit LME model estimating the variance components */
proc mixed data=randomint;
  class subject ;
  model response = time / SOLUTION;
  random Intercept / SUBJECT=subject type=UN;
run;

ods rtf close;

* ============ EPSI ============================================;
ods graphics on /  imagename="Ch01Fig01"
                   reset=index imagefmt=EPSI border=OFF ;
ods listing dpi=600;
/* plot the subject-specific trajectories */
proc sgplot data=randomint noborder noautolegend;
  series x=time y=response / group=subject;
run;
ods listing close;



/* Program 1.3 Sampling distribution of means of Poisson variates ========

SAS Help
http://support.sas.com/documentation/cdl/en/grstatproc/69716/HTML/default/viewer.htm#n0j7m77qd6d03ln1l4bk301h2imo.htm
   ====================================================================== */
title 'Poisson (mu=0.5) distribution';

data PoissonDistrib;
   mu=0.5;
   do x=0 to 10;
     ProbX = PDF("Poisson",x,mu);
	 output;
   end;
run;

*ods rtf file="&Folder.&subFolder.\ch01-fig1.6-and-7.rtf"
        image_dpi=300
        style=sasuser.customSapphire;

* ============ EPSI ============================================;

ods graphics on /  imagename="Ch01Fig02"
                   reset=index imagefmt=epsi border=OFF;
ods listing image_dpi=600;

* Probabilty Function for Poisson(mu = 0.5);
proc sgplot data=PoissonDistrib noborder;  * remove box around plot;
  needle x=x y=ProbX;
  xaxis offsetmin =.1;  * create space between first tick mark and x-axis;
run;
ods listing close;


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

* ============ EPSI ============================================;
ods graphics on /  imagename="Ch01Fig3"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;
* Sampling Distribution for means of samples from Poisson(mu = 0.5);
proc sgpanel data=RanPoi;
  title2 'Sampling Distribution of Xbar for different sample sizes';
  panelby nsize / layout=panel columns=1 noborder;
  histogram xbar / binwidth=.1;
  density xbar;
  density xbar / type=kernel;
run;
ods listing close;



* ods rtf close;

/* ------------------------------------------------------------------------------*/
/* Program 1.4 ======================================================================

/*     mreg-country-04jun19.sas
Folder: C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01

Modified from: mreg-country-20may09.sas
 Folder:  C:\baileraj\Classes\Spring09\programs\regression-examples\

Author:   John Bailer
Purpose:  multiple regression example where average life expectancy 
          of women is modeled as a function of country 
          characteristics
Last Revised:  
  03 June 2019 - updated variable names
  17 Jan. 2018 - read data from web and output Folder changed

Input data file -------------------------------------
   country.data

Folders:
   C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01

Input variables -------------------------------------
   Name = country name (Character variable)
   Area = country area
   Popn_Size = population size
   Pct_Urban = % residents in urban setting
   Lang = primary language
   Literacy = % literate
   Life_Men = average life expectancy men
   Life_Women = average life expectancy women
   PC_GNP = per capita gross national product

Created Variables -----------------------------------
   log_area = log10(area);
   log_popn = log10(popnsize);
   log_GNP  = log10(pcGNP);
   speaks_english = (lang="English");

Data Source:  Extracted from World Almanac
*/

/* read file from web 
   REF: http://support.sas.com/resources/papers/proceedings12/121-2012.pdf
*/

filename onweb url "http://www.users.miamioh.edu/baileraj/classes/sta402/data/country.data";
data country; 
  title "country data analysis";
  infile onweb;

  input  name $ area Popn_Size Pct_Urban lang $ Literacy Life_Men
         Life_Women PC_GNP;
  log_area = log10(area);
  log_popn = log10(Popn_Size);
  log_GNP  = log10(PC_GNP);
  speaks_english = (lang="English");
  drop area Popn_Size PC_GNP;
run;

proc print data=country;
run;

proc reg data=country;
  title "LITER and LOGGNP as predictors of Life expectancy of women";
  model Life_Women = Literacy log_GNP/ tol vif collinoint;      
  output out=new p=yhat r=resid;
run;

* setting up macro variable for Folder;  
%let Folder1 = C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01;

/* plot life expectancy of women vs. log(GNP) with a linear regression
   fit and LOESS fit superimposed
*/
ods rtf file="&Folder1.\ch01-pgm1p4-output.rtf"
        image_dpi=300
        style=sasuser.customSapphire;
title "";
proc sgplot data=country;
  reg   y=Life_Women x=log_GNP;
  loess y=Life_Women x=log_GNP;
run;
ods rtf close;

/* ------------------------------------------------------------------------------*/
/* Program 1.5 ======================================================================

/* 
   ch01-linregsim-04june19.sas
   Folder:  C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter01

   Author:  John Bailer

   generate a data set of 10 (X,Y) pairs where
   X = 1, 2, ..., 10
   Y ~ N(mu= 3 + 2X, sigma=2)
   ====================================================================== */

%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed\;
%include "&Folder\book_template_and_options.sas"; * page options and CustomSaphire specification;
%let subFolder=chapter01;

ods graphics on / imagefmt=jpeg border=OFF;
 
data lin_reg_data;
   call streaminit(32123);
   do x = 1 to 10 by 1;
      y = 3+2*x+2*RAND('NORMAL');
     output;
   end;
run;

ods rtf file="&Folder.\&SubFolder.\ch1-table1.5-and-6.rtf" 
        image_dpi=300
        style=sasuser.customSapphire;
proc print data=lin_reg_data;  * check data generation;
run;


proc reg data=lin_reg_data plots(only)=FitPlot(nolimits);
   model y=x;
run;
quit;

ods rtf close;

* to construct figure for inclusion in the book ;
* ========================= EPSI ============================;
ods graphics on /  imagename="Ch01Fig5"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=300;
proc reg data=lin_reg_data plots(only)=FitPlot(nolimits);
   model y=x;
run;
quit;
ods listing close;

ods graphics off;
ods rtf close;

/* ------------------------------------------------------------------------------*/

/* Program 1.5 ======================================================================
  Code to debug example   
  ====================================================================== */

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
