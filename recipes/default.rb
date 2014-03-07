#
# Cookbook Name:: unbound
# Recipe:: default
#
# Copyright 2011, Joshua Timberman
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

root_group = value_for_platform(
  "freebsd" => { "default" => "wheel" },
  "default" => "root"
)

# The Ubuntu package activates the service immediately upon installing. If the
# Chef server is in a private zone (e.g., chef.mycorp), this renders the Chef
# server unreachable and breaks the rest of the Chef run. So defer installation
# until configuration files are in place if running on Ubuntu.
unless node[:platform] == 'ubuntu'
  package "unbound" do
    action :upgrade
  end
end

directory "#{node['unbound']['directory']}/conf.d" do
  mode 0755
  owner "root"
  group root_group
  recursive true
end

template "#{node['unbound']['directory']}/unbound.conf" do
  source "unbound.conf.erb"
  mode 0644
  owner "root"
  group root_group
  variables(:types => node['unbound']['zone_types'])
  notifies :restart, "service[unbound]"
end

if node['unbound']['zone_types'].include?('local')
  begin
    local_zone = data_bag_item("dns", node['dns']['domain'].gsub(/\./, "_"))
  rescue
    local_zone = node['dns']['domain']
  end
end

node['unbound']['zone_types'].each do |type|

  template "#{node['unbound']['directory']}/conf.d/#{type}-zone.conf" do
    source "#{type}-zone.conf.erb"
    mode 0644
    owner "root"
    group root_group
    variables(:local_zone => local_zone)
    notifies :restart, "service[unbound]"
  end

end

# Delayed package install for Ubuntu. Have to tell 'apt-get install' to accept
# the configuration files installed above or the Chef run break.
if node[:platform] == "ubuntu"

  template "/etc/default/unbound" do
    source "default_unbound.erb"
    owner 'root'
    group 'root'
    mode '0644'
    variables({
      :unbound_enable => node['unbound']['unbound_enable'],
      :root_trust_anchor_update => node['unbound']['root_trust_anchor_update'],
      :root_trust_anchor_file => node['unbound']['root_trust_anchor_file'],
      :resolvconf => node['unbound']['resolvconf'],
      :resolvconf_forwarders => node['unbound']['resolvconf_forwarders'],
      :daemon_opts => node['unbound']['daemon_opts']
    })
  end

  package "unbound" do
    action :upgrade
    options '-o DPkg::Options::="--force-confold"'
  end

end

if node['unbound']['remote_control']['enable']
  include_recipe "unbound::remote_control"
end

service "unbound" do
  supports value_for_platform(
    ["redhat", "centos", "fedora"] => { "default" => ["status", "restart", "reload"]},
    "freebsd" => {"default" => ["status", "restart", "reload"]},
    ["debian", "ubuntu"] => {"default" => ["restart"]},
    "default" => "restart"
  )
  action [:enable, :start]
end
