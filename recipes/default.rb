#
# Cookbook Name:: ossec
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set up some user accounts as system users to prevent mayhem later
group 'ossec' do
  system true
end

%w(ossec ossecm ossecr).each do |oscuser|
  user oscuser do
    shell '/bin/false'
    system true
    gid 'ossec'
    home node['ossec']['user']['dir']
  end
end

include_recipe "build-essential"

ossec_dir = "ossec-hids-#{node['ossec']['version']}"

remote_file "#{Chef::Config[:file_cache_path]}/#{ossec_dir}.tar.gz" do
  source node['ossec']['url']
  checksum node['ossec']['checksum']
end

execute "tar zxvf #{ossec_dir}.tar.gz" do
  cwd Chef::Config[:file_cache_path]
  creates "#{Chef::Config[:file_cache_path]}/#{ossec_dir}"
end

template "#{Chef::Config[:file_cache_path]}/#{ossec_dir}/etc/preloaded-vars.conf" do
  source "preloaded-vars.conf.erb"
  variables :ossec => node['ossec']['user']
end

bash "install-ossec" do
  cwd "#{Chef::Config[:file_cache_path]}/#{ossec_dir}"
  code <<-EOH
  echo "HEXTRA=-DMAX_AGENTS=#{node['ossec']['server']['maxagents']}" >> src/Config.OS
  ./install.sh
  EOH
  creates "#{node['ossec']['user']['dir']}/bin/ossec-control"
end

# not really a template, dist by ossec, so we don't need a copy in the cookbook
template "#{node['ossec']['user']['dir']}/bin/ossec-batch-manager.pl" do
  source "#{Chef::Config[:file_cache_path]}/#{ossec_dir}/contrib/ossec-batch-manager.pl"
  local true
  owner "root"
  group "ossec"
  mode 0755
end

template "#{node['ossec']['user']['dir']}/etc/ossec.conf" do
  source "ossec.conf.erb"
  owner "root"
  group "ossec"
  mode 0440
  variables(:ossec => node['ossec']['user'])
  notifies :restart, "service[ossec]"
  not_if { node['ossec']['disable_config_generation'] }
end

case node['platform']
when "arch"
  template "/usr/lib/systemd/system/ossec.service" do
    source "ossec.service.erb"
    owner "root"
    mode 0644
  end
end

ossec_plist = ::File.join(node['ossec']['user']['dir'], 'bin', '.process_list')
execute 'Enable Remote Syslog Shipping' do
  cwd ::File.join(node['ossec']['user']['dir'], 'bin')
  command './ossec-control enable client-syslog'
  not_if { ::File.exists?(ossec_plist) && ::File.read(ossec_plist).downcase.include?('csyslog_daemon') }
  only_if { node['ossec']['install_type'] != 'agent' && node['ossec']['user']['syslog_output']['enabled'] }
  notifies :restart, 'service[ossec]', :delayed
end

service "ossec" do
  supports :status => true, :restart => true
  action [:enable, :start]
  # Since the ossec-maild exits if mail is disabled, the status command always returns false,
  # and the services are started, causing an extra delay.
  # This tests whether maild is running when it shouldn't be, as well as allowing the :status action
  # to not trigger a :start.
  # Ultimately, this should be responsibility of the upstream init script's status command.
  status_command '/etc/init.d/ossec status | grep -cq "ossec-maild not running"'
end
