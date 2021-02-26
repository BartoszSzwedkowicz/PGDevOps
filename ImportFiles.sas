%let path=/opt/sas/Workshop/danePGDevOps/LWPG1V2/data_old;

libname np_park xlsx "&path/np_info.xlsx";

data parks;
	set np_park.visits(obs=10);


run;

libname np_park clear;


proc import file="&path/np_info.xlsx" out=tab1 dbms=xlsx;



proc import file="&path/np_traffic.csv" out=np_traffic dbms=csv replace;
run;


data np_traffic;
	infile file="&path/np_traffic.csv" firstobs=2 dlm=',';
	input ParkName :30. UniCode :30. ParkType $30. Region :30. TrafficCounter :30. ReportingDate :date9. TrafficCount;
run;


%let path=/opt/sas/Workshop/danePGDevOps/PD3;


data script;
	infile "/opt/sas/Workshop/scripts/lesson4_practice3.sh";
	input @'-' a :$100.;
run;

data script;
	infile "/opt/sas/Workshop/scripts/lesson4_practice3.sh";
	input;
	x=_infile_;
	backup=index(x, "back");
run;

data test;
	
	infile "/opt/sas/Workshop/danePGDevOps/PD3/PD3/SASApp_STPServer_2020-01-28_sasapp_18318.log" firstobs=2 dlm=' ';
	input @'WARN';
	x=_infile_;
	date=input
run;