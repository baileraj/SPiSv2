/*
   CHAPTER 04:  ===========================

   Revised:  25 June 2019

*/

/* set up for directories ................................... */
%let dir=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subdir=chapter04;

/* template code that defines a style for output produced ... */
%include "&dir\book_template_and_options.sas";   * page options and CustomSaphire specification;

/* need to use this so graphics embedded in ODS RTF are PNG and not WMF */ 
ods graphics on / imagefmt=png;


/* Program 4.1  Combining observations from five separate 
                 concentration-specific data sets into a single analysis data set */

data conc_0;
  input total @@;
  conc = 0;  * define a variable containing the value of the nitrofen conc.;
  datalines;
27 32 34 33 36 34 33 30 24 31
;
run;

data conc_80;
  input total @@;
  conc = 80;  * define a variable containing the value of the nitrofen conc.;
  datalines;
33 33 35 33 36 26 27 31 32 29
;
run;

data conc_160;
  input total @@;
  conc = 160;  * define a variable containing the value of the nitrofen conc.;
  datalines;
29 29 23 27 30 31 30 26 29 29
;
run;

data conc_235;
  input total @@;
  conc = 235;  * define a variable containing the value of the nitrofen conc.;
  datalines;
23 21 7 12 27 16 13 15 21 17
;
run;

data conc_310;
  input total @@;
  conc = 310;  * define a variable containing the value of the nitrofen conc.;
  datalines;
6 6 7 0 15 5 6 4 6 5 
;
data set_all5;
  set conc_0 conc_80 conc_160 conc_235 conc_310;
run;

ods rtf file="&dir\&subdir\ch4-fig4.x1.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=set_all5;
  var conc total;
run;
ods rtf close;
/*******************************************************************/


/*  Program 4.2  Merge using DATA step programming    */

data SMSA_subset_weather;
  length city $ 27; 
  input city & JanTemp JulyTemp RelHum Rain;
datalines;
Akron, OH  27 71 59 36 
Albany-Schenectady-Troy, NY  23 72 57 35 
Baltimore, MD  35 77 55 43 
Allentown, Bethlehem, PA-NJ  29 74 54 44 
Atlanta, GA  45 79 56 47 
;
run;

data SMSA_subset_demog;
  length city $ 27; 
  input city & Mortality Education PopDensity 
        pct_NonWhite pct_WC pop pop_per_house income;
datalines;
Akron, OH  921.87 11.4 3243 8.8 42.6 660328 3.34 29560
Albany-Schenectady-Troy, NY  997.87 11.0 4281 3.5 50.7 835880 3.14 31458
Baltimore, MD  1071.29 9.6 6441 24.4 43.7 2199531 3.44 32368
Allentown, Bethlehem, PA-NJ  962.35 9.8 4260 0.8 39.4 635481 3.21 31856
Atlanta, GA  982.29 11.1 3125 27.1 50.2 2138231 3.41 32452
;
run;
data SMSA_subset_pollution;
  length city $ 27; 
  input city & HCPot NOxPot S02Pot NOx;
datalines;
Akron, OH  21 15 59 15
Albany-Schenectady-Troy, NY  8 10 39 10
Baltimore, MD  43 38 206 38
Allentown, Bethlehem, PA-NJ  6 6 33 6
Atlanta, GA  18 8 24 8
;
run;

proc sort data=SMSA_subset_weather;
     by city;
run;
proc sort data=SMSA_subset_demog;  
     by city;
run;
proc sort data=SMSA_subset_pollution;  
     by city;
run;

data all_subset;
  merge SMSA_subset_weather SMSA_subset_demog SMSA_subset_pollution;
  by city;
run;

ods rtf file="&dir\&subdir\ch4-fig4.x2.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=all_subset;
  var city JanTemp mortality NOx;
run;
ods rtf close;
/*******************************************************************/


/* Program 4.3  Merging with DATA steps—indicators that observations 
                 that are part of a particular data set (IN=) are defined */
options nodate nonumber;                                      *** comment 0;

data SMSA_subset_weather2;
   length city $ 27; 
   input city & JanTemp JulyTemp RelHum Rain;
datalines;
Akron, OH  27 71 59 36 
Baltimore, MD  35 77 55 43 
Allentown, Bethlehem, PA-NJ  29 74 54 44 
Atlanta, GA  45 79 56 47 
;
run;

data SMSA_subset_demog2;
   length city $ 27; 
   input city & Mortality Education PopDensity 
      pct_NonWhite pct_WC pop pop_per_house income;
datalines;
Akron, OH  921.87 11.4 3243 8.8 42.6 660328 3.34 29560
Albany-Schenectady-Troy, NY  997.87 11.0 4281 3.5 50.7 835880 3.14 31458
Baltimore, MD  1071.29 9.6 6441 24.4 43.7 2199531 3.44 32368
Allentown, Bethlehem, PA-NJ  962.35 9.8 4260 0.8 39.4 635481 3.21 31856
;
run;

proc sort data=SMSA_subset_weather2;                      *** comment 1;
  by city;
run;

proc sort data=SMSA_subset_demog2; 
  by city;
run;

data in_either;	 * city in either weather2 or demog2 data set;
  merge SMSA_subset_weather2 (in=in1)   
        SMSA_subset_demog2 (in=in2);                      *** comment 2;
  by city;
  weather2_in = in1;   * save indicator of presence in data set;
  demog2_in = in2;
