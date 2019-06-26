/*
   CHAPTER 05:  ===========================

   Revised:  26 June 2019
*/

/* set up for Folders ................................... */
%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder=chapter05;

/* template code that defines a style for output produced ... */
%include "&Folder\book_template_and_options.sas";   * page options and CustomSaphire specification;

/* need to use this so graphics embedded in ODS RTF are PNG and not WMF */ 
ods graphics on / imagefmt=png;

/* 
Program 5.1 Estimating P(0<Z<1.645) using the trapezoidal rule
*/ 
%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder=chapter05;

data trapper;
  trapsum=0;
  array x_value(25) x1-x25;
  array f_value(25) y1-y25;

  low = 0;
  high = 1.645;
  incr = (high-low)/24;
  multiplier = 1/sqrt(2*CONSTANT('PI'));

  do point = 1 to 25;
    x_value[point] = low + incr*(point-1);
    f_value[point] = multiplier*exp(-x_value[point]*x_value[point]/2);

    if point=1 or point=25 then trapsum = trapsum + f_value[point]/2;
    else trapsum = trapsum + f_value[point];
  end;
  area_est = trapsum*incr;
  output;
run;

ods rtf file="&Folder\&subFolder\ch5-fig5.1-2-3.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=trapper noobs;
  title "Trapezoidal Rule Area Estimate for P(0<Z<1.645)";
  var low high incr area_est;
run;

data trapper2;
   set trapper;
   array x_value(25) x1-x25;
   array f_value(25) y1-y25;
   do point =1 to 25;
     xout = x_value[point];
     yout = f_value[point];
     output;
   end;
run;

proc print data=trapper2 noobs;
title "Interpolation Points for Trapezoidal Rule";
   var point low high incr area_est xout yout;
run;
ods rtf close;


ods graphics on /  imagename="Ch5Fig3"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;  

proc sgplot data=trapper2;
title "Plot of function values vs. x-values";
  scatter x=xout y=yout;
run;
ods listing close;

/*********************************************************************/

/* 
Program 5.2 Replacing the limits of integration and 
            number of points to evaluate

            Estimate P(low < Z < high) using the trapezoidal rule 
*/ 

%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder=chapter05;

%let npts = 50;   * 25, 15, 5, and 3 tried as well;
%let LOW = -1.645;
%let HIGH = 1.645;

data trapper;
  file  "&Folder\&subFolder\ch5-fig5.5-est.out" MOD;

  trapsum = 0;
  array x_value(&npts) x1-x&npts;
  array f_value(&npts) y1-y&npts;

  low = &LOW;
  high = &HIGH;
  incr = (high-low)/( &npts -1);
  multiplier = 1/sqrt(2*CONSTANT('PI'));

  do point = 1 to &npts;
   x_value[point] = low + incr*(point-1);
   f_value[point] = multiplier*exp(-x_value[point]*x_value[point]/2);

    if point =1 or point =&npts then trapsum = trapsum + f_value[point]/2;
	else trapsum = trapsum + f_value[point];
  end;
  area_est = trapsum*incr;
  output;

put;
put "est. P(&LOW < Z < &HIGH) =" area_est "(based on &NPTS points)";
put;
run;

ods rtf file="&Folder\&subFolder\ch5-fig5.4.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;
proc print data=trapper noobs;
  title "Trapezoidal Rule Area Estimate for P(&LOW<Z<&HIGH)";
  title2 "(based on &NPTS equally spaced points)";
  var low high incr area_est;
run;

data trapper2;
   set trapper;
   array x_value(&npts) x1-x&npts;
   array f_value(&npts) y1-y&npts;
   do point=1 to &npts;
     xout = x_value[point];
     yout = f_value[point];
     output;
   end;
run;

proc print data=trapper2 noobs;
title "Interpolation Points for Trapezoidal Rule";
   var point low high incr area_est xout yout;
run;

proc sgplot data=trapper2;
title "Plot of function values vs. x-values";
  scatter x=xout y=yout;
run;
ods rtf close;

/*********************************************************************/
/*
  Program 5.3 Macro to construct a trapezoidal rule estimate of the 
              area under a standard normal density curve
*/
%macro trap_area_Z(LOW=-1.645, HIGH=1.645, npts_lo=10, npts_hi=10, npts_by=2,
   fout=&Folder\&subFolder\est3.out,
   print_est=FALSE, print_pts=FALSE, display_graph=FALSE, ODS_on=FALSE);

