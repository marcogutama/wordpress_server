
require 'chefspec'

describe 'wordpress_server::wordpress' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  it 'downloads the WordPress tarball' do
    expect(chef_run).to create_remote_file('/var/www/html/latest.tar.gz')
  end

  it 'extracts the WordPress tarball' do
    expect(chef_run).to run_bash('extract_wordpress')
  end

  it 'creates the wp-config.php template' do
    expect(chef_run).to create_template('/var/www/html/wp-config.php')
  end
end