run;

data in_both;   * city in both data sets;
  set in_either;                                          *** comment 3;
  if weather2_in=1 and demog2_in=1;                       *** comment 4;
run;
data in_weather;  * city in weather2 data set;
  set in_either;
  if weather2_in=1;
run;

data in_demog;  * city in demog2 data set;
  set in_either;
  if demog2_in=1;
run;

ods rtf file="&dir\&subdir\ch4-table4.x3.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;
                                                          *** comment 5;
proc print data=in_either;                                *** comment 6;
  title "city in EITHER weather OR demog data set OR BOTH data sets";
  var city weather2_in demog2_in JanTemp Rain Mortality income;
run;

proc print data=in_both;
  title "city in BOTH weather AND demog data sets";
  var city weather2_in demog2_in JanTemp Rain Mortality income;
run;

proc print data=in_weather;
  title "city in weather data set";
  var city weather2_in demog2_in JanTemp Rain Mortality income;
run;

proc print data=in_demog;
  title "city in demography data set";
  var city weather2_in demog2_in JanTemp Rain Mortality income;
run;

ods rtf close;
title;

/*******************************************************************/

/* Program 4.4  Running a simple queries on a SAS data set containing the highest 
                       nitrofen concentration data  */
data conc_310;
  input total @@;
  conc = 310;  * define a variable containing the value of the nitrofen conc.;
  datalines;
6 6 7 0 15 5 6 4 6 5 
;
run;

ods rtf file="&dir\&subdir\ch4-fig4.x4.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;
proc sql;
  select conc,total from conc_310;
  select total from conc_310;
  select * from conc_310 
     where total > 10;
quit;
ods rtf close;


/*******************************************************************/

/* Program 4.5  Concatenating data sets using UNION in PROC SQL  */ 
data conc_0;
  input total @@;
  conc = 0;  * define a variable containing the value of the nitrofen conc.;
  id=_n_;    * define an animal ID corresponding the observation number;
  datalines;
27 32 34 33 36 34 33 30 24 31
;
run;

data conc_80;
  input total @@;
  conc = 80; * define a variable containing the value of the nitrofen conc.;
  id=_n_;    * define an animal ID corresponding the observation number;
  datalines;
33 33 35 33 36 26 27 31 32 29
run;

data conc_160;
  input total @@;
  conc = 160;* define a variable containing the value of the nitrofen conc.;
  id=_n_;    * define an animal ID corresponding the observation number;
  datalines;
29 29 23 27 30 31 30 26 29 29
;
run;

data conc_235;
  input total @@;
  conc = 235;* define a variable containing the value of the nitrofen conc.;
  id=_n_;    * define an animal ID corresponding the observation number;
  datalines;
23 21 7 12 27 16 13 15 21 17
;
run;

data conc_310;
  input total @@;
  conc = 310;* define a variable containing the value of the nitrofen conc.;
  id=_n_;    * define an animal ID corresponding the observation number;
  datalines;
6 6 7 0 15 5 6 4 6 5 
;
run;
proc sql;
  create table all_sql as 
  select * from conc_0
  union
  select * from conc_80
  union
  select * from conc_160
  union
  select * from conc_235
  union
  select * from conc_310
  order by conc,id;
quit;  * RUN has no effect on SQL because statements are immediately executed;
       * QUIT ends SQL;
ods rtf file="&dir\&subdir\ch4-fig4.x5.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;
proc print data=all_sql;
run;
ods rtf close;

/*******************************************************************/
/* Program 4.6 An inner join of the three SMSA subset data sets using 
               PROC SQL 
*/

data SMSA_subset_weather;
   length city $ 27; 
   input city & JanTemp JulyTemp	RelHum Rain;
datalines;
Akron, OH  27 71 59 36 
Albany-Schenectady-Troy, NY  23 72 57 35 
Baltimore, MD  35 77 55 43 
Allentown, Bethlehem, PA-NJ  29 74 54 44 
Atlanta, GA  45 79 56 47 
;
run;

data SMSA_subset_demog;
   length city $ 27; 
   input city & Mortality Education PopDensity 
      pct_NonWhite pct_WC pop pop_per_house income;
datalines;
Akron, OH  921.87 11.4 3243 8.8 42.6 660328 3.34 29560
Albany-Schenectady-Troy, NY  997.87 11.0 4281 3.5 50.7 835880 3.14 31458
Baltimore, MD  1071.29 9.6 6441 24.4 43.7 2199531 3.44 32368
Allentown, Bethlehem, PA-NJ  962.35 9.8 4260 0.8 39.4 635481 3.21 31856
Atlanta, GA  982.29 11.1 3125 27.1 50.2 2138231 3.41 32452
;
run;

data SMSA_subset_pollution;
   length city $ 27; 
   input city & HCPot NOxPot S02Pot NOx;
datalines;
Akron, OH  21 15 59 15
Albany-Schenectady-Troy, NY  8 10 39 10
Baltimore, MD  43 38 206 38
Allentown, Bethlehem, PA-NJ  6 6 33 6
Atlanta, GA  18 8 24 8
;
run;