/*  ======================================================================== 
Purpose: Estimate P{LOW<Z< HIGH) using the trapezoidal rule
Macro variables:
LOW, HIGH: interval of interest
NPTS_LO, NPTS_HI, NPTS_BY: # function values evaluated in area calc.
FOUT: output data file containing area estimate for each NPTS value
PRINT_EST: print area estimate
PRINT_PTS: print points/nodes {x1-xn} + function values {f(x1)-f(xn)}  
DISPLAY_GRAPH: generate PROC GPLOT with function values
ODS_ON: generate ODS RTF output
======================================================================== 
*/

%do npts = &npts_lo %to &npts_hi %by &npts_by; *loop over npts values;

data trapper;
  file "&fout" MOD;
  trapsum = 0;
  array x_value(&npts) x1-x&npts;
  array f_value(&npts) y1-y&npts;

  low = &LOW;
  high = &HIGH;
  incr = (high-low)/( &npts -1);
  multiplier = 1/sqrt(2*CONSTANT('PI'));

  do point = 1 to &npts;
    x_value[point] = low + incr*(point-1);
    f_value[point] = multiplier*exp(-x_value[point]*x_value[point]/2);

    if point=1 or point=&npts then trapsum = trapsum + f_value[point]/2;
	else trapsum = trapsum + f_value[point];
  end;
  area_est = trapsum*incr;
  output;

put "est. P(&LOW < Z < &HIGH) =" area_est "(based on &NPTS points)";
run;

%if %upcase(&ODS_ON)=TRUE %then %do;
    ods rtf file="&Folder\&subFolder\ch5-fig5.6.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
%end;

%if %upcase(&print_est)=TRUE %then %do;
proc print data=trapper;
  title "Trapezoidal Rule Area Estimate for P(&LOW<Z<&HIGH)";
  title2 "(based on &NPTS equally spaced points)";
  var low high incr area_est;
run;
%end;

data trapper2;
   set trapper;
   array x_value(&npts) x1-x&npts;
   array f_value(&npts) y1-y&npts;
   do point = 1 to &npts;
     xout = x_value[point];
     yout = f_value[point];
     output;
   end;
run;

%if %upcase(&print_pts)=TRUE %then %do;
proc print data=trapper2;
title "Interpolation Points for Trapezoidal Rule";
   var point low high incr area_est xout yout;
run;
%end;

%if %upcase(&display_graph)=TRUE %then %do;
proc sgplot data=trapper2;
title "Plot of function values vs. x-values";
  scatter x=xout y=yout;
run;
%end;

%if %upcase(&ODS_ON)=TRUE %then %do;
ods rtf close;
%end;

%end;   * of loop over npts values;
%mend trap_area_Z;

* Calling the macro with different parameter configurations >>>>>>>>>>>>>>>>>>;

%trap_area_Z()                    /*  all default values    */
%trap_area_Z(LOW=0)               /* changing LOW to 0      */
%trap_area_Z(LOW=-.67, HIGH=.67)  /* changing LOW and HIGH  */
%trap_area_Z(LOW=-.67, HIGH=.67, npts_lo=10, npts_hi=20, npts_by=5)
%trap_area_Z(LOW=-.67, HIGH=.67, print_est=TRUE, print_pts=true)
%trap_area_Z(LOW=-.67, HIGH=.67, display_graph=TRUE)
%trap_area_Z(LOW=-.67, HIGH=.67, ODS_ON=TRUE, display_graph=TRUE)

/*********************************************************************/
/* Program 5.4 Resolving a complex macro variable  */
%let var1=week;
%let var2=weight;
%let time1=1;
%let time2=2;
%let var1time1 = week1;
%let var1time2 = week2;
%let var2time1 = weight1;
%let var2time2 = weight2;

data tester;
  input week1 weight1 week2 weight2;
  datalines;
15 70 25 74
;
run;

%macro showvalue(variable, obs); 
      %put Value of '&variable' = &variable;
      %put Value of '&obs' = &obs;
      %put Value of '&&&variable.&obs' = AMPERSAND-&variable.&obs = &&&variable.&obs;
   data _NULL_;
      set tester;
      put  "Value of &&&variable.&obs =" &&&variable.&obs;
   run;
