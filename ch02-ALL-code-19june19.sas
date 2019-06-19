/*
   CHAPTER 02:  All Ch 02 SAS Code combined into single file ===========================

   Revised:  19 June 2019

*/

%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder=chapter02;

/* template code that defines a style for output produced ... */
%include "&Folder.\book_template_and_options.sas";   * page options and CustomSaphire specification;

/* need to use this so graphics embedded in ODS RTF are PNG and not WMF */ 
ods graphics on / imagefmt=png;

/*
Program 2.0 R
*/

DATA ZZTop1;
  length Member $13;
  input Member & Instrument $ @@;
  datalines;
Frank Beard    drums    Billy Gibbons   guitar  Dusty Hill     bass
;

proc print data=ZZTop1;
run;

Data ZZTop2;
  input first_name $ family_name $ instrument $;
  Member = first_name || family_name; * concatenates two character variables;
  datalines;
Frank 
Beard
drums
Billy
Gibbons
guitar
Dusty
Hill
bass
;

proc print data=ZZTop2;
run;

Data ZZTop3;
  input first_name $ #2 family_name $ #3 instrument $;
  Member = first_name || family_name; * concatenates two character variables;
  datalines;
Frank     You might only want to read part  
Beard         of an input line. The #d specifies
drums         line number to find a variable value.
Billy     Is he a William or a Billy?
Gibbons
guitar    other instruments too?
Dusty     Nickname or birth?
Hill
bass
;

proc print data=ZZTop3;
run;


proc print data=import_test;
run;

/*
Program 2.1 - Reading free-format data into SAS using a DATALINES statement

*/
data SMSA_subset; 
input city $ JanTemp JulyTemp RelHum Rain Mortality  Education  PopDensity pct_NonWhite pct_WC pop pop_per_house income HCPot NOxPot S02Pot NOx;
datalines;
Akron, OH	27	71	59	36	921.87	11.4	3243	8.8	42.6	660328	3.34	29560	21	15	59	15
Albany-Schenectady-Troy, NY		23	72	57	35	997.87	11.0	4281	3.5	50.7	835880	3.14	31458	8	10	39	10
Allentown, Bethlehem, PA-NJ		29	74	54	44		962.35	9.8	4260	0.8	39.4	635481	3.21	31856	6 6	33 6
Atlanta, GA	45	79	56	47	982.29	11.1	3125	27.1	50.2	2138231	3.41	32452	18	8	24	8
Baltimore, MD	35	77	55	43	1071.29	9.6	6441	24.4	43.7 2199531	3.44 32368 43 38 206 38
;
run;

ods rtf file="&Folder\&subFolder\ch2-fig2.1.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=SMSA_subset;
  var city JanTemp JulyTemp RelHum NOxPot S02Pot NOx;
run;
ods rtf close;

/* ------------------------------------------------------------------------------*/
 
* PROGRAM 2.2 
  Reading the SMSA data with a length declaration and code to allow embedded blanks in the value of a character value
; 

data SMSA_subset;
   length city $ 27; 
   input city & JanTemp JulyTemp RelHum Rain Mortality Education PopDensity
         pct_NonWhite pct_WC pop pop_per_house income HCPot NOxPot S02Pot NOx;
datalines;
Akron, OH	27	71	59	36	921.87	11.4	3243	8.8	42.6	660328	3.34	29560	21	15	59	15
Albany-Schenectady-Troy, NY		23	72	57	35	997.87	11.0	4281	3.5	50.7	835880	3.14	31458	8	10	39	10
Allentown, Bethlehem, PA-NJ		29	74	54	44		962.35	9.8	4260	0.8	39.4	635481	3.21	31856	6 6	33 6
Atlanta, GA	45	79	56	47	982.29	11.1	3125	27.1	50.2	2138231	3.41	32452	18	8	24	8
Baltimore, MD	35	77	55	43	1071.29	9.6	6441	24.4	43.7 2199531	3.44 32368 43 38 206 38
;
run;

ods rtf file="&Folder\&subFolder\ch2-fig2.2.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=SMSA_subset;
  var city JanTemp JulyTemp RelHum NOxPot S02Pot NOx;
run;

ods rtf close;

/* ------------------------------------------------------------------------------*/
* Program 2.3 - Reading an external text file into a SAS data set using an INFILE 
                     statement;

