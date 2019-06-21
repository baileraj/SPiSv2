/*
   CHAPTER 03:  All Ch 03 SAS Code combined into single file ===========================
   Revised:  21 June 2019
*/

/* Program 3.1 :  IF-THEN-ELSE to define 4 categories of BMI */
%let dir=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subdir=chapter03;

/* template code that defines a style for output produced ... */
%include "&dir\book_template_and_options.sas";   * page options and CustomSaphire specification;

/* need to use this so graphics embedded in ODS RTF are PNG and not WMF */ 
ods graphics on / imagefmt=png;

Data TestCode;
  input BMI @@;

  IF BMI <18.50    THEN BodyClassif = " Underweight";
  ELSE IF BMI < 25 THEN BodyClassif = "Normal range";
  ELSE IF BMI < 30 THEN BodyClassif = "  Overweight";
  ELSE BodyClassif = "Obese";
datalines;
15 18.50 22 25 29 30 35
;
run;

ods rtf file="&dir\&subdir\ch3-fig3.1.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=TestCode;
run;

ods rtf close;

/* Program 3.2 :  Subseting data set using IF statement */

Data UnderWt;
  set TestCode;
  if BodyClassif=" Underweight";
run;
ods rtf file="&dir\&subdir\ch3-fig3.2.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=UnderWt;
run;
 
proc print data=TestCode;
  where BodyClassif=" Underweight";
run;

ods rtf close;


/* Program 3.3 :  DO-END to define long car ride experience */

data KidCrazy;
  do ask = 1 to 25;
     put "Are we there yet?";
  end;
run;

/* Program 3.4 :  Pseudocode in SAS */

/*

Estimate the probability that a randomly selected 30-39 year male 
         is taller than a randomly selected female 
         (all race/ethnicity)

Values (M:  NCHS ’08 Table 12; F:  NCHS ‘08 Table 10)
     MaleHt:  mean= 69.4 in., se=0.13 in., n=742 
              [ sd = sqrt(742)*0.13 ] 
   FemaleHt:  mean= 64.3,  se=0.13, n=842 
              [ sd = sqrt(842) * 0.13]  

Data Source:  http://www.cdc.gov/nchs/data/nhsr/nhsr010.pdf
*/
Data SimHeight;
*  1. Sample a female and a male;
      * define parameters of populations;
      * set seed for random number generation;

      * generate 1500 F and M from population;
      
*  2. Determine if randomly selected male is taller than the randomly selected female;

*  3.  Repeat steps 1 & 2 a large number of times;
       * write out results to data set before next pair;

*  4.  Calculate the proportion of times that a randomly selected male ht > female ht;

run;

/* Program 3.5 :  Height probability simulation solution in SAS */
/*
Estimate the probability that a randomly selected 30-39 year male 
         is taller than a randomly selected female 
         (all race/ethnicity)

Values (M:  NCHS ’08 Table 12; F:  NCHS ‘08 Table 10)
     MaleHt:  mean= 69.4 in., se=0.13 in., n=742 
              [ sd = sqrt(742)*0.13 ] 
   FemaleHt:  mean= 64.3,  se=0.13, n=842 
              [ sd = sqrt(842) * 0.13]  

Data Source:  http://www.cdc.gov/nchs/data/nhsr/nhsr010.pdf
*/
Data SimHeight;
*  1. Sample a female and a male;
   mean_M = 69.4;          * define parameters of populations;
   sd_M = sqrt(742)*0.13;
   mean_F = 64.3;
   sd_F = sqrt(842)*0.13;
   call streaminit(20160107);  * set seed;

   put _all_;              * write all values to the LOG;

   do pair = 1 to 1500;   * generate 1500 F and M from population;
      FemaleHt = RAND('Normal', mean_F, sd_F);
      MaleHt = RAND('Normal', mean_M, sd_M);

*  2. Determine if randomly selected male is taller than the randomly selected female;
      if MaleHt > FemaleHt then MaleTaller=1;
	  else MaleTaller = 0;

*  3.  Repeat steps 1 & 2 a large number of times;
      output;   * write out results to data set before next pair;
   end;

run;

*  4.  Calculate the proportion of times that a randomly selected male ht > female ht;

ods rtf file="&dir\&subdir\ch3-fig3.4.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc freq data=SimHeight;
  table MaleTaller;
run;

proc means data=SimHeight;
run;

ods rtf close;

/* Program 3.6:  Test code for order of operations */

data preced_test;
  x1a = 3*2**2;
  x1b = (3*2)**2;
  x2a = 3-2/2;
  x2b = (3-2)/2;
  x3a = -2**2;
  x3b = (-2)**2;
  put '-------------------------';
  put '| Order of operations   |';
  put '| illustrated           |';
  put '-------------------------';
  put '  3*2**2 = ' x1a;
  put '(3*2)**2 = ' x1b;
  put '   3-2/2 = ' x2a;
  put ' (3-2)/2 = ' x2b;
  put '   -2**2 = ' x3a;
  put ' (-2)**2 = ' x3b;