%mend showvalue;

%showvalue(variable=var1, obs=time1)

%showvalue(variable=var2, obs=time2)

/*********************************************************************/
/* Program 5.5  Macro illustrating %GOTO   */
%macro ncheck(npts);
%* npts = needs to be greater than or equal to 1;
%if %sysevalf(&npts<1) %then %do;
  %put ERROR:  '&npts' must exceed 1;
  %put ERROR:  value of '&npts' = &npts;
  %goto badend;
%end;
%put Value of '&npts' = &npts;
%badend:  ;
%mend ncheck;

%ncheck(1)
%ncheck(-2)
%ncheck(0.5)

/*********************************************************************/

/*  Program 5.6  %Put-ting values of macro variables   */
%put _USER_;
%put _AUTOMATIC_;
%put _ALL_;

/*********************************************************************/

/*  Program 5.7  Illustrating output produced by SAS options for debugging macros  */
options mprint;              * turn on MPRINT;
%trap_area_z(LOW=0,HIGH=1.96,npts_lo=15,npts_hi=25,npts_by=5, display_graph=TRUE)

options nomprint symbolgen;  * turn off MPRINT, turn on SYMBOLGEN;
%trap_area_z(LOW=0,HIGH=1.96,npts_lo=15,npts_hi=25,npts_by=5, display_graph=TRUE)

options nosymbolgen mlogic;  * turn off SYMBOLGEN, turn on MLOGIC;
%trap_area_z(LOW=0,HIGH=1.96,npts_lo=15,npts_hi=25,npts_by=5, display_graph=TRUE)

options nomlogic;            * turn off MLOGIC;


/*********************************************************************/

/* Program 5.8  Illustrating macro functions results displayed in the SAS LOG */
%let summer = June July August;
%let pickmth = 3;
%let mymonth = %scan(&summer, &pickmth);   * pickmth word of summer;
%let mymonth3 =%substr(&summer, 11, 3);    * start @ position 11 and move 3;
%let upper_month3 = %upcase(&mymonth3);

%put Summer=&summer;
%put Length of '&summer' = %length(&summer);
%put Where is Aug in the '&summer'? = %index(&summer, Aug);
%put Month picked = &pickmth;
%put Which month? = &mymonth;
%put Which month (3 letters)? = &mymonth3;
%put Upper case (3 letters)? = &upper_month3;

/*********************************************************************/

/* Program 5.9  SYMPUT function in a macro  */
data nitrofen;
 filename cdub URL "http://www.users.miamioh.edu/baileraj/datasets/ch2-dat.txt";

 infile cdub firstobs=16 expandtabs missover pad;
 input @9 animal 2.
       @17 conc 3.
       @25 brood1 2.
       @33 brood2 2.
       @41 brood3 2.
       @49 total 2.;
run;

data test; set nitrofen;
  brood=1; conc=conc;  nyoung=brood1; output;
  brood=2; conc=conc;  nyoung=brood2; output;
  brood=3; conc=conc;  nyoung=brood3; output;
run;

%macro threeregs;
  proc sort data=test out=test;
      by brood;
  run;
  data _null_;
      set test;
      by brood;
      if first.brood then do;
        brood_count+1;
        brood = left(put(brood_count,2.));
        call symput('mbrood'||brood,trim(left(brood)));
        call symput('mtotal',brood);
/*
  Alternative with symputx
        call symputx('mbrood'||brood, brood);
        call symputx('mtotal',brood);
*/
      end;
  run;

%do brood = 1 %to &mtotal;
   proc sgplot data=test;
      where brood=&&mbrood&brood;
      reg x=conc y=nyoung / degree=2;

      title "Plot: # Young vs. Nitrofen Conc.";
      title2 "[brood &&mbrood&brood]";

      %put 'brood' = &brood;
      %put '&&mbrood&brood' = &&mbrood&brood;
  run;
%end;

  proc sgpanel data=test;
      title "SGPANEL alternative display [avoids macros & looping]";
      panelby brood / columns=3;
      reg x=conc y=nyoung / degree=2;
  run;
%mend;

*ods rtf file="&Folder\&subFolder\ch5-fig5.13.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

ods graphics on /  imagename="Ch04Fig2-5"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;  


%threeregs()
quit;
ODS listing close;





/*********************************************************************/


