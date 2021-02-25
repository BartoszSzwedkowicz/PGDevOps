data storm_summary;
	set pg2.storm_summary(obs=5);
	duration = endDate-startDate;
	putlog "ERROR: duration=" duration;
	putlog "WARNING: " duration=;
	putlog "-----------------------";
	putlog _all_;
run;

data quiz;
	set pg2.class_quiz;
	avgQuiz = mean(of q:);
	drop Quiz1-Quiz5;

run;



data quiz;
	set pg2.class_quiz;
	putlog "NOTE: przed turyna";
	putlog _all_;

	call sortn(of Q:);
	putlog "NOTE: po rutynie";
	putlog _all_;

	if mean(of Q:) < 7 then
		call missing(of _numeric_);
run;

data quiz;
	set pg2.class_quiz;
	quiz1st=largest(1, of quiz:);
	quiz2nd=largest(2, of quiz:);
	avgBest=mean(quiz1st, quiz2nd);
	studentId=rand('integer', 100,999);
run;



data test;
	a="ala ";
	call missing(a);
	l1=length(a);
	l2=lengthc(a);
	l3=lengthn(a);

run;


data test;
	length imie imie2 nazwisko $20;
	imie="Kasia";
	imie2="Barbara";
	nazwisko="Kowalska";
	fullname=cat(imie, imie2, nazwisko);
	fullname2=imie !! imie2 || nazwisko;
	fullname3=catx(" ", imie, imie2, nazwisko);
run;


data test;
	set sashelp.class pg2.class_new;
	

run;

proc copy in=sashelp out=work;
	select class;


run;


data class;
	length name $9;
	set sashelp.class;
run;

proc append base=class data=pg2.class_new;
run;

proc append base=class data=pg2.class_new2(rename=(student=name));
run;


***********************************************************;
*  LESSON 5, PRACTICE 1                                   *;
*  a) Complete the SET statement to concatenate the       *;
*     PG2.NP_2015 and PG2.NP_2016 tables to create a new  *;
*     table, NP_COMBINE.                                  *;
*  b) Use a WHERE statement to include only rows where    *;
*     Month is 6, 7, or 8.                                *;
*  c) Create a new column named CampTotal that is the sum *;
*     of CampingOther, CampingTent, CampingRV, and        *;
*     CampingBackcountry. Format the new column with      *;
*     commas.                                             *;
***********************************************************;

data work.np_combine;
    set pg2.np_2014(rename=(park=ParkCode Type=ParkType)) pg2.np_2015 pg2.np_2016;
	CampTotal=sum(of Camping:);
	where month in(6, 7, 8) and ParkType="National Park";
	format CampTotal comma15.;
    drop Camping:;
run;

***********************************************************;
*  LESSON 3, PRACTICE 6                                   *;
*  a) Run the program. Notice that the Column1 column     *;
*     contains raw data with values separated by various  *;
*     symbols. The SCAN function is used to extract the   *;
*     ParkCode and ParkName values.                       *;
*  b) Examine the PROC CONTENTS report. Notice that       *;
*     ParkCode and ParkName have a length of 200, which   *;
*     is the same as Column1.                             *;
*     Note: When the SCAN function creates a new column,  *;
*     the new column will have the same length as the     *;
*     column listed as the first argument.                *;
*  c) The ParkCode column should include only the first   *;
*     four characters in the string. Add a LENGTH         *;
*     statement to define the length of ParkCode as 4.    *;
*  d) The length for the ParkName column can be optimized *;
*     by determining the longest string and setting an    *;
*     appropriate length. Modify the DATA step to create  *;
*     a new column named NameLength that uses the LENGTH  *;
*     function to return the position of the last         *;
*     non-blank character for each value of ParkName.     *;
*  e) Use a RETAIN statement to create a new column named *;
*     MaxLength that has an initial value of zero.        *;
*  f) Use an assignment statement and the MAX function to *;
*     set the value of MaxLength to either the current    *;
*     value of NameLength or MaxLength, whichever is      *;
*     larger.                                             *;
*  g) Use the END= option in the SET statement to create  *;
*     a temporary variable in the PDV named LastRow.      *;
*     LastRow will be zero for all rows until the last    *;
*     row of the table, when it will be 1. Add an IF-THEN *;
*     statement to write the value of MaxLength to the    *;
*     log if the value of LastRow is 1.                   *;
***********************************************************;

