data suv_upto_30000;
	set sashelp.cars;
	where type = "SUV" && msrp <= 30000;





run;


/* Uzycie formatow */

data class_bd;
	set PG1.class_birthdate;
	format Birthdate ddmmyy10.;
	where Birthdate >= "01sep2005"d;


run;


/*Sortowanie danych */

proc sort data=class_bd out=class_bd_srt;
	by Birthdate Height;


run;
/*sortowanie rosnaco po wieku i rosnaco po wzroscie*/


proc sort data=class_bd out=class_bd_srt;
	by age Height;


run;

/*sortowanie rosnaco po wieku i malejaco po wzroscie*/


proc sort data=class_bd out=class_bd_srt;
	by age descending Height;


run;


/*Usuwanie duplikatow*/

proc sort data=pg1.class_test3 out=class_test3_clean nodupkey dupout=class_dups;
	by name Subject TestScore;

run;

data np_sort;

/*Przetwarzanie danych w data step*/

data class_bd;
	set PG1.class_birthdate;
	format Birthdate ddmmyy10.;
	where Birthdate >= "01sep2005"d;


run;

data cars_avg;
format mpg_mean 5.2;
	set sashelp.cars;
	mpg_mean = mean(mpg_city, mpg_highway);

	run;

data storm_avg;
	set PG1.storm_range;
	windAvg = mean(of Wind1-Wind4);
run;

data np_summary_update;
	set pg1.np_summary;
	keep Reg ParkName DayVisits OtherLodging Acres SqMiles Camping OtherCamping TentCampers RVCampers BackcountryCampers;	
	SqMiles = Acres*0.0015625;	
	Camping= sum(OtherCamping, TentCampers, RVCampers, BackcountryCampers);  
	format SqMiles Camping comma15.0;
	drop OtherCamping TentCampers RVCampers BackcountryCampers;
run;

data eu_occ_total;
	set pg1.eu_occ;
	Year=substr(YearMon, 1, 4);
	Month=substr(YearMon, 6, 2);
	ReportDate = mdy(Month, 1 ,Year);
	Total=sum(Camp, Hotel, ShortStay);
	format ReportDate MONYY. Hotel ShortStay Camp comma15.;
	drop Geo YearMon Year Month;
run;


/*Wyrazenia watunkowe*/

data cars_categories;
	set sashelp.cars;
	length car_category $12;
	if msrp <= 30000 then do
		num_category=1;
		car_category="Basic";
	end;
	else if msrp <= 60000 and msrp > 30000 then do
		num_category=2;
		car_category="Luxury";
	end;
	else do num_category=3;
		car_category="Extra Luxury";
	end;

run;

data Basic Luxury Extra_Luxury;
	set sashelp.cars;
	length car_category $12;
	if msrp <= 30000 then do
		num_category=1;
		car_category="Basic";
		output Basic;
	end;
	else if msrp <= 60000 and msrp > 30000 then do
		num_category=2;
		car_category="Luxury";
		output Luxury;
	end;
	else do num_category=3;
		car_category="Extra Luxury";
		output Extra_Luxury;
	end;

run;

***********************************************************;
*  LESSON 4, PRACTICE 7                                   *;
*    a) Submit the program and view the generated output. *;
*    b) In the DATA step, use IF-THEN/ELSE statements to  *;
*       create a new column, ParkType, based on the value *;
*       of Type.                                          *;
*       NM -> Monument                                    *;
*       NP -> Park                                        *;
*       NPRE, PRE, or PRESERVE -> Preserve                *;
*       NS -> Seashore                                    *;
*       RVR or RIVERWAYS -> River                         *;
*    c) Modify the PROC FREQ step to generate a frequency *;
*       report for ParkType.                              *;
***********************************************************;

data park_type;
	length ParkType $12;
	set pg1.np_summary;
	if Type="NM" then do
		ParkType="Monument";
	end;
	else if Type="NP" then do
		ParkType="Park";
	end;
	else if Type="NPRE" or Type="PRE" or Type="PRESERVE" then do
		ParkType="Preserve";
	end;
	else if Type="NS" then do
		ParkType="Seashore";
	end;
	else if Type="RVR" or Type="RIVERWAYS" then do
		ParkType="River";
	end;
	*Add IF-THEN-ELSE statements;
run;

proc freq data=park_type;
	tables ParkType;
run;

data parks monuments;
	set pg1.np_summary;
	length ParkType $10;
	if Type="NP" then do
		ParkType="Park";
		Campers = sum(BackcountryCampers, OtherCamping, RVCampers, TentCampers);
		output parks;	
	end;
	else if Type="NM" then do
		ParkType="Monument";
		Campers = sum(BackcountryCampers, OtherCamping, RVCampers, TentCampers);
		output monuments;	
	end;
	format Campers comma15.;
	drop Type BackcountryCampers OtherCamping RVCampers TentCampers Acres;
	
run;

data parks monuments;
	set pg1.np_summary;
	length ParkType $10;
	select (Type);
	when ('NP') do
		ParkType="Park";
		Campers = sum(BackcountryCampers, OtherCamping, RVCampers, TentCampers);
		output parks;	
	end;
	when ('NM') do
		ParkType="Monument";
		Campers = sum(BackcountryCampers, OtherCamping, RVCampers, TentCampers);
		output monuments;	
	end;
	otherwise;
	end;
	format Campers comma15.;
	drop Type BackcountryCampers OtherCamping RVCampers TentCampers Acres;
	
run;



title "Most Costly Storms";
proc sql;
select event, cost format=dollar20., year(date) as Season
from pg1.storm_damage
where cost>25000000000
order by cost desc;

quit;


title "Most Costly Storms";
proc sql number;
create table storm_damage_big as
select event, cost format=dollar20., year(date) as Season
from pg1.storm_damage
where cost>25000000000
order by cost desc;

quit;




proc sql;
	create table class_gradees as
	select t.name, sex, age, teacher, grade
	from pg1.class_teachers as t
	inner join pg1.class_update as c
	on t.name=c.name;
quit;



proc sql;
	create table class_gradees as
	select t.name, sex, age, teacher, grade
	from pg1.class_teachers as t
	inner join pg1.class_update as c
	on t.name=c.name;
quit;




