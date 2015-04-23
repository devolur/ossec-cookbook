#
# Cookbook Name:: ossec
# Recipe:: purge
#
# Copyright 2015, Datadog, Inc.
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

# Stop service
# Fake the restart to avoid the delayed notification
service 'ossec' do
  supports :start => true, :stop => true, :disable => true, :status => true
  action :nothing
end

ruby_block 'stop service' do
  block do
    r = resources('service[ossec]')
    r.restart_command('/bin/true')
    r.run_action(:stop)
    r.run_action(:disable)
  end
end

ossec_dir = "ossec-hids-#{node['ossec']['version']}"

# Remove files
directory "#{node['ossec']['user']['dir']}" do
  action :delete
  recursive true
end

file "/etc/init.d/ossec" do
  action :delete
end

# Remove users
%w(ossec ossecm ossecr).each do |oscuser|
  user oscuser do
    action :remove
  end
end

group 'ossec' do
  action :remove
end

