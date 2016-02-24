#
# Cookbook Name:: sensu
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

user 'sensu' do
  comment 'Sensu user'
  home '/home/sensu'
  shell '/bin/bash'
  password '$1$I6ueWr6n$jUqEs8umSuv9Hpoo36D4O0'
end

bash 'sudo' do 
 code "echo 'sensu ALL=(ALL:ALL) ALL' >> /etc/sudoers "
end

