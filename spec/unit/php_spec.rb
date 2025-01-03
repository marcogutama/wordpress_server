
require 'chefspec'

describe 'wordpress_server::php' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

  %w[php libapache2-mod-php php-mysql].each do |pkg|
    it "installs #{pkg}" do
      expect(chef_run).to install_package(pkg)
    end
  end
end
