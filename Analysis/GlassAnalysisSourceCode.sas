

proc import datafile= '"\\client\c$\Users\anobs\Documents\GitHub\MSDS-6372-Project-2--Glass\Data\glass.csv' out = glass 
dbms=csv replace;
guessingrows = 214 ;
getnames = yes; 
run;


proc print data = glass; run;
*Variable list;
*Obs ID RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3 TYPE ;


proc sgscatter data = glass;
matrix Type RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;

proc boxplot data = glass;
plot  (RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3) * type /
	boxstyle = schematic
	horizontal;
run;

title1 "Means by Glass Type";
proc means data = glass;
class Type;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;



* follows example in BLT 8.5 for crime statistics;
* should we standardize?  Chemical composition is same scale =% weight;
* should we use covariance.  http://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/viewer.htm#statug_princomp_syntax01.htm;
* SAS documentation says don't use COV unless the units in which bariables measured are comparible, most are, if we ommited RI-Refractive index and Type-Glass Type;

title1 "Full PCA";
proc princomp data = glass out=glassPC plots = all n=4;
var TYPE RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
ID type;
run;
* first 4 account for 80% of variance;




proc print data = glassPC; run;

title1 "PCR using cross validation for component selection";
proc pls data = glass method = pcr cv=one cvtest (stat=press);
model type = RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;


* PLS chose 2 components in above step so set nfact=2, but not sure what this means at this point;
title1 "PCR using selected factors";
proc pls data = glass method =pcr nfact=2;
model type = RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;


