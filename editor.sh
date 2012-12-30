#!/bin/bash

if [ "$UID" -ne 0 ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi

echo "Table:"
read TABLE

echo "Column:"
read COLUMN

echo "Id:"
read ID

echo "(postgres kotodama password)"
psql -c "select $COLUMN from $TABLE where id=$ID;" -U kotodama -o tmp.txt -A -t kotodama_dev

echo "Opening the record for editing. Save as is when done."
gedit tmp.txt

echo "(as above)"
psql -c "update $TABLE set $COLUMN='`sed "s/'/''/g" < tmp.txt`' where id=$ID;" -U kotodama -d kotodama_dev

function finish {
 rm tmp.txt
}
trap finish EXIT
