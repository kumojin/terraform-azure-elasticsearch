#!/bin/bash

echo "elasticsearch.hosts:" | sudo tee -a /etc/kibana/kibana.yml
for i in $(seq -f "%06g" 0 ${data_node_count})
do
    echo "- http://default-data$i:9200" | sudo tee -a /etc/kibana/kibana.yml
done

systemctl daemon-reload
systemctl enable kibana.service
sudo service kibana restart
