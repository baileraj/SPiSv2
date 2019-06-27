/*
   CHAPTER 07:  ===========================

   Revised:  27 June 2019

*/

/* set up for directories ................................... */
%let dir=C:\Users\baileraj\Documents\book-SPiS-2nd-ed;
%let subdir=chapter07;

/* template code that defines a style for output produced ... */
%include "&dir\book_template_and_options.sas";   * page options and CustomSaphire specification;

/* need to use this so graphics embedded in ODS RTF are PNG and not WMF */ 
ods graphics on / imagefmt=png;


/* ================================================== */
/* Program 7.1 - counting unique letters in a familiar pangram */

data pangram_letter;
  length line $80. letter $1.;
  input line &;
  line_length = length(line);
  call symput('sentence_read', substr(line,1,line_length));
  do letter_pos = 1 to line_length;
    letter = lowcase(substr(line,letter_pos, 1));  
	letter_index = index('abcdefghijklmnopqrstuvwxyz', letter);
	if letter_index > 0 then output;  * index()>0 if 'a-z' in variable letter;
  end;
datalines;
The quick brown fox jumps over the lazy dog.
;
run;
ods rtf file="&dir\&subdir\ch7-fig7.1.rtf"
        image_dpi=300  bodytitle
        style=sasuser.customSapphire;

proc print data=pangram_letter;
run;

proc freq data=pangram_letter ;
  table letter / out=letter_freqs;
run;

proc print data=letter_freqs;
run;

proc sql;
  select count(*) from work.letter_freqs;
  select count(*) into :N_unique_letters from work.letter_freqs;
quit;

%put Number of unique letters in "&sentence_read" = %trim(&N_unique_letters);
ods rtf close;

/* ================================================== */
/* Program 7.2 - counting unique letters in multiple input sentences */
/*  what if you have a second sentence?  */

data pangram_letter2_lines;
  length line $80.;
  input line &;
  line_Number = _N_;
datalines;
The quick brown fox jumps over the lazy dog.
This sentence doesn't have all letters.
;
run;
proc print data=pangram_letter2_lines;
run;

data pangram_letter2;
  retain line_Number 0;
  length line $80. letter $1.;
  input line &;
  line_Number = Line_number + 1;
  line_length = length(line);
  do letter_pos = 1 to line_length;
    letter = lowcase(substr(line,letter_pos, 1));  
	letter_index = index('abcdefghijklmnopqrstuvwxyz', letter);
	if letter_index > 0 then output;
  end;
datalines;
The quick brown fox jumps over the lazy dog.
This sentence doesn't have all letters.
;
proc print data=pangram_letter2;
run;

proc freq data=pangram_letter2 ;
  table line_Number*letter / out=letter_freqs2;
run;

ods rtf file="&dir\&subdir\ch7-fig7.2.rtf"
        image_dpi=300  bodytitle
        style=sasuser.customSapphire;

proc print data=letter_freqs2;
run;

data count;
  retain line_num letter_Count;
  set letter_freqs2;
  by line_Number;

  if First.line_Number then do;
    letter_Count = 1;
  end;
  else if Last.line_Number then do;
    letter_Count = letter_Count + 1;
    output;
  end;
  else do;
    letter_Count = letter_Count + 1;
  end;

run;
  
data unique_letters;
  merge pangram_letter2_lines count;
  by line_number;
run;

proc print data=unique_letters;
  var line_Number line letter_Count;
run;

ods rtf close;

/* BONUS MATERIAL ........................................
    Alternatives for counting number of rows ... 
REF
  https://www.listendata.com/2017/04/number-of-observations-in-sas-data.html
*/

* use Descriptor portion of data set;
data _NULL_;
 if 0 then set work.letter_freqs nobs=n;
 put "no. of observations =" n;
 stop;
run;

data _NULL_;
 if 0 then set work.letter_freqs nobs=n;
 call symputx('totobs',n);
 stop;
run;
%put no. of observations = &totobs;

data _NULL_;
  set work.letter_freqs nobs=N;
  if _N_ = 2 then stop;
  put 'Number of unique letters = ' N;
run;


