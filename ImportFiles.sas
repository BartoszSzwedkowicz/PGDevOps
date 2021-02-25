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