proc sql;
  create table SMSA_subset_sql as
  select * from
    SMSA_subset_weather w, SMSA_subset_demog d, SMSA_subset_pollution p
  where w.city=d.city and d.city=p.city;

ods rtf file="&dir\&subdir\ch4-fig4.16.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;
proc print data=SMSA_subset_sql;
  var city JulyTemp education S02Pot;
run;
ods rtf close;

/*******************************************************************/

/* Program 4.7  Left, right, or full outer joins with a subset of the 
                 SMSA observations  */
data SMSA_subset_weather2;
   length city $ 27; 
   input city & JanTemp JulyTemp	RelHum Rain;
datalines;
Akron, OH  27 71 59 36 
Baltimore, MD  35 77 55 43 
Allentown, Bethlehem, PA-NJ  29 74 54 44 
Atlanta, GA  45 79 56 47 
;
run;

data SMSA_subset_demog2;
   length city $ 27; 
   input city & Mortality Education PopDensity 
      pct_NonWhite pct_WC pop pop_per_house income;
datalines;
Akron, OH  921.87 11.4 3243 8.8 42.6 660328 3.34 29560
Albany-Schenectady-Troy, NY  997.87 11.0 4281 3.5 50.7 835880 3.14 31458
Baltimore, MD  1071.29 9.6 6441 24.4 43.7 2199531 3.44 32368
Allentown, Bethlehem, PA-NJ  962.35 9.8 4260 0.8 39.4 635481 3.21 31856
;
run;

ods rtf file="&dir\&subdir\ch4-fig4.x7.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;
/* inner join / conventional join */
proc sql;
title "inner join";
  select w.city,JanTemp,JulyTemp,Education,income from 
     SMSA_subset_weather2 as w,SMSA_subset_demog2 as d
  where w.city=d.city;

/* LEFT outer join - with duplicate columns */

title "LEFT outer join with duplicate columns";
  select * from 
       SMSA_subset_weather2 as w
  left join
       SMSA_subset_demog2 as d
  on w.city=d.city;

/* LEFT outer join - eliminating duplicate columns using COALESCE */

title "LEFT outer join eliminating duplicate columns";
  select coalesce(w.city, d.city),JanTemp,JulyTemp,Education,income from 
       SMSA_subset_weather2 as w
  left join
       SMSA_subset_demog2 as d
  on w.city=d.city;

/* RIGHT outer join */

title "RIGHT outer join";
  select coalesce(w.city, d.city),JanTemp,JulyTemp,Education,income from 
       SMSA_subset_weather2 as w
  right join
       SMSA_subset_demog2 as d
  on w.city=d.city;

/* FULL outer join */

title "FULL outer join";
  select coalesce(w.city, d.city),JanTemp,JulyTemp,Education,income from 
       SMSA_subset_weather2 as w
  full join
       SMSA_subset_demog2 as d
  on w.city=d.city;
quit;
ods rtf close;

/*******************************************************************/

/* Program 4.8  Constructing the sample space based on tossing a coin and 
rolling a die  */

data coin_toss;
  toss="Heads"; output;
  toss="Tails"; output;
run;

data die_roll;
  face=1; output;  face=2; output;
  face=3; output;  face=4; output;
  face=5; output;  face=6; output;
run;

proc sql;
 create table roll_n_toss as 
 select * from coin_toss,die_roll;
quit;

ods rtf file="&dir\&subdir\ch4-fig4.x8.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;
proc print data=roll_n_toss;
run;

data roll_n_toss2;  * using ARRAYS (see Ch. 9 for details);
  array array_toss(*) $ toss1-toss2 ("Heads", "Tails");
  array array_face(*) face1-face6 (1, 2, 3, 4, 5, 6);

  do itoss=1 to 2;
    do iface=1 to 6;
      toss = array_toss(itoss);
      face = array_face(iface);
      keep toss face;
      output;
    end;
  end;
run;

proc print data=roll_n_toss2;
run;

ods rtf close;


/*  Program 4.9  Wide to long format  */
data wide_original;
  input name $ gender $ t1 t2 t3 t4 t5 t6 t7;
datalines;
Smith M 6 6 5 5 5 4 3
Jones F 7 5 4 4 3 2 1
Fisher M 5 5 5 3 2 2 1
;
run;

data wide2long;
  input name $ gender $ t1 t2 t3 t4 t5 t6 t7;

  array num_array{*} _NUMERIC_;
  do time = 1 to dim(num_array);
     ADL = num_array{time};
     output;
  end;
  keep name gender time ADL;

datalines;
Smith M 6 6 5 5 5 4 3
Jones F 7 5 4 4 3 2 1
Fisher M 5 5 5 3 2 2 1
;
run;

ods rtf file="&dir\&subdir\ch4-fig4.1.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=original_shape;
run;
ods rtf close;

ods rtf file="&dir\&subdir\ch4-fig4.2.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=wide2long;
run;
ods rtf close;


/* Program 4.10 Wide to Long format reshaping using PROC TRANSPOSE */

proc sort data=wide_original;
  by name;
run;

proc transpose data=wide_original out=twide2long;
  by name;
  var t1-t7;
run;

proc print data=wide_original;
run;

ods rtf file="&dir\&subdir\ch4-fig4.3.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=twide2long;
run;
ods rtf close;

