/*
   CHAPTER 08:  ===========================

   Revised:  27 June 2019

*/

/* set up for directories ................................... */
%let dir=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subdir=chapter08;

/* template code that defines a style for output produced ... */
%include "&dir\book_template_and_options.sas";   * page options and CustomSaphire specification;

/* need to use this so graphics embedded in ODS RTF are PNG and not WMF */ 
ods graphics on / imagefmt=png;

/*  Program 8.1  =====================================  */

ods rtf file="&dir\&subdir\ch8-fig8.1.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;
 
PROC IML;
* reset noname;  * inhibit default printing of matrix name;

*make a 2x3 matrix;
    C = {1 2 3,4 5 6};
    print '2x3 matrix C = {1 2 3,4 5 6} =' C;

*select 2nd row;
    C_r2 = C[2,];
    print '2nd row of C = C[2,] =' C_r2;

*select 3rd column;
    C_c3 = C[,3];
    print '3rd column of C = C[,3] =' C_c3;

*select last two columns;
    Col23 = C[,2:3];
    Print 'Columns 2 and 3 of C =' Col23;

*select the (2,3) element of C;
    C23 = C[2,3];
    print '(2,3) element of C = C[2,3] =' C23;

*make a 1x3 matrix by summing over rows in each column;
    C_csum=C[+,];
    print '1x3 column sums of C = C[+,] =' C_csum;

*make a 2x1 matrix by summing over columns in each row;
    C_rsum=C[,+];
    print '2x1 row sums of C = C[,+] =' C_rsum; 

* row means and column means ;
    C_row_mean = C[,+]/ncol(C);
    C_col_mean = C[+,]/nrow(C);

    print '2x1 row means of C = C[,+] =' C_row_mean;
    print '1x3 column means of C = C[,+] =' C_col_mean;

* construct a 3x3 identity matrix;
    I3 = I(3);
    print "3x3 Identity matrix = "  I3;
quit;
ods rtf close;


/* =======================================================================
Program 8.2  Summarizing, extracting, shaping, and manipulating vectors 
             and matrices
*/

ods rtf file="&dir\&subdir\ch8-fig8.2.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;

PROC IML;
*make a 2x3 matrix;
    C = {1 2 3,4 5 6};
    print '2x3 example matrix C = {1 2 3,4 5 6} =' C;

*make a 1x3 matrix by summing rows in each column
 and a 2x1 matrix by summing columns in each row;
    C1=C[+,];
    C2=C[,+];

*make a matrix (col. vector) out of second column of C;
    F = C[,2];
    print 'extract 2nd column of C into new vector (F) = C[,2] =' F;
*put second column of C on diagonal;
    D = DIAG( C[,2] );
    print '2nd column of C into a diag, matrix (D)=DIAG(C[,2]) =' D;

*make a vector out of the diagonal;
    CC= VECDIAG(D);
    print 'convert diagonal (of D) into vector (CC) = VECDIAG(D) =' CC;

*put C next to itself - column binds C with itself;
    E = C || C;
    print 'Column bind C with itself yielding E = C||C =' E;

*put a row of 2s below C - row bind;
    F =  C // SHAPE(2,1,3);
    print "Row bind C with vector of 2s (F) = C // SHAPE(2,1,3) =" F;
* . . . also adds (2 2 2) as another row on C;
    F2 = C // J(1, 3, 2);
    print "Using J(nrow,ncol,value) to add row to C (F2) = " F2;

