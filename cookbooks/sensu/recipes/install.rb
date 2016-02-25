#
# Cookbook Name:: sensu
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#include_recipe "apt"

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

bash 'copy_SSL_Rabbitmq' do 
 code "cp /tmp/ssl_certs/sensu_ca/cacert.pem /tmp/ssl_certs/server/cert.pem /tmp/ssl_certs/server/key.pem /etc/rabbitmq/ssl"
end

file '/etc/rabbitmq/rabbitmq.config' do
 content '[
    {rabbit, [
    {ssl_listeners, [5671]},
    {ssl_options, [{cacertfile,"/etc/rabbitmq/ssl/cacert.pem"},
                   {certfile,"/etc/rabbitmq/ssl/cert.pem"},
                   {keyfile,"/etc/rabbitmq/ssl/key.pem"},
                   {verify,verify_peer},
                   {fail_if_no_peer_cert,true}]}
    ]}
  ]. '
 mode '0644'
 owner 'root'
 group 'root'
end

service 'rabbitmq-server' do
 action  :restart 
end

execute 'adding RabbitMQ virtual host' do
 command 'rabbitmqctl add_vhost /sensu; rabbitmqctl add_user sensu pass ; rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*" '
end

package 'redis-server' do
 action :install
end

service 'redis-server' do
 action [ :enable, :start ]
end

bash 'adding sources & keys to sensu' do
 code "wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add - ; echo 'deb http://repos.sensuapp.org/apt sensu main' | sudo tee -a /etc/apt/sources.list.d/sensu.list "
end

package 'sensu' do
 action :install
end

package 'uchiwa' do
 action :install
end

directory '/etc/sensu/ssl' do
 owner 'root'
 group 'root'
 mode '0755'
 action :create
end

bash 'SSL_copy_sensu' do
 code "cp /tmp/ssl_certs/client/cert.pem /tmp/ssl_certs/client/key.pem /etc/sensu/ssl"
end

file '/etc/sensu/conf.d/rabbitmq.json' do
 content '{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    },
    "host": "localhost",
    "port": 5671,
    "vhost": "/sensu",
    "user": "sensu",
    "password": "abc123"
    }
  }'
 owner 'root'
 group 'root'
 mode '0644'
 action :create
end

file '/etc/sensu/conf.d/redis.json' do
 content '{
  "redis": {
    "host": "localhost",
    "port": 6379
   }
  }'
 owner 'root'
 group 'root'
 mode '0644'
 action :create
end

file '/etc/sensu/conf.d/api.json' do
 content '{
  "api": {
    "host": "localhost",
    "port": 4567
   }
  }'
 owner 'root'
 group 'root'
 mode '0644'
 action :create
end

file '/etc/sensu/uchiwa.json' do
 content '{
    "sensu": [
        {
            "name": "Sensu",
            "host": "localhost",
            "ssl": false,
            "port": 4567,
            "path": "",
            "timeout": 5000
        }
    ],
    "uchiwa": {
        "port": 3000,
        "stats": 10,
        "refresh": 10000
    }
  }'
 owner 'root'
 group 'root'
 mode '0644'
 action :create
end

service 'sensu-server'  do
 action [ :enable, :start ]
end

service 'sensu-api' do
 action [ :enable, :start ]
end

service 'uchiwa' do
 action [ :enable, :start ]
end


