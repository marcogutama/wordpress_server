# Actualización del índice de paquetes según la plataforma
if platform_family?('debian')
  apt_update 'Actualizar caché de APT' do
    action :update
  end
end

if platform_family?('rhel')
  # Arreglar repositorios CentOS 8
  execute 'fix-centos8-repos' do
    command <<-EOH
      sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
      sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
    EOH
    action :run
  end
end

# Incluir las recetas principales
include_recipe 'wordpress_server::apache'
include_recipe 'wordpress_server::php'
include_recipe 'wordpress_server::mysql'
include_recipe 'wordpress_server::wordpress'
