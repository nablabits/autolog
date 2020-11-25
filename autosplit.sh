#! /bin/bash

# Description:
# Split a file (usually a log) into parts and compress them. 
# It's intended to be executed over long periods as a scheduled
# cron job
#
# Args:
# $1 -> path/to/file

if [ ! -s $1 ]; then 
	timestamp=`date`
	echo "${timestamp} - No file was especified or its size is 0." >> autosplit.log
	exit
fi

# Remove older (should be really old) splits
if [[ (`ls | grep .tar.gz`) ]]; then
	rm -f split.log0*.tar.gz
fi

# Split the file and compress parts
split -d -l 300 $1 split.log  

for entry in *.log0*; do
	tar cfz "${entry}.tar.gz" "$entry"
	rm $entry
done

# Finally get rid of the original and start a new log
rm -f $1
touch $1
