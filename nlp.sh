#!/bin/bash

TAILWIND=false
JETSTREAM=false
BREEZE=false
MYSQL_TEST=false
POSTGRES=false
POSTGRES_TEST=false
PHPSTORM=false
SUBLIME=false
VSCODE=false
MESSAGE=''


function useTailwind() {
  if [[ " ${PARAMETERS[*]} " =~ " -t " ]] || [[ " ${PARAMETERS[*]} " =~ " -tailwind " ]]
  then
    TAILWIND=true
  fi
}

function useBreeze() {
  if [[ " ${PARAMETERS[*]} " =~ " -b " ]] || [[ " ${PARAMETERS[*]} " =~ " -breeze " ]]
  then
    BREEZE=true
  fi
}

function useJetstream() {
  if [[ " ${PARAMETERS[*]} " =~ " -j " ]] || [[ " ${PARAMETERS[*]} " =~ " -jetstream " ]]
  then
    JETSTREAM=true
  fi
}

function usePostgres() {
  if [[ " ${PARAMETERS[*]} " =~ " -db=postgres " ]] || [[ " ${PARAMETERS[*]} " =~ " -database=postgres " ]]
  then
    POSTGRES=true
  fi
}

function useMySQLTest() {
  if [[ " ${PARAMETERS[*]} " =~ " -test=mysql " ]]
  then
    MYSQL_TEST=true
  fi
}

function usePostgresTest() {
  if [[ " ${PARAMETERS[*]} " =~ " -test=postgres " ]]
  then
    POSTGRES_TEST=true
  fi
}

function parseArguments() {
  PARAMETERS=($1 $2 $3 $4 $5 $6) 
  useTailwind 
  useBreeze 
  useJetstream 
  usePostgres 
  useMySQLTest
  usePostgresTest
} 

function validateInstallationOptions() {
  if [ "$JETSTREAM" = true ] && [ "$BREEZE" = true ]
  then
    MESSAGE='You cant install both Jetstream and Breeze.'
  fi
  if [ "$JETSTREAM" = true ] && [ "$TAILWIND" = true ]
  then
    TAILWIND=false
  fi
  if [ "$BREEZE" = true ] && [ "$TAILWIND" = true ]
  then
    TAILWIND=false
  fi
  if [ "$MYSQL" = true ] && [ "$POSTGRES_TEST" = true ]
  then
    MESSAGE='You should use MySQL for testing.'
  fi
  if [ "$POSTGRES" = true ] && [ "$MYSQL_TEST" = true ]
  then
    MESSAGE='You should use Postgres for testing.'
  fi
}

function showDocs() {
  echo 'nlp command to create new Laravel projects.'
  echo 'Syntax: nlp <project name> -<option> -<option>'
  echo 'Options available:'
  echo ''
  echo '-breeze or -b to install Laravel Breeze starter kit'
  echo '-jetsream or -j to install Laravel Jetstream'
  echo '-tailwind or -t to install TailwindCSS'
  echo '-database=postgres or -db=postgres to use PostgreSQL' 
  echo '-test=mysql to setup a testing database with MySQL'
  echo '-test=postgres to setup a testing database with PostgreSQL'
  echo ''
  echo 'Breeze and Jetstream installs tailwind by default.'
  echo 'Example: nlp new-project -b -test=mysql'
  echo '' 
}

function init() {
  parseArguments $1 $2 $3 $4 $5 $6
  validateInstallationOptions
  if [ ! "$MESSAGE" = '' ]
  then
    echo $MESSAGE
    exit
  fi
}

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
  if [ $JETSTREAM = true ]
  then
    echo 'Installing Jetstream.'
    composer require laravel/jetstream > /dev/null 2>&1
    echo 'Jetstream Installed.'
  fi
}

function installBreeze() {
  if [ $BREEZE = true ]
  then 
    echo 'Installing Breeze.'
    composer require laravel/breeze --dev > /dev/null 2>&1
    echo 'Breeze Installed.'
  fi
}

function installTailwind() {
  if [ $TAILWIND = true ] 
  then 
    echo 'Installing TailwindCSS.'
    npm install -D tailwindcss autoprefixer > /dev/null 2>&1
    npx tailwindcss init -p > /dev/null 2>&1
    echo -e "@tailwind base;\n@tailwind components;\n@tailwind utilities;" > "$HOME"/code/"$1"/resources/css/app.css 
    sed -i -e "s/content: \[\]/content: \[\\n\\t'\.\/resources\/\*\*\/\*\.blade\.php',\\n\\t'\.\/resources\/\*\*\/\*\.js',\\n\\t'\.\/resources\/\*\*\/\*\.vue',\\n  ]/g" tailwind.config.js > /dev/null 2>&1
    rm tailwind.config.js-e > /dev/null 2>&1
    wget -q -O ./resources/views/welcome.blade.php https://gist.githubusercontent.com/Tray2/e5be9b2fad7ded2ac45e91f3dc9fb85c/raw/30ea0ba51753f256b02346f501cbb667143e5c66/welcome.blade.php  
    npm run build > /dev/null 2>&1
    echo 'TailwindCSS Installed.'
  fi
}