run;

/*
Program 3.7 - Dealing with missing values in a sum
*/

data test;
  input x1 x2 x3;
  tot1 = x1+ x2 + x3;
  tot2 = sum(x1, x2, x3);
  datalines;
1 2 3
1 . 3
. . 3
. . .
;
run;
ods rtf file="&dir\&subdir\ch3-fig3.6.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=test;
run;
ods rtf close;

/* Program 3.8  Converting temperature scales using arrays   */
data temps;
  array tempF(4) tempF1-tempF4 (32,50,68,86);
  array tempC(4) tempC1-tempC4;

  do temp = 1 to 4;
    tempC(temp) = 5/9*(tempF(temp)-32);
  end;
  drop temp;
run;
 
ods rtf file="&dir\&subdir\ch3-fig3.7.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=temps;
run;
ods rtf close;

/* Program 3.9  Recoding missing values in numeric variables  */
data D4;
  ARRAY ADL{*} t1 t2 t3 t4 t5 time6 time_7;
  input t1 t2 t3 t4 t5 time6 time_7;
  DO element = 1 to 7;
    if ADL{element}=-999 then ADL{element}=.;
  END;
  datalines;
6 6 5 5 5 4 3
7 -999 4 4 3 -999 2
;
run;

ods rtf file="&dir\&subdir\ch3-fig3.8.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=D4;
title "Recoding missing values using arrays and DO loop";
run;
ods rtf close;
title;  * reset title;

/* Program 3.10 Recoding missing values in numeric and character variables */
data D5;
  input name $ gender $ t1 t2 t3 t4 t5 time6 time_7;

  ARRAY  num_array{*} _NUMERIC_;
  ARRAY char_array{*} _CHARACTER_;

/* recode the numeric variables */
  DO num = 1 to dim(num_array);
    if num_array{num}=-999 then num_array{num}=.;
  END;

/* recode the character variables */
  Do char = 1 to dim(char_array);
                                                                                                                          
    if char_array{char}="-999" then char_array{char}=" ";
  END;

  drop inum ichar;
datalines;
MrSmith -999 6    6 5 5 5    4 3
-999       F 7 -999 4 4 3 -999 2
;
run;

ods rtf file="&dir\&subdir\ch3-fig3.9.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=D5;
title "Recoding missing values using arrays and DO loop";
run;
ods rtf close; 

/* Program 3.11 CDF functions in SAS   */

data cdf_examples;

/* Z ~ N(0,1) table values */
  norm_area_left = cdf("Normal",-1.645);

  norm_area_right = 1-cdf("Normal",-1.645);  * area above -1.645 under N(0,1);

/* T ~ t(df) table values */
  t_area_left_06 = cdf("T",-1.645, 6);    * area <= -1.645 for t(df=6);
  t_area_left_60 = cdf("T",-1.645, 60);   * area <= -1.645 for t(df=60);
  t_area_left_600 = cdf("T",-1.645, 600); * area <= -1.645 for t(df=600);

/* Pr(Y<=m) for Y ~ binomial(m=successes, p=prob of success=0.5, n=4 trials) */
  bin_cdf_0 = CDF('binomial', 0, 0.50, 4);
  bin_cdf_1 = CDF('binomial', 1, 0.50, 4);
  bin_cdf_2 = CDF('binomial', 2, 0.50, 4);
  bin_cdf_3 = CDF('binomial', 3, 0.50, 4);
  bin_cdf_4 = CDF('binomial', 4, 0.50, 4);

  p0 = bin_cdf_0;        /* Pr(Y=m) for Y ~ binomial(p=0.5, n=4)  */
  p1 = bin_cdf_1 - bin_cdf_0;
  p2 = bin_cdf_2 - bin_cdf_1;
  p3 = bin_cdf_3 - bin_cdf_2;
  p4 = bin_cdf_4 - bin_cdf_3;
run;
ods rtf file="&dir\&subdir\ch3-fig3.10.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=cdf_examples;
run;
ods rtf close;

/* Program 3.12  PDF and PMF examples   */

data pdf_examples;

/* Pr(Y=m) for Y ~ binomial(p=prob of success=0.5,  n=4 trials)  */
  bin_0 = PDF('binomial', 0, 0.50, 4);
  bin_1 = PDF('binomial', 1, 0.50, 4);
  bin_2 = PDF('binomial', 2, 0.50, 4);
  bin_3 = PDF('binomial', 3, 0.50, 4);
  bin_4 = PDF('binomial', 4, 0.50, 4);

/* Z ~ N(0,1) value of phi(0) */
  normal_density_0 = pdf("Normal", 0);
