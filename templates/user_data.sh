#!/bin/bash

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Configure elasticsearch
cat <<'EOF' >>/etc/elasticsearch/elasticsearch.yml
cluster.name: ${cluster_name}

# only data nodes should have ingest and http capabilities
node.master: ${master}
node.data: ${data}
node.ingest: ${data}
path.data: ${elasticsearch_data_dir}
path.logs: ${elasticsearch_logs_dir}
bootstrap.memory_lock: true
xpack.security.enabled: ${security_enabled}
xpack.monitoring.enabled: ${monitoring_enabled}
EOF

if [ "${master}" == "true"  ]; then
    cat <<'EOF' >>/etc/elasticsearch/elasticsearch.yml
cluster.initial_master_nodes: ["${cluster_name}-master000000"]
EOF
fi

if [ "${xpack_monitoring_host}" != "self" ]; then
cat <<'EOF' >>/etc/elasticsearch/elasticsearch.yml
xpack.monitoring.exporters.xpack_remote:
  type: http
  host: "${xpack_monitoring_host}"
EOF
fi

# Azure doesn't have a proper discovery plugin, hence we are going old-school and relying on scaleset name prefixes
cat <<'EOF' >>/etc/elasticsearch/elasticsearch.yml
network.host: _site_,localhost

# For discovery we are using predictable hostnames (thanks to the computer name prefix), but could just as well use the
# predictable subnet addresses starting at 10.1.0.5.
discovery.seed_hosts: ["${cluster_name}-master000000", "${cluster_name}-data000000"]
EOF

cat <<'EOF' >>/etc/security/limits.conf

# allow user 'elasticsearch' mlockall
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
EOF

sudo mkdir -p /etc/systemd/system/elasticsearch.service.d
cat <<'EOF' >>/etc/systemd/system/elasticsearch.service.d/override.conf
[Service]
LimitMEMLOCK=infinity
LimitFSIZE=infinity
LimitAS=infinity
Restart=always
RestartSec=10
EOF

# Setup heap size and memory locking
sudo sed -i 's/#MAX_LOCKED_MEMORY=.*$/MAX_LOCKED_MEMORY=unlimited/' /etc/init.d/elasticsearch
sudo sed -i 's/#MAX_LOCKED_MEMORY=.*$/MAX_LOCKED_MEMORY=unlimited/' /etc/default/elasticsearch
sudo sed -i "s/^-Xms.*/-Xms${heap_size}/" /etc/elasticsearch/jvm.options
sudo sed -i "s/^-Xmx.*/-Xmx${heap_size}/" /etc/elasticsearch/jvm.options

# Setup GC
sudo sed -i "s/^-XX:+UseConcMarkSweepGC/-XX:+UseG1GC/" /etc/elasticsearch/jvm.options

# Storage
sudo mkdir -p ${elasticsearch_logs_dir}
sudo chown -R elasticsearch:elasticsearch ${elasticsearch_logs_dir}

# we are assuming volume is declared and attached when data_dir is passed to the script
if { [ "${master}" == "true" ] || [ "${data}" == "true" ]; }; then
    sudo mkdir -p ${elasticsearch_data_dir}

    export DEVICE_NAME=$(lsblk -ip | tail -n +2 | awk '{print $1 " " ($7? "MOUNTEDPART" : "") }' | sed ':a;N;$!ba;s/\n`/ /g' | grep -v MOUNTEDPART | grep -v sda | grep -v sr0)
    if sudo mount -o defaults -t ext4 $DEVICE_NAME ${elasticsearch_data_dir}; then
        echo 'Successfully mounted existing disk'
    else
        echo 'Trying to mount a fresh disk'
        sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard $DEVICE_NAME
        sudo mount -o defaults -t ext4 $DEVICE_NAME ${elasticsearch_data_dir} && echo 'Successfully mounted a fresh disk'
    fi
    echo "$DEVICE_NAME ${elasticsearch_data_dir} ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
    sudo chown -R elasticsearch:elasticsearch ${elasticsearch_data_dir}
fi

# Start Elasticsearch
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

if [ "${bootstrap_node}" == "true"  ]; then
    while true
    do
        echo "Checking cluster health"
        HEALTH="$(curl --silent http://localhost:9200/_cluster/health | jq -r '.status')"
        if [ "$HEALTH" = "green" ]; then
            break
        fi
        sleep 5
    done
    shutdown -h now
else
    # Setup x-pack security also on Kibana configs where applicable
    if [ -f "/etc/kibana/kibana.yml" ]; then
        echo "xpack.security.enabled: ${security_enabled}" | sudo tee -a /etc/kibana/kibana.yml
        echo "xpack.monitoring.enabled: ${monitoring_enabled}" | sudo tee -a /etc/kibana/kibana.yml
        systemctl daemon-reload
        systemctl enable kibana.service
        sudo service kibana restart
    fi

    sleep 60
    if [ $(systemctl is-failed elasticsearch.service) == "failed" ]; then
        echo "Elasticsearch unit failed to start"
        exit 1
    fi
fi