/* ================================================== */
/* Program 7.3 - removing stop words from a familiar pangram */
/*   stop words - suggested sources from Raymond Ng
              https://gist.github.com/sebleier/554280   * used in data set below
              https://pythonspot.com/nltk-stop-words/
*/

data pangram_letter2_lines;
  length word $ 10;
  input word $ @@;
  word = lowcase(word);
datalines;
The quick brown fox jumps over the lazy dog.
This sentence doesn't have all letters.
;
run;

proc print data=pangram_letter2_lines;
run;

data stopwords;
  length word $ 10;
  input word $ @@;
datalines;
i me my myself we our ours 
ourselves you your yours yourself yourselves
he him his himself she her hers herself it its
itself they them their theirs themselves what which
who whom this that these those am is are was were
be been being have has had having do does did doing
a an the and but if or because as until while of
at by for with about against between into through
during before after above below to from up down
in out on off over under again further then once
here there when where why how all any both each few
more most other some such no nor not only own same
so than too very s t can will just don should now
;
run;

proc print data=stopwords;
run;

/* using DATA STEP programming with Merges to remove stop words */
proc sort data=pangram_letter2_lines; 
   by word;
run;
proc sort data=stopwords; 
   by word;
run;

data PangramNotStop;
  merge pangram_letter2_lines (in=inP) stopwords (in=inS);
  by word;
  if inP=1 and inS=0;
run;

ods rtf file="&dir\&subdir\ch7-fig7.3.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=PangramNotStop;
run;
ods rtf close;

/* Program 7.4:  Using PROC SQL to remove stop words 
REF: https://communities.sas.com/t5/SAS-Data-Mining-and-Machine/How-to-eliminate-articles-prepositions-and-pronous-from-data/td-p/209159
*/
 
* now use proc sql to select the words that are in the dataset *pangram*
       but NOT in the dataset *stopwords*;

proc sql; 
  create table PangramNotStop2 as
  select *
  from pangram_letter2_lines
  where word NOT IN (select word from stopwords)
  order by word;
quit;
proc print data=PangramNotStop2;
run;

/* ========================================================== */
/*
Program 7.5:  Extract bi-grams and removing pairs with stop words

Limitations:
   Bi-grams / pairs defined within sentences and not across sentences
   Assumes that sentences end with either period (.) or question mark (?)
   Assumes maximum word length of 10 letters
*/

data bigrams;
  length word $ 10 word1 $ 10 word2 $ 10;
  retain word1 word2;
  retain nwords_read 0 nsentences_read 1;
  input word $ @@;
  word = lowcase(word);
  nwords_read = nwords_read + 1;
  if nwords_read = 1 then do;
     word1 = word;
  end;
  else if nwords_read = 2 then do;
     word2 = word;
	 output;
  end;
  else if nwords_read > 2 then do;
     word1 = word2;
	 word2 = word;
     output;
  end;
  if index(word,".")>0 or index(word,"?")>0 then do;  * punctuation!;
     nsentences_read = nsentences_read +1;
     nwords_read = 0;
  end;
*  put word nwords_read nsentences_read; 
datalines;
The quick brown fox jumps over the lazy dog. This sentence doesn't have all letters. The third sentence spans
multiple lines and challenges the programmer to first parse the datalines into sentences before breaking this
into bi-grams.  Can the author figure out how to do this?
;
run;

proc print data=bigrams;
run;

data bigrams2; set bigrams;
     word_pair = cat(trim(word1), " ", trim(word2));
	 word_pair = tranwrd(word_pair,".","");
     word_pair = tranwrd(word_pair,"?","");
run;

proc print data=bigrams2;
run;

proc sql; 
  create table BigramNotStop2 as
  select *
  from bigrams2
  where word1 NOT IN (select word from stopwords) and
        word2 NOT IN (select word from stopwords)
  ;
quit;

ods rtf file="&dir\&subdir\ch7-fig7.4.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=BigramNotStop2;
  var word_pair nsentences_read;
run;
ods rtf close;


/* ========================================================== */

/* --------------------------------------------------------------------------------*/
/* Program 7.6: Pseudocode for sentiment analysis of State of the Union addresses  */

