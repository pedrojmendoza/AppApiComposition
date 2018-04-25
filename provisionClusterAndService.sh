# creating
aws cloudformation create-stack --stack-name OkCluster --template-body file://cluster.yml --capabilities CAPABILITY_IAM

aws cloudformation create-stack --stack-name OkService1 --template-body file://service.yml --capabilities CAPABILITY_IAM --parameters \
  ParameterKey=StackName,ParameterValue=OkCluster \
  ParameterKey=ServiceName,ParameterValue=OkService1 \
  ParameterKey=AppImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-app:latest \
  ParameterKey=ApiImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-api:latest

# describing
aws cloudformation describe-stacks --stack-name OkService1 | jq '.Stacks[0].Outputs[] | select(.OutputKey == "ExternalUrl") | .OutputValue'

# removing
aws cloudformation delete-stack --stack-name OkService1
# remove services created SGs within relevant VPC
aws cloudformation delete-stack --stack-name OkCluster