run;
ods rtf file="&dir\&subdir\ch3-fig3.11.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=pdf_examples;
run;
ods rtf close;

/* Program 3.13  Comparing a standard normal density to t4  */
title;
data t_vs_z;
  do x= -3.5 to 3.5 by .001;
    t4= x;
    t_density = PDF('t', x, 4);
    t_CDF = CDF('t', x, 4);
    z = x;
    z_density = PDF('Normal', x);
    z_CDF = CDF('Normal', x);
    output;
  end;
run;

ods graphics on /  imagename="Ch03Fig1"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

*ods rtf file="&dir\&subdir\ch3-fig3.12.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc sgplot data=t_vs_z;
   label t_density="t[df=4] density";
   label z_density="N(0,1) density";
   series x=t4 y=t_density / curvelabel;
   series x=z  y=z_density / curvelabel;
   xaxis label="value";
   yaxis label="density";
run;
*ods rtf close;
ods listing close;

ods graphics on /  imagename="Ch03Fig2"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;
proc sgplot data=t_vs_z;
   label t_CDF="t[df=4] CDF";
   label z_CDF="N(0,1)  CDF";
   series x=t4 y=t_CDF / curvelabel;
   series x=z  y=z_CDF / curvelabel;
   xaxis label="value";
   yaxis label="Prob(Variable <= value)";
   where z>=-2 and z<=2;
run;
ods listing close;




/*  Program 3.14 - QUANTILE function */

data quant_calc;

*  z examples ;
  zq_50 = QUANTILE('Normal',0.50);
  zq_90 = QUANTILE('Normal',0.90);
  zq_95 = QUANTILE('Normal',0.95);
  zq_975 = QUANTILE('Normal',0.975);

  put "Z:  50th   percentile = " @25 zq_50;
  put "Z:  90th   percentile = " @25 zq_90;
  put "Z:  95th   percentile = " @25 zq_95;
  put "Z:  97.5th percentile = " @25 zq_975;
  put " ";

* binomial examples;
  binq_50 =  QUANTILE('Binomial',0.50,.50,4);
  binq_90 =  QUANTILE('Binomial',0.90,.50,4);
  binq_95 =  QUANTILE('Binomial',0.95,.50,4);
  binq_975 = QUANTILE('Binomial',0.975,.50,4);

  put "Binomial:    50th percentile = " @35 binq_50;
  put "Binomial:    90th percentile = " @35 binq_90;
  put "Binomial:    95th percentile = " @35 binq_95;
  put "Binomial:  97.5th percentile = " @35 binq_975;
  put " ";

run;

/* Program 3.15 - QQ plot of N(0,1) vs t(4)   */
data t_vs_z_quant;
  do prob = .01 to .99 by .01;
    t_quantile = QUANTILE('t', prob, 4);
    z_quantile = QUANTILE('Normal', prob);
    output;
  end;
run;


ods graphics on /  imagename="Ch03Fig3"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

*ods rtf file="&dir\&subdir\ch3-fig3.14.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc sgplot data=t_vs_z_quant;
   series x=z_quantile y=t_quantile;
   yaxis label ="t[df=4] density";
   xaxis label ="N(0,1) density";
run;
*ods rtf close;

ods listing close;

/*  Program 3.16 - Generating and displaying a triangular random deviate */
data triangular;
  call streaminit(34567);
  do inum = 1 to 1400;
     mynum = RAND('Triangle', 0.70);
            * h=0.70 is a parameter of the triag. distn.;
     output;
  end;
run;


ods graphics on /  imagename="Ch03Fig4"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

*ods rtf file="&dir\&subdir\ch3-fig3.15.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc sgplot data=triangular;
  histogram mynum;
run;

*ods rtf close;
ods listing close;

/* Program 3.17 -   Simulating rolling a pair of dice  */
data diceroll;   * rolling two six-sided balanced dice;
  call streaminit(34567);
  do inum = 1 to 6000;
     die1 = RAND('Table', 1/6, 1/6, 1/6, 1/6, 1/6);
     die2 = RAND('Table', 1/6, 1/6, 1/6, 1/6, 1/6);
     sum7plus = (die1+die2)>=7;
  output;
  end;
run;


ods graphics on /  imagename="Ch03Fig5"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=300;

*ods rtf file="&dir\&subdir\ch3-fig3.16.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
*ods trace on;
ods select DeviationPlot;
proc freq data=diceroll;
  table die1 / nocum testf=(1000,1000,1000,1000,1000,1000);
  table sum7plus;
run;
*ods trace off;
*ods rtf close;
ods listing close;

/* Program 3.18  Processing multiple observations for an individual  */
data test;
  input id xstart xstop;
datalines;
1 15 25
2 10 12
2 18 22
3 6 12
3 14 15
3 17 23
;
run;

* make sure that data are sorted by ID and XSTART;
proc sort data=test;
    by id xstart;