data wide2long2;
  set twide2long;
  time = input(substr(_NAME_,2,1),2.);
  ADL = COL1;
  drop _NAME_ COL1;
run;

proc print data=wide2long2;
run;

/*******************************************************************/

/* Program 4.11  Long to wide format reshaping using RETAIN and arrays */
data long_original;
  input name $ gender $ time ADL;
datalines;
Smith	M	1	6
Smith	M	2	6
Smith	M	3	5
Smith	M	4	5
Smith	M	5	5
Smith	M	6	4
Smith	M	7	3
Jones	F	1	7
Jones	F	2	5
Jones	F	3	4
Jones	F	4	4
Jones	F	5	3
Jones	F	6	2
Jones	F	7	1
Fisher	M	1	5
Fisher	M	2	5
Fisher	M	3	5
Fisher	M	4	3
Fisher	M	5	2
Fisher	M	6	2
Fisher	M	7	1
;
run;
proc sort data=long_original;
  by name time;
run;

proc print data=long_original;
run;

data long2wide;
  set long_original;
  by name;

  array t(7) t1-t7;
  array ADL_array(7) ADL1-ADL7;
  retain count_time wname wgender t1-t7 ADL1-ADL7;

  if first.name = 1 then do;
    count_time = 1;
    wname = name;
	wgender = gender;
	t(count_time) = time;
	ADL_array(time) = ADL;
 end;
 else do;
    count_time = count_time + 1;
	t(count_time) = time;
	ADL_array(count_time) = ADL;
 end;

  if last.name = 1 then output;
  keep wname wgender t1-t7 ADL1-ADL7;
run;

proc print data=long2wide;
  var wname wgender t1-t7 ADL1-ADL7;
run;

/*******************************************************************/

/* Program 4.12  Long to wide format reshaping using PROC TRANSPOSE */

proc transpose data=long_original out=tlong2wide prefix=t;
  by name gender;
  id time;
  var ADL;
run;

proc print data=tlong2wide;
run;


/*******************************************************************/

/* Program 4.13  Reading and reshaping World Bank data - first attempt */

* read in World Bank data;
data WB;
  infile "&dir\&subdir\World-Bank-HNP-05apr18.csv" dsd firstobs=2; 
  input SeriesName $ SeriesCode $ CountryName $ CountryCode $
        YR1998 $ YR1999 $ YR2000 
        YR2001 $ YR2002 $ YR2003 $ YR2004 $ YR2005 $ YR2006 $
        YR2007 $ YR2008 $ YR2009 $ YR2010 $ YR2011 $ YR2012 $
        YR2013 $ YR2014 $ YR2015 $ YR2016 $ YR2017 $ ;
run;

ods rtf file="&dir\&subdir\ch4-fig4.4.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=WB (firstobs=100 obs=115);
  var SeriesName SeriesCode CountryCode YR1998 YR2000;
run;

proc contents data=WB;
run;

ods rtf close;

/* Program 4.14 Reading and reshaping World Bank data - second attempt */

* read in World Bank data;
data WB;
  infile "&dir\&subdir\World-Bank-HNP-05apr18.csv" dsd firstobs=2; 
  length SeriesName $ 80 SeriesCode $ 35 CountryName $ 40 ;
  input SeriesName $ SeriesCode $ CountryName $ CountryCode $
        YR1998 $ YR1999 $ YR2000 
        YR2001 $ YR2002 $ YR2003 $ YR2004 $ YR2005 $ YR2006 $
        YR2007 $ YR2008 $ YR2009 $ YR2010 $ YR2011 $ YR2012 $
        YR2013 $ YR2014 $ YR2015 $ YR2016 $ YR2017 $ ;
run;

ods rtf file="&dir\&subdir\ch4-fig4.5.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=WB (firstobs=100 obs=115);
  var SeriesName -- YR2001;
run;

ods rtf close;

/* Program 4.15 Moving YR1998-YR2017 columns to single column
                (Reshaping World Bank data)                          */
/* home directory: "C:\Users\John Bailer\Downloads"   .............. */

* read in World Bank data;
data WB;
  infile "&dir\&subdir\World-Bank-HNP-05apr18.csv" dsd firstobs=2; 
  length SeriesName $ 80 SeriesCode $ 35 CountryName $ 40 ;
  input SeriesName $ SeriesCode $ CountryName $ CountryCode $
        YR1998 $ YR1999 $ YR2000 $
        YR2001 $ YR2002 $ YR2003 $ YR2004 $ YR2005 $ YR2006 $
        YR2007 $ YR2008 $ YR2009 $ YR2010 $ YR2011 $ YR2012 $
        YR2013 $ YR2014 $ YR2015 $ YR2016 $ YR2017 $ ;
run;

/* First:  get the YR variables in a column with year and a column with 
           variable value   */
proc sort data=WB;
  by CountryName SeriesName SeriesCode;
run;

proc transpose data=WB out=WBlong let;
  by CountryName SeriesName SeriesCode;
  var YR1998-YR2017;
run;

proc freq data=WB;
  table CountryName;
run;

proc contents data=WBlong;   * check the contents of the transposed data;
run;

proc freq data=WBlong;
  table _NAME_ CountryName;  * check for valid entries;
run;

proc print data=WBlong;      * 51 rows contain missing CountryNames;
  where CountryName="";
