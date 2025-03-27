#########################################################################################################
#This script will update firmware on an iDRAC from a CIFS share.
#CSV must have at least the following headers: ipaddress,filename,location,username,password
#File is where the CSV file is located.
#CSV example: 192.168.1.1,Updatename.EXE,//100.77.18.23/TempShare,username,password
#Filename is the update file.
#Location is where the update file is stored.
#Username and Password are the creds for the CIFS share.
#########################################################################################################
#File containing iDRAC information
$file=Import-csv c:\scripts\iDRACs.csv

#Current iDRAC login information
$u="root"
$p="calvin"
$warn = "--nocertwarn"

foreach ($idrac in $file){
    racadm -r $idrac.ipaddress $warn -u $u -p $p update -f $file.filename -l $file.location -u $file.username -p $file.password
}