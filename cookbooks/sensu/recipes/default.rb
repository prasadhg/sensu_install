#
# Cookbook Name:: sensu
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#include_recipe "apt"

include_recipe  "sensu::install"

user 'sensu' do
  comment 'Sensu user'
  home '/home/sensu'
  shell '/bin/bash'
  password '$1$I6ueWr6n$jUqEs8umSuv9Hpoo36D4O0'
end

bash 'sudo' do 
 code "echo 'sensu ALL=(ALL:ALL) ALL' >> /etc/sudoers "
end

package 'rabbitmq-server' do
 action :install
end

package 'erlang-nox' do
 action :install
end

service 'rabbitmq-server' do
 action [ :enable, :start ]
end

bash 'SSL' do
 code " cd /tmp && wget http://sensuapp.org/docs/0.13/tools/ssl_certs.tar && tar -xvf ssl_certs.tar ; cd ssl_certs && ./ssl_certs.sh generate"
end

directory '/etc/rabbitmq/ssl' do
  owner 'root'
  group 'root'
  mode '0755'
 action :create
end

bash 'copy_SSL' do 
 code "cp /tmp/ssl_certs/sensu_ca/cacert.pem /tmp/ssl_certs/server/cert.pem /tmp/ssl_certs/server/key.pem /etc/rabbitmq/ssl"
end


