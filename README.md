# straliens-server

**The frontend code has been moved to `save_static_frontend`.** It should be moved to another repository.

 - [REST API Documentation](https://github.com/AlsaceDigitale/straliens-server/wiki/Straliens-Server-REST-API)


## Requirements

 - NodeJS & NPM
 - CoffeeScript `sudo npm install -g coffee-script`
 - A MySQL-compatible database (you should look at MariaDB)

## Installation

 - `git clone https://github.com/AlsaceDigitale/straliens-server.git`
 - `npm install`

To create the database, use phpmyadmin, MySQL Workbench or SQL (please use the same db/username/pwd):
```
$ sudo apt-get install mysql-server
$ mysql -u root -p
mysql> create database straliens;
mysql> grant usage on *.* to straliens@localhost identified by 'stralienspa$$';
mysql> grant all privileges on straliens.* to straliens@localhost ;
```

Optional : phpmyadmin to visualize/edit the database datas. Try it in three commands:
```
sudo apt-get install php5-cli php5-mysql
git clone https://github.com/phpmyadmin/phpmyadmin.git
cd phpmyadmin; php -S localhost:8080
```

## Run

 - `coffee server.coffee`
