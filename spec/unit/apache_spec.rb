require 'chefspec'

describe 'wordpress_server::apache' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'installs apache2' do
    expect(chef_run).to install_package('apache2')
  end

  it 'enables and starts apache2 service' do
    expect(chef_run).to enable_service('apache2')
    expect(chef_run).to start_service('apache2')
  end

  it 'creates the wordpress.conf template' do
    expect(chef_run).to create_template('/etc/apache2/sites-available/wordpress.conf')
  end
end