*create a 6x6 matrix [C // C // C] || [C // C // C];
    K = REPEAT(C,3,2);
    print '6x6 matrix = ' K;

quit;

ods rtf close;


/* =======================================================================
Program 8.3  Using elementwise operations and multiplying matrices
*/

ods rtf file="&dir\&subdir\ch8-fig8.3.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;

PROC IML;
    C = {1 2 3,4 5 6};   * a 2x3 matrix;
    D = {1, 1, 1};       * a 3x1 column vector;

* matrix multiplication – C post-multiplied by D;
    row_sum = C*D;
    print 'row_sum = ' row_sum;

* raise each entry of columns 2 & 3 of C to the third power then 
    multiply by 3 and add 3;
    G = 3+3*(C[,2:3]##3);
    print '3 + 3*(col2&3)^3 (G) = ' G;

* raise each entry of C to itself;
    H = C ## C;
    print 'raise each C element to itself (H) = C##C =' H;

* multiply each entry of C by itself;
    J = C # C;
    print 'elementwise multiplication of C with itself (J) = C#C =' J;
quit;

ods rtf close;

* extract code play;
proc iml;
   c1 = shape(1,3,1);
   c3 = T({1 1 1});
   c4 = T({[3] 1});
   print c1 c3 c4;
quit;


/* =======================================================================
Program 8.4  Reading a SAS data set into IML
*/

filename cdub URL "http://www.users.miamioh.edu/baileraj/datasets/ch2-dat.txt";

data nitrofen;
 infile cdub firstobs=16 expandtabs missover pad;
 input @9 animal 2.
       @17 conc 3.
       @25 brood1 2.
       @33 brood2 2.
       @41 brood3 2.
       @49 total 2.;
run;
ods rtf file="&dir\&subdir\ch8-fig8.4.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;

proc iml;
/* read SAS data in IML  */
  use WORK.nitrofen;
  read all var { total conc } into nitro;

/*  alternative coding   */
  use mydat.nitrofen var{ total conc };
  read all into nitro2;

nitro = nitro || nitro[,2]##2;  * adding column with conc^2;

* add column with centered concentration;
nitro2 = nitro2 || (nitro2[,2]- nitro2[+,2]/nrow(nitro2));

* adding column with scaled conc^2;
nitro2 = nitro2 || nitro2[,3]##2;

show names;   * show matrices constructed in IML;

* extract a subset of rows for later printing;
nitro2_subset = nitro2[ {1 2 11 12 21 22 31 32 41 42 50} ,];

* creates SAS data set n2 from matrix nitro;
*   with variable names from the COLNAME argument;

varnames = ('total'||'conc'||'c_conc'||'c_conc2');
print varnames nitro2_subset;
create n2 from nitro2 [colname=varnames];
append from nitro2;

quit;

proc print data=n2;
  title 'print of data constructed in SAS/IML';
run;

ods rtf close;

/* =======================================================================
Program 8.5  Using SAS/IML to estimate \pi using Monte Carlo integration 
             (pts. in first quadrant) 
*/

ods rtf file="&dir\&subdir\ch8-fig8.5.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;

PROC IML;

  nsim = 4000;
  temp_mat = J(nsim,2,0);

 /* Generate (X,Y) with single call using 'randgen'  */
  call randseed(21509);   * set seed for randgen;
  call randgen(temp_mat,'uniform');

  temp_mat = temp_mat || (temp_mat[,2]<= sqrt(J(nsim,1,1)-temp_mat[,1]##2));
 
  pi_over4 = temp_mat[+,3]/nsim;

  pi_est = 4*pi_over4;
  se_est = 4*sqrt(pi_over4*(1-pi_over4)/nsim);
  pi_LCL = pi_est - 2*se_est;
  pi_UCL = pi_est + 2*se_est;

  * -----------------------------------------------------------;
  print 'Estimating PI using MC simulation methods with ' nsim 
        'data points';
  print 'PI-estimate = ' pi_est se_est pi_LCL pi_UCL;

quit;

ods rtf close;

/* =======================================================================
Program 8.6  Using the method of bisection to estimate sqrt(3) 

   find sqrt(x = 3) using bisection
   Author:  Robert Noble
   Modified:  John Bailer
*/

options ls=78 formdlim='-' nodate pageno=1;

proc iml;
  x = 3;
  hi = x;
  lo = 0;
  history = 0||lo||hi;
  iteration = 1;
  delta = hi - lo;
  do while(delta > 1e-7);
    mid = (hi + lo)/2;
    check = mid**2 > x;
    if check 
      then hi = mid;
      else lo = mid;
    delta = hi - lo;
    history = history//(iteration||lo||hi);
    iteration = iteration + 1;
  end;
  print mid;
  create process var {iteration low high};
  append from history;
quit;

ods rtf file="&dir\&subdir\ch8-fig8.6.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;
proc print data=process;
run;
ods rtf close;

ods rtf file="&dir\&subdir\ch8-fig8.1.rtf"
        image_dpi=300  
        style=journal bodytitle;
		
ods graphics on /  imagename="Ch08Fig"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=300 style=journal;
title;
proc sgplot data=process;
  series x=iteration y=low;
  series x=iteration y=high;
run;
ods listing close;

ods rtf close;

/* =======================================================================
Program 8.7 SAS/IML code to implement randomization test
*/

options nocenter nodate;
libname class "&dir\&subdir";  * folder containing SAS dataset nitrofen;
* libname class 'folder-containing-nitrofen-data';

title "Randomization test in IML – Nitrofen conc 0 vs. 160 compared";
data test; set class.nitrofen;
  if conc=0 | conc=160;
run;

proc plan seed=20102020;
  factors test=4000 ordered in=20;
  output out=d_permut;
run;

proc transpose data=d_permut prefix=in
               out=out_permut(keep=in1-in20);
   by test;
run;

proc iml;
/* read SAS data in IML  */
  use class.nitrofen;
  read all var { total conc } where (conc=0|conc=160) into nitro;

/* read the indices for generating the permutations into IML */
  use out_permut;
  read all into perm_index;

  obs_vec = nitro[,1];
  obs_diff = sum(obs_vec[1:10]) - sum(obs_vec[11:20]);  * test statistic;

  PERM_RESULTS = J(nrow(perm_index),2,0);  * initialize results matrix;

  do iperm = 1 to nrow(perm_index);
    ind = perm_index[iperm,];           * extract permutation index;
    perm_resp = obs_vec[ind];           * select corresponding obs;
    perm_diff = sum(perm_resp[1:10]) - sum(perm_resp[11:20]);
    PERM_RESULTS[iperm,1] = perm_diff;  * store perm TS value/indicator;
    PERM_RESULTS[iperm,2] = abs(perm_diff) >= abs(obs_diff);
  end;

  perm_Pvalue = PERM_RESULTS[+,2]/nrow(PERM_RESULTS);
  print 'Permutation P-value = ' perm_Pvalue;
quit;


/* =======================================================================
Program 8.8 SAS/IML module to estimate /pi using Monte Carlo integration
*/

/* MODULE TO ESTIMATE PI
   - Monte Carlo integration used
   - Strategy:
       Generate X~Unif(0,1) and Y~Unif(0,1)
       Determine if Y <= sqrt(1-X*X)
       PI/4 estimated by proportion of times condition above is true
   - INPUT 
       nsim	= # simulations
       seed = seed for RANDGEN
   - OUTPUT
       estimate of PI along with SE and CI
*/

options nocenter nodate;
ods rtf file="&dir\&subdir\ch8-fig8.8.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;

proc iml;

start MC_PI(nsim, seed);
  temp_mat = J(nsim,2,0);

  call randseed(seed);
  call randgen(temp_mat,'uniform');

  temp_mat=temp_mat||(temp_mat[,2]<=sqrt(J(nsim,1,1)-temp_mat[,1]##2));
 
  pi_over4 = temp_mat[+,3]/nsim;

  pi_est = 4*pi_over4;
  se_est = 4*sqrt(pi_over4*(1-pi_over4)/nsim);
  pi_LCL = pi_est - 2*se_est;
  pi_UCL = pi_est + 2*se_est;

  *-----------------------------------------------------------;
  print 'Estimating PI using MC integration method with' nsim;
  print 'data points';
  print pi_est se_est pi_LCL pi_UCL;

finish MC_PI;

/*******************************************************************/
run MC_PI(400, 12345);
run MC_PI(1600, 12345);
run MC_PI(4000, 12345);
quit;

ods rtf close;


/* =======================================================================
Program 8.9  Storing a SAS/IML module
*/

libname mylib "&dir\&subdir";    * location of catalog;
proc iml;

/* MODULE TO ESTIMATE PI
   - Monte Carlo integration used
   - Strategy:
       Generate X~Unif(0,1) and Y~Unif(0,1)
       Determine if Y <= sqrt(1-X*X)
       PI/4 estimated by proportion of times condition above is true
   - INPUT
       nsim = # simulations
       seed = seed for RANDGEN
   - OUTPUT
       estimate of PI along with SE and CI
*/

start MC_PI(nsim, seed);
  temp_mat = J(nsim,2,0);

  call randseed(seed);
  call randgen(temp_mat,'uniform');

  temp_mat=temp_mat||(temp_mat[,2]<=sqrt(J(nsim,1,1)-temp_mat[,1]##2));
 
  pi_over4 = temp_mat[+,3]/nsim;

  pi_est = 4*pi_over4;
  se_est = 4*sqrt(pi_over4*(1-pi_over4)/nsim);
  pi_LCL = pi_est - 2*se_est;
  pi_UCL = pi_est + 2*se_est;

  *-----------------------------------------------------------;
  print 'Estimating PI using MC integration method with' nsim;
  print 'data points';
  print pi_est se_est pi_LCL pi_UCL;

finish MC_PI;

reset storage=mylib.mystor;
store module= MC_PI;

quit;


/* =======================================================================
Program 8.10  Loading and using a SAS/IML module
*/
%let dir=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subdir=chapter08;

options nocenter;
libname mylib "&dir\&subdir";    * location of catalog;
proc iml;
  reset storage=mylib.mystor;
  load module= MC_PI;
  run MC_PI(2500,98765);
quit;


/* =======================================================================
   Running R from SAS

   Getting ready to run R from SAS
   1.  right click SAS on start menu and save to desktop (Windows 7)
       drag from Start menu to desktop (Windows 10)
   2.  right click on SAS icon on desktop and select properties
          add -rlang to end of "Target" field (after ....cfg")
   3.  add option pointing to location of R home directory

   REF:
      SAS/IML(R) 13.1 User's Guide

*/


*options set=R_HOME='C:\Program Files\R\R-3.5.1';  * dept ofc computer;
options set=R_HOME='C:\Program Files\R\R-3.5.2';   * 2nd ofc computer;


/* =======================================================================
Program 8.11 Exporting a SAS Data Set from SAS to R
*/

filename cdub URL "http://www.users.miamioh.edu/baileraj/datasets/ch2-dat.txt";

data nitrofen;
 infile cdub firstobs=16 expandtabs missover pad;
 input @9 animal 2.
       @17 conc 3.
       @25 brood1 2.
       @33 brood2 2.
       @41 brood3 2.
       @49 total 2.;
run;

options set=R_HOME='C:\Program Files\R\R-3.5.2';   * 2nd ofc computer;
proc iml;
  call ExportDataSetToR("work.nitrofen","nitro.df");
  submit/R;
     names(nitro.df)
	 library(ggplot2)
	 gg <- ggplot(data=nitro.df,aes(x=conc, y=total)) +
	     geom_point(shape=1,
                    position=position_jitter(width=1, height=.5)) +
		 geom_smooth(method="loess",se=FALSE) +
		 labs(x="Nitrofen concentration",
		      y="Number of young (3 broods)",
			  caption="[Based on data from Bailer and Oris (1993)]") +
         theme_minimal() 

	  jpeg('C:\\Users\\baileraj\\Documents\\book-SPiS-2nd-ed\\chapter08\\ch8-fig8.9.jpg')
        print(gg)
      dev.off()


  endsubmit;
quit;

/* =======================================================================
Program 8.12 Exporting an R object to a SAS Data Set
*/

proc iml;
  submit/R;
	 library(gapminder)
	 names(gapminder)
	 str(gapminder)
  endsubmit;

  run ImportDataSetFromR("WORK.gap","gapminder");
quit;

ods rtf file="&dir\&subdir\ch8-fig8.10.rtf"
        image_dpi=300  
        style=sasuser.customSapphire bodytitle;

proc means data=gap maxdec=1;
  var lifeExp;
  class continent;
  where year=2007;
run;

ods rtf close;

/* =======================================================================
Program 8.13 Exporting an R object to a SAS Data Set
*/

proc iml;
  submit/R;
      # load required packages (assumes these have been installed)
      library(tidyverse)
      library(gapminder)
      library(waffle)
	  library(RColorBrewer)
      ## waffle plots - https://www.rdocumentation.org/packages/waffle/versions/0.7.0 

      # data processing to build a data frame with continent % of world GDP
      myGapData <- gapminder %>%
        mutate(TotalGDP = pop*gdpPercap) %>%
        mutate(order_continent = 
                 factor(continent,
                        levels=c("Oceania", "Africa", "Europe", "Americas", "Asia")))
      
      # total GDP for each continent and year combination
      
      GDPsummaryDF <- myGapData %>%
        group_by(continent, year) %>%
        summarise(ContinentTotalGDP = sum(TotalGDP), 
                  ncountries = n())
      
      # world total GDP
      
      GDPyearDF <- myGapData %>%
        group_by(year) %>%
        summarise(YearTotalGDP = sum(TotalGDP))
      
      # join the continent annual GDP with total world GDP
      #    and then calculate country % of world total GDP and rescale units
      
      GDPcombo <- left_join(GDPsummaryDF, GDPyearDF, by="year")
      
      GDPcombo <- GDPcombo %>% 
        mutate(PropWorldGDP = ContinentTotalGDP / YearTotalGDP,
               PctWorldGDP = 100*PropWorldGDP,
               ContGDPBillions = ContinentTotalGDP/1000000000)
      
      GDPshare07 <- GDPcombo %>%
        filter(year==2007) %>%
        select(continent,PctWorldGDP)
      #  GDPshare07
      
      # waffle(parts=GDPshare07$PctWorldGDP,
      #        xlab="1 sq == 1% world GDP in 2007",rows=10)
      
      pctGDP <- GDPshare07$PctWorldGDP
      names(pctGDP) <- as.vector(GDPshare07$continent)
      # pctGDP    

      # explicit rounding to clean up display
      pctGDP2 <- pctGDP
      pctGDP2[4] <- 26
      #  sum(pctGDP2)   # always good to build in checks
      
      pctGDP2 <- round(pctGDP2)
      sum(pctGDP2)
      
      # order waffle plot in terms of decreasing world GDP share
      
      dd <- order(pctGDP2, decreasing=TRUE)
#      waffle(parts=pctGDP2[dd],xlab="1 sq == 1% world GDP in 2007",rows=10)

      jpeg('C:\\Users\\baileraj\\Documents\\book-SPiS-2nd-ed\\chapter08\\ch08-fig8.10.jpg')
#      waffle(parts=pctGDP2[dd],xlab="1 sq == 1% world GDP in 2007",rows=10)
	  waffle(parts=pctGDP2[dd],xlab="1 sq == 1% world GDP in 2007",
                    colors=brewer.pal(n=5, name="BrBG"),
                    rows=10)
      dev.off()

endsubmit;

quit;

/*   H O M E W O R K data  ============================== */

/* 
  Problem 1
*/
data meat;
  input condition $ logcount @@;
  iPlastic = (condition= "Plastic");
  iVacuum = (condition= "Vacuum");
  iMixed = (condition= "Mixed");
  iCO2 = (condition= "Co2");
  datalines;
Plastic	7.66 Plastic 6.98 Plastic 7.80
Vacuum	5.26 Vacuum	5.44  Vacuum 5.80
Mixed	7.41 Mixed	7.33  Mixed 7.04
Co2		3.51 Co2	2.91  Co2 3.66
;
run;

title "bacteria growth under 4 packaging conditions";


/*
  Problem 7
*/

data Fitness;
   input Age Weight Oxygen RunTime @@;
   datalines;
44 89.47 44.609 11.37
40 75.07 45.313 10.07
44 85.84 54.297 8.65
42 68.15 59.571 8.17
38 89.02 49.874 .
47 77.45 44.811 11.63
40 75.98 45.681 11.95
43 81.19 49.091 10.85
44 81.42 39.442 13.08
38 81.87 60.055 8.63
44 73.03 50.541 10.13
45 87.66 37.388 14.03
45 66.45 44.754 11.12
47 79.15 47.273 10.60
54 83.12 51.855 10.33
49 81.42 49.156 8.95
51 69.63 40.836 10.95
51 77.91 46.672 10.00
48 91.63 46.774 10.25
49 73.37 . 10.08
57 73.37 39.407 12.63
54 79.38 46.080 11.17
52 76.32 45.441 9.63
50 70.87 54.625 8.92
51 67.25 45.118 11.08
54 91.63 39.203 12.88
51 73.71 45.790 10.47
57 59.08 50.545 9.93
49 76.32 . .
48 61.24 47.920 11.50
52 82.78 47.467 10.50
;





/* PROGRAM bonus example ..............................  
   simulating data and generating simple graph in R
*/

proc iml;
  submit/R;
     xx <- rnorm(1000)
	 yy <- 3 + 2*xx + 4*rnorm(length(xx))
	 library(ggplot2)
	 myDF <- data.frame(x=xx,y=yy)
	 ggplot(aes(x=x,y=y), data=myDF) + geom_point()
  endsubmit;
quit;


/* PROGRAM bonus example ..............................  
   bootstrapping to get CI for mean

   Canty, Angelo and Brian Ripley. 2008. boot: Bootstrap R (S-Plus) 
       Functions. R Package Version 1.2-33. 

*/

proc iml;
  submit/R;
     xx <- rnorm(1000)
	 yy <- 3 + 2*xx + 4*rnorm(length(xx))
	 library(ggplot2)
	 myDF <- data.frame(x=xx,y=yy)
	 ggplot(aes(x=x,y=y), data=myDF) + geom_point()
  endsubmit;

* define SAS/IML matrix with AGE data;
  myAGEmat = {
   44 40 44 42 38 47 40 43 44 38 44 45 45 47 54 49 51 51 48 49 57 54 52 50 51 54 51 57 49 48 52
 };
  myAGEmat = t(myAGEmat);
  mattrib myAGEmat colname={AGE};
  print myAGEmat;

* Export matrix to R;
  run ExportMatrixToR(myAGEmat, "age.df");

  submit / R;
  age.df
  mymean <- function(x,ii) mean(x[ii])

  library(boot) 

  set.seed(9035768)
  myboots.mean <- boot(age.df[,1], mymean, R=4000)
  myboots.mean.ci <- boot.ci(myboots.mean, type = c("perc","bca"),
                     conf=c(0.90, 0.95))
  names(myboots.mean)
  names(myboots.mean.ci)
  myboots.mean.ci

  hist(myboots.mean$t,xlab="Means",
     main="Histogram of means from bootstrap samples")
  abline(v=myboots.mean.ci$percent[1,4:5])   # percentile limits
  abline(v=myboots.mean.ci$bca[1,4:5],lty=2) # bca limits

endsubmit;

quit;



