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