run;

data WBlong2;                * remove rows with missing CountryName;
  set WBlong;
  if (CountryName = "") then delete;
  keep CountryName SeriesName SeriesCode COL1 _NAME_;
run;

ods rtf file="&dir\&subdir\ch4-fig4.6.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=WBlong2 (firstobs=10 obs=15);
run;

ods rtf close;

/* Second:  extract the year (e.g. 1960) from the character value (e.g. YR1960) and make it numeric  */
data WBlong3;
  set WBlong2;
  year = 1.*substr(_NAME_,3,4); * extract year & makes this variable numeric;
  SeriesCode = tranwrd(SeriesCode,".","_");  * replace . by _;
  drop _NAME_;
run;

ods rtf file="&dir\&subdir\ch4-fig4.7.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

proc print data=WBlong3 (firstobs=10 obs=15);
run;

ods rtf close;


/* Program 4.16 Completing the reshaping World Bank data */

/* Third:  move the variableName column to separate distinct columns
           label the variable names with the SeriesCode              */
data WB;
  infile "&dir\&subdir\World-Bank-HNP-05apr18.csv" dsd firstobs=2; 
  length SeriesName $ 80 SeriesCode $ 35 CountryName $ 40 ;
  input SeriesName $ SeriesCode $ CountryName $ CountryCode $
        YR1998 $ YR1999 $ YR2000 $
        YR2001 $ YR2002 $ YR2003 $ YR2004 $ YR2005 $ YR2006 $
        YR2007 $ YR2008 $ YR2009 $ YR2010 $ YR2011 $ YR2012 $
        YR2013 $ YR2014 $ YR2015 $ YR2016 $ YR2017 $ ;
run;


/* First:  get the YR variables in a column with year and a column with 
           variable value   */
proc sort data=WB;
  by CountryName SeriesName SeriesCode;
run;

proc transpose data=WB out=WBlong let;
  by CountryName SeriesName SeriesCode;
  var YR1998-YR2017;
run;

data WBlong2;                * remove rows with missing CountryName;
  set WBlong;
  if (CountryName = "") then delete;
  keep CountryName SeriesName SeriesCode COL1 _NAME_;
run;

/* Second:  extract the year (e.g. 1960) from the character value (e.g. YR1960) and make it numeric  */
data WBlong3;
  set WBlong2;
  year = 1.*substr(_NAME_,3,4); * extract year & makes this variable numeric;
  SeriesCode = tranwrd(SeriesCode,".","_");  * replace . by _;
  drop _NAME_;
  VALUE = 1.*COL1;               * make sure values are numeric;
run;

proc contents data=WBlong3;
run;

/* Third:  move the variableName column to separate distinct columns
           label the variable names with the SeriesCode              */

proc sort data=WBlong3;
  by CountryName year;
run;

proc transpose data=WBlong3 out=WBfinal;
  by CountryName Year;
  var VALUE;
  id SeriesCode;
  idlabel SeriesCode;
run;

proc contents data=WBfinal;
run;

* ods rtf file="&dir\&subdir\ch4-fig4.8.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

/* ----------------- BONUS -------------------------- */
/* saving WBfinal as a permanent SAS data set */
libname ch4files "&dir\&subdir";
data ch4files.WBfinal;
  set WBfinal;
run;

data WBfinal;
  set ch4files.WBfinal;
run;

/* -------------------------------------------------- */



proc print data=WBfinal (firstobs=10 obs=15);
run;

ods graphics on /  imagename="Ch04Fig1"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;

proc sgplot data=WBfinal;
  title "Plot of Age at first marriage for females vs. time";
  series x=year y=SP_DYN_SMAM_FE / group=CountryName
         lineattrs = (COLOR = GRAY4F );  * request grayscale! - omit for color; 
  where SP_DYN_SMAM_FE NE .;
run;

ods listing close;


ods graphics on /  imagename="Ch04Fig2"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;  

proc sgplot data=WBfinal noautolegend;
  title "Plot of Life Expectancy at birth vs. time";
  series x=year y=SP_DYN_LE00_FE_IN / group=CountryName
         lineattrs = (COLOR = GRAY4F );
run;

ods listing close;


* ods rtf close;

title "";
/*******************************************************************/




/*******************************************************************/

/* Program 4.17 Selecting training and test data in SAS*/
/*
https://communities.sas.com/t5/SAS-Statistical-Procedures/Randomly-splitting-data-for-training-and-data-set-for/td-p/307875
*/

title;
proc contents data=SASHELP.CARS;
run;   * 428 obs;

* select 75%/25% of the observations for a training/test set;
* using RETAIN allows control of exactly how many observations
        are assigned to training and test data sets;
data train_test;
  set SASHELP.CARS;
  call streaminit(7525);
  retain ntest ntrain 0;
  pick_test = RAND("uniform");

  if (pick_test <= .25) then do; 
      if (ntest < 107) then do;  
        ntest = ntest + 1;
        dsn= "test ";
     end;
     else do;  * test sample filled - put obs into training set;
        ntrain = ntrain + 1;
        dsn = "train";  
     end;
  end;
  else do;
     if (ntrain < 321) then do;  
        ntrain = ntrain + 1;
        dsn = "train";
     end;
     else do;  * training sample filled - put obs into test set;
        ntest = ntest + 1;
        dsn= "test ";
     end;
  end;