run;

proc print data=test;
run;

data test2;
  set test;
  by id;        **** Comment 1;

  array start{9} start1-start9;     * (explained on next page);
  array stop{9} stop1-stop9;        
  array times{9} times1-times9;

  retain count 0;                   **** Comment 2;
  retain start1-start9 stop1-stop9 times1-times9;

* initialize count and arrays with new ID;
  if FIRST.id then do;            **** Comment 3;
    count = 0;
    do ii=1 to 9;
      start{ii} = .;
      stop{ii} = .;
      times{ii} = .;
    end;
  end;

  count = count + 1;	           **** Comment 4;
  start{count} = xstart;
  stop{count} = xstop;
  times{count} = xstop - xstart;
  if LAST.id=1 then do;             **** Comment 5;
     first_time = times(1);
     total_time = sum(of times1-times9);
     output;  * output results if last obs for ID;
  end;  

  keep id count first_time total_time;
run;

ods rtf file="&dir\&subdir\ch3-fig3.17.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=test2;
run;
ods rtf close;

/*Program 3.19  Processing multiple observations for an individual without using arrays */
data test;
  input id xstart xstop;
datalines;
1 15 25
2 10 12
2 18 22
3 6 12
3 14 15
3 17 23
;
run;

proc print data=test;
run;

*** make sure data are sorted by ID and XSTART variables;
proc sort data=test;
    by id xstart;
run;

data test2;
    set test;
    by id;

    retain count total_time first_time;

    if first.id then do;
        count=0;
        total_time=0;
        first_time=0;
    end;
    count=count+1;
    total_time=total_time + (xstop-xstart);
    if first.id then first_time=xstop-xstart;

    if last.id then output;

    keep id count total_time first_time;
run;

proc print data=test2;
run;

/* Program 3.20  Pseudocode and comments for the t-test simulation */

/*  Problem:  Explore whether t-test really is robust to
              violations of the equal variance assumption

    Strategy: See if the t-test operates at the nominal
              Type I error rate when the unequal variance
              assumption is violated

*/ 
/* specify the conditions to be generated  */
/* generate data sets reflecting these conditions  */
/* calculate the test statistic  */
/* accumulate results over numerous simulated data sets  */



/* Program 3.21 - Specifying the conditions for the t-test simulation  */
/*  Problem:  Explore whether t-test really is robust to
              violations of the equal variance assumption

    Strategy: See if the t-test operates at the nominal 
              Type I error rate when the unequal variance
              assumption is violated

*/ 

/* specify the conditions to be generated  */

Nsims = 1;       * number of simulated experiments;
Myseed = 65432;  * specify seed for random number sequence;

N1 = 10;      * sample sizes from populations 1 and 2;
N2 = 10;

Mu_1 = 0;     * mean/sd of population 1;
Sig_1 = 1;

Mu_2 = 0;     * mean/sd of population 2;
Sig_2 = 1;

/* generate data sets reflecting these conditions  */

* generate N1 observations ~ N(mu_1, sig_1^2);

* generate N2 observations ~ N(mu_2, sig_2^2);


/* calculate the test statistic  */

/* accumulate results over numerous simulated data sets  */


/* ================================================================ */

/* Program 3.22 -   Adding data generation and test statistic code to the t-test simulation */
/*  Problem:  Explore whether t-test really is robust to
              violations of the equal variance assumption
    Strategy: See if the t-test operates at the nominal 
              Type I error rate when the unequal variance
              assumption is violated
*/ 



/* specify the conditions to be generated  */

Data simulate_2group_t;
  Nsims = 1;       * number of simulated experiments;
  Myseed = 65432;  * specify seed for random number sequence;
  call streaminit(Myseed);  * see Section 8.11 for more descrip.;

  N1 = 10;      * sample sizes from populations 1 and 2;
  N2 = 10;

  Mu_1 = 0;     * mean/sd of population 1;
  Sig_1 = 1;

  Mu_2 = 0;     * mean/sd of population 2;
  Sig_2 = 1;

  do expt = 1 to Nsims;

/* generate data sets reflecting these conditions  */
* generate N1 observations ~ N(mu_1, sig_1^2);
    do obs = 1 to N1;
      group = 1;
      Y = RAND('normal',mu_1,sig_1);
      output;
    end;

* generate N2 observations ~ N(mu_2, sig_2^2);
    do obs = 1 to N2;
      group = 2;
      Y = RAND('normal',mu_2,sig_2);
      output;
    end;

/* calculate the test statistic  */
/* accumulate results over numerous simulated data sets  */

  end;  * of the do-loop over simulated experiments;
run;
*ods rtf file="&dir\&subdir\ch3-2group_t.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=simulate_2group_t;
run;
proc means data=simulate_2group_t;
  var y;
  class group;
run;
*ods rtf close;


