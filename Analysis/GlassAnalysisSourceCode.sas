

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

title1 "Full PCA";
proc princomp data = glass out=glassPC;
var TYPE RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;





proc print data = glassPC; run;

title1 "PCR using cross validation for component selection";
proc pls data = glass method = pcr cv=one cvtest (stat=press);
model type = RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;

title1 "PCR using selected factors";
proc pls data = glass method =pcr nfact=3;
model type = RI NA2O MGO AL2O3 SIO2 K2O CAO BAO FE2O3;
run;


