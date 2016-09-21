#!/bin/bash

#default configuration
framework='yii'
alias='origin'
branch='master'

#seting configuration from command line
for i in "$@"
do
	case $i in
	    -f=*|--framework=*) framework="${i#*=}" ;;
	    -a=*|--alias=*) alias="${i#*=}" ;;
		-b=*|--branch=*) branch="${i#*=}"
	esac
done

#downloading form repo
git pull $alias $branch

#selecting migration command
case "$framework" in
	"yii" ) migrate=`php yii migrate --interactive=0` ;;
	"symfony" ) migrate=`./symfony doctrine:migrate` ;;
	"laravel" ) migrate=`php artisan migrate --force` ;;
	*) echo "You must set your framework!!" exit
esac

#last commit message
commit=`git log -1 --pretty=%B`

#create array from last commit
IFS=';' read -r -a command <<< "$commit"

#run command from commit
case "${command[-1]}" in
  "composer") composer update ;;
  "migrate") $migrate ;;
  "all") composer update && $migrate;;
  *) echo "Every thing is done."
esac