/* 1. Read / process SOTU from 2010 and 2018 ................................................
/*    a. read data from whitehouse.gov
      b. remove special characters and words describing crowd reactions
      c. create text file with lines from SOTUs
      d. read and process words from each line

   2. Read data set with sentiment values

   3. Merge with SOTU data sets, keeping words with values
      a. sort data sets by word
      b. merge data sets by word
      c. keep words that are in both a SOTU speech and 
         in the sentiments data set

   4. Generate contingency tables and mosaic plots displaying data

*/



/* ================================================================= */

/*  Program 7.7:  Sentiment analysis of SOTU in 2010 and 2018
   1. Read / process SOTU from 2010 and 2018 ................................................
      a. read data from whitehouse.gov
      b. remove special characters and words describing crowd reactions
      c. create text file with lines from SOTUs
      d. read and process words from each line

   2. Read data set with sentiment values

   3. Merge with SOTU data sets, keeping words with values
      a. sort data sets by word
      b. merge data sets by word
      c. keep words that are in both a SOTU speech and 
         in the sentiments data set

   4. Generate contingency tables and mosaic plots displaying data

   Coding Contributions: Bunyod Tusmatov 

Data sources:
........ Downloaded 2018 SOTU transcript from 
https://www.whitehouse.gov/briefings-statements/president-donald-j-trumps-state-union-address/

Saved as file:
President Donald J. Trump's State of the Union Address _ The White House.HTML

........  Downloaded Obama 2010 SOTU transcript from 
https://obamawhitehouse.archives.gov/photos-and-video/video/2010-state-union-address#transcript

Saved as file:
The 2010 State of the Union Address _ The White House.HTML

Afinn lexicons were received from the author's GitHub repository:  
    https://github.com/fnielsen/afinn/tree/master/afinn/data 
Version used: AFINN-111.txt. 
Nielsen, F. �. (2011). A new ANEW: Evaluation of a word list for sentiment analysis in 
     microblogs. arXiv preprint arXiv:1103.2903.

*/



/* =================================================================== */


filename tSOTU "&dir\&subdir\President Donald J. Trump's State of the Union Address _ The White House.HTML";

data trump2018;
infile tSOTU length=len lrecl=32767;
input line $varying32767. len;
 line = strip(line);
 if len>0;
run;
/*
proc print data=trump2018;   * used to determine starting / ending line of SOTU;
run;
*/ 
* we need to remove (Laughter.) (Applause.) and special characters  ;
data trump2;
  set trump2018(firstobs=148 obs=296);
  line = TRANWRD(line,"�","");
  line = TRANWRD(line,"(Laughter.)","");
  line = TRANWRD(line,"(Applause.)","");
  line = TRANWRD(line,"(Applause.)","");
  line = TRANWRD(line,"(applause)","");
  line = TRANWRD(line,"(applause.)","");
  line = TRANWRD(line,"((Laughter and applause.)",""); 
  line = TRANWRD(line,"(Laughter and applause.)","");
  line = TRANWRD(line,"’","'");
  line = TRANWRD(line,"–","");
  line = TRANWRD(line,"— ","");
  line = TRANWRD(line,"�","");
  line = TRANWRD(line,"&nbsp;","");
  line = TRANWRD(line,"</p>","");
  line = TRANWRD(line,"<p>","");
  line = TRANWRD(line,"…","");
  line = TRANWRD(line,"naïve","naive");
  line = TRANWRD(line,"<br>","");
run;

proc print data=trump2;
run;

/* one solution:
   write out to a text file that is then read one word at a time ...
*/

data _NULL_;
  set trump2;
  file "&dir\&subdir\sotu2018.txt";
  put line;
run;

data sotu2018;
  length word $ 20.;
  infile "&dir\&subdir\sotu2018.txt";
  input word $ @@;
  word = COMPRESS(word, ".,!?_();:1234567890+-$[]{}");  * remove numbers+;
  word = LOWCASE(word);          * convert all letters to lowercase;
  if (word=" ") then delete;     * remove words that are blanks;
  position = _n_;                * position of word in speech;
  year = 2018;
run;