data parklookup;
	set pg2.np_unstructured_codes end=LastRow;
	length ParkCode $4 ParkName $83;
	ParkCode=scan(Column1, 2, '{}:,"()-');
	ParkName=scan(Column1, 4, '{}:,"()');
	NameLength=LENGTH(ParkName);
	
	retain MaxLength 0;
	MaxLength=max(MaxLEngth, NameLength);
	if LastRow=1 then putlog MaxLength=;

run;

proc print data=parklookup(obs=10);
run;

proc contents data=parklookup;
run;


options locale=pl_pl;
data stock2;
	set pg2.stocks2(rename=(date=date_old high=high_old volume=volume_old));
	Date=input(date_old, date9.);
	High=input(high_old, best12.);
	Volume=input(volume_old, comma12.);
	format Date ddmmyy10. Volume nlnum12.;
run;

data stocks3;
	set stock2;
	value_zl=put(Volume, nlmny15.2);
run;


***********************************************************;
*  LESSON 3, PRACTICE 5                                   *;
*  a) Notice that the DATA step creates a table named     *;
*     PARKS and reads only those rows where ParkName ends *;
*     with NP.                                            *;
*  b) Modify the DATA step to create or modify the        *;
*     following columns:                                  *;
*     1) Use the SUBSTR function to create a new column   *;
*        named Park that reads each ParkName value and    *;
*        excludes the NP code at the end of the string.   *;
*        Note: Use the FIND function to identify the      *;
*        position number of the NP string. That value can *;
*        be used as the third argument of the SUBSTR      *;
*        function to specify how many characters to read. *;
*     2) Convert the Location column to proper case. Use  *;
*        the COMPBL function to remove any extra blanks   *;
*        between words.                                   *;
*     3) Use the TRANWRD function to create a new column  *;
*        named Gate that reads Location and converts the  *;
*        string Traffic Count At to a blank.              *;
*     4) Create a new column names GateCode that          *;
*        concatenates ParkCode and Gate together with a   *;
*        single hyphen between the strings.               *;
***********************************************************;

data parks;
	set pg2.np_monthlytraffic;
	where ParkName like '%NP';
	Park=substr(ParkName, 1, find(ParkName, "NP")-1);
/*	pos=find(ParkName, "NP");*/
	Location=compbl(Location);
	Gate=tranwrd(Location, "TRAFFIC COUNT AT", "");

run;

proc print data=parks;
	var Park GateCode Month Count;
run;


***********************************************************;
*  Activity 3.04                                          *;
*  1) Notice that the INTCK function does not include the *;
*     optional method argument, so the default discrete   *;
*     method is used to calculate the number of weekly    *;
*     boundaries (ending each Saturday) between StartDate *;
*     and EndDate.                                        *;
*  2) Run the program and examine rows 8 and 9. Both      *;
*     storms were two days, but why are the values        *;
*     assigned to Weeks different?                        *;
*  3) Add 'c' as the fourth argument in the INTCK         *;
*     function to use the continuous method. Run the      *;
*     program. Are the values for Weeks in rows 8 and 9   *;
*     different?                                          *;
***********************************************************;
*  Syntax Help                                            *;
*     INTCK('interval', start-date, end-date, <'method'>) *;
*         Interval: WEEK, MONTH, YEAR, WEEKDAY, HOUR, etc.*;
*         Method: DISCRETE (D) or CONTINUOUS (C)          *;
***********************************************************;

data storm_length;
	set pg2.storm_final(obs=10);
	keep Season Name StartDate Enddate StormLength Weeks;
	Weeks=intck('week', StartDate, EndDate);
	WeeksC=intck('week', StartDate, EndDate, 'c');
