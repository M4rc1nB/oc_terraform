#!/bin/bash

set -e

while [[ -n $(pidof apt) ]]
do
	sleep 3;
done

#Install DDCLIENT for setting dynamic dns 
cat <<'EOT' >> ddclient.conf
# Configuration file for ddclient generated by debconf
#
# /etc/ddclient.conf

protocol=namecheap \
use=web, web=checkip.dyndns.com/, web-skip='IP Address' \
login=marcin.pro \
password='${DDCLIENT_TOKEN}' \
oci
EOT

sudo apt update -y

sudo cp ddclient.conf /etc/ddclient.conf
sudo apt install ddclient -y
sudo service ddclient restart

# format and mount volume
sudo mkdir -p /mnt/data
part=$(sudo partprobe -d -s /dev/oracleoci/oraclevdag)
if [ -z "$part" ]; then
  sudo mkfs.ext4 /dev/oracleoci/oraclevdag
  while [ ! -L /dev/oracleoci/oraclevdag ]; do sleep 10; done
fi

n=0
ok=false
until [ "$n" -ge 5 ]
do
  if mountpoint -q /mnt/data ; then    
      echo "/mnt/data mounted";
      ok=true
      break 
  else    
      echo "/mnt/data not mounted";
      sudo mount /dev/oracleoci/oraclevdag /mnt/data/; 
  fi
  n=$((n+1))
  sleep 10
done
if ! $ok ; then exit 1; fi

# install and enable Docker
sudo apt install -y jq
sudo apt install -y docker.io
sudo usermod -a -G docker ubuntu
sudo apt install docker-compose -y

docker network create my-shared-network
cd /home/ubuntu/

#Create persistant folders for docker-compose deployments
mkdir -p /mnt/data/sqlserver/data
mkdir -p /mnt/data/sqlserver/logs
mkdir -p /mnt/data/sqlserver/secrets
mkdir -p /mnt/data/code-server/config
mkdir -p /mnt/data/postgres/data


cat <<'EOT' >> docker-compose.yml
version: '2.2'

networks:
    my-shared-network:
        external: true
services:
  sqlserver:
      image:  mcr.microsoft.com/azure-sql-edge
      networks:
        - my-shared-network
      hostname: mb-sqlserver-01
      ports:
        - "1433:1433"
      user: root
      environment:
        ACCEPT_EULA: 1
        MSSQL_SA_PASSWORD: ${MSSQL_SA_PASSWORD}
        MSSQL_PID: Developer
        MSSQL_USER: SA
      volumes:
          - "/mnt/data/sqlserver/data:/var/opt/mssql/data"
          - "/mnt/data/sqlserver/log:/var/opt/mssql/log"
          - "/mnt/data/sqlserver/secrets:/var/opt/mssql/secrets"
      restart: unless-stopped

  code-server:
      image: lscr.io/linuxserver/code-server
      networks:
        - my-shared-network
      environment:
        - PUID=1001 # Use the UID from the command mentioned above
        - PGID=1001 # Use the GID from the command mentioned above
        - TZ=GB/London # Time Zone of your choice for the container
        - PASSWORD=${CODE_SRV_PASSWORD} # Login password for the Web UI
        - SUDO_PASSWORD=${CODE_SRV_SU_PASSWORD} # Sudo password (Optional)
      volumes:
        - /mnt/data/code-server/config:/config # Volume mount for the container config files (Replace the path with the path on your host)
      ports:
        - 8443:8443 # Port mapping for the container in the format <host-port>:<container-port>. You can choose the <host-port> as per your convenience
        - 22:22 #SSH
      restart: unless-stopped # Keep the container running unless manually stopped

  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    networks:
      - my-shared-network
    hostname: mb-zookeeper-01
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - 22181:2181
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:latest
    networks:
      - my-shared-network
    hostname: kafka01
    depends_on:
      - zookeeper
    ports:
      - 29092:29092
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092,PLAINTEXT_HOST://demo-factory-kafka-1:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    restart: unless-stopped

  postgres:
     image: postgres:10.5
     networks:
       - my-shared-network
     hostname: mb-postgres-01
     #restart: always
     environment:
       - POSTGRES_USER=postgres
       - POSTGRES_PASSWORD=postgres
     logging:
       options:
          max-size: 10m
          max-file: "3"
     ports:
       - '5432:5432'
     volumes:
       - /mnt/data/postgres/data:/var/lib/postgresql/data
     restart: unless-stopped

  sdc:
    image: streamsets/datacollector:JDK17_5.4.0-latest
    networks:
      - my-shared-network
    hostname: mb-sdc-01
    ports:
      - "18630:18630"
    environment:
      STREAMSETS_DEPLOYMENT_SCH_URL: https://musala.hub.streamsets.com
      STREAMSETS_DEPLOYMENT_ID: 23c65a19-20a6-45f5-a374-cea023072c62:6e1ffbd3-6a93-11ed-ba50-3f79daffbd29
      STREAMSETS_DEPLOYMENT_TOKEN: eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiZjFiZmNkNGFmN2E5YzI2ZmQxMWY3OTI5MjUyNzJkZmMxOWI3ZjE0NDZkZTc3NzJhZThiYmEwOTI0ZmUxYTVhNGJjZjAwOTY0NDU0Y2MxNDQ3YTE5MjNkY2NlYzU3YjVkNzU5MWRmOGY3ODFkZDdlMzBlY2JhZTkyYmNlNjY3YzQiLCJ2IjoxLCJpc3MiOiJtdXNhbGEiLCJqdGkiOiIzYzE5OGNhYi05ZDRmLTQzZDQtODg0OS1kMjkzNDdmMWEyYmIiLCJvIjoiNmUxZmZiZDMtNmE5My0xMWVkLWJhNTAtM2Y3OWRhZmZiZDI5In0.
    restart: unless-stopped

EOT

sudo docker-compose up -d 