run;

* define new variable to be Y for the training data but
  missing for the test data - produces prediction for both
  data sets - also construct the quadratic and cubic terms;
data reg_train;
  set train_test;
  obs_no = _N_;
  if dsn="train" then Y_MPG_Highway = MPG_Highway;
  else Y_MPG_Highway = .; 
  Weight2 = Weight**2;
  Weight3 = Weight**3;
run;

* debugging code to check variable and data set construction;
proc print data=reg_train (obs=4);
run;

proc freq data=reg_train;
  table dsn;
run;

* fit linear, quadratic and cubic models to the training data set;
proc reg data=reg_train;
  M1: model Y_MPG_Highway = Weight;
      output out=pred_mpg1  pred=yhat1;  
  M2: model Y_MPG_Highway = Weight Weight2;
      output out=pred_mpg2  pred=yhat2;  
  M3: model Y_MPG_Highway = Weight Weight2 Weight3;
      output out=pred_mpg3  pred=yhat3;  
quit;

/* combine 3 data sets with predicted values and 
   calculate (y-yhat)^2 for each observation */
data all_fit;
  merge pred_mpg1 pred_mpg2 pred_mpg3;
  by obs_no;
    lin_pred_SS = (MPG_Highway - yhat1)**2;
   quad_pred_SS = (MPG_Highway - yhat2)**2;
  cubic_pred_SS = (MPG_Highway - yhat3)**2;
run;

proc print data=all_fit (obs=4);
  where dsn="test ";
run;

* generate table with SS of prediction error for the test data
  (and SSE for the training data set);
proc means data=all_fit n sum;
  class dsn;
  var lin_pred_SS quad_pred_SS cubic_pred_SS;
run;

* compare the 3 fits on the test data set;

proc sort data=all_fit;
  by weight;
run;

*ods graphics on / imagefmt=png;
* ods rtf file="&dir\&subdir\ch4-fig4.21.rtf"
        image_dpi=300  
        style=sasuser.customSapphire
        bodytitle;


ods graphics on /  imagename="Ch04Fig3"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=600;  

proc sgplot data=all_fit;
  scatter x=Weight y=MPG_Highway / markerattrs = (COLOR = GRAY4F);
  series x=Weight y=yhat1 / lineattrs=(color=lightgrey pattern=1);
  series x=Weight y=yhat2 / lineattrs=(color=black   pattern=2);
  series x=Weight y=yhat3 / lineattrs=(color=grey  pattern=4);
  where dsn="test";
run;

ods listing close;
* ods rtf close;
* ods graphics off;

/* ref:
   Change line colors and styles for PROC SGPLOT output
                   http://support.sas.com/kb/35/864.html
*/


/*******************************************************************/

* Homework - Problem 2;

data B1;   * Brood=1 data;
  input ID   conc   number of young @@;
  datalines;
3 0 6  4 0 6  5 0 6  6 0 5  7 0 6  8 0 5 9 0 3 10 0 6 
12 80 5 13 80 6  14 80 5  15 80 8  16 80 3  17 80 5  18 80 7
19 80 5  20 80 3  
21 160 6  22 160 6  23 160 2  24 160 6  25 160 6  26 160 6
27 160 6  28 160 5  30 160 6
31 235 4  32 235 6  34 235 6  35 235 6  36 235 6  37 235 7
38 235 4  39 235 6  40 235 7
41 310 6  42 310 6  43 310 7  44 310 0  45 310 5  47 310 6
48 310 4  49 310 6  50 310 5
;
run;

data B2;   * Brood=2 data;
  input ID   conc   number of young @@;
  datalines;
1 0 14  2 0 12  3 0 11  4 0 12  6 0 14  7 0 12  8 0 13
9 0 10  10 0 11
11 80 11  13 80 11  14 80 12  15 80 13  16 80 9  17 80 9
18 80 12  19 80 13  20 80 12
21 160 12  22 160 12  23 160 8  24 160 10  25 160 11
26 160 13  27 160 12  29 160 13  30 160 12
31 235 13  32 235 10  33 235 5  34 235 0  35 235 13
36 235 0  37 235 0  38 235 2  39 235 8  40 235 0
41 310 0  42 310 0  43 310 0  45 310 10  46 310 0  47 310 0
48 310 0  49 310 0  50 310 0
;
run;

data B3;   * Brood=3 data;
  input ID   conc   number of young @@;
  datalines;
1 0 10  2 0 15  3 0 17  4 0 15  5 0 15  6 0 15  7 0 15
8 0 12  10 0 14
11 80 16  12 80 16  13 80 18  14 80 16  15 80 15  16 80 14
17 80 13  18 80 12  19 80 14  20 80 14
21 160 11  22 160 11  23 160 13  24 160 11  25 160 13  26 160 12
27 160 12  28 160 11  29 160 10  30 160 11
31 235 6  32 235 5  33 235 0  34 235 6  35 235 8  36 235 10
38 235 9  39 235 7  40 235 10
41 310 0  42 310 0  43 310 0  44 310 0  45 310 0  46 310 0
48 310 0  49 310 0  50 310 0 
;
run;


/*******************************************************************/



