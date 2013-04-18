#!/bin/bash

##############################################################################
# Http load testing using siege.
#
# Example usage:
# hperf -n "TestApache" -f dvbt2api-testurls-dvbt2_azure-top1000.txt
#
# Author: Andreas Fachathaler
# Date: 2013-04-18
# License: http://www.gnu.org/copyleft/gpl.html GNU General Public License (GPL)
##############################################################################

usage="Usage: `basename $0` -n <Testname>  -f <Textfile with URLS, one per line>"

#declare -a testruns=(
#"siege -c 5 -t 5S"
#"siege -c 20 -t 5S"
#)

declare -a testruns=(
"siege -c 5 -t 60S"
"siege -c 20 -t 60S"
"siege -c 40 -t 60S"
"siege -c 40 -t 600S"
"siege -c 100 -t 60S"
"siege -c 100 -t 600S"
)

# Set up options
while getopts ":n:f:" options; do
 case $options in
 n ) testname=$OPTARG;;
 f ) urlfile=$OPTARG;;
 \? ) echo -e $usage
  exit 1;;
 * ) echo -e $usage
  exit 1;;

 esac
done

# Test for testname
if [  ! -n "$testname" ]
then
 now=$(date +"%m.%d.%Y %H:%M")
 testname="hperf-$now"
fi

# Test for urlfile
if [  ! -n "$urlfile" ]
then
 echo -e $usage
 exit 1
fi

# Test if urlfile exists
if [ ! -e "$urlfile" ]
then
 echo "$urlfile does not exist."
 echo 
 echo -e $usage
 exit 2
fi

logfile="$(mktemp)"

echo "===== $testname ====="
echo "first urls" 
head -n 5 $urlfile
echo ""

for (( i = 0; i < ${#testruns[@]} ; i++ )); do
    echo "==== Test#$i ===="
    echo "${testruns[$i]} -f $urlfile"
    echo "=== Result ==="
    # redirect stderr to stdout and skip first lines
    # sieve writes output to stderr :(
    RESULT=`${testruns[$i]} -m "$testname-Test#$i" -f $urlfile --log="$logfile" 2>&1`
    if [ -n "$RESULT" ]; then
        echo "$RESULT" | tail -n+5
    fi
    # give the server some time to recover
    sleep 10
done

echo "==== Summary ===="
echo "Date & Time,  Trans,  Elap Time,  Data Trans,  Resp Time,  Trans Rate,  Throughput,  Concurrent,    OKAY,   Failed"
cat $logfile

#echo "logfile: $logfile"
