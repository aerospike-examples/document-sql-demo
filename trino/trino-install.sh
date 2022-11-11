#!/bin/bash

# Assign arguments
while getopts t:h:c:a:n: flag
do
    case "${flag}" in
        t) trino_version=${OPTARG};; # Trino server version, e.g. 399
        h) host_list=${OPTARG};; # Comma separated list of Aerospike seed nodes, e.g. 172.17.0.3:3000,172.17.0.4:3000
        c) host_list2=${OPTARG};; # Comma separated list of Aerospike seed nodes for a second cluster, e.g. 172.17.0.3:3000,172.17.0.4:3000
        a) aerospike_trino=${OPTARG};; # Aerospike Trino connector version, e.g. 4.2.1-391 
        n) namespace=${OPTARG};; # Aerospike cluster namespace, e.g. demo
    esac
done

# Set defaults
if [ -z "$trino_version" ]; then trino_version="399"; fi
if [ -z "$host_list" ]; then host_list="127.0.0.1:3000"; fi
if [ -z "$aerospike_trino" ]; then aerospike_trino="4.2.1-391"; fi
if [ -z "$namespace" ]; then namespace="demo"; fi

# Split aerospike_trino argument 
aerospike=(${aerospike_trino//-/ })

# Install startup script
mkdir /opt/autoload

cat << EOF > /opt/autoload/trino-start.sh
#!/bin/bash

# Start trino server
su - trino -c "bash ./trino-server/bin/launcher start &"
EOF

chmod +x /opt/autoload/trino-start.sh

# Add trino user
useradd -m -d /home/trino -s /bin/bash trino
cd /home/trino

# Update and install necessary packages
apt-get update
apt-get install unzip openjdk-17-jdk python-is-python3 uuid-runtime -y

# Update limits.conf with suggested limits
sed 's/# End of file/trino      soft        nofile      131072\ntrino       hard        nofile      131072\n\n# End of file/' /etc/security/limits.conf

# Get Trino server and install
wget -O trino.tar.gz https://repo1.maven.org/maven2/io/trino/trino-server/$trino_version/trino-server-$trino_version.tar.gz
tar -xvf trino.tar.gz
rm -rf trino.tar.gz
mv trino-server-$trino_version trino-server

# Create necessary server directories
mkdir data trino-server/etc trino-server/etc/catalog

# Add Trino config files
cat << EOF > trino-server/etc/node.properties
node.environment=aerolab
node.id=`uuidgen`
node.data-dir=/home/trino/data
EOF

cat << EOF > trino-server/etc/jvm.config
-server
-Xmx16G
-XX:InitialRAMPercentage=80
-XX:MaxRAMPercentage=80
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
-XX:+UnlockDiagnosticVMOptions
-XX:+UseAESCTRIntrinsics
EOF

cat << EOF > trino-server/etc/config.properties
coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8080
discovery.uri=http://127.0.0.1:8080
EOF

cat << EOF > trino-server/etc/log.properties
io.trino=INFO
EOF

# Get Trino CLI tool
wget -O trino https://repo1.maven.org/maven2/io/trino/trino-cli/$trino_version/trino-cli-$trino_version-executable.jar
chmod +x trino

# Get and install Aerospike connector
wget -O aerospike.zip https://download.aerospike.com/artifacts/enterprise/aerospike-trino/${aerospike[0]}/aerospike-trino-$aerospike_trino.zip
mkdir aerotmp trino-server/plugin/aerospike
unzip aerospike.zip -d aerotmp
find aerotmp/trino-aerospike-$aerospike_trino -name '*.jar' -exec cp {} trino-server/plugin/aerospike \;

cat << EOF > trino-server/etc/catalog/aerospike.properties
connector.name=aerospike
aerospike.hostlist=$host_list
EOF

cat << EOF > trino-server/etc/catalog/aerospike2.properties
connector.name=aerospike
aerospike.hostlist=$host_list2
EOF

rm -rf aerotmp aerospike.zip

# Change ownership to trino user
chown -R trino /home/trino

su - trino -c "bash ./trino-server/bin/launcher start &" 

exit