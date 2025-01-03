if platform_family?('debian')
  package ['php', 'php-mysql', 'libapache2-mod-php']
elsif platform_family?('rhel')
  package ['php', 'php-mysqlnd', 'php-fpm', 'php-json']
end