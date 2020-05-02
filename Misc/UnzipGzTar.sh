#!/bin/bash
set -e

i=1819

while [ $i -ge 0 ]
do
	tp=`file $i* | cut -d':' -f2 | cut -b 2`
	if [ "$tp" == 'g' ]
	then
		gunzip $i*
		tp2=`file $i* | cut -d':' -f2 | cut -b 2`
		b=$(( i - 1 ))
		if [ "$tp2" == 'P' ]
		then
			mv $i $b.tar
		fi
		if [ "$tp2" == 'g' ]
		then
			mv $i $b.gz
		fi
		if [ "$tp2" == 'Z' ]
		then
			mv $i $b.zip
		fi
	fi
	if [ "$tp" == 'Z' ]
	then
		~/bin/JohnTheRipper/run/zip2john $i.zip > w
		~/bin/JohnTheRipper/run/john --wordlist=wl.txt w
		pass=`~/bin/JohnTheRipper/run/john --show w | cut -d':' -f2 | head -n 1`
		echo "$pass"
		unzip -P $pass $i.zip
		rm $i.zip
	fi
	if [ "$tp" == 'P' ]
	then
		tar -xvf $i.tar
		rm $i.tar
	fi
	(( i-- ))
	rm -rf owo.txt
done
