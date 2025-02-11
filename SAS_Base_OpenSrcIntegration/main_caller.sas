/*-----------------------------------------------------------------------------
---- Example: SAS program that calls Python, R using Java Object --------------
------------------------------------------------------------------------------*/

*** WORKING DIRECTORY      (----- USER UPDATE NEEDED -----);
%let WORK_DIR = C:\SGF2015\OpenSrcIntegration;	
*** SYSTEM PYTHON LOCATION (----- USER UPDATE NEEDED -----); 
%let PYTHON_EXEC_COMMAND = c:\users\saswtw\Anaconda3\python.exe; 			
*** SYSTEM R LOCATION      (----- USER UPDATE NEEDED -----);
%let R_EXEC_COMMAND = C:\Program Files\R\R-4.2.0\bin\Rscript.exe;

*** JAVA LIBRARIES/CLASS FILES LOCATION;
%let JAVA_BIN_DIR = &WORK_DIR.\bin;
%put &JAVA_BIN_DIR; 

options linesize = MAX; 
ods html close; 
ods listing; 


*** VALIDATE JAVA CLASSPATH; 
data _null_; 
  length _x1 $32767; 
  _x1 = sysget('CLASSPATH');  
  _x2 = index(upcase(trim(_x1)), %upcase("&JAVA_BIN_DIR")); 
  if _x2 = 0 then put "ERROR: Invalid Java Classpath.";
run; 


/*** Part II: R ***/
data _null_; 
  length rtn_val 8;
  *** R program takes working directory as first argument;
  r_pgm = "&WORK_DIR.\digitsdata_svm.R";
  r_arg1 = "&WORK_DIR";      
  r_call = cat('"', trim(r_pgm), '" "', trim(r_arg1), '"'); 

  declare javaobj j("dev.SASJavaExec", "&R_EXEC_COMMAND", r_call); 
  j.callIntMethod("executeProcess", rtn_val);
run; 


proc import out = predict_R 
            datafile = "&WORK_DIR.\predict_test_R.csv" 
            dbms = csv 
            replace;
  getnames = no;
run;

proc import out = digitsdata_17_test 
            datafile = "&WORK_DIR.\digitsdata_17_test.csv" 
            dbms = csv 
            replace;
  getnames = yes; 
run;

data cmp_py_r;
  set digitsdata_17_test (keep=label);
/*  set predict_py (rename=(var1=pred_py));*/
  set predict_r (rename=(var1=pred_r));
run;

proc freq data = cmp_py_r;
/*  table label*pred_py / norow nocol;*/
  table label*pred_r / norow nocol;
run;