/*
........  Downloaded Obama 2010 SOTU transcript from 
https://obamawhitehouse.archives.gov/photos-and-video/video/2010-state-union-address#transcript

Saved as file:
The 2010 State of the Union Address _ The White House.HTML

*/
filename oSOTU "&dir\&subdir\The 2010 State of the Union Address _ The White House.HTML";

data obama2010;
infile oSOTU length=len lrecl=32767;
input line $varying32767. len;
 line = strip(line);
 if len>0;
run;

data obama2;
  set obama2010(firstobs=261 obs=374);
  line = TRANWRD(line,"(Applause.)","");
  line = TRANWRD(line,"</p>","");
  line = TRANWRD(line,"<p>","");
  line = TRANWRD(line,"&nbsp;","");
  line = TRANWRD(line,"–","");
  line = TRANWRD(line,"(Laughter.)","");
  line = TRANWRD(line,"(applause)","");
  line = TRANWRD(line,"naïve","naive");
  line = TRANWRD(line,"<br>","");
  line = TRANWRD(line,"(Laughter and applause.)","");
run;

data _NULL_;
  set obama2;
  file "&dir\&subdir\sotu2010.txt";
  put line;
run;

data sotu2010;
  length word $ 20.;
  infile "&dir\&subdir\sotu2010.txt";
  input word $ @@;
  word = COMPRESS(word, ".,!?_();:1234567890+-$[]{}");  * remove numbers+;
  word = LOWCASE(word);          * convert all letters to lowercase;
  if (word=" ") then delete;     * remove words that are blanks;
  position = _n_;                * position of word in speech;
  year = 2010;
run;

/* =================================================================================== */


/* 2. Read data with sentiment values  */

filename afinnweb URL "https://raw.githubusercontent.com/fnielsen/afinn/master/afinn/data/AFINN-111.txt";

data work.afinn;
  length word $ 20;
  infile afinnweb DLM='09'X DSD TRUNCOVER;;
  input word $ value;
run;


/* 3. Merge with SOTU data sets, keeping words with values ....... */
/* 3.a sort data by word before merging .......................... */
proc sort data=afinn;
  by word;
run;

proc sort data=sotu2010;
  by word;
run;

proc sort data=sotu2018;
  by word;
run;

/* 3.b. merge data sets by word ................................. */
/* 3.c. keep words that are in both a SOTU speech and in the 
        sentiment data set ...................................... */

data sent_sotu2010;
  merge sotu2010 (in=sotu) afinn (in=senti);
  by word;
  if (sotu AND senti) then output; * word in SOTU AND has sentiment dataset;
run;

data sent_sotu2018;
  merge sotu2018 (in=sotu) afinn (in=senti);
  by word;
  if (sotu AND senti) then output; * work not in SOTU or SOTU does not have sentiment word;
run;

/* create dataset with frequency of each year - word sentiment value .................................. */
/*        define variable that reflects either positive or negative sentiment                           */
data sotu1018;
  set sent_sotu2010 sent_sotu2018;
  positive = value>0;
run;

/* 4. Generate contingency tables and mosaic plots .............. */

/* create Mosaic plot to display distribution of sentiment by year
  REF: Rick Wicklin (2013) Create mosaic plots in SAS by using PROC FREQ
  https://blogs.sas.com/content/iml/2013/11/04/create-mosaic-plots-in-sas-by-using-proc-freq.html
*/

*ods rtf file="&dir\&subdir\ch7-fig7.1-2.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;

ods graphics on /  imagename="Ch07Fig"
                   reset=index imagefmt=EPSI border=OFF;
ods listing image_dpi=300 style=journal;


proc freq data=sotu1018;
  tables value*year / norow chisq plots=MOSAIC; /* alias for MOSAICPLOT */
run;

proc freq data=sotu1018;
  tables positive*year / norow chisq plots=MOSAIC; /* alias for MOSAICPLOT */
run;
ods listing close;
*ods rtf close;


/* ============================================================================== */
/* Program 7.8 processing data extracted from web page
   Contributor:  Sooyeong Lim
    
Data source:  
     http://bulletin.miamioh.edu/courses-instruction/sta/
*/

data test;
  input coursetags $ 1-150;
  datalines;
