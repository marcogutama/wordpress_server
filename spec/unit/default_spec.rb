require 'chefspec'

describe 'wordpress_server::default' do
  # Configuración global de stubs para comandos
  before do
    # Stub para Ubuntu
    stub_command("apache2ctl -M | grep rewrite").and_return(true)
    # Stub para CentOS
    stub_command("httpd -M | grep rewrite").and_return(true)
    # Otros posibles comandos que necesiten stub
    stub_command("which mysql").and_return('/usr/bin/mysql')
    stub_command("test -f /var/www/html/wp-config.php").and_return(false)
    stub_command("mysql -uroot -e 'SHOW DATABASES;' | grep wordpress").and_return(true)
    stub_command("mysql -uroot -e 'SELECT User FROM mysql.user WHERE User = \"wordpress_user\";' | grep wordpress_user").and_return(true)
  end

  # Test Case 1: Verificación de dependencias de paquetes por plataforma
  context 'validación de instalación de paquetes' do
    context 'cuando es Ubuntu 22.04' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
          node.normal['memory']['total'] = '2048MB'
          node.normal['ipaddress'] = '1.1.1.1'
        end.converge(described_recipe)
      end

      it 'instala los paquetes necesarios' do
        expect(chef_run).to install_package('apache2')        
        expect(chef_run).to install_package(['php', 'php-mysql', 'libapache2-mod-php'])
        expect(chef_run).to install_package('mysql-server')
      end
    end

    context 'cuando es CentOS 8' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: '8') do |node|
          node.normal['memory']['total'] = '2048MB'
          node.normal['ipaddress'] = '1.1.1.1'
        end.converge(described_recipe)
      end

      it 'instala los paquetes necesarios' do
        expect(chef_run).to install_package('httpd')
        expect(chef_run).to install_package(['php', 'php-mysqlnd', 'php-fpm', 'php-json'])
        expect(chef_run).to install_package('mysql-server')
      end
    end
  end

  # Test Case 2: Verificación de configuración de servicios
  context 'configuración de servicios' do
    platforms = {
      'ubuntu' => { version: '22.04', web_service: 'apache2' },
      'centos' => { version: '8', web_service: 'httpd' }
    }

    platforms.each do |platform, platform_data|
      context "cuando es #{platform}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: platform_data[:version]) do |node|
            # Configuración específica de la plataforma si es necesaria
            if platform == 'ubuntu'
              stub_command("apache2ctl -M | grep rewrite").and_return(true)
            else
              stub_command("httpd -M | grep rewrite").and_return(true)
            end
          end.converge(described_recipe)
        end

        it 'configura los servicios' do
          expect(chef_run).to enable_service(platform_data[:web_service])
          expect(chef_run).to start_service(platform_data[:web_service])
        end
      end
    end
  end

  # Test Case 3: Verificación de directorios
  context 'configuración de directorios' do
    platforms = {
      'ubuntu' => { 
        version: '22.04',
        web_root: '/var/www/html'
      },
      'centos' => {
        version: '8',
        web_root: '/var/www/html'
      }
    }

    platforms.each do |platform, platform_data|
      context "cuando es #{platform}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: platform_data[:version]).converge(described_recipe)
        end

        it 'crea el archivo wp-config.php' do
          expect(chef_run).to create_template('/var/www/html/wp-config.php')
        end
      end
    end
  end

  # Test Case 4: Verificación de configuración de WordPress
  context 'configuración de WordPress' do
    platforms = {
      'ubuntu' => { version: '22.04', config_path: '/var/www/html/wp-config.php' },
      'centos' => { version: '8', config_path: '/var/www/html/wp-config.php' }
    }

    platforms.each do |platform, platform_data|
      context "cuando es #{platform}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: platform_data[:version]) do |node|
            node.normal['wordpress'] = {
              'db' => {
                'name' => 'wordpress',
                'user' => 'wordpress_user',
                'pass' => 'password'
              }
            }
          end.converge(described_recipe)
        end

        before do
          # Stub para verificar si el archivo de configuración existe
          stub_command("test -f #{platform_data[:config_path]}").and_return(false)
        end

        it 'crea el archivo wp-config.php' do
          expect(chef_run).to create_template(platform_data[:config_path])
        end
      end
    end
  end

  # Test Case 5: Verificación de configuración del servidor web
  context 'configuración del servidor web' do
    platforms = {
      'ubuntu' => {
        version: '22.04',
        config_path: '/etc/apache2/sites-available/wordpress.conf',
        command: 'apache2ctl -M | grep rewrite'
      },
      'centos' => {
        version: '8',
        config_path: '/etc/httpd/conf.d/wordpress.conf',
        command: 'httpd -M | grep rewrite'
      }
    }

    platforms.each do |platform, platform_data|
      context "cuando es #{platform}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: platform_data[:version]) do |node|
            node.normal['wordpress'] = {
              'server_name' => 'wordpress.example.com'
            }
          end.converge(described_recipe)
        end

        before do
          # Stub específico para cada plataforma
          stub_command(platform_data[:command]).and_return(true)
        end

        it 'crea la configuración del virtual host' do
          expect(chef_run).to create_template(platform_data[:config_path])
        end
      end
    end
  end
end