/* ================================================================ */

/* Program 3.23 - Determining output objects produced by PROC TTEST */
/*  Problem:  Explore whether t-test really is robust to
              violations of the equal variance assumption

    Strategy: See if the t-test operates at the nominal 
              Type I error rate when the unequal variance
              assumption is violated

*/ 

/* specify the conditions to be generated  */

data simulate_2group_t;
  Nsims = 1;       * number of simulated experiments;
  Myseed = 65432;  * specify seed for random number sequence;
  call streaminit(Myseed);  

  N1 = 10;      * sample sizes from populations 1 and 2;
  N2 = 10;

  Mu_1 = 0;     * mean/sd of population 1;
  Sig_1 = 1;

  Mu_2 = 0;     * mean/sd of population 2;
  Sig_2 = 1;

  do expt = 1 to Nsims;

/* generate data sets reflecting these conditions */

* generate N1 observations ~ N(mu_1, sig_1^2);
    do obs = 1 to N1;
      group = 1;
      Y = RAND('normal',mu_1,sig_1);
      output;
    end;

* generate N2 observations ~ N(mu_2, sig_2^2);
    do obs = 1 to N2;
      group = 2;
      Y = RAND('normal',mu_2,sig_2);
      output;
    end;

  end;  * of the do-loop over simulated experiments;
run;

/* calculate the test statistic */
*ods rtf file="&dir\&subdir\Figure-3-18.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
options formdlim="+";
ods listing;
ods trace on/listing;
proc ttest data=simulate_2group_t;
  by expt;
  class group;
  var Y;
run;
ods trace off; 
* ods rtf close;
ods listing close;


/* Program 3.24 - Displaying contents of data set created by ODS output */
ods output TTests=Out_TTests;
proc ttest data= simulate_2group_t;
  by expt;
  class group;
  var Y;
run;

ods output close; 

ods rtf file="&dir\&subdir\ch3-fig3.19.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=Out_TTests;
run;
ods rtf close;

/* ================================================================ */

/* Program 3.25 - ODS output version of the t-test simulation program */
/*  Problem:  Explore whether t-test really is robust to
              violations of the equal variance assumption

    Strategy: See if the t-test operates at the nominal 
              Type I error rate when the unequal variance
              assumption is violated
*/ 


/* START timer --------------------------------->  */
%let _timer_start = %sysfunc(datetime());


/* specify the conditions to be generated  */

data simulate_2group_t;
  Nsims = 100;    * number of simulated experiments;
  Myseed = 65432;  * specify seed for random number sequence;
  call streaminit(Myseed);  

  N1 = 10;      * sample sizes from populations 1 and 2;
  N2 = 10;

  Mu_1 = 0;     * mean/sd of population 1;
  Sig_1 = 1;

  Mu_2 = 0;     * mean/sd of population 2;
  Sig_2 = 1;

  do expt = 1 to Nsims;

/* generate data sets reflecting these conditions  */

* generate N1 observations ~ N(mu_1, sig_1^2);
    do obs = 1 to N1;
      group = 1;
      Y = RAND('normal',mu_1,sig_1);
      output;
    end;

* generate N2 observations ~ N(mu_2, sig_2^2);
    do obs = 1 to N2;
      group = 2;
      Y = RAND('normal',mu_2,sig_2);
      output;
    end;
  end;  * of the do-loop over simulated experiments;
run;
/* calculate the test statistic  */
/* Note:  ODS TRACE was used to determine the output
          object containing the test statistics.  This
          included the pooled-variance t-test and the 
          Satterthwaite df approximation for the t-test
          allowing for unequal variances */
ods output TTests=Out_TTests;
proc ttest data= simulate_2group_t; 
  by expt;
  class group;
  var Y;
run;
ods output close; 

/* accumulate results over numerous simulated data sets  */

data out_ttests; set out_ttests;
  retain Pooled_p;  * RETAIN explained in Section 8.3;
  if method="Pooled" then Pooled_p = Probt;
  else do;
    Satter_p = Probt;
    Pooled_reject = (Pooled_p <= 0.05); * Boolean trick again;
    Satter_reject = (Satter_p <= 0.05);
    keep expt Pooled_p Satter_p Pooled_reject Satter_reject;
    output;
  end;
run;

* ods rtf file="&dir\&subdir\ch3-fig3.xx.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc freq;
  table Pooled_reject Satter_reject;
run;
* ods rtf close;


/* STOP timer --------------------------------->  */
Data _null_;
  Dur = datetime() - &_timer_start;
  Put 30*'-' / 'Total Duration: ' dur / 30*'-';
run;






/* Program 3.26 - Generating data as one record per simulated experiment */

