#!/bin/bash

  function exitProject() {
    echo 'Exiting Project directory.'
    cd "$HOME"/code
  }

  function dropMySQLDatabase() {
    DATABASE_NAME=${1//[-]/_}
    DATABASE_NAME_TEST=${1//[-]/_}_test
    Q1="DROP DATABASE IF EXISTS $DATABASE_NAME;"
    Q2="DROP DATABASE IF EXISTS $DATABASE_NAME_TEST;"
    MYSQL=`which mysql`
    if [ ! $MYSQL = 'mysql not found' ]
    then 
      echo 'Dropping Databases.'
      $MYSQL -uroot -e "$Q1"
      $MYSQL -uroot -e "$Q2"
      echo 'Databases Dropped.'
    fi
  }

  function dropPostgreDatabase() {
    DATABASE_NAME=${1//[-]/_}
    DATABASE_NAME_TEST=${1//[-]/_}_test
    Q1="DROP DATABASE $DATABASE_NAME;"
    Q2="DROP DATABASE $DATABASE_NAME_TEST;"
    PSQL=`which psql`
    if [ ! $PSQL = 'psql not found' ]
    then
      echo 'Dropping Databases.'
      $PSQL postgres -c "$Q1" > /dev/null 2>&1
      $PSQL postgres -c "$Q2" > /dev/null 2>&1
      echo 'Databases Dropped.'
    fi
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
    dropMySQLDatabase $1
    dropPostgreDatabase $1
    deleteProject $1
    echo 'Laravel Project Removed.'
  else
    echo 'No project name given'
  fi
