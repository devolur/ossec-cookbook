name             "ossec"
maintainer       "Alexis Le-Quoc"
maintainer_email "alq@datadoghq.com"
license          "Apache 2.0"
description      "Installs/Configures ossec"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.8"

%w{ build-essential apt }.each do |pkg|
  depends pkg
end

%w{ debian ubuntu arch redhat centos fedora }.each do |os|
  supports os
end
