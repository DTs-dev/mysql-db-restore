#!/bin/bash
echo -e "\e[1;33mSelect database encoding:\e[1;37m"
echo "1 - utf8"
echo "2 - utf8mb4"
echo "3 - cp1251"
echo "4 - latin1"
echo -n ": "

read char

case $char in
	1)
		CHARACTER="utf8"
		echo -e "Selected database encoding: \e[1;31mutf8\e[1;33m"
		echo ""
		echo -e "Now select the DB collation scheme:\e[1;37m"
		echo "1 - utf8_general_ci"
		echo "2 - utf8_unicode_ci"
		echo "3 - utf8_unicode_520_ci"
		echo "4 - utf8_bin"
		echo -n ": "

		read coll

		case $coll in
			1)
				COLLATION="utf8_general_ci"
				;;
			2)
				COLLATION="utf8_unicode_ci"
				;;
			3)
				COLLATION="utf8_unicode_520_ci"
				;;
			4)
				COLLATION="utf8_bin"
				;;
		esac
		echo -e "Selected the DB collation scheme: \e[1;31m${COLLATION}\e[1;37m"
		;;
	2)
		CHARACTER="utf8mb4"
		echo -e "Selected database encoding: \e[1;31mutf8mb4\e[1;33m"
		echo ""
		echo -e "Now select the DB collation scheme:\e[1;37m"
		echo "1 - utf8mb4_general_ci"
		echo "2 - utf8mb4_unicode_ci"
		echo "3 - utf8mb4_unicode_520_ci"
		echo "4 - utf8mb4_bin"
		echo -n ": "

		read coll

		case $coll in
			1)
				COLLATION="utf8mb4_general_ci"
				;;
			2)
				COLLATION="utf8mb4_unicode_ci"
				;;
			3)
				COLLATION="utf8mb4_unicode_520_ci"
				;;
			4)
				COLLATION="utf8mb4_bin"
				;;
		esac
		echo -e "Selected the DB collation scheme: \e[1;31m${COLLATION}\e[1;37m"
		;;
	3)
		CHARACTER="cp1251"
		echo -e "Selected database encoding: \e[1;31mcp1251\e[1;33m"
		echo ""
		echo -e "Now select the DB collation scheme:\e[1;37m"
		echo "1 - cp1251_general_ci"
		echo "2 - cp1251_bin"
		echo -n ": "

		read coll

		case $coll in
			1)
				COLLATION="cp1251_general_ci"
				;;
			2)
				COLLATION="cp1251_bin"
				;;
		esac
		echo -e "Selected the DB collation scheme: \e[1;31m${COLLATION}\e[1;37m"
		;;
	4)
		CHARACTER="latin1"
		echo -e "Selected database encoding: \e[1;31mlatin1\e[1;33m"
		echo ""
		echo -e "Now select the DB collation scheme:\e[1;37m"
		echo "1 - latin1_general_ci"
		echo "2 - latin1_bin"
		echo -n ": "

		read coll

		case $coll in
			1)
				COLLATION="latin1_general_ci"
				;;
			2)
				COLLATION="latin1_bin"
				;;
		esac
		echo -e "Selected the DB collation scheme: \e[1;31m${COLLATION}\e[1;37m"
		;;
esac

echo ""

echo -en "\e[1;33mEnter the name of the DB dump file: \e[1;37m"
read dump_db
echo -e "DB dump file: \e[1;31m${dump_db}\e[1;33m"

echo ""

echo -en "Enter database name: \e[1;37m"
read db
echo -e "Database name used: \e[1;31m${db}\e[1;33m"

echo ""

while true; do
	read -p "Create a new database? (Y|N), N - use existing database " db_create
	case $db_create in
		[Yy]*)
			DB_CREATE_SQL="CREATE DATABASE ${db} DEFAULT CHARACTER SET ${CHARACTER} COLLATE ${COLLATION};"
			MYSQL_OPERATION_USER="root"
			break
			;;
		[Nn]*)
			DB_CREATE_SQL=""
			break
			;;
		*)
			echo -e "Please answer Y or N"
			;;
	esac
done

echo ""

while true; do
	read -p "Do you want to create a database user? (Y|N), N - use existing " db_user_yn
	case $db_user_yn in
		[Yy]*)
			echo -en "Enter the name of the database user to be created: \e[1;37m"
			read db_user
			echo -e "OK, the selected name for the user to be created: \e[1;31m${db_user}\e[1;33m"
			echo -en "Enter the password for the new user: "
			read -s db_user_pass
			echo ""
			echo ""
			echo -e "\e[1;31mEnter the password for the MySQL user 'root'"
			gunzip -k ${dump_db}
			dump_db_sql=${dump_db%.gz}
			mysql -uroot -p -h 127.0.0.1 --default-character-set=${CHARACTER} -e \
			"SET names ${CHARACTER}; SET collation_connection = ${COLLATION}; ${DB_CREATE_SQL} CREATE USER ${db_user} IDENTIFIED BY '${db_user_pass}'; GRANT ALL PRIVILEGES ON ${db}.* TO ${db_user}; FLUSH PRIVILEGES; USE ${db}; SOURCE ${dump_db_sql};"
			rm ${dump_db_sql}
			break
			;;
		[Nn]*)
			echo -en "Enter the name of an existing user for the database: \e[1;37m"
			read db_user
			echo -e "OK, the following existing user is selected: \e[1;31m${db_user}"
			echo ""
			if [[ -z "${MYSQL_OPERATION_USER}" ]]
			then
				MYSQL_OPERATION_USER=${db_user}
			else
				DB_CREATE_SQL="CREATE DATABASE ${db} DEFAULT CHARACTER SET ${CHARACTER} COLLATE ${COLLATION}; GRANT ALL PRIVILEGES ON ${db}.* TO ${db_user}; FLUSH PRIVILEGES;"
			fi
			echo -e "Enter the password for the MySQL user '${MYSQL_OPERATION_USER}'"
			gunzip -k ${dump_db}
			dump_db_sql=${dump_db%.gz}
			mysql -u${MYSQL_OPERATION_USER} -p -h 127.0.0.1 --default-character-set=${CHARACTER} -e \
			"SET names ${CHARACTER}; SET collation_connection = ${COLLATION}; ${DB_CREATE_SQL} USE ${db}; SOURCE ${dump_db_sql};"
			rm ${dump_db_sql}
			break
			;;
		*)
			echo -e "Please answer Y or N"
			;;
	esac
done

echo ""

echo -e "\e[1;33mDB dump restoration completed!\e[1;37m"
