#!/bin/bash

  function exitProject() {
    echo 'Exiting Project directory.'
    cd "$HOME"/code
  }

  function dropDatabase() {
    readonly DATABASE_NAME=${1//[-]/_}
    readonly DATABASE_NAME_TEST=${1//[-]/_}_test
    readonly MYSQL=`which mysql`
    readonly Q1="DROP DATABASE IF EXISTS $DATABASE_NAME;"
    readonly Q2="DROP DATABASE IF EXISTS $DATABASE_NAME_TEST;"
    echo 'Dropping Databases.'
    $MYSQL -uroot -e "$Q1"
    $MYSQL -uroot -e "$Q2"
    echo 'Databases Dropped.'
  }

  function deleteProject() {
    echo 'Deleting Project Directory.'
    rm -rf "$1"
    echo 'Project Directory Deleted.'

  }

  if [ ! -z "$1" ]
  then
    echo 'Remove Laravel project.' 
    exitProject
    dropDatabase $1
    deleteProject $1
    echo 'Laravel Project Removed.'
  else
    echo 'No project name given'
  fi
