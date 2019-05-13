#!/bin/bash
A="2019-04-08"
B=$(date +'%Y-%m-%d')
C=$(( ($(date -d $B +%s) - $(date -d $A +%s)) / 86400 ))
D=$(($C % 14))

ignoreDate='0'

print_usage() {
  printf "Usage: -d 1 >> Ignore date validation. Optional parameter "
}

while getopts 'd' option; do
	case "${option}" in
	d) ignoreDate="${OPTARG}" ;;
	*) print_usage
	   exit 1 ;;
	esac
done

echo $ignoreDate