/*
Notes:
1) Two spaces separate each entry in the input data file.  A global 
   replace of tabs with two spaces was performed before saving the text file.
2) The first line contains the names of the variables, and the data begins on 
   the 2nd line of the file.
3) Fort Worth had missing values for POP and INCOME and "." were entered
   in the data file.
4) Increased LENGTH to 39 to accommodate GREENSBORO-WINSTON-SALEM...
*/
data SMSA_from_txt;
   infile "&Folder\&subFolder\SMSA-DASL-2space-sep.txt" firstobs=2;
   length city $ 39; 
   input city & JanTemp	JulyTemp	RelHum	Rain	Mortality	Education	PopDensity
         pct_NonWhite pct_WC pop pop_per_house income HCPot NOxPot S02Pot NOx;
run;

ods rtf bodytitle file="&Folder\&subFolder\ch2-fig2.3.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=SMSA_from_txt;
  var city JanTemp JulyTemp RelHum NOxPot S02Pot NOx;
run;

ods rtf close;

/* ------------------------------------------------------------------------------*/
/*
Program 2.4  Reading an external text file into a SAS data set where variables are found in specific columns
  statement provided by CSB site to read data ... 
         infile “ch2-dat.txt" firstobs=16 expandtabs missover pad;
  - not all input options needed
;
*/

data nitro_tox; 
   infile "&Folder\&subFolder\ch2-dat.txt" 
           firstobs=16 expandtabs missover pad;  
   input @9 animal 2. @17 conc 3. @25 brood1 2. @33 brood2 2. @41 
           brood3 2. @49 total 2.;
run;

/* ref: http://www.cpc.unc.edu/research/tools/data_analysis/sastopics/obs */
proc print data=nitro_tox (obs=10);  * equivalent to head(dsn);
run;

proc print data=nitro_tox (firstobs=40 obs=50);  * equivalent to tail(dsn);
run;

proc print data=nitro_tox (firstobs=25 obs=35);  * print rows 25-35 of dsn;
run;

/* ------------------------------------------------------------------------------*/
*  Program 2.5  Reading input data from files using commas as delimiters between 
                       variable values;

data SMSA_from_CSV;
   infile "&Folder\&subFolder\DASL-SMSA-commasep.csv" firstobs=2 dsd;
   length city $ 39; 
   input city &	JanTemp JulyTemp  RelHum  Rain  Mortality Education PopDensity 
         pct_NonWhite pct_WC pop pop_per_house income HCPot NOxPot S02Pot NOx;
run;

proc import OUT= SMSA_from_CSV2
            DATAFILE= "&Folder\&subFolder\DASL-SMSA-commasep.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
run;

ods rtf bodytitle file="&Folder\&subFolder\ch2-fig2.4.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=SMSA_from_CSV (firstobs=17 obs=25);
  var city JanTemp JulyTemp RelHum pop pop_per_house income;
run;

proc print data=SMSA_from_CSV2 (firstobs=17 obs=25);
  var city JanTemp JulyTemp RelHum pop pop_house income;
run;

ods rtf close;


proc contents data=SMSA_from_CSV2;
run;

/* ------------------------------------------------------------------------------*/

/* ------------------------- via EXCEL engine with LIBNAME 
   BONUS PROGRAM [only works if Excel driver available - 
    if not, will throw error: ERROR: Connect: Class not registered]
*/
options nodate;
title ;

libname spreads excel "&Folder/&subFolder/DASL-SMSA.xls" header=yes;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.12.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
/* list the contents of the spreadsheet that was read */
proc contents data=spreads._all_ varnum;
run;

/* set contents of the 1st worksheet to SAS data set */
data DASL_from_Libname_Excel_engine; 
  set spreads.'sheet1$'n;
run;

proc print data=DASL_from_Libname_Excel_engine;
run;
ods rtf close;


/* ------------------------------------------------------------------------------*/
* Program 2.6  Defining a library and referencing a data set within that library
                READING permanent SAS data set;

libname myfiles "&Folder/&subFolder";

ods rtf file="&Folder/&subFolder/ch2-fig2.5.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc means data=myfiles.nitrofen maxdec=1 min q1 median q3 max;
  class conc;
  var total brood1 brood2 brood3;
run;

ods rtf close;

/* ------------------------------------------------------------------------------*/
*  Program 2.7  Example code that generates a temporary data set
             (GENERATING a data set by simulation);

