#!/bin/bash

# Script para instalar el stack ELK desde nuestro Vagrantfile

# Habilitamos repositorio e instalamos elasticsearch + apt key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

#Instalamos dependencias, herramientas y elasticsearch
sudo apt update
sudo apt -y install openjdk-11-jre-headless
sudo apt install elasticsearch

sudo cat <<EOF >>/etc/elasticsearch/elasticsearch.yml
network.host: localhost
http.port: 9200
EOF
sudo systemctl daemon-reload
sudo systemctl start elasticsearch.service
sudo systemctl enable elasticsearch.service

# Instalación de kibana
sudo apt install kibana
sudo cat <<EOF >>/etc/kibana/kibana.yml
server.port: 5601
elasticsearch.hosts: ["http://localhost:9200"]
server.host: "0.0.0.0"
EOF
sudo systemctl start kibana.service
sudo systemctl enable kibana.service
sudo ufw allow 5601/tcp

# Instalación de logstash
sudo apt-get -y install logstash
sudo cat << EOF >>/etc/logstash/conf.d/apache_logs.conf
input {
  beats {
    port => 5044 
  }
}

filter{
  grok {
    match => {"message" => "%{COMBINEDAPACHELOG}"}
  }
  date {
    match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
  }
  geoip {
    source => "clientip"
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    manage_template => false
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
EOF

sudo systemctl start logstash
sudo systemctl enable logstash
