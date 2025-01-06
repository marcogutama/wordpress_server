# Detectar el sistema operativo
os_name = os.name

if os_name == 'ubuntu'
  # Tests para Ubuntu
  describe package('apache2') do
    it { should be_installed }
  end

  describe service('apache2') do
    it { should be_running }
    it { should be_enabled }
  end
elsif os_name == 'centos'
  # Tests para CentOS
  describe package('httpd') do
    it { should be_installed }
  end

  describe service('httpd') do
    it { should be_running }
    it { should be_enabled }
  end
end

describe port(80) do
  it { should be_listening }
end

describe package('php') do
  it { should be_installed }
end

describe package('mysql-server') do
  it { should be_installed }
end

describe file('/var/www/html/wp-config.php') do
  it { should exist }
  its('content') { should match /DB_NAME.*wordpress/ }
end

describe command('curl -o /dev/null -s -w "%{http_code}" http://localhost') do
  its('stdout') { should eq '200' }
end

describe command('curl -s http://localhost') do
  its('stdout') { should match /<html.*>.*<\/html>/m }
end