data lin_reg_data; 
  call streaminit(32123);
  do x = 0 to 10 by 1; 
     y = 3 + 2*x + 2*RAND('NORMAL'); 
    output; 
  end; 
run;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.xx.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc sgplot data=lin_reg_data;   * or equivalently, data=work.lin_reg_data; 
   scatter y=y x=x; 
run; 

proc reg data=lin_reg_data; 
   model y=x; 
run;
quit;

ods rtf close;

/* ------------------------------------------------------------------------------*/
* Program 2.8  Code with a few formatting options;

data d1;
  input x y @@;
  format y dollar6.2;
  datalines;
1 2 43 34 555 654 7777 8765 12345 12345 654321 654321
1.234 1.234 12.34 12.34 654.321 654.321 123.45 123.45 
1234.56 1234.56 1211100908.0706 1211100908.0706 
;
run;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.6.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=d1;
   title "Y formatted in DATA";
run;

proc print data=d1;
  title2 "X now formatted in the 2nd PROC PRINT"; 
  format x dollar12.2;
run;

proc print data=d1;
  title2;
run;
ods rtf close;

/* ------------------------------------------------------------------------------*/
* Program 2.9  Reading character and numeric variables with implicit and explicit formats;


%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data mrexample;
* Lunneborg (1994) - body weight brain example;
  input species $ bodywt brainwt @@;
datalines;
beaver        1.35   8.1     cow       465.   423.   wolf        36.33  119.5  
goat          27.66  115.    guipig    1.04   5.5    diplodocus  11700. 50.  
asielephant   2547.  4603.   donkey    187.1  419.   horse       521.   655.  
potarmonkey   10.    115.    cat       3.30   25.6   giraffe     529.   680.  
gorilla       207.   406.    human     62.    1320.  afrelephant 6654.  5712. 
triceratops   9400.  70.     rhemonkey 6.8    179.   kangaroo    35.    56.  
hamster       0.12   1.      mouse     0.023  0.4    rabbit      2.5    12.1  
sheep         55.50  175.    jaguar    100.   157.   chimp       52.16  440. 
brachiosaurus 87000. 154.5   rat       0.28   1.9    mole        0.122  3.  
pig           192.0  180
beaver        1.35   8.1     cow       465.   423.   wolf        36.33  119.5 
goat          27.66  115.    guipig    1.04   5.5    diplodocus  11700. 50. 
asielephant   2547.  4603.   donkey    187.1  419.   horse       521.   655. 
potarmonkey   10.    115.    cat       3.30   25.6   giraffe     529.   680. 
gorilla       207.   406.    human     62.    1320.  afrelephant 6654.  5712. 
triceratops   9400.  70.     rhemonkey 6.8    179.   kangaroo    35.    56. 
hamster       0.12   1.      mouse     0.023  0.4    
rabbit        2.5    12.1 
sheep         55.50  175.    jaguar    100.   157.   chimp       52.16  440. 
brachiosaurus 87000. 154.5   rat       0.28   1.9    
mole          0.122  3.      pig       192.0  180
;
run;

data mrexample2;
  length species $ 15;
  input species bodywt brainwt @@;
  datalines;
beaver        1.35   8.1     cow       465.   423.   wolf        36.33  119.5  
goat          27.66  115.    guipig    1.04   5.5    diplodocus  11700. 50.  
asielephant   2547.  4603.   donkey    187.1  419.   horse       521.   655.  
potarmonkey   10.    115.    cat       3.30   25.6   giraffe     529.   680.  
gorilla       207.   406.    human     62.     1320. afrelephant 6654.  5712. 
triceratops   9400.  70.     rhemonkey 6.8    179.   kangaroo    35.    56.  
hamster       0.12   1.      mouse     0.023  0.4    rabbit      2.5    12.1  
sheep         55.50  175.    jaguar    100.   157.   chimp       52.16  440. 
brachiosaurus 87000. 154.5   rat       0.28   1.9    mole        0.122  3.  
pig           192.0  180
beaver        1.35   8.1     cow       465.   423.   wolf        36.33  119.5 
goat          27.66  115.    guipig    1.04   5.5    diplodocus  11700. 50. 
asielephant   2547.  4603.   donkey    187.1  419.   horse       521.   655. 
potarmonkey   10.    115.    cat       3.30   25.6   giraffe     529.   680. 
gorilla       207.   406.    human     62.    1320.  afrelephant 6654.  5712. 
triceratops   9400.  70.     rhemonkey 6.8    179.   kangaroo    35.    56. 
hamster       0.12   1.      mouse     0.023 0.4    rabbit      2.5    12.1 
sheep         55.50  175.    jaguar    100.  157.   chimp       52.16  440. 
brachiosaurus 87000. 154.5   rat       0.28  1.9    mole        0.122  3. 
pig           192.0  180
;
run;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.7.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=mrexample;
  title "default informats"; 
  id species;
