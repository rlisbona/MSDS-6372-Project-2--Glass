

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

title1 "Full PCA";
proc princomp data = glass out=glassPC plots = all ;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
*ID type;
run;

* Note : first 4 account for 80% of variance ;
* Eigenvalues of the Correlation Matrix: Pick factors with Eigenvalue >=1, Therefor we would pick the first 4 principle components;

ods graphics on /width = 6in height = 4in;
* I don't understand the component scroe plots ;
title1 "PCA using four factors";
proc princomp data = glass out=glassPC plots = all n=4; *N=4 uses the first four factors;
var RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
*ID type;
run;





* What do we do with this, somewhere it said to plot it?;
proc print data = glassPC; run;

title1 "Scatterplot of RI * Prin1-Prin9";
* but prin2-9 don't seem to make sense here, not sure how to interpret the plot;
proc sgscatter data = glassPC;
compare y= RI x=( Prin1 - Prin9)/ reg ellipse = (type=mean) spacing = 4;
run;




* Pretty much follows example in BLT 8.5;
* I think this is picking 8 factors, not really sure;
title1 "PCR on RI using cross validation for component selection";
proc pls data = glass method = pcr cv=one cvtest (stat=press);
model  RI = NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;


* PLS chose 8 components in above step so set nfact=8, but not sure what this means at this point, do we need 8 or 4 from princomp?;
title1 "PCR using selected factors";
proc pls data = glass method =pcr nfact=8;
model RI = NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;




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


