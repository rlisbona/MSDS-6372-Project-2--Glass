

proc import datafile= '"\\client\c$\Users\anobs\Documents\GitHub\MSDS-6372-Project-2--Glass\Data\glass.csv' out = glass 
dbms=csv replace;
guessingrows = 214 ;
getnames = yes; 
label
RI = 		'RI  	- Refractive Index'
NA2O =		'NA20	- Sodium Oxide (Soda Ash)'
MGO = 		'MGO 	- Magnesium Oxide'
AL2O3 =	'AL203 - Aluminum Oxide'
SIO2 = 	'SI02	- Silicon Oxide (Silica Sand) '
K2O = 		'K20	- Potassium Oxide (Potash)'
CAO = 		'CA0	- Calcium Oxide (Limestone)'
BAO = 		'BA0 	- Barium Oxide'
FE2O3 = 	'FE2O3 - Iron Oxide'
;
run;

proc print data = glass label; run;
*Variable list;
*Obs ID RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3 TYPE ;


data glass;
retain ID TYPE RI SIO2 NA2O CAO MGO AL2O3 K2O BAO FE2O3;
set glass;
run;


ods graphics on /width = 11in height = 6in;
title1 "Scatter plot Chemical composition % weight x RI";
proc sgscatter data = glass;
compare y= RI x=( SIO2 NA2O CAO MGO AL2O3 K2O BAO FE2O3)/ reg ellipse = (type=mean) spacing = 4;
run;
ods graphics off;




title1 "Mean values for glass dataset";
proc means data = glass  maxdec = 2;
var RI SIO2 NA2O CAO MGO AL2O3 K2O BAO FE2O3;
output Out = GlassMeans mean = Mean std = Std ;
run;

* couldn't figure out how to get proc means sorted or get a cumulative column added so copied proc means output;
* and created the summary table in Excel;







* follows example in BLT 8.5 for crime statistics;
* should we standardize?  Chemical composition is same scale =% weight;
* should we use covariance.  http://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/viewer.htm#statug_princomp_syntax01.htm;
* SAS documentation says don't use COV unless the units in which variables measured are not comparible, most are, if we ommited RI-Refractive index and Type-Glass Type;
ods graphics on /width = 6in height = 4in;
title1 "Full PCA with dependent RI included";
proc princomp data = glass out=glassPC_all plots = all ;
var RI SIO2 NA2O CAO MGO AL2O3 K2O BAO FE2O3;
run;
ods graphics off;


ods graphics on /width = 6in height = 4in;
title1 "Principal Components N=4 ";
proc princomp data = glass out=glassPC plots = all N=4; * uses the first four factors;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;
ods graphics off;



ods graphics on /width = 6in height = 4in;
title1 "PCA using four factors";
proc princomp data = glass out=glassPC plots = pattern n=4; *N=4 uses the first four factors;
var RI SIO2 NA2O CAO MGO AL2O3 K2O BAO FE2O3;
*ID type;
run;
ods graphics off;


ods graphics on /width = 6in height = 4in;
title1 "PCA using four factors";
proc princomp data = glass out=glassPC plots = pattern n=4; *N=4 uses the first four factors;
var NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
*ID type;
run;
ods graphics off;

proc print data = glasspc;run;

ods graphics on /width = 6in height = 4in;
proc sgscatter data = glasspc;
compare y=RI x=(prin1-prin4)/ reg ellipse = (type=mean);
run;





* What do we do with this, somewhere it said to plot it?;
proc print data = glassPC; run;

title1 "Scatterplot of RI * Prin1-Prin9";
* but prin2-9 don't seem to make sense here, not sure how to interpret the plot;
proc sgscatter data = glassPC;
compare y= RI x=( Prin1 - Prin9)/ reg ellipse = (type=mean) spacing = 4;
run;




* Pretty much follows example in BLT 8.5;

*(ALGORITHM=EIG)  Says it goes after the method statement but I couldn't make it work, might give us the eigenvalue chart, not sure;

*Need to figure out how to scale everthing to same scale, might be CENSCALE, I'm not sure right now;
ods graphics on /width = 6in height = 4in;
title1 "PCR on RI using cross validation for component selection";
proc pls data = glass censcale method = pcr  cv=one cvtest  (stat=press) plots=all;
model  RI = NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;


* Figure out how many factors are used, I havent been able to get an eigenvalue table yet but Percent Variation accounted for table seems to show the same thing;
* of four factors;
* just not the eigenvalues;
* after we pick the number of factors then we use NFACT=XXX to rerun the model with the selected factors;
title1 "PCR using selected factors";
proc pls data = glass  method =pcr  cv=one cvtest (stat=press) nfact=4 plots=all;
model RI = NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3 /solution;
output out = glassPLS XSCORE=PRIN YSCORE=RIPLS PRESS;  *This gives us output but I don't see YSCORE or Residuals, XSCORE are the principal components;
run;

proc print data = glassPLS;run;


*   STOP HERE     ;
******************* Old unused code  *********************************************************************************;
* Can't use Type since it is catagorical, UGH!!;

title1 "PCR using cross validation for component selection";
proc pls data = glass method = pcr cv=one cvtest (stat=press);
model type = RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;


* PLS chose 2 components in above step so set nfact=2, but not sure what this means at this point;
title1 "PCR using selected factors";
proc pls data = glass method =pcr nfact=2;
model type = RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;



* attempt to create a nice box and whisker plot, gave up;

ods graphics on /width = 17in height = 10in;
* This doesn't work for RI, it produces a plot for each different value of RI;
proc boxplot data = glass;
plot  NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3 /
	header = 'Glass Composition' pos = tm;
	insetgroup min max ;
run; 





%let DSNAME = glass;
%let stat = Median;

data glasscomp;
set glass;
drop type;
run;

Proc stdize method = range data = &DSNAME out = Glass2;run;

proc means data = glasscomp &STAT STACKODSOUTPUT;
ODS output summary = STATOUT;
run;

proc SQL noprint;
select variable into :varlist seperated by ' '
from Statout order by &stat;
quit;

data wide / view = wide;
retain &varlist;
set glass2;
obsnum = _N_;
keep obsnum &varlist
drop type;
run;

proc transpose data = Wide name=varname
     out=long(rename=(Col1=_value_) drop = _Label_);
     by obsnum;
     run;

Proc sgplot data = long;
	label _Value_ = "standardized value" varname = "variable";
	vbox _value_ /category = varname;
	xaxis discreteorder=data display=(nolabel);
	run;



title1 "Mean values for glass dataset";
proc means data = glass  maxdec = 3;
class type;
var RI SIO2 NA2O CAO MGO AL2O3 K2O BAO FE2O3;
output Out = GlassMeans mean = Mean std = Std ;
run;