run;

proc print data=mrexample2;
  title "specified informat for species";
  id species;
run;

ods rtf close;

/* ------------------------------------------------------------------------------*/
* PROGRAM 2.10  DATA step displaying numeric formats;

data numeric_format_show;
  test_num = 1277695.384;
  put '-------------------------------';
  put 'COMMA7. / COMMA11.2 / COMMA12.2 / COMMA12.3 / COMMA13.3';
  put test_num COMMA7.;
  put test_num COMMA11.2;
  put test_num COMMA12.2;
  put test_num COMMA12.3;
  put test_num COMMA13.3;
  put '-------------------------------';
  put 'E7.';
  put test_num E7.;
  put '-------------------------------';
  put '6. / 7. / 10.1 / 11.3';
  put test_num 6.;
  put test_num 7.;
  put test_num 10.1;
  put test_num 11.3;
  put '-------------------------------';
  put 'DOLLAR9. / DOLLAR12.2';
  put test_num DOLLAR9.;
  put test_num DOLLAR12.2;
  put '-------------------------------';
  put 'BEST6. / BEST9. / BEST12.';
  put test_num BEST6.;
  put test_num BEST9.;
  put test_num BEST12.;
run;

/* ------------------------------------------------------------------------------*/
* Program 2.11  Formats for reading common date values into SAS;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data tester;
  input  @1 indate1 date7.  @9  indate2 date9. 
        @19 indate3 mmddyy. @26 indate4 ddmmyy8.;
;
datalines;
30jun20 30jun2020 063020 30.06.20
;
run;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.9.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=tester;
run;
ods rtf close;


/* ------------------------------------------------------------------------------*/
* Program 2.12  Assigning date formats to numeric variables;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data tester2;
  input  @1 indate1 date7.  @9  indate2 date9. 
        @19 indate3 mmddyy. @26 indate4 ddmmyy8.;
  format _numeric_ date9.;
datalines;
30jun20 30jun2020 063020 30.06.20
;
run;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.10.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=tester2;
run;
ods rtf close;

/* ------------------------------------------------------------------------------*/
*Program 2.13  Various date formats;

data date_format_show;
  start = 0;
  put start date9.;
  today = 22096;  * days since Jan 1, 1960;
  put '-------------------------------';
  put 'DATE7. / DATE9.';
  put today date7.;
  put today date9.;
  put '-------------------------------';
  put 'DAY2. / DAY7.';
  put today day2.;
  put today day7.;
  put '-------------------------------';
  put 'EURDFDD8.';
  put today eurdfdd8.;
  put '-------------------------------';
  put 'MMDDYY8. / MMDDYY6.';
  put today mmddyy8.;
  put today mmddyy6.;
  put '-------------------------------';
  put 'WEEKDATE15. / WEEKDATE29.';
  put today weekdate15.;
  put today weekdate29.;
  put '-------------------------------';
  put 'WORDDATE12. / WORDDATE18.';
  put today worddate12.;
  put today worddate18.;
run;


/* ------------------------------------------------------------------------------*/
* Program 2.14  Time and date formats;

Data _NULL_;
 time_date_origin = 0;
 nowtime = '09:00't;
 today = '30jun2020'd; 
 put time_date_origin @20 time_date_origin datetime13.;
 put nowtime @20 nowtime time9.; 
 put today @20 today date9.;
run;


/* ------------------------------------------------------------------------------*/
* Program 2.15  Reading date, time, and currency data into SAS;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data test;
  input @1 date MMDDYY10. @21 time TIME8.  @31 money DOLLAR10.2;
  datalines;
01/01/1960          01:00:00  $100.22
09/29/2003          09:49:59  $12693.79
;
run;


ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.13.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=test;
title "print of date and time w/o formatting – internal SAS representation";
  var date time money; 
run;

proc print data=test;
title "print of date and time w/ formatting";
  var date time money;
  format date MMDDYY10. time TIME8. money DOLLAR10.2;
run;
ODS RTF CLOSE;

/* ------------------------------------------------------------------------------*/
*  Program 2.16  User-defined format using PROC FORMAT;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

title;
proc format;
  value totfmt     0='none'
              1-HIGH='some';
run;

data nitro_tox;
   infile "&Folder\&subFolder\ch2-dat.txt"
         firstobs=16 expandtabs missover pad ;
*   infile 'C:\Users\baileraj\Documents\book-SPiS-2nd-ed\chapter02\ch2-dat.txt'
         firstobs=16 expandtabs missover pad ;
   input @9 animal 2.  @17 conc 3. @25 brood1 2.
         @33 brood2 2. @41 brood3 2. @49 total 2.;

   cbrood3 = brood3;
   format cbrood3 totfmt.;
   label animal = 'animal ID';
   label   conc = 'Nitrofen conc.';
   label brood1 = '# young in first brood';
   label brood2 = '# young in 2nd brood';
   label brood3 = '# young in 3rd brood';
   label  total = 'total young produced in three broods';
run;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.14-and-15.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=nitro_tox;
  where conc=235;
run;

proc print data=nitro_tox label;
  where conc=235;
run;

proc means data=nitro_tox maxdec=1;
  var brood1 brood2 brood3 total;
  class conc;
 run;

ods rtf close;

/* ------------------------------------------------------------------------------*/
* Program 2.17 Constructing a user-defined format for a numeric variable;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data toyexample;
  input literacy @@;
  literacy_too = literacy;
  datalines;
-99 25.55 53 53.5 73.7 83  99.9 107 .
;
run;

proc format;
  value literacyfmt       
                        0-53='First quartile'
                        53<-76='Second quartile'
                        76<-90 ='Third quartile'
                        90<-100='Fourth quartile'
                        . = 'Missing'
                        OTHER = 'Invalid';
run;

data toyexample2; set toyexample;
  format literacy literacyfmt.;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.16-and-17.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=toyexample2;
run; 

proc means data=toyexample2;
  var literacy literacy_too;
run;
ods rtf close;

/* ------------------------------------------------------------------------------*/

* Program 2.18  Saving user-defined formats for later use;
/* ------------------------------------------------
   BMI example - 20 to 29 y.o. females

   BMI categories:  http://apps.who.int/bmi/index.jsp?introPage=intro_3.html

   REF:  http://www.cdc.gov/nchs/data/nhsr/nhsr010.pdf
         mean = 26.5,  sd = sqrt(705) * .36 { Table 14 }
   ------------------------------------------------ */

%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder=chapter02;

/* From PROC FORMAT documentation ...
Permanently storing informats and formats:
  If you want to use a format or informat that is created in one SAS job or session in a 
  subsequent job or session, then you must permanently store the format or informat in a 
  SAS catalog.

Need to use the LIBRARY= option in the PROC FORMAT statement. 

LIBRARY=libref<.catalog> 
  specifies a catalog to contain informats or formats that you are creating in the current 
  PROC FORMAT step. The procedure stores these informats and formats in the catalog that you 
  specify so that you can use them in subsequent SAS sessions or jobs.
*/

libname SAVEIT "&Folder/&subFolder/";

proc format lib=SAVEIT;
  value bmifmt low-< 18.50 = " Underweight"
               18.50 -< 25 = "Normal Range"
			   25 -< 30 = "Overweight"
			   30 - high = "Obese";
run;

Data SimBMI;
  call streaminit(1807);
  mean_BMI = 26.5;        * 20-29 y.o. female, all race/ethinicity;
  sd_BMI = sqrt(705)*.36;

  do iBMI = 1 to 2000; 
     BMI = RAND('Normal',mean_BMI,sd_BMI); 

     IF BMI < 18.50   THEN BodyClassif = " Underweight";
     ELSE IF BMI < 25 THEN BodyClassif = "Normal range";
     ELSE IF BMI < 30 THEN BodyClassif = "  Overweight";
     ELSE BodyClassif = "Obese";

	 output;
  end;
  format BMI bmifmt.;
run;

proc contents data=SimBMI;
run;

proc freq data=SimBMI;
  table BMI BodyClassif;
run;

/* =============================================================================== */
/* Program 2.19 Using a saved format in a later program  */
/* suppose we start a new SAS session but want to use previously assigned formats? */
/* so, exit SAS and then launch it again and submit the following code to
   illustrate using a saved format */

%let Folder=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder=chapter02;

libname SAVEIT "&Folder/&subFolder/";
options fmtsearch = ( SAVEIT ); * will search WORK, LIBRARY and MYFMTLIB for fmts;
data BMItest;
  input BMI @@;
datalines;
15 18 19 24 25 29 30 35
;

proc print data=BMItest;
  var BMI;
run;

proc print data=BMItest;
  var BMI;
  format BMI bmifmt.;
run;

/* ------------------------------------------------------------------------------*/

* Program 2.20  Data transformations before fitting a polynomial regression model;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data nitrofen;
 infile "&Folder\&subFolder\ch2-dat.txt" firstobs=16 expandtabs 
            missover pad;
   input  @17 conc 3.  @49 total 2.;
   sqrt_total = sqrt(total);  * transformed response variable;
   cconc = conc - 157;        * construct mean-centered concentration;
   cconc2 = cconc*cconc;      * quadratic term;
run;

ods graphics on /  imagename="Ch02Fig1"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

proc reg data=nitrofen;
  model sqrt_total = cconc cconc2;  * fit the polynomial reg. model;
quit;

ods listing close;


/* ------------------------------------------------------------------------------*/
* Figure 2.21  Defining indicator variables for different conditions to fit an ANOVA model;


%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data meat;
  input condition $ logcount @@;
  is_Plastic = (condition= "Plastic");
  is_Vacuum = (condition= "Vacuum");
  is_Mixed = (condition= "Mixed");
  is_CO2 = (condition= "CO2");
  datalines;
Plastic	7.66	 Plastic	6.98	 Plastic	7.80
Vacuum		5.26	 Vacuum	5.44	 Vacuum	5.80
Mixed		7.41	 Mixed		7.33	 Mixed		7.04
CO2		3.51	 CO2		2.91	 CO2		3.66
;
run;

title "bacteria growth under 4 packaging conditions";

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.19.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=meat;
title "Print to check indicator variable construction";
run;

proc means data=meat;
title "Summary statistics for different packaging conditions";
  class condition;
  var logcount;
run;

proc reg data=meat;
title "Regression with indicator variables: alt. to one-way anova model";
title2 "Reference Cell Coding";
  model logcount = is_Plastic is_Vacuum is_Mixed;
quit;

proc reg data=meat;
title "Regression with indicator variables: alt. to one-way anova model";
title2 "Cell Means Coding";
  model logcount = is_Plastic is_Vacuum is_Mixed is_CO2 / noint;
quit;

proc glm data=meat;
title "One-way ANOVA model";
  class condition;
  model logcount = condition / solution;
  means condition;
quit;

ods rtf close;


/* ------------------------------------------------------------------------------*/
* Program 2.22  Defining indicator variables for literacy categories;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

data toyexample;
  input literacy @@;

/* method 1-2:
   Boolean trick to assign category labels 1-4;
   If a logical comparison is TRUE (FALSE), it evaluates to 1 (0)
   e.g. if literacy=54, (53<literacy<=76)=TRUE while
        (0<literacy<=53)=(76<literacy<=90)=(90<literacy<=100)=FALSE
        And so cat_literacy = 1*0 + 2*1 + 3*0 + 4*0 = 2
*/

  cat_literacy1 = 1*(0<literacy<=53) + 2*(53<literacy<=76)
              + 3*(76<literacy<=90) + 4*(90<literacy<=100);

  cat_literacy2 = 1*(literacy<=53) + 2*(53<literacy<=76)
              + 3*(76<literacy<=90) + 4*(90<literacy<=100);

/*
  method 3:
  First check for nonmissing and valid ranges before Boolean trick
*/

  if ( (literacy NE .) AND (0<=literacy<=100) ) then 
     cat_literacy3 = 1*(literacy<=53) + 2*(53<literacy<=76)
                 + 3*(76<literacy<=90) + 4*(90<literacy<=100);

/* method 4:
   IF-THEN-ELSE blocks to assign category labels
*/

 if ( (literacy EQ .) OR (100<literacy)
                      OR (literacy<0) ) then cat_literacy4=.;
 else if (literacy <=53) then cat_literacy4=1;
 else if (literacy <=76) then cat_literacy4=2;
 else if (literacy <=90) then cat_literacy4=3;
 else cat_literacy4=4;

datalines;
-99 25.55 73.7 83  99.9 107 .
;
run;

