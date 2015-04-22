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
service "ossec" do
  action [:stop, :disable]
end

# Remove files
file "#{Chef::Config[:file_cache_path]}/#{ossec_dir}/etc/preloaded-vars.conf" do
  action :delete
end

directory "#{node['ossec']['user']['dir']}" do
  action :delete
  recursive true
end

# Remove users
group 'ossec' do
  action :delete
end

%w(ossec ossecm ossecr).each do |oscuser|
  user oscuser do
    action :delete
  end
end


