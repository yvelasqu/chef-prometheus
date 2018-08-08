name 'chef-prometheus'
maintainer 'yvelasqu'
maintainer_email 'yanara.velasquez@latam.com'
license 'Apache 2.0'
description 'Installs/Configures Prometheus'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.147'

if respond_to?(:source_url)
  source_url 'https://github.com/yvelasqu/chef-prometheus'
end

if respond_to?(:issues_url)
  issues_url 'https://github.com/yvelasqu/chef-prometheus'
end

%w(redhat centos).each do |os|
  supports os
end

depends 'one', '>=0.1.4'
depends 'ulimit', '>=0.4.0'
depends 'logrotate'