<p class="courseblocktitle"><strong>STA 125.  Introduction to Business Statistics.  (3)</strong></p>
<p class="courseblocktitle"><strong>STA 147.  First Year Seminar in Mathematics and Statistics.  (1)</strong></p>
<p class="courseblocktitle"><strong>STA 177.  Independent Studies.  (0-5)</strong></p>
<p class="courseblocktitle"><strong>STA 261.  Statistics.  (4) (MPF, MPT)</strong></p>
<p class="courseblocktitle"><strong>STA 301.  Applied Statistics.  (3) (MPT)</strong></p>
run;

proc print data=test;
run; 

data test2;
  set test;
  index_htm = index(coursetags, '<strong>');   * end of stuff before STA xxx;
  firstOff = substr(coursetags, index_htm+12);  * get rid of front stuff;
  coursenum = substr(firstOff,1,index(firstOff," ")-2);
  coursedescr = substr(firstOff, 6, index(firstOff,"(")-9); 
  hours = substr(firstOff, index(firstOff,"(")+1, 
                           index(firstOff,')')-index(firstOff,'(')-1);
run;

ods rtf file="&dir\&subdir\ch7-fig7.9.rtf"
        image_dpi=300  
        style=sasuser.customSapphire;
proc print data=test2 noobs;
  var firstOff coursenum coursedescr hours;  
run;
ods rtf close;

/* ===================================================================== */
/* Program 7.9
  - MODULE 5, Video 6 --------------------------------------------------
  REF:   http://support.sas.com/resources/papers/proceedings11/062-2011.pdf
/* 
LRECL = 32767 <- max record length (default 256)
        changes helps to avoid truncating lines

* %STR not strictly necessary here but provides a wrapper to text that may have special characters;
*/

filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/sta/)" DEBUG;

data statbull;
  format webpage $1000.;   * long enough to hold most HTML code lines;
  infile source lrecl=32767 DELIMITER=">"; * read source from web page;
  input webpage $char500. @@;
run;

data statbull2;
  set statbull;
  if index(webpage,'STA') NE 0 then output;  * select lines with STA, elimates lots of tags;
run;

/* step that get input data close to that considered in Program 7.8 */
data statbull3;
  set statbull2;
  if index(webpage,'</strong') NE 0 then output; * narrow down to only courses - lines with /strong;
run;

data statbull4;
  set statbull3;
  index_num=index(webpage,'STA');
  course_num_plus = substr(webpage,index_num+5);  * removes 'STA ' from each line;
  course_num = substr(course_num_plus,1,index(course_num_plus,'.')-1);

  * clean up 4xx/5xx;
  if index(course_num, "/") then
     course_num = substr(course_num, 1, 4) || substr(course_num, 10,3);

  course_descrip_plus = substr(course_num_plus,index(course_num_plus,'.')+1);
  coursedescr = substr(course_descrip_plus, 1, index(course_descrip_plus,".")-1);
  hours = substr(course_descrip_plus, 
                           index(course_descrip_plus,"(")+1, 
                           index(course_descrip_plus,')')-index(course_descrip_plus,'(')-1);
run;

data statbull5;
  set statbull4;
  * Adding an indicator for grduate level class;
  if (substr(course_num,1,1)="6") then graduate_course='Y';
  else if (substr(course_num,4,1)="/") then graduate_course='Y';
  else graduate_course='N';
	
  * Get the maximum credit hours for the classes;
  * reverse function might be useful to get the maximum credit hours;
  max_index=index(hours,'maximum');
  dash_index=index(hours,'-');
  if max_index ne "0" then max_capacity = substr(hours, max_index+8, 2);
  else  max_capacity='N/A';

  if max_index ne "0" then hour=substr(hours,1, max_index-3);
  else hour=hours;

  * Categorize the level of courses;
  if (substr(course_num,1,1)="1") then level="1xx"; *In the original code there was no section for 1xx level. I added it here.;
  else if (substr(course_num,1,1)="2") then level="2xx";
  else if (substr(course_num,1,1)="3") then level="3xx";
  else if (substr(course_num,1,1)="4") then level="4xx/5xx";
  else level="6xx";

run;

ods rtf file="&dir\&subdir\ch7-fig7.10.rtf"
        image_dpi=300 bodytitle
        style=sasuser.customSapphire;

