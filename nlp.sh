#!/bin/bash

  function installLaravel() {
    echo 'Installing Laravel.'
    composer create-project laravel/laravel "$HOME"/code/"$1" > /dev/null 2>&1
    echo 'Laravel Installed.'
    cd "$HOME"/code/"$1" > /dev/null 2>&1
  }

  function installDebugbar() {
    echo 'Installing Laravel Debugbar.' 
    composer require barryvdh/laravel-debugbar --dev > /dev/null 2>&1
    echo /storage/debugbar >> .gitignore
    echo 'Laravel Debugbar Installed.'
  }

  function installJetstream() {
    echo 'Installing Jetstream.'
    composer require laravel/jetstream > /dev/null 2>&1
    echo 'Jetstream Installed.'
  }

  function installBreeze() {
    echo 'Installing Breeze.'
    composer require laravel/breeze --dev > /dev/null 2>&1
    echo 'Breeze Installed.'
  }

  function installTailwind() {
    echo 'Installing TailwindCSS.'
    npm install -D tailwindcss autoprefixer > /dev/null 2>&1
    npx tailwindcss init -p > /dev/null 2>&1
    echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > "$HOME"/code/"$1"/resources/css/app.css 
    sed -i -e "s/content: \[\]/content: \[\\n\\t'\.\/resources\/\*\*\/\*\.blade\.php',\\n\\t'\.\/resources\/\*\*\/\*\.js',\\n\\t'\.\/resources\/\*\*\/\*\.vue',\\n  ]/g" tailwind.config.js > /dev/null 2>&1
    rm tailwind.config.js-e > /dev/null 2>&1
    wget -q -O ./resources/views/welcome.blade.php https://gist.githubusercontent.com/Tray2/e5be9b2fad7ded2ac45e91f3dc9fb85c/raw/30ea0ba51753f256b02346f501cbb667143e5c66/welcome.blade.php  
    npm run build > /dev/null 2>&1
    echo 'TailwindCSS Installed.'
  }

  function setupGit() {
    echo 'Setting up a Git Repository.'
    git init > /dev/null 2>&1
    git add . > /dev/null 2>&1
    git commit -m "Initial commit" > /dev/null 2>&1
    echo 'Git Repository Done.'
  } 

  function createDatabase() {
    readonly DATABASE_NAME=${1//[-]/_}
    readonly DATABASE_NAME_TEST=${1//[-]/_}_test
    readonly MYSQL=`which mysql`
    readonly Q1="CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    readonly Q2="CREATE DATABASE IF NOT EXISTS $DATABASE_NAME_TEST;"
    echo 'Creating the database.'
    $MYSQL -uroot -e "$Q1" > /dev/null 2>&1
    $MYSQL -uroot -e "$Q2" > /dev/null 2>&1 
    echo 'Databases Created.'
  }

  function enableMySQLForTest() {
    sed -i -e "s/sqlite/mysql/g" phpunit.xml  > /dev/null 2>&1
    sed -i -e "s/:memory:/$1/g" phpunit.xml  > /dev/null 2>&1
  }

  function updatePhpUnitXML() {
    echo 'Updating phpunit.xml.'
    sed -i -e "s/\<!-- //g" phpunit.xml > /dev/null 2>&1
    sed -i -e "s/\--\>//g" phpunit.xml > /dev/null 2>&1
    if [ ! -z "$2" ]
    then 
      if [ $2 = "-test=mysql" ]  
      then
        enableMySQLForTest $DATABASE_NAME_TEST
      fi
    fi
    if [ ! -z "$3" ]
    then
      if [ $3 = "-test=mysql" ]
      then
        enableMySQLForTest $DATABASE_NAME_TEST
      fi
    fi
    rm phpunit.xml-e
    echo 'phpunit.xml updated.'
  }

  function updateEnv() {
    readonly APP_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
    echo 'Updating the .env file to fit your project.'
    sed -i -e "s/DB_DATABASE=laravel/DB_DATABASE=$DATABASE_NAME/g" .env > /dev/null 2>&1
    sed -i -e "s/APP_NAME=Laravel/APP_NAME=$APP_NAME/g" .env > /dev/null 2>&1
    rm .env-e > /dev/null 2>&1
    echo '.env updated.'
  }

  function launchBrowser() {
    echo 'Launching Browser.'
    open -a "Google Chrome" "http://$1.test"
  }

  if [ ! -z "$1" ]
  then

    installLaravel "$1"
    installDebugbar

    if [ ! -z "$2" ]
     then 
      if [ $2 = "-jetstream" ] || [ $2 = "-j" ]
      then
        installJetstream
      elif [ $2 = "-breeze" ] || [ $2 = "-b" ]
      then
        installBreeze
      elif [ $2 = "-tailwind" ] || [ $2 = "-t" ]
      then
        installTailwind "$1"
      elif [ $2 = "-test=mysql" ]
      then
        #We do nothing
        echo '' > /dev/null 2>&1
      else
        echo "Unknown parameter given: $2"
      fi
    fi

    createDatabase $1
    updatePhpUnitXML $1 $2 $3
    updateEnv $1
    setupGit
    echo 'Project created.'
    if [ "$2" != "-jetstream" ] && [ "$2" != "-j" ]
    then
      launchBrowser $1
    fi
  else
    echo 'nlp command to create new Laravel projects.'
    echo 'Syntax: nlp <project name> -<option> -<option>'
    echo 'Options available:'
    echo ''
    echo '-breeze or -b to install Laravel Breeze starter kit'
    echo '-jetsream or -j to install Laravel Jetstream'
    echo '-tailwind or -t to install TailwindCSS'
    echo '-test=mysql to setup a testing database with MySQL'
    echo ''
    echo 'Breeze and Jetstream installs tailwind by default.'
    echo 'To use MySQL as a testing database together with'
    echo 'Breeze, Jetstream or tailwind, it must come as a'
    echo 'third argument.'
    echo 'Example: nlp new-project -b -test=mysql'
    echo '' 
  fi
