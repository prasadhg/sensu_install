##Before configuring client machine, copy the SSL certificates from server to client.
##scp /tmp/ssl_certs/client/cert.pem /tmp/ssl_certs/client/key.pem user@ip:/tmp
include apt

bash 'adding sources & keys to sensu' do
 code "wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add - ; echo 'deb http://repos.sensuapp.org/apt sensu main' | sudo tee -a /etc/apt/sources.list.d/sensu.list "
end

execute "apt-get-update" do
  command "apt-get update"
end

package 'sensu' do
 action : install
end

bash 'SSL_copy_sensu' do
 code "mkdir -p /etc/sensu/ssl && sudo cp /tmp/cert.pem /tmp/key.pem /etc/sensu/ssl"
end

file '/etc/sensu/conf.d/rabbitmq.json' do
 content '{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    },
    "host": "#{server_ip}",
    "port": 5671,
    "vhost": "/sensu",
    "user": "sensu",
    "password": "abc123"
   } 
  }'
end

file '/etc/sensu/conf.d/client.json' do
 content '{
  "client": {
    "name": "client1",
    "address": "localhost",
    "subscriptions": [ "ALL" ]
    }
  }'
end

service 'sensu-client'  do
 action [ :enable, :start ]
end

## Now should be able to see client machine on Uchiwa dashboard
