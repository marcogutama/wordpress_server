# Determinar el usuario y grupo correctos
web_user = platform_family?('debian') ? 'www-data' : 'apache'
web_group = platform_family?('debian') ? 'www-data' : 'apache'

# Descargar y extraer WordPress
remote_file '/var/www/html/latest.tar.gz' do
  source 'https://wordpress.org/latest.tar.gz'
  action :create
end

bash 'extract_wordpress' do
  cwd '/var/www/html'
  code <<-EOH
    tar -xzf latest.tar.gz --strip-components=1
    chown -R #{web_user}:#{web_group} /var/www/html
    chmod -R 755 /var/www/html
  EOH
  not_if { ::File.exist?('/var/www/html/wp-config.php') }
end

# Crear el archivo wp-config.php
template '/var/www/html/wp-config.php' do
  source 'wp-config.php.erb'
  owner web_user
  group web_group
  mode '0644'
  variables(
    db_name: 'wordpress',
    db_user: 'wordpress_user',
    db_password: 'password'
  )
end

# Descargar WP-CLI
remote_file '/usr/local/bin/wp' do
  source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  mode '0755'
  action :create
end

# Configurar WordPress y crear el primer post
bash 'configure_wordpress_and_create_post' do
  cwd '/var/www/html'
  code <<-EOH
    /usr/local/bin/wp core install \
      --url="#{node['wordpress']['site_url']}" \
      --title="Mi Sitio WordPress" \
      --admin_user="admin" \
      --admin_password="admin_password" \
      --admin_email="admin@tudominio.com" \
      --allow-root

    # Configurar WordPress para mostrar la página de posts
    /usr/local/bin/wp option update show_on_front 'posts' --allow-root
    
    /usr/local/bin/wp post create \
      --post_title="Bienvenido a mi blog" \
      --post_content="Este es el primer post de mi sitio WordPress instalado desde la terminal." \
      --post_status=publish \
      --allow-root
      
    # Asegurar permisos correctos
    chown -R #{web_user}:#{web_group} /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \\;
    find /var/www/html -type f -exec chmod 644 {} \\;
  EOH
  only_if { ::File.exist?('/var/www/html/wp-config.php') }
end