function setupGit() {
  echo 'Setting up a Git Repository.'
  git init > /dev/null 2>&1
  git add . > /dev/null 2>&1
  git commit -m "Initial commit" > /dev/null 2>&1
  echo 'Git Repository Done.'
} 

function createMySQLDatabases() {
  if [ $POSTGRES = false ] 
  then  
    DATABASE_NAME=${1//[-]/_}
    readonly MYSQL=`which mysql`
    Q1="CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    echo 'Creating the database.'
    $MYSQL -uroot -e "$Q1" > /dev/null 2>&1
    if [ $MYSQL_TEST = true ]
    then 
      DATABASE_NAME_TEST=${1//[-]/_}_test
      Q2="CREATE DATABASE IF NOT EXISTS $DATABASE_NAME_TEST;"
      $MYSQL -uroot -e "$Q2" > /dev/null 2>&1 
    fi
    echo 'Database(s) Created.'
  fi
}

function createPostgreDatabases() {
  if [ $POSTGRES = true ]
  then
      DATABASE_NAME=${1//[-]/_}
      readonly PSQL=`which psql`
      Q1="CREATE DATABASE $DATABASE_NAME;"
      echo 'Creating the database.'
      $PSQL postgres -c "$Q1" > /dev/null 2>&1
      if [ $POSTGRES_TEST = true ]
      then
          DATABASE_NAME_TEST=${1//[-]/_}_test
          Q2="CREATE DATABASE $DATABASE_NAME_TEST;"
          $PSQL postgres -c "$Q2" > /dev/null 2>&1
      fi
      echo 'Database(s) Created.'
  fi
}

function enableMySQLForTest() {
  if [ $MYSQL_TEST = true ]
  then 
      sed -i -e "s/sqlite/mysql/g" phpunit.xml  > /dev/null 2>&1
      sed -i -e "s/:memory:/$1/g" phpunit.xml  > /dev/null 2>&1
  fi
}

function enablePostgreSQLForTest() {
  if [ $POSTGRES_TEST = true ]
  then
      sed -i -e "s/sqlite/pgql/g" phpunit.xml  > /dev/null 2>&1
      sed -i -e "s/:memory:/$1/g" phpunit.xml  > /dev/null 2>&1
  fi
}

function updatePhpUnitXML() {
  echo 'Updating phpunit.xml.'
  sed -i -e "s/\<!-- //g" phpunit.xml > /dev/null 2>&1
  sed -i -e "s/\--\>//g" phpunit.xml > /dev/null 2>&1
  enableMySQLForTest $DATABASE_NAME_TEST
  enablePostgreSQLForTest $DATABASE_NAME_TEST
  rm phpunit.xml-e
  echo 'phpunit.xml updated.'
}

function updateEnv() {
  readonly APP_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
  echo 'Updating the .env file to fit your project.'
  if [ $POSTGRES = true ]
  then
      sed -i -e "s/DB_CONNECTION=mysql/DB_CONNECTION=pgsql/g" .env > /dev/null 2>&1
      sed -i -r "s/DB_PORT=3306/DB_PORT=5432/g" .env > /dev/null 2>&1
  fi
  sed -i -e "s/DB_DATABASE=laravel/DB_DATABASE=$DATABASE_NAME/g" .env > /dev/null 2>&1
  sed -i -e "s/APP_NAME=Laravel/APP_NAME=$APP_NAME/g" .env > /dev/null 2>&1
  rm .env-e > /dev/null 2>&1
  echo '.env updated.'
}

function launchBrowser() {
  if [ $JETSTREAM = false ]
    then
      echo 'Launching Browser.'
      open -a "Google Chrome" "http://$1.test"
  fi
}

function checkProjectDirectory() {
  if [ -d "$HOME/code/$1" ]
  then
    echo "There is already a project named: $1"
    exit
  fi
}

function launchPHPStorm() {
  PSTORM=`which pstorm`
  if [ ! $PSTORM = 'pstorm not found' ]
  then
    pstorm "$HOME/code/$1"
    PHPSTORM=true
  fi 
}

function launchSublime() {
  if [ $PHPSTORM = false ]
  then
    SUBL=`which subl`
    if [ ! $SUBL = 'subl not found' ]
    then
      subl "$HOME/code/$1"
    fi
  fi
}

function launchVSCode() {
  if [ $PHPSTORM = false ] && [ $SUBL = false ]
  then
    SUBL=`which code`
    if [ ! $CODE = 'code not found' ]
    then
      code "$HOME/code/$1"
    fi
  fi
}


if [ -z "$1" ]
then
    showDocs
    exit
fi

checkProjectDirectory $1
init $2 $3 $4 $5 $6 $7
installLaravel $1
installDebugbar
installBreeze
installJetstream
installTailwind $1
createMySQLDatabases $1
createPostgreDatabases $1
updateEnv $1
updatePhpUnitXML
setupGit
launchBrowser $1
launchPHPStorm $1
launchSublime $1
launchVSCode $1
