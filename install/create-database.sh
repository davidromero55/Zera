echo -n "Please, write your Database name: "
read DBNAME
echo -n "Please, write your DataBase Username: "
read DBUSER
echo -n "Please, write a password for your database user (be sure to follow MySQL password requeriments): "
read -s DBPASS
# create random password

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then

    mysql -e "SET GLOBAL validate_password_length = 6;"
    mysql -e "SET GLOBAL validate_password_number_count = 0;"
    mysql -e "CREATE DATABSE IF NOT EXISTS ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${DBPASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${DBUSER}.* TO '${DBNAME}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"

# If /root/.my.cnf doesn't exist then it'll ask for root password
else
    echo -n "Please enter root user MySQL password: "
    read -s rootpasswd
    mysql -uroot -p${rootpasswd} -e "SET GLOBAL validate_password_length = 6;"
    mysql -uroot -p${rootpasswd} -e "SET GLOBAL validate_password_number_count = 0;"
    mysql -uroot -p${rootpasswd} -e "CREATE DATABSE IF NOT EXISTS ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -p${rootpasswd} -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${DBPASS}';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${DBUSER}.* TO '${DBNAME}'@'localhost';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi
#echo "Database and user created with random generated password: ${DBPASS}"