data simulate_2group_t;

  Nsims = 4000;    * number of simulated experiments;
  Myseed = 65432;  * specify seed for random number sequence;
  call streaminit(Myseed);

  N1 = 10;      * sample sizes from populations 1 and 2;
  N2 = 10;

  Mu_1 = 0;     * mean/sd of population 1;
  Sig_1 = 1;

  Mu_2 = 0;     * mean/sd of population 2;
  Sig_2 = 1;

  do expt = 1 to Nsims;

* generate N1=10 observations ~ N(mu_1, sig_1^2);
    X1 = RAND('normal',mu_1,sig_1);
    X2 = RAND('normal',mu_1,sig_1);
    X3 = RAND('normal',mu_1,sig_1);
    X4 = RAND('normal',mu_1,sig_1);
    X5 = RAND('normal',mu_1,sig_1);
    X6 = RAND('normal',mu_1,sig_1);
    X7 = RAND('normal',mu_1,sig_1);
    X8 = RAND('normal',mu_1,sig_1);
    X9 = RAND('normal',mu_1,sig_1);
    X10 = RAND('normal',mu_1,sig_1);
* generate N2=10 observations ~ N(mu_2, sig_2^2);
    Y1 = RAND('normal',mu_2,sig_2);
    Y2 = RAND('normal',mu_2,sig_2);
    Y3 = RAND('normal',mu_2,sig_2);
    Y4 = RAND('normal',mu_2,sig_2);
    Y5 = RAND('normal',mu_2,sig_2);
    Y6 = RAND('normal',mu_2,sig_2);
    Y7 = RAND('normal',mu_2,sig_2);
    Y8 = RAND('normal',mu_2,sig_2);
    Y9 = RAND('normal',mu_2,sig_2);
    Y10 = RAND('normal',mu_2,sig_2);

    output;
  end;
/* calculate the test statistic                        */
run;

/* Program 3.27 - Storing simulated data in arrays */
data simulate_2group_t;

   array x{10} x1-x10;   * storage for sample from population 1;
   array y{10} y1-y10;   * storage for sample from population 2;

   Nsims = 4000;    * number of simulated experiments;
   Myseed = 65432;  * specify seed for random number sequence;
   call streaminit(Myseed);

   N1 = 10;      * sample sizes from populations 1 and 2;
   N2 = 10;

   Mu_1 = 0;     * mean/sd of population 1;
   Sig_1 = 1;

   Mu_2 = 0;     * mean/sd of population 2;
   Sig_2 = 1;

   do expt = 1 to Nsims;

* generate N1=10 observations ~ N(mu_1, sig_1^2);
       do obs = 1 to N1;
         x{obs} = RAND('normal',mu_1,sig_1);
       end;

* generate N2=10 observations ~ N(mu_2, sig_2^2);
       do obs = 1 to N2;
         y{obs} = RAND('normal',mu_2,sig_2);
       end;

       output;

/* calculate the test statistic                        */

   end;
run;


/* Program 3.28 - Pseudocode and comments for the t-test simulation in a DATA step */

/* calculate the test statistic                        */

* >>>> calculate sample means and variances;

* >>>> calculate pooled variance and t-test statistic;

* >>>> calculate p-value;


/* START timer ----------------------->  */
%let _timer_start = %sysfunc(datetime());


/* Program 3.29 - DATA step programming with arrays for t-test sim */
data simulate_2group_t;

   array x{10} x1-x10;   * storage for sample from population 1;
   array y{10} y1-y10;   * storage for sample from population 2;

   Nsims = 100;    * number of simulated experiments;
   Myseed = 65432;  * specify seed for random number sequence;
   call streaminit(Myseed);

   N1 = 10;      * sample sizes from populations 1 and 2;
   N2 = 10;
   Mu_1 = 0;     * mean/sd of population 1;
   Sig_1 = 1;
   Mu_2 = 0;     * mean/sd of population 2;
   Sig_2 = 1;

   do expt = 1 to Nsims;

* generate N1=10 observations ~ N(mu_1, sig_1^2);
        do obs = 1 to N1;
          x{obs} = RAND('normal',mu_1,sig_1);
        end;

* generate N2=10 observations ~ N(mu_2, sig_2^2);
        do obs = 1 to N2;
          y{obs} = RAND('normal',mu_2,sig_2);
        end;

/* calculate the test statistic                        */

* >>>> calculate sample means and variances;
        xbar = mean(of x1-x10);
        ybar = mean(of y1-y10);
        xvar = var(of x1-x10);
        yvar = var(of y1-y10);

* >>>> calculate pooled variance and t-test statistic;
        s2p = ( (N1-1)*xvar + (N2-1)*yvar)/(N1 + N2 - 2);
   
        tstat = (xbar-ybar)/sqrt(s2p*(1/N1 + 1/N2));
   
* >>>> calculate p-value   ;
        Pvalue = 2*(1-CDF('t',abs(tstat),(N1 + N2 - 2)));
        Reject05 = (Pvalue <= 0.05);

        output;
   end;  * of loop over simulated experiments;