proc print data=statbull5 noobs label;
	var course_num coursedescr hour graduate_course max_capacity;
run;

proc freq data=statbull5;
  title "Number of stat courses at each level";
  table level / nocum ;
run;
ods rtf close;






/* ======================================================================= */


/*------------------------------------------------------------------------------*/

/* Extracting information using regular expressions */

/*  Regular expressions are powerful tools for string processing.
    Powerful but not easily readable!

    RESOURCE:  testing regular expressions - 
    http://www.regexplanet.com/advanced/java/index.html

" There is no gentle beginning to regular expressions. 
  You are either into hieroglyphics big time - in which case you will love this stuff 
  - or you need to use regular expression, in which case your only reward may be a 
  headache. But they are jolly useful. Sometimes."
  from:  http://www.zytrax.com/tech/web/regex.htm

*/

/* ==================================================================== */
/* Program 7.10:

*/
data PRXintro;
If _N_ = 1 then do;
  Pattern_cnum = PRXPARSE("/STA/");                   * "STA";
  Pattern_c5Num = PRXPARSE("/(\/STA\s)/");            * "/STA ";
  end;

  retain Pattern_cnum Pattern_c5Num;
  input coursetags $ 1-150;
  call PRXSUBSTR(Pattern_cnum, coursetags, start_c, length_c);
  call PRXSUBSTR(Pattern_c5Num, coursetags, start_c5, length_c5);

  cnum    = substr(coursetags, start_c + 4,          length_c);
  cnum5   = substr(coursetags, start_c5 + length_c5, 3);
datalines;
<p class="courseblocktitle"><strong>STA 402/STA 502.  Statistical Programming.  (3)</strong></p>
;
proc print data=PRXintro;
run;


/* ==================================================================== */
/* Program 7.11
*/

data PRXintro2;
If _N_ = 1 then do;
  Pattern_num_anywhere = PRXPARSE("/\d/");
  Pattern_num_start = PRXPARSE("/\A\d/");
  Pattern_num_twoORmore = PRXPARSE("/\d\d+/");
  Pattern_num_boundary = PRXPARSE("/\d\b/");
  Pattern_num_interior = PRXPARSE("/\d\B/");
  Pattern_num_btwn = PRXPARSE("/\D\d\D/");
  Pattern_letter_start = PRXPARSE("/\A[A-Z]/");
  end;

  retain Pattern_num_anywhere Pattern_num_start Pattern_num_twoORmore 
         Pattern_num_boundary Pattern_num_interior Pattern_num_btwn
         Pattern_letter_start;
  input strings $ 1-80;
  call PRXSUBSTR(Pattern_num_anywhere,  strings, start_1, length_1);
  call PRXSUBSTR(Pattern_num_start,     strings, start_2, length_2);
  call PRXSUBSTR(Pattern_num_twoORmore, strings, start_3, length_3);
  call PRXSUBSTR(Pattern_num_boundary,  strings, start_4, length_4);
  call PRXSUBSTR(Pattern_num_interior,  strings, start_5, length_5);
  call PRXSUBSTR(Pattern_num_btwn,      strings, start_6, length_6);
  call PRXSUBSTR(Pattern_letter_start,  strings, start_7, length_7);

  datalines;
8675309
Jenny I got your number
I feel like a numb3r
My name is 905.
;
proc print data=PRXintro2;
  var strings -- length_7;
run;


/*
  Program 7.12

*/


filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/sta/)" DEBUG;

data statbull;
  format coursetags $1000.;   * long enough to hold most HTML code lines;

