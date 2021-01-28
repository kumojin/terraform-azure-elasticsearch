#!/bin/bash

echo "xpack.security.enabled: ${security_enabled}" | sudo tee -a /etc/kibana/kibana.yml
echo "xpack.monitoring.enabled: ${monitoring_enabled}" | sudo tee -a /etc/kibana/kibana.yml
echo "xpack.reporting.enabled: false" | sudo tee -a /etc/kibana/kibana.yml

echo "elasticsearch.hosts:"
for i in $(seq -f "%06g" 0 ${data_node_count})
do
    echo "- http://default-data$i:9200" | sudo tee -a /etc/kibana/kibana.yml
done

systemctl daemon-reload
systemctl enable kibana.service
sudo service kibana restart