run;

data storm_length;
	set pg2.storm_final(obs=10);
	month1later=intnx("month", endDate, 1);
	format month1later ddmmyy10.;
run;




data snow;
	set winter2015_2016;
	by Code;
	if first.code=1 then FirstSnow=Date;
run;


data weather;
	set pg2.weather_japan;
	NewLocation=compbl(Location);
	NewStation=compress(Station, "- ");
run;

data klasa;
	if 0 then do;
		set sashelp.class;
		output;
	end;
run;

/*laczenie danych */
data class_grades;
	merge sashelp.class(in=c) pg2.class_teachers(in=t);
	by name;
run;


data petlaDo;
	do i=1 to 10;
		los=rand("integer", 1, 100);
		output;
	end;
	

run;


data doWhile;
	i=1;
	do while(i<10);
		los=rand("integer", 1, 100);
		i=i+1;
		output;
	end;

run;

data doUntil;
	i=1;
	do while(i<10);
		los=rand("integer", 1, 100);
		i=i+1;
		output;
	end;
run;


***********************************************************;
*  LESSON 6, PRACTICE 1                                   *;
*  a) Add an iterative DO loop around the sum statement   *;
*     for Invest.                                         *;
*     1) Add a DO statement that creates the column Year  *;
*        with values ranging from 1 to 6.                 *;
*     2) Add an OUTPUT statement to show the value of the *;
*        retirement account for each year.                *;
*     3) Add an END statement.                            *;
*  b) Run the program and review the results.             *;
*  c) Add an inner iterative DO loop between the sum      *;
*     statement and the OUTPUT statement to include the   *;
*     accrued quarterly compounded interest based on an   *;
*     annual interest rate of 7.5%.                       *;
*     1) Add a DO statement that creates the column       *;
*        Quarter with values ranging from 1 to 4.         *;
*     2) Add a sum statement to add the accrued interest  *;
*        to the Invest value.                             *;
*            Invest+(Invest*(.075/4));                    *;
*     3) Add an END statement.                            *;
*  d) Run the program and review the results.             *;
*  e) Drop the Quarter column. Run the program and review *;
*     the results.                                        *;
***********************************************************;

data retirement;
	do Year=1, 2, 3, 4, 5, 6;
       Invest+10000;
	   do Quarter=1, 2, 3, 4;
		Invest=Invest+(Invest*(.075/4));
	   end;
		output;

	end;
drop Quarter;
run;

title1 'Retirement Account Balance per Year';
proc print data=retirement noobs;
    format Invest dollar12.2;
run;
title;


data petlaDo;
	do i=1 to 10;
		los=rand("integer", 1, 100);
		output;
	end;
	

run;


**************************************************;
*  LESSON 6, PRACTICE 5                          *;
**************************************************;

data IncrExports;
    set pg2.eu_sports;
    where Year=2015 and Country='Belgium' 
          and Sport_Product in ('GOLF','RACKET');
/*	do while(Amt_Export <= Amt_Import);*/
		  do year=2016 to 2025 while(Amt_Export <= Amt_Import);
    	Amt_Export=Amt_Export*1.07;
/*		Year=Year+1;*/
		output;
	end;

    format Amt_Import Amt_Export comma12.;
run; 

title 'Belgium Golf and Racket Products - 7% Increase in Exports'; 
proc print data=IncrExports;
    var Sport_Product Year Amt_Import Amt_Export;
run;
title;



/*Transpozycja kolumn*/


proc transpose data=sashelp.class out=class;
	id name;
	var Height, Weight;
	by sex;
run;


proc sort data=sashelp.class out=class_s;
by age;
run;

proc transpose data=class_s out=class;
	id name;
	var Height Weight;
	by age;
run;


proc transpose data=pg2.storm_top4_narrow prefix=Wind out=storm(drop=_NAME_);
	id WindRank;
	var WindMPH;
	by Season Basin Name;

run;

proc transpose data=storm out=storm2 name=;
	by Season Basin Name;
	var Wind1-Wind4;
run;