If _N_ = 1 then do;
  Pattern_cnum = PRXPARSE("/\d{3}/");                    * 3 digits;
  Pattern_c5Num = PRXPARSE("/(\/STA)/");                 * /STA;
  Pattern_descrip = PRXPARSE("/\.\s\s[a-zA-Z,\s]+\./");  * . followed by 2 spaces, text and ending with .;
  Pattern_hours_start = PRXPARSE("/\([0-9]/");           * ( followed by a digit;
  Pattern_hours_stop = PRXPARSE("/\d\)/");               * digit followed by );
  end;

  retain Pattern_cnum Pattern_c5Num Pattern_descrip Pattern_hours_start Pattern_hours_stop;

  infile source lrecl=32767 DELIMITER=">"; * read source from web page;
  input coursetags $char500. @@;

  if (index(coursetags,'STA') NE 0) and 
     (index(coursetags,'</strong') NE 0);  * select lines with STA and /strong, elimates lots of tags;

  call PRXSUBSTR(Pattern_cnum, coursetags, start_c, length_c);
  call PRXSUBSTR(Pattern_c5Num, coursetags, start_c5, length_c5);
  call PRXSUBSTR(Pattern_descrip, coursetags, start_d, length_d);
  call PRXSUBSTR(Pattern_hours_start, coursetags, start_p, length_start);
  call PRXSUBSTR(Pattern_hours_stop, coursetags, stop_p, length_stop);

  cnum    = substr(coursetags, start_c,       length_c);
  cnum5   = substr(coursetags, start_c5 + 6,  3.);
  single_num = INPUT(cnum, 3.);                     * convert character to numbers;                        
  double_num = INPUT(cnum5, 3.);
  descrip = substr(coursetags, start_d + 3,   length_d - 4);
  hours   = substr(coursetags, start_p + 1,   stop_p - start_p);

run;
proc print data=statbull;
  var coursetags single_num double_num descrip hours;
run;


/*
Notes:
  Converting between character and numeric types - INPUT() and PUT() functions
https://blogs.sas.com/content/sgf/2015/05/01/converting-variable-types-do-i-use-put-or-input/
*/



/* ============================================================================== */

* HOMEWORK SOLUTION ................... ;
*** Let's try farmer school's finance department case;

/* Program 7.4
  - MODULE 5, Video 6 -------------------------------------------------- */
  REF:   http://support.sas.com/resources/papers/proceedings11/062-2011.pdf
/* 
LRECL = 32767 <- max record length (default 256)
        changes helps to avoid truncating lines
*/
/* *filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/sta/)"         DEBUG;
  

* %STR not strictly necessary here but provides a wrapper to text that may have special characters;
*/
filename source URL "%STR(http://bulletin.miamioh.edu/courses-instruction/fin/)" DEBUG;
* %STR not strictly necessary here but provides a wrapper to text that may have special characters;


data finbull;
  format webpage $1000.;   * long enough to hold most HTML code lines;
  infile source lrecl=32767 DELIMITER=">"; * read source from web page;
  input webpage $char500. @@;
run;

proc print data=finbull;
run;

data finbull2;
  set finbull;
  if index(webpage,'FIN') NE 0 then output;  * change the course char from STA to FIN;
run;
proc print data=finbull2;
run;

data finbull3;
  set finbull2;
  if index(webpage,'</strong') NE 0 then output; * narrow down to only courses - lines with /strong;
run;
proc print data=finbull3;
run;

data finbull4;
  set finbull3;
  index_num=index(webpage,'FIN');
  course_num_plus = substr(webpage,index_num+5);  * removes 'FIN ' from each line;
  course_num = substr(course_num_plus,1,index(course_num_plus,'.')-1);

  * clean up 4xx/5xx;
  if index(course_num, "/") then
     course_num = substr(course_num, 1, 4) || substr(course_num, 10,3);

  course_descrip_plus = substr(course_num_plus,index(course_num_plus,'.')+1);
  coursedescr = substr(course_descrip_plus, 1, index(course_descrip_plus,".")-1);
  hours = substr(course_descrip_plus, 
                           index(course_descrip_plus,"(")+1, 
                           index(course_descrip_plus,')')-index(course_descrip_plus,'(')-1);
run;
proc print data=finbull4;
run;

proc print data=finbull4 noobs label;
  var course_num coursedescr hours;
run;

