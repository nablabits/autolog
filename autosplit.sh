#! /bin/bash

# Description:
# Split a file (usually a log) larger than 500MB into parts and compress them. 
# It's intended to be executed as a scheduled cron job
#
# Args:
# $1 -> path/to/file

timestamp=`date`

# First check that file exists and it's no 0 sized
if [ ! -s $1 ]; then 
	echo "${timestamp} - No file was especified or its size is 0." >> autosplit.log
	exit
fi

# Just operate on files larger than 500MB
minimumsize=500000  # 500MB
actualsize=$(du -k "$1" | cut -f 1)
if [ $actualsize -le $minimumsize ]; then
	echo "${timestamp} - The file was not big enough." >> autosplit.log
    exit
fi


# Remove older (should be really old) splits
if [[ (`ls | grep .tar.gz`) ]]; then
	rm -f split.log0*.tar.gz
fi

# Split the file in 100MB parts and compress
split -d -b 100000000 $1 split.log  

for entry in *.log0*; do
	tar cfz "${entry}.tar.gz" "$entry"
	rm $entry
done

# Finally get rid of the original and start a new log
rm -f $1
touch $1