run;

*ods rtf file="&dir\&subdir\ch3-fig3.xx.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc freq data=simulate_2group_t; 
  table Reject05;
run;  
*ods rtf close;

/* STOP timer ----------------------->  */
data _null_;
  dur = datetime() - &_timer_start;
  Put 30*'-' / 'Total Duration: ' dur / 30*'-';
run;



/* Program 3.30 - Pseudocode for Monte Carlo integration */

/* generate data [x, f(x)] in a rectangle containing f(x) = density 
   for N(0,1) */

/* determine proportion of points that lie below f(x) */

/* derive the area estimate and place a bound on the error of 
   estimation */

/* Program 3.31  Expanding the program for Monte Carlo integration  */

Repeatedly do the following  (
   /* generate data (x, f(x)) in a rectangle containing the 
                                       f(x) = density for N(0,1) */
      x = 1.645*RAND('uniform');
      y = 0.400*RAND('uniform');
   
   /* determine if point lies below f(x) */
      is_under = (y<= (1/sqrt(2*pi) )*exp(-x*x/2) );
}

/* determine proportion of simulated points under the curve  */
   p_est = sum(is_under)/number of simulated points;

/* derive the area estimate, SE and CI   */
  AUC_hat = Area_Rectangle * p_est;
  SE_AUC_hat = Area_Rectangle * sqrt(p_est * (1-p_est) / n_pts);
  LCL = AUC_hat - zmult * SE_AUC_hat;
  UCL = AUC_hat + zmult * SE_AUC_hat;
/* write out results   */



/* Program 3.32  Generating a Monte Carlo estimate of P(0<Z<1.645) */

data area_est;
  retain n_under 0;       * initialize counter – aside: n_under=0 – also works;
  seed1 = 98765;          * seed specified;
  call streaminit(seed1);

  pi = CONSTANT('PI');
  const = 1/sqrt(2*pi);   * bring constant calc. outside loop;
  n_pts = 4000;
  zmult = 1.96;                  * 95% Confidence interval requested;
  Area_rectangle = 1.645*.400;

  do sim = 1 to n_pts;             *  REPEAT { . . .  ;

    /* generate data [x, f(x)] in a rectangle containing the 
                                       f(x) = density for N(0,1) */
    x = 1.645*RAND('uniform');
    y = 0.400*RAND('uniform');

    /* determine if point lies below f(x) */

    is_under = (y<= const*exp(-x*x/2) );

    /* determine proportion of points that lie below f(x) */
    n_under = n_under + is_under;
    p_est = n_under/sim;

    /* derive the area estimate, SE and CI   */
    AUC_hat = Area_Rectangle * p_est;
    SE_AUC_hat = Area_Rectangle * sqrt(p_est * (1-p_est) / n_pts);
    LCL = AUC_hat - zmult * SE_AUC_hat;
    UCL = AUC_hat + zmult * SE_AUC_hat;

    output;
  end;                           *  . . . } ;

/* write out the results  */
  put "Area est. = " AUC_hat;
  put "(SE = " SE_AUC_hat ")";
  put "CI: [" LCL "," UCL  "]";
run;


/* Program 3.33 Graphics portion of the program generating a Monte Carlo estimate of 
                        P(0<Z<1.645)
 */


/* generate plot of estimate of P(0<Z<1.645) plus pointwise CI */
/*  Code enhancement suggested by SAS reviewer       */
data area_est; set area_est;
  AUC_TRUE = 0.45;
run;


ods graphics on /  imagename="Ch03Fig6"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

*ods rtf file="&dir\&subdir\ch3-fig3.20.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc sgplot data=area_est;
  where 10 <= sim <= 3500;
  label sim = "Number of simulated data points";
  label AUC_hat = "Estimated Area";

  series x=sim y=AUC_hat / name="AUC est." curvelabel;
  series x=sim y=LCL / name = "LCL" curvelabel;
  series x=sim y=UCL / name = "UCL" curvelabel;
  series x=sim y=AUC_TRUE / name="TRUE" lineattrs=(pattern=solid color=black 
                thickness=2);
  yaxis values=(0.38 to 0.48 by 0.01); 
  keylegend "TRUE" / location=inside position=bottomright;

run;
*ods rtf close;
ods listing close;

ods graphics on /  imagename="Ch03Fig7"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

*ods rtf file="&dir\&subdir\ch3-fig3.21.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc sgplot data=area_est;
  scatter x=x y=y / group=is_under markerchar=is_under;
  label x="Randomly generated X-coordinate";
  label y="Randomly generated Y-coordinate"; 
run;

*ods rtf close;
ods listing close;

proc sgplot data=sashelp.class;
 scatter x=height y=weight / group=sex markerchar=sex;
run;