ods rtf bodytitle file="&Folder/&subFolder/ch2-fig2.20.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=toyexample;
run; 
ods rtf close;

/* ------------------------------------------------------------------------------*/
* Program 2.23  Echoing the values of variables in a data set using a PUT statement;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

libname myfiles "&Folder/&subFolder";

proc sort data=myfiles.nitrofen; 
     by conc;
run;

data _null_;
  set myfiles.nitrofen;
  by conc;
  if FIRST.CONC then do; * first observation in concentration group;
     put 50*'-';         * add separator line of 50 dashes + column headings;
     put "Animal" @10 "Conc" @20 "Total" @30 "First?" @40 "Last?";
  end;
  put animal @10 conc @20 total @30 FIRST.CONC @40 LAST.CONC;

*  put _all_;   /* useful to check values during input  */
run;


/* ------------------------------------------------------------------------------*/
* Program 2.24  Producing a formatted report with an annotated printout of the 
                      nitrofen data;
%let Folder = C:/Users/baileraj/Documents/book-SPiS-2nd-ed;
%let subFolder = chapter02;

libname myfiles "&Folder/&subFolder";

proc sort data=myfiles.nitrofen; 
     by conc;
run;

data _NULL_; 
  set myfiles.nitrofen; 
  by conc;
  file "&Folder/&subFolder/nitrofen-put.txt";
 
/* Write out header text information for the first observation in each conc*/
  if FIRST.conc then do;
    put 6*'+-----' '+';
    put 'Conc = ' conc  / 
        @1 'Brood 1'  @10 'Brood 2'  @20 'Brood 3' @30 'TOTAL' /
        @1 '-------'  @10 '-------'  @20 '-------' @30 '-----';
  end;

/* Write out the data for all records */
  put @5 brood1 3.  @14 brood2 3. @24 brood3 3. @32 total 3.;
run;

data _NULL_;     /* add last line to the output file */
  file "&Folder/&subFolder/nitrofen-put.txt" MOD;
  put 6*'+-----' '+' //
      'Data from C. dubia Nitrofen exposure data [Bailer & Oris 1993]';
run;

/* ------------------------------------------------------------------------------*/
* Program 2.25  Creating external data files containing the contents of a SAS data set;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

libname myfiles "&Folder/&subFolder";

/* create a TEXT file with the nitrofen data */
data _NULL_;  set myfiles.nitrofen;
  file  "&Folder/&subFolder/nitrofen-TEXT.txt";
  put @1 conc  @10 animal @15 brood1 @20 brood2 @25 brood3 @30 total;
run;

/* create a CSV file with the nitrofen data */
data _NULL_;  set myfiles.nitrofen;
  file  "&Folder/&subFolder/nitrofen-CSV.csv" dsd;
  put conc animal brood1 brood2 brood3 total;
run;

/* create a CSV file with the nitrofen data and a row with variable names */
data _NULL_;  * write variable names to first line of file;
  file  "&Folder/&subFolder/nitrofen-CSV2.csv" dsd;
  put "conc,animal,brood1,brood2,brood3,total";
run;

data _NULL_; set myfiles.nitrofen;  * add data values below var names;
  file  "&Folder/&subFolder/nitrofen-CSV2.csv" dsd MOD;
  put conc animal brood1 brood2 brood3 total;
run;


/* ------------------------------------------------------------------------------*/

*Program 2.26 - Alternatives for producing *.csv data files containing SAS data sets;

%let Folder = C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subFolder = chapter02;

libname myfiles "&Folder/&subFolder";

/*
  nitrofen = SAS data set in this library
*/

proc contents data=myfiles.nitrofen;
run;

/* Using ODS with CSV + PROC PRINT to produce *.csv file
   Thanks to Kathy Roggenkamp for suggesting this alternative!
*/
ods csv file="&Folder/&subFolder/nitrofen.csv";
proc print data=myfiles.nitrofen;
  var conc total;
  id animal;
  run;
ods csv close;

/*
  Using File > Export Data ... can be used to construct a
  *.csv file AND save the associated SAS PROC EXPORT code
  (see below)
*/
PROC EXPORT DATA= MYFILES.NITROFEN 
            OUTFILE= "&Folder/&subFolder/nitrofen2.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

ods graphics off;

/* ------------------------------------------------------------------------------*/
* Homework code;

proc contents data=sashelp.cars;
run;




/* ------------------------------------------------------------------------------*/
/* ------------------------------------------------------------------------------*/