data finbull5;
  set finbull4;
  * Adding an indicator for grduate level class;
  if (substr(course_num,1,1)="6") then graduate_course='Y';
  else if (substr(course_num,4,1)="/") then graduate_course='Y';
  else graduate_course='N';
	
  * Get the maximum credit hours for the classes;
  * reverse function might be useful to get the maximum credit hours;
  max_index=index(hours,'maximum');
  dash_index=index(hours,'-');
  if max_index ne "0" then max_capacity = substr(hours, max_index+8, 2);
  else  max_capacity='N/A';

  if max_index ne "0" then hour=substr(hours,1, max_index-3);
  else hour=hours;

  * Categorize the level of courses;
  if (substr(course_num,1,1)="1") then level="1xx"; *In the original code there was no section for 1xx level. I added it here.;
  else if (substr(course_num,1,1)="2") then level="2xx";
  else if (substr(course_num,1,1)="3") then level="3xx";
  else if (substr(course_num,1,1)="4") then level="4xx/5xx";
  else level="6xx";
run;

proc print data=finbull5 noobs label;
	var course_num coursedescr hour graduate_course max_capacity;
run;


proc freq data=finbull5;
  title "Number of fin courses at each level";
  table level / nocum ;
run;


/* ================================================= */
/* ================================================= */
/* ================================================= */
/* ================================================= */
/* ================================================= */
/* ================================================= */
/* D E L E T E below ............................... */
/* ================================================= */
/* ================================================= */
/* ================================================= */
/* ================================================= */
/* ================================================= */

/* ==================================================================== */
/* Program 7.BONUS - code development / testing
*/
data test2;

If _N_ = 1 then do;
  Pattern_cnum = PRXPARSE("/\d{3}/");                    * 3 digits;
  Pattern_c5Num = PRXPARSE("/(\/STA\s)/");               * /STA;
  Pattern_descrip = PRXPARSE("/\.\s\s[a-zA-Z,\s]+\./");  * . followed by 2 spaces, text and ending with .;
  Pattern_hours = PRXPARSE("/\([0-9,-]+\)/") ;           * ( digits and possible - and ending with );
  end;

  retain Pattern_cnum Pattern_c5Num Pattern_descrip Pattern_hours;
  input coursetags $ 1-150;
  call PRXSUBSTR(Pattern_cnum, coursetags, start_c, length_c);
  call PRXSUBSTR(Pattern_c5Num, coursetags, start_c5, length_c5);
  call PRXSUBSTR(Pattern_descrip, coursetags, start_d, length_d);
  call PRXSUBSTR(Pattern_hours, coursetags, start_h, length_h);

  cnum    = substr(coursetags, start_c,              length_c);
  cnum5   = substr(coursetags, start_c5 + length_c5, 3);
  descrip = substr(coursetags, start_d + 3,          length_d - 3);
  hours   = substr(coursetags, start_h + 1,          length_h - 2);

 datalines;
<p class="courseblocktitle"><strong>STA 125.  Introduction to Business Statistics.  (3)</strong></p>
<p class="courseblocktitle"><strong>STA 147.  First Year Seminar in Mathematics and Statistics.  (1)</strong></p>
<p class="courseblocktitle"><strong>STA 177.  Independent Studies.  (0-5)</strong></p>
<p class="courseblocktitle"><strong>STA 261.  Statistics.  (4) (MPF, MPT)</strong></p>
<p class="courseblocktitle"><strong>STA 301.  Applied Statistics.  (3) (MPT)</strong></p>
<p class="courseblocktitle"><strong>STA 402/STA 502.  Statistical Programming.  (3)</strong></p>
;
ods rtf file="&dir\&subdir\ch7-fig7.11.rtf"
        image_dpi=300 bodytitle
        style=sasuser.customSapphire;
proc print;
  var coursetags cnum cnum5 descrip hours;
run;
ods rtf close;

/*
         1         2         3         4         5         6         7         8         9
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
<p class="courseblocktitle"><strong>STA 125.  Introduction to Business Statistics.  (3)</strong></p>
<p class="courseblocktitle"><strong>STA 147.  First Year Seminar in Mathematics and Statistics.  (1)</strong></p>
<p class="courseblocktitle"><strong>STA 177.  Independent Studies.  (0-5)</strong></p>
<p class="courseblocktitle"><strong>STA 261.  Statistics.  (4) (MPF, MPT)</strong></p>
<p class="courseblocktitle"><strong>STA 301.  Applied Statistics.  (3) (MPT)</strong></p>
<p class="courseblocktitle"><strong>STA 402/STA 502.  Statistical Programming.  (3)</strong></p>
*/