/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*                                                                 */ 
/* Chapter 4 Self-study Lab                                        */
/*******************************************************************/

/* ==================================================== */
/* PUT examples ...                                     */
/* ==================================================== */

data;
  put "Hello World!!!";
  put @20 "Hello World!!!";  * start at column 20;
  put 3*"Hello World!!!";    * 3 copies;
run;

data;
  put;
  put "Hello World!!!" /;
  put @20 "Hello World!!!" /;  * start at column 20;
  put 3*"Hello World!!!" /;    * 3 copies;
  put;
run;  

data;
  input name $ @@;
  put "Hello " name ", welcome to SAS Statistical Programming." /;
  datalines;
Dave Hal
;
run;
 
data;
  file " C:\Users\baileraj.IT\Desktop\put-example.TXT";
* replace path in FILE with folder on your system;
  input name $ @@;
  put "Hello " name ", welcome to SAS Statistical Programming." /;
  datalines;
Dave Hal
;
run;
 
/* ==================================================== */
/*  CONCATENATING ("row binding") data sets             */
/* ==================================================== */

/* clean example */
data d1;
  input v1 v2 v3;
  datalines;
1 2 3
4 5 6
;
run;

data d2;
  input v1 v2 v3;
  datalines;
11 12 13
14 15 16
17 18 19
;
run;

data d12;
  set d1 d2;
run;
proc print;
run;

/* not-so-clean example */
data d1a;
  input v1 v2 v3;
  datalines;
1 2 3
4 5 6
;
run;

data d2a;
  input var1 var2 var3;
  datalines;
11 12 13
14 15 16
17 18 19
;
run;

data d12a;
  set d1a d2a;
run;

proc print data=d12a;
run;

/* fixing not-so-clean example */
data d1b;
  input v1 v2 v3;
  datalines;
1 2 3
4 5 6
;
data d2b;
  input var1 var2 var3;
  v1=var1;
  v2=var2;
  v3=var3;
  drop var1-var3;
  datalines;
11 12 13
14 15 16
17 18 19
;
data d12b;
  set d1b d2b;
run;
proc print data=d12b;
run;

/* one last concatenation example */

options formdlim="-";
data d1c;
  input v1 v2 v3;
  datalines;
1 2 3
4 5 6
;
run;

data d2c;
  input var1 var2 var3;
  datalines;
11 12 13
14 15 16
17 18 19
;
run;

data d12c;
  set d1c d2c (rename=(var1=v1 var2=v2 var3=v3));
run;

proc print data=d12c;
run;

/* merging data examples */

options formdlim="-";

data m1;
  input ID v1 v2;
  datalines;
1 2 3
2 5 6
4 7 8
;
run;

data m2;
  input ID var1 var2 var3;
  datalines;
1 11 12 13
2 14 15 16
3 17 18 19
;
run;

data M12;
  merge m1 m2;
  by ID;
run;

proc print data=m12;
  title "First Merge data example";
run;

/* suppose you have common variables in the data sets that are merged? */

options formdlim="-";

data m1b;
  input ID v1 v2;
  datalines;
1 2 3
2 5 6
4 7 8
;
run;

data m2b;
  input  ID v1 v2 var3;
  datalines;
1 11 12 13
2 14 15 16
3 17 18 19
;
data M12b;
  merge m1b m2b;
  by ID;
run;

proc print data=m12b;
  title "Second Merge data example - common variables in 2 data sets";
run;

data M12b2;
  merge m2b m1b;
  by ID;
run;

proc print data=m12b2;
  title "Second Merge data example - diff merge order";
run;

proc print data=m1b;
run;
proc print data=m2b; 
run;

/* what if the data sets have multiple records with an ID? */

data m1c;
  input ID v1 v2;
  datalines;
1 2 3
1 4 5
2 6 7
;
run;

data m2c;
  input ID var1;
  datalines;
1 11
2 21
2 22
;
run;

data m12c;
  merge m1c m2c;
  by ID;
proc print data=m12c;
  title "many to one merging issues";
run;

data m1d;
  input ID v1 v2;
  datalines;
1 2 3
1 4 5
;
run;

data m2d;
  input ID var1;
  datalines;
1 11
1 12
1 13
;
run;

data m12d;
  merge m1d m2d;
  by ID;
run;

proc print data=m12d;
  title "many to many merging issues";
run;

/* ================================================================ */
/* BASIC SQL stuff >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */
/* ================================================================ */

options formdlim="-";
data junk;
  input cgroup $ x y @@;
  datalines;
a 1 2 B 3 4 B 5 6 A 7 8 A 9 10
;
run;

/* basic PROC stuff */
proc print data=junk;

run;

proc sort data=junk; 
     by cgroup;
run;

proc print data=junk;
run;

proc means data=junk;
  class cgroup;
  var x y;
run;

