# Instalar MySQL
if platform_family?('debian')
  package 'mysql-server'
  mysql_service = 'mysql'
elsif platform_family?('rhel')
  package 'mysql-server'
  mysql_service = 'mysqld'
end

# Habilitar y arrancar el servicio de MySQL
service mysql_service do
  action [:enable, :start]
end

# Crear la base de datos WordPress si no existe
execute 'create-wordpress-db' do
  command "mysql -uroot -e 'CREATE DATABASE IF NOT EXISTS wordpress;'"
  not_if "mysql -uroot -e 'SHOW DATABASES;' | grep wordpress"
end

# Crear un usuario específico para WordPress si no existe y otorgar permisos
execute 'create-wordpress-user-and-permissions' do
  command <<-SQL
    mysql -uroot -e "
    CREATE USER IF NOT EXISTS 'wordpress_user'@'localhost' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress_user'@'localhost';
    FLUSH PRIVILEGES;
    "
  SQL
  not_if "mysql -uroot -e 'SELECT User FROM mysql.user WHERE User = \"wordpress_user\";' | grep wordpress_user"
end
