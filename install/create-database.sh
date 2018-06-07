echo -n "Please, write your Database name: "
read DBNAME
echo -n "Please, write your DataBase Username: "
read DBUSER
echo -n "Please, write a password for your database user (be sure to follow MySQL password requeriments): "
read -s DBPASS

    mysql -e "DROP DATABASE IF EXISTS ${DBNAME};"
    mysql -e "CREATE DATABASE IF NOT EXISTS ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${DBPASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBUSER}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
#echo "Database and user created with random generated password: ${DBPASS}"