/*  notes:  
1.  Multiple select statements can be used to generate different views of the data
2. SQL continues until QUIT; or a DATA/PROC step                    
*/
proc sql;
  select * 
     from junk;   * select and display all variables;

  select cgroup  
     from junk;   * select particular variable;

  select cgroup,x,y
     from junk
       order by cgroup;  * order the rows of the view table;

  select cgroup,x,y
     from junk
       order by x;

  select cgroup,x,y, x/(x+y)*100 as pctsum
     from junk;            * construct and name a new variable/column;

  select cgroup,x,y, x/(x+y)*100 as pctsum
         label='% sum' format=4.1
     from junk;

  select avg(x) label='avg x',avg(y) label='avg y'  
     from junk;                    * summary functions of SQL;

  select cgroup label='Variable', count(*) label='n', 
         avg(x) label='avg x',avg(y) label='avg y'
     from junk
     group by cgroup;              * grouping rows/summaries in SQL;
  
  select cgroup label='Variable', count(*) label='n', 
         avg(x) label='avg x',avg(y) label='avg y'
     from junk
     where cgroup in ('A','B')
     group by cgroup ;                 * subsetting rows in SQL;


select cgroup label='Variable', count(*) label='n', 
         avg(x) label='avg x',avg(y) label='avg y'
     from junk
     where cgroup in ('A','B')
     group by cgroup 
     having avg(x) > 5;

/* to check a query before running it */
/*
validate
      select . . ..
*/

/* ================================================================ */
/* SQL:  CONCATENATE examples >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */
/* ================================================================ */

/* clean example */
data d1;
  input v1 v2 v3;
  datalines;
1 2 3
4 5 6
;
run;

data d2;
  input v1 v2 v3;
  datalines;
11 12 13
14 15 16
17 18 19
;
run;

proc sql;
  select * from d1;
  select * from d2;
  select * from d1,d2;
  select * 
      from d1
  outer union
  select * 
      from d2; 
* SET operators in SQL - outer union, union, except, intersect; 
  select * 
      from d1
  outer union corr
  select * 
      from d2;             * CORR overlays common columns;

  select * 
      from d1
  union 
  select * 
      from d2;             * even simpler;

  create table work.d12 as
  select * 
      from d1
  outer union corr
  select * 
      from d2;             * produce a SAS data set from an SQL query;

/* not-so-clean example */
data d1a;
  input v1 v2 v3;
  datalines;
1 2 3
4 5 6
;
run;

data d2a;
  input var1 var2 var3;
  datalines;
11 12 13
14 15 16
17 18 19
;
run;

proc sql;
  select * from d1a,d2a;

  select * 
      from d1a
  outer union
  select * 
      from d2a;

  select * 
      from d1a
  union
  select * 
      from d2a;

  select * 
      from d1a
  outer union corr
  select var1 as v1, var2 as v2, var3 as v3 
      from d2a;                 * renaming as part of selection;

/* ================================================================ */
/* merging data examples >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
/* ================================================================ */

options formdlim="-";

data m1;
 input ID v1 v2;
 datalines;
1 2 3
2 5 6
4 7 8
;
run;

data m2;
  input ID var1 var2 var3;
  datalines;
1 11 12 13
2 14 15 16
3 17 18 19
;
run;

proc sql;
  select * 
    from m1,m2;

  select * 
    from m1,m2
    where m1.id=m2.id;

  select m1.ID,v1,v2,var1,var2,var3 
    from m1,m2
    where m1.id=m2.id;

  select * 
    from m1 inner join m2
    on m1.id=m2.id;

  select * 
    from m1 right join m2
    on m1.id=m2.id;

  select * 
    from m1 left join m2
    on m1.id=m2.id;

  select * 
    from m1 full join m2
    on m1.id=m2.id;

/* multiple records per id */
data m1c;
  input ID v1 v2;
  datalines;
1 2 3
1 4 5
2 6 7
;
run;
data m2c;
  input ID var1;
  datalines;
1 11
2 21
2 22
;
run;

proc sql;
  select * 
    from m1c,m2c;

  select * 
    from m1c,m2c
    where m1c.id=m2c.id;

  select m1c.ID,v1,v2,var1,var2,var3 
    from m1c,m2c
    where m1c.id=m2c.id;

  select * 
    from m1c inner join m2c
    on m1c.id=m2c.id;

  select * from m1c;
  select * from m2c;

/* many to many merging issues */
data m1d;
  input ID v1 v2;
  datalines;
1 2 3
1 4 5
;
run;

data m2d;
  input ID var1;
  datalines;
1 11
1 12
1 13
;
run;

proc sql;
  select * from m1d;
  select * from m2d;
  select *
     from m1d, m2d
     where m1d.id=m2d.id;
quit;

/**********************************************************************/
/* Easter egg?                                                        */
/* Can count #observations in SAS data set automatically              */
/*   "Here's a trick I occasionally use. Note only one record is read */
/*    from each dataset but SAS magic knows all…                      */
/* from 
  https://communities.sas.com/t5/Base-SAS-Programming/How-to-count-the-number-of-observations-in-a-data-frame/td-p/293167;
*/

Data my_dataset ;
   do I=1 to 27 ;
       output ;
   end ;
run ;

Data my_dataset2 ;
   do I=1 to 73 ;
      output ;
   end ;
run ;

data _null_ ;
    set my_dataset(obs=1) nobs=nobs ;
    call symputx('records',nobs) ;
run ;
%put records: &records ;

/* Here SAS knows how many obs are in the concatenated datasets too… */
data _null_ ;
    set my_dataset(obs=1) my_dataset2(obs=1) nobs=nobs ;
    call symputx('records',nobs) ;
run ;
%put Concatenated records: &records ;

 