/* Program 3.34 - Constructing percentile-based bootstrap CI 
    input the data  
    construct the t-based CI for the mean response  
    calculate the bootstrap-based CI for the mean response  
    * generate bootstrap resamples of the data vector
    * calculate the mean for each resample
    * select the 5th and 95th percentiles from the bootstrap distribution of 
      the mean

/* Program 3.35 - Constructing percentile-based bootstrap CI for a population mean */
/* input the data  */
/* From the FITNESS data set found in SAS Help 

Help > Getting Started with SAS Software > Learning to Use SAS > Sample SAS Programs > SAS/STAT > Sample and select Example 2 for PROC REG
  
   Note: Only AGE data considered.
*/

data in_data;
  input age @@;
  datalines;
44 40 44 42 38 47 40 43 44 38 44 45 45 47 54 49 51 51 48 49 57 54 52 50 51 54 51 57 49 48 52
;
run;

ods rtf file="&dir\&subdir\ch3-fig3.22.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

/* construct the t-based CI for the mean response */
proc tabulate data=in_data alpha=0.10;
  var age;
  table age, LCLM UCLM; * 90% CI requested for the mean MPG;
run;

/* calculate the bootstrap-based CI for the mean response */
data boot_data;
  array age{31} age1-age31;
  array boot_age{31} boot_age1-boot_age31;
  input age1-age31;

* generate 4000 bootstrap resamples of the 31 element data vector;
  call streaminit(27549);

  do bootstrap_sample = 1 to 4000;
    do obs = 1 to 31;
      boot_age(obs) = age(ceil(31*RAND('uniform')));
    end;
    boot_mean = mean(of boot_age1-boot_age31);    * calculate the test statistic; 
    keep boot_mean;
    output boot_data;
  end;

datalines;
44 40 44 42 38 47 40 43 44 38 44 45 45 47 54 49 51 51 48 49 57 54 52 50 51 54 51 57 49 48 52
run;

* select 5th and 95th percentiles from bootstrap distribution of the mean;
proc tabulate data=boot_data;
  var boot_mean;
  table boot_mean, P5 P95;
run;


ods graphics on /  imagename="Ch03Fig8"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

proc sgplot data=boot_data;  * histogram of bootstrap means (not shown);
  histogram boot_mean;
run;

ods listing close;

ODS RTF close;


/* Program 3.36 Reading conc= 0 or 160 C. dubia data and constructing t-test */

data nitrofen0_160;                * entering directly as alternative to ;
  input Obs conc total;   *    permanent SAS data file reference;
datalines;
  1       0      27
  2       0      32
  3       0      34
  4       0      33
  5       0      36
  6       0      34
  7       0      33
  8       0      30
  9       0      24
 10       0      31
 11     160      29
 12     160      29
 13     160      23
 14     160      27
 15     160      30
 16     160      31
 17     160      30
 18     160      26
 19     160      29
 20     160      29
;
run;

ods rtf file="&dir\&subdir\ch3-fig3.22.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc ttest data=nitrofen0_160;
  class conc;
  var total;
run;
ods rtf close;

/* Program 3.37 Constructing a randomization test of two-population mean equality */
/* Original code:  Display 9.8 in Bailer (2010)
   Improvements:   S. Wright
*/

data nitrofen0_160;              
  input Obs conc total; 
datalines;
  1       0      27
  2       0      32
  3       0      34
  4       0      33
  5       0      36
  6       0      34
  7       0      33
  8       0      30
  9       0      24
 10       0      31
 11     160      29
 12     160      29
 13     160      23
 14     160      27
 15     160      30
 16     160      31
 17     160      30
 18     160      26
 19     160      29
 20     160      29
;
run;

proc print data=nitrofen0_160;
  title "NITROFEN: print of (0, 160) concentrations";
  var conc total;
run;

title 'randomization test: nitrofen';
data _NULL_;
	/* bring the observed data */
	array obs_data{20} obs1-obs20; * array to store all observed responses;
	do j=1 to 20;
		set nitrofen0_160; * read one observation;
		obs_data{j} = total; * copy response into array;
	end;

	/* calculate test statistic for observed data: absolute difference
		of means
	*/
	obs_diff = abs(mean(of obs1-obs10) - mean(of obs11-obs20));

	/* process 4000 permutations of the observed data */
	seed = 8675309; * set the seed for RANPERM used below;
	do p=1 to 4000;
		/* permute the observed responses */
		call ranperm(seed, of obs_data{*});

		/* calculate test statistic for permuted data */
		perm_diff = abs(mean(of obs1-obs10) - mean(of obs11-obs20));

		/* count values as extreme as observed value */
		extreme + (perm_diff >= obs_diff);
	end;

	/* summarize the results */
	pvalue = extreme/4000;
	put pvalue= ; * print answer in Log window;
run;

/*
    HOMEWORK
*/


