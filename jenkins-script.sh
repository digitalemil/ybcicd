echo Hello Jenkins! \# $BUILD_NUMBER

UUID=$(./bin/linux-x64/yugaware-client universe create jenkins-build$BUILD_NUMBER --hostname 10.156.0.2 --provider GCP  --node-count 1 --regions europe-west3 --replication-factor 1 --instance-type n1-standard-4 --version 2.9.0.0-b4 -o json | jq -r '.content.resourceUUID')
#UUID=242cd81f-8fa1-4f63-b790-4413e6031d7e
echo
echo Universe ID: $UUID

ip="null"
while [ "$ip" = "null" ]
do
        ip=$(curl -s --request GET   --url http://35.246.171.42/api/v1/customers/21d85e80-13aa-4dc3-b706-16d310cc3802/universes/$UUID  --header 'Content-Type: application/json'   --header 'X-AUTH-YW-API-TOKEN: 8e00cae5-0179-432d-a183-0a7a121c5ebf' | jq -r '.universeDetails.nodeDetailsSet[0].cloudInfo.private_ip')
      	echo IP: $ip
        sleep 2
done

ysqlsh -h $ip -c "Drop database thegym;" || true
ysqlsh -h $ip --file=sql/thesimple.sql

./bin/linux-x64/yugaware-client universe create jenkins-build$BUILD_NUMBER --hostname 10.156.0.2
