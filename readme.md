# Laravel-Scripts
## is a collection of scripts that will imporve the creation and removal of projects

### Installation

1. Clone this git repository.
2. Make the `*.sh` files executable by running `sudo chmod +x *.sh`.
3. Copy the sh files to a directory in your path, i.e. `/usr/local/bin` using `cp <command>.sh /usr/local/bin/<command>`.
replace the `<command>` with the command you want to copy.

### Create a new Laravel project with nlp

To create a new you just need to run the following command.

`nlp <project-name>`

This will. 

* Install a new Laravel project.
* Install the barryvdh/laravel-debugbar. 
* Add a MySQL/MariaDB database with your project name.
* Update your `.env` file to match the database name for your project.
* Update `phpunit.xml` to use an SQLite in memory database.
* Create a new local Git repository and do the first initial commit.
 
You can customize your project setup by passing these optional parameters.

* `-breeze` or `-b` to install the Laravel Breeze starterkit.
* `-jetstream` or `-j` to install the Laravel Jetstrem package.
* `-tailwind` or `-t` to install TailwindCSS (Installed by default by Breeze and Jetstream).
* `-database=postgres` or `-db=postgres` to use a PostgreSql data base instead of a MySQL/MariaDB database.
* `-test=mysql` to use a MySQL/MariaDB database for testing.
* `-test=postgres` to use a PostgreSQL database for testing.

The order of the optional parameters doesn't matter.
There are some compinations that you can't use but the script will tell you.

### Remove a Laravel project with klp

To remove a Laravel or any project for that matter, you just run this command.

`klp <project-name>`

This will remove the directory and it will drop the databases that has the same name as your project.

**Be careful so that you don't drop any database that you would want to keep.**