/* Program 5.10:  Macro for buidling training / test data sets
  based on Program 4.17 Selecting a subset of a data set to train a model  */
* select 75%/25% of the observations for a training/test set;
* using RETAIN allows control of exactly how many observations
        are assigned to training and test data sets;
data train_test;
  set SASHELP.CARS;        * <--------  data set could be specified;
  call streaminit(7525);   * <--------  Seed could be specified;
  retain ntest ntrain 0;
  pick_test = RAND("uniform");
  if (pick_test < 0.25 and ntest < 107) then do;   
                           * <---- fraction could be set, 107 = n*fraction;
	  ntest = ntest + 1;
	  dsn= "test ";
  end;
  else if (ntrain < 321) then do;                 * <---- 321 = n*(1-fraction);
	  ntrain = ntrain + 1;
	  dsn = "train";
  end;
run;

* define new variable to be Y for the training data but
  missing for the test data - produces prediction for both
  data sets - also construct the quadratic and cubic terms;
data reg_train;       * <----- provide a name for the output data set;   
  set train_test;
  obs_no = _N_;       * <----- useful to have for merging diff model fits;
  if dsn="train" then Y_MPG_Highway = MPG_Highway;
                      * <--- specify name of the response variable;
  else Y_MPG_Highway = .; 
run;

* debugging code to check variable and data set construction;
proc print data=reg_train (obs=4);                * <------ print out if want to debug;
run;

proc freq data=reg_train;
  table dsn;
run;

/*********************************************************************/

/* Program 5.11:  Macro for buidling training / test data sets - macro variables set */

* start with macro variables that replace hard coded values;
%let dsn = SASHELP.CARS;
%let seed = 7525;
%let test_frac = 0.25;
%let nobs = 428;  * number of observations in the CARS data set - need to calculate in future;
%let y_var = MPG_HIGHWAY;
%let new_y_var = Y_&y_var;  
%put y_var new_y_var;
%let outdsn = reg_train;

%put _USER_;

* need to calculate the size of the training and test data sets;
data _NULL_;
     ntest_size = &nobs * &test_frac;
     ntrain_size = &nobs - ntest_size;
     put ntrain_size ntest_size;
     call symput('Mtrain_n', ntrain_size);
     call symput('Mtest_n',  ntest_size);
run;


data train_test;
  set &dsn;        * <--------  &dsn now used ;
  call streaminit(&seed);   * <--------  &seed now specified;
  retain ntest ntrain 0;
  pick_test = RAND("uniform");
  if (pick_test < &test_frac and ntest < &Mtest_n) then do;   * <---- &fraction could be set, 107 = n*fraction;
	  ntest = ntest + 1;
	  dsn= "test ";
  end;
  else if (ntrain < &Mtrain_n) then do;                  * <---- 321 = n*(1-fraction) = n - n_test;
	  ntrain = ntrain + 1;
	  dsn = "train";
  end;
run;

* define new variable to be Y for the training data but
  missing for the test data - produces prediction for both
  data sets - also construct the quadratic and cubic terms;
data &outdsn;
  set train_test;
  obs_no = _N_;                                    * <----- useful to have for merging diff model fits;
  if dsn="train" then &new_y_var = &y_var;   
  else &new_y_var = .; 
run;

* debugging code to check variable and data set construction;
proc print data=&outdsn (obs=4);                * <------ print out if want to debug;
run;

proc freq data=&outdsn;
  table dsn;
run;

options nomlogic;
/*********************************************************************/

/* Program 5.12:  Calculating number of observations in a SAS data set  */
* instead of hard coding value - need to calculate the # observations in the data set;

/*
  macro modified from SAS Help documentation for %SYSFUNC
*/

%macro nobs_in_dsn(dsn);
/* macro modified from SAS Help documentation for %SYSFUNC
   Example 5: Determining the Number of Variables and Observations in a Data Set
   functions employed:
     %sysfunc:  applies function to macro
     open:      opens a data set and returns a unique identifier
                identifier = 0 if data set does not exist
     attrn:     return value of numeric attribute for a SAS data set
                required argument - data set id that OPEN fcn returns (SAS help)
     close:     close a data set after used

*/
  %global dset nobs;
  %let dset = &dsn;
  %let dsid = %sysfunc(open(&dset));

  %if (&dsid=1) %then %do;
     %let nobs = %sysfunc(attrn(&dsid,NOBS));
     %let rc = %sysfunc(close(&dsid));
     %put Dataset &dsn has &nobs observations;
     %put dsid = &dsid;
  %end;

  %else %put &dsn does not exist.  Enter a valid data set name.;
