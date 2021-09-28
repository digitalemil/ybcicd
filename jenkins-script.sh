echo Yugabyte CI/CD Demo with Jenkins

# Requirements:
# Yugabyte Platform installed and accessable from Jenkins VM
# Jenkins installed 
# ysqlsh installed on Jenkins VM (in $YUGAHOME/bin)
# APITOKEN (https://api-docs.yugabyte.com/docs/yugabyte-platform)
# CUSTOMERID (https://api-docs.yugabyte.com/docs/yugabyte-platform/b3A6MTg5NDc2MTc-list-customers)

# Setting Environment Variables
export YUGAHOME=/home/esiemes/yugabyte-2.9.0.0
export PLATFORM=10.156.0.2
export CUSTOMERID=21d85e80-13aa-4dc3-b706-16d310cc3802
export APITOKEN=8e00cae5-0179-432d-a183-0a7a121c5ebf
export YBVERSION=2.9.0.0-b4


# Using yugaware-client to create Universe. Yugaware-client needs to pre-authenticated, or do:
# ./bin/linux-x64/yugaware-client login --email admin@yugabyte --hostname $PLATFORM -p password
UUID=$(./bin/linux-x64/yugaware-client universe create jenkins-build$BUILD_NUMBER --hostname $PLATFORM --provider GCP  --node-count 1 --regions europe-west3 --replication-factor 1 --instance-type n1-standard-4 --version $YBVERSION -o json | ./bin/linux-x64/jq -r '.content.resourceUUID')

echo Universe ID: $UUID

# Let us wait until we have an ip from a node
ip="null"
while [ "$ip" = "null" ]
do
        ip=$(curl -s --request GET   --url http://$PLATFORM/api/v1/customers/$CUSTOMERID/universes/$UUID  --header "Content-Type: application/json"   --header "X-AUTH-YW-API-TOKEN: $APITOKEN" | ./bin/linux-x64/jq -r '.universeDetails.nodeDetailsSet[0].cloudInfo.private_ip')
        sleep 8
done
echo IP: $ip

# Let us wait until we can connect
ready="null"
while [ "$ready" != "yugabyte" ]
do
        ready=$($YUGAHOME/bin/ysqlsh -h $ip -c "select max(table_catalog) as x from information_schema.tables" -t | xargs )
        sleep 8
done


sleep 8

# Table Creation
$YUGAHOME/bin/ysqlsh -h $ip --file=sql/thegym.sql

# Inserts
$YUGAHOME/bin/ysqlsh -h $ip -d thegym --file=sql/inserts.sql

# Check with our Inserts are succesful
res=$($YUGAHOME/bin/ysqlsh -h $ip -d thegym -c "Select count(*) from hrdata" -t | xargs)

# Delete Universe
./bin/linux-x64/yugaware-client universe delete jenkins-build$BUILD_NUMBER --hostname $PLATFORM --approve

if [ "$res" != 3 ]; then
	echo Error. Expecting 3 got: $res
	exit 1
else
	echo Success. Expecting 3 got $res
fi


