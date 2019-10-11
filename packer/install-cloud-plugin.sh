#!/bin/bash
set -e

# See https://stackoverflow.com/a/50103533
printf '\xfe\xed\xfe\xed\x00\x00\x00\x02\x00\x00\x00\x00\xe2\x68\x6e\x45\xfb\x43\xdf\xa4\xd9\x92\xdd\x41\xce\xb6\xb2\x1c\x63\x30\xd7\x92' | sudo tee /etc/ssl/certs/java/cacerts > /dev/null
sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure

cd /usr/share/elasticsearch/

# install Azure-specific plugins
sudo bin/elasticsearch-plugin install --batch repository-azure
