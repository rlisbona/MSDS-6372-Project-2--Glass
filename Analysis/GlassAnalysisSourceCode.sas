

proc import datafile= '"\\client\c$\Users\anobs\Documents\GitHub\MSDS-6372-Project-2--Glass\Data\glass.csv' out = glass 
dbms=csv replace;
guessingrows = 214 ;
getnames = yes; 
run;

proc sort data = glass; by RI; run;

proc print data = glass; run;
*Variable list;
*Obs ID RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3 TYPE ;

ods graphics on /width = 17in height = 10in;
title1 "Scatter plot Chemical composition % weight x RI";
proc sgscatter data = glass;
compare y= RI x=( NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3)/ reg ellipse = (type=mean) spacing = 4;
run;
ods graphics off;
* This doesn't work for RI, it produces a plot for each different value of RI;
/*proc boxplot data = glass;
plot  (NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3)  /
	boxstyle = schematic
	horizontal;
run; */

title1 "Means by Glass Type";
proc means data = glass;
* class Type;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;



* follows example in BLT 8.5 for crime statistics;
* should we standardize?  Chemical composition is same scale =% weight;
* should we use covariance.  http://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/viewer.htm#statug_princomp_syntax01.htm;
* SAS documentation says don't use COV unless the units in which bariables measured are comparible, most are, if we ommited RI-Refractive index and Type-Glass Type;
ods graphics on /width = 6in height = 4in;
title1 "Full PCA";
proc princomp data = glass out=glassPC plots = all ;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
*ID type;
run;
ods graphics off;

ods graphics on /width = 6in height = 4in;
title1 "Full PCA";
proc princomp data = glass out=glassPC plots = all ;
var NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
*ID type;
run;
ods graphics off;

* Note : first 4 account for 80% of variance ;
* Eigenvalues of the Correlation Matrix: Pick factors with Eigenvalue >=1, Therefor we would pick the first 4 principle components;

ods graphics on /width = 6in height = 4in;
* I don't understand the component scroe plots ;
title1 "PCA using four factors";
proc princomp data = glass out=glassPC plots = all n=4; *N=4 uses the first four factors;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
*ID type;
run;
ods graphics off;

ods graphics on /width = 6in height = 4in;
title1 "PCA using four factors";
proc princomp data = glass out=glassPC plots = pattern n=4; *N=4 uses the first four factors;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
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


