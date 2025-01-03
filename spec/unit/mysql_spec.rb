
require 'chefspec'

describe 'wordpress_server::mysql' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'installs mysql-server' do
    expect(chef_run).to install_package('mysql-server')
  end

  it 'enables and starts mysql service' do
    expect(chef_run).to enable_service('mysql')
    expect(chef_run).to start_service('mysql')
  end

  it 'executes a command to create the WordPress database' do
    expect(chef_run).to run_execute('create-wordpress-db')
  end
end