%mend;

%nobs_in_dsn(SASHELP.CARS)
%nobs_in_dsn(NoSuchDataSet)


/*********************************************************************/

/* Program 5.15:  Macro for buidling training / test data sets - macro variables set */

%macro train_test_gen(dsn, seed, test_frac, y_var, debug, outdsn);
%* INPUT:
       dsn = input data set
       seed = starting seed for random number generator
       test_frac = fraction of dsn to be assigned to TEST sample
                1-test_frac assigned to TRAINING sample
       y_var = name of variable in dsn that will be used in later modeling
       debug = produce output for debugging checks
   OUTPUT:
       outdsn = output dataset with new variable
       Y_(y_var) = value of the (y_var) for training data and . (missing) if test data
       obs_no = observation number (useful for merging different fits)

   Note:  code generalized after testing
;

%* need to define new Y variables;
%let new_y_var = Y_&y_var;  


%* part of macro nobs_in_dsn() needed to generate macro variable
   with # of observations in the data set;
%global dset nobs;
%let dset = &dsn;
%let dsid = %sysfunc(open(&dset));

%* check to make sure dataset exists;
%if (&dsid = 0) %then %put Invalid data set name -> &dsn <- provided;

%else %do;  * <<<<<<<<<<<<<<<<< data set exists;

    %let nobs = %sysfunc(attrn(&dsid,NOBS)); *nobs in data set;

    * need to calculate the size of the training and test data sets;
    data _NULL_;
         ntest_size = &nobs * &test_frac;
         ntrain_size = &nobs - ntest_size;
         call symput('Mtrain_n', ntrain_size);
         call symput('Mtest_n',  ntest_size);
    run;
    
    data train_test;
      set &dsn;        
      call streaminit(&seed);
      retain ntest ntrain 0;
      pick_test = RAND("uniform");

      if (pick_test <= &test_frac) then do; 
          if (ntest < &Mtest_n) then do;  
            ntest = ntest + 1;
            dsn= "test ";
	      end;
	      else do;  * test sample filled - put obs into training set;
	        ntrain = ntrain + 1;
            dsn = "train";  
          end;
      end;
      else do;
          if (ntrain < &Mtrain_n) then do;  
            ntrain = ntrain + 1;
            dsn = "train";
          end;
          else do;  * training sample filled - put obs into test set;
            ntest = ntest + 1;
            dsn= "test ";
          end;
      end;
    run;

    data &outdsn;
      set train_test;
      obs_no = _N_;           
      if dsn="train" then &new_y_var = &y_var; 
      else &new_y_var = .; 
    run;

    * debugging code to check variable and data set construction;
    %if (&debug=TRUE) %then %do;
	  %put _USER_;   * write out user defined macro variables;
      proc print data=&outdsn (obs=4);
      run;

      proc freq data=&outdsn;
        table dsn;
      run;
   %end;

   %let rc = %sysfunc(close(&dsid));   * close the data set;

%end;   * <<<<<<<<  if data set found ;


%mend;  *  of macro train_test_gen ;

/* Now, run the macro with a few test cases */
ods rtf file="&Folder\&subFolder\ch5-fig5.15.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;
title "Testing train_test_gen macro";

* test the macro to generate test and training values;
%train_test_gen(dsn=SASHELP.CARS, seed=7525, test_frac=0.25, 
                y_var=MPG_HIGHWAY, debug=FALSE, outdsn=CarTrainTest)

* look at a different data set;
%train_test_gen(dsn=SASHELP.COMET, seed=8675309, test_frac=0.30, 
                y_var=LENGTH, debug=TRUE, outdsn=CometTrainTest)

* change the test sample fraction;
%train_test_gen(dsn=SASHELP.COMET, seed=9035768, test_frac=.10,
                y_var=LENGTH, debug=TRUE, outdsn=C2)

* how about a data set that doesn't exist?;
%train_test_gen(dsn=SASHELP.CUPID, seed=8675309, test_frac=0.30, 
                y_var=LENGTH, debug=TRUE, outdsn=CometTrainTest)

title;
ods rtf close;

/*******************************************************************/

/*
  Program 5.16 Constructing three data sets for later use
  construct 3 example data sets with time and temperature data
*/
data aug03;
  call streaminit(9035768);
  mydate='AUG03';
  do time=1 to 24;
    temp = 74 - abs(time-16) + RAND('Normal',0,0.5);
    output;
  end;
run;

data aug05;
  mydate='AUG05';
  do time=1 to 24;
    temp = 78 - abs(time-16) + RAND('Normal',0,0.5);
    output;
  end;
run;

data aug17;
  mydate='AUG17';
  do time=1 to 24;
    temp = 90 - abs(time-16) + RAND('Normal',0,0.5);
    output;
  end; 
run;

/* DEBUGGING BLOCK TO CHECK DATA SET CONSTRUCTION */
data tester; set aug03 aug05 aug17;
proc print data=tester;
  id time;
run;

ods rtf file="&Folder\&subFolder\ch5-fig5.15.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc sgplot data=tester;
  series x=time y=temp / group=mydate;
  symbol interpol=join;
run;
ods rtf close;
*/

/*********************************************************************/

/*
Program 5.17  Reading data set names and constructing macro variables
  create macro variable names corresponding to each data set  */
* read data sets and create macro variable with name of each;

data _null_;
* read data sets and create macro variable with name of each;
  retain counter 0;
  input times $ @@;
  counter = counter + 1;
  put times counter;
* create a macro variable with each data set name;
* create macro variable name with total number of DSNs;
  call symputx('dsn' || LEFT(counter), times);
  call symputx('num_data_sets', counter);
  datalines;
aug03 aug05 aug17
;
run;
%put _user_;

/*********************************************************************/

/* Program 5.18  Defining and running a macro program   */
/*
  construct macro to concatenate data sets
*/

%macro concatenator(combine);
  data &combine;
    set
      %do n_dsn = 1 %to &num_data_sets;
    &&dsn&n_dsn
    %end;
;
  run;
%mend concatenator;

/*
  concatenate the three data sets and print results
*/
options mprint mlogic;
%concatenator(combine=all3)

title;
*ods rtf file="&Folder\&subFolder\ch5-fig5.15-16.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=all3;
run;


ods graphics on /  imagename="Ch05Fig6"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600 style=journal;  
title;
proc sgplot data=all3;
  series x=time y=temp / group = mydate lineattrs=(color=gray);
  yaxis label="Temperature (deg. F)"
        values=(55 to 95 by 10);
  xaxis label="Time (h) since midnight"
        values=(0 to 24 by 6);

run;
ods listing close;

* save as RTF file for other use ............................; 
ods rtf file="&Folder\&subFolder\ch5-fig6.rtf"
        image_dpi=300  
        style=journal;
proc sgplot data=all3;
  series x=time y=temp / group = mydate lineattrs=(color=gray);
  yaxis label="Temperature (deg. F)"
        values=(55 to 95 by 10);
  xaxis label="Time (h) since midnight"
        values=(0 to 24 by 6);
run;
ods rtf close;

/*******************************************************************/

/*  HOMEWORK --------------------------------------------------------------------*/
/*  Problem:  Explore whether t-test really is robust to violations of the equal variance assumption

    Strategy: See if the t-test operates at the nominal Type I error rate when the unequal variance assumption is violated
*/ 
 
data twogroup;

array x{10} x1-x10;
array y{10} y1-y10;

call streaminit(11223344);

do sim = 1 to 10000;
  
/* generate samples X~N(0,1)  Y~N(0,4) - normal case */
  do sample = 1 to 10;
    x{sample} = RAND('normal',0,1);
    y{sample} = RAND('normal',0,2);
  end;

/* calculate the t-statistic                        */
  xbar = mean(of x1-x10);
  ybar = mean(of y1-y10);

  xvar = var(of x1-x10);
  yvar = var(of y1-y10);

  s2p = (9*xvar + 9*yvar)/18;

  tstat = (xbar-ybar)/sqrt(s2p*(2/10));
  Pvalue = 2*(1-probt(abs(tstat),18));
  Reject05 = (Pvalue <= 0.05);

  keep xbar ybar xvar yvar s2p tstat Pvalue Reject05;
  output;
end;   * end of the simulation loop;
run;

/*
proc print;
run;
*/

proc freq; 
  table Reject05;
run;

/**********************************************************************/
