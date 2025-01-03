if platform_family?('debian')
  package 'apache2'
  apache_service = 'apache2'
  apache_dir = '/etc/apache2'
  config_path = "#{apache_dir}/sites-available"
  
  # Habilitar módulos (solo para Debian/Ubuntu)
  %w(rewrite).each do |mod|
    execute "enable-#{mod}" do
      command "a2enmod #{mod}"
      notifies :restart, "service[#{apache_service}]"
      not_if "apache2ctl -M | grep #{mod}"
    end
  end

elsif platform_family?('rhel')
  package 'httpd'
  apache_service = 'httpd'
  apache_dir = '/etc/httpd'
  config_path = "#{apache_dir}/conf.d"
  
  # En CentOS el módulo rewrite ya viene habilitado por defecto
  file '/etc/httpd/conf.modules.d/00-rewrite.conf' do
    content 'LoadModule rewrite_module modules/mod_rewrite.so'
    notifies :restart, "service[#{apache_service}]"
  end
end

# Determinar el directorio de logs dependiendo de la plataforma
log_dir = platform_family?('debian') ? '${APACHE_LOG_DIR}' : '/var/log/httpd'

# Eliminar index por defecto
file '/var/www/html/index.html' do
  action :delete
  only_if { File.exist?('/var/www/html/index.html') }
  notifies :restart, "service[#{apache_service}]"
end

# Configurar VirtualHost
template "#{config_path}/wordpress.conf" do
  source 'wordpress.conf.erb'
  variables(log_dir: log_dir)
  notifies :restart, "service[#{apache_service}]"
end

# Solo para Ubuntu: habilitar/deshabilitar sitios
if platform_family?('debian')
  execute 'disable-default-site' do
    command 'a2dissite 000-default'
    notifies :restart, "service[#{apache_service}]"
    only_if { File.exist?('/etc/apache2/sites-enabled/000-default.conf') }
  end

  execute 'enable-wordpress-site' do
    command 'a2ensite wordpress'
    notifies :restart, "service[#{apache_service}]"
    not_if { File.exist?('/etc/apache2/sites-enabled/wordpress.conf') }
  end
end

service apache_service do
  action [:enable, :start]
end