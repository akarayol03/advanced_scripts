#!/bin/bash
volCheck() {
    check="true"
    count=1
    # iterate through volumes, apply ec2 tags via tag()
    while [ "$check" = "true" ]; do   
        vol=$(echo $blockDevices | awk -F ' ' -v item=$count '{print $item}')
        if [ -n "$vol" ]; then #if vol exists, then call tag function
            echo "vol $vol exists"
            tag $vol
            ((count++))
        else
            check="false"
        fi
    done
}
# function that uses awscli to apply tags, is called form volCheck()
tag() {
    aws ec2 create-tags --region $REGION --resources $1 --tags Key=Location,Value=$LOCATION Key=Environment,Value=$ENVIRONMENT Key=Service,Value=$SERVICE Key=Role,Value=$ROLE Key=SubService,Value=VOL Key=Name,Value=$NAME
}
# grab ec2 instance metadata
INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
INSTDATA=$(aws ec2 describe-instances --region $REGION --filters "Name=instance-id,Values=$INSTANCEID")

# specify tags 
TAGS=$(echo "$INSTDATA" | jq ".Reservations[0].Instances[0].Tags")
LOCATION=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Location").Value')
ENVIRONMENT=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Environment").Value')
SERVICE=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Service").Value')
ROLE=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Role").Value')
NAME=$(echo "$TAGS" | jq -r '.[] | select(.Key == "Name").Value')
# grab block devices from instance metadata
blockDevices=$(echo "$INSTDATA" | jq -r '.Reservations[0].Instances[0].BlockDeviceMappings[].Ebs.VolumeId')
# start tagging
volCheck
