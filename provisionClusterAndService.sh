aws cloudformation create-stack --stack-name OkCluster --template-body file://cluster.yml --capabilities CAPABILITY_IAM

aws cloudformation create-stack --stack-name OkService1 --template-body file://service.yml --parameters \
  ParameterKey=StackName,ParameterValue=OkCluster
  ParameterKey=ServiceName,ParameterValue=OkService1
  ParameterKey=ImageUrl,ParameterValue=...

aws cloudformation describe-stacks --stack-name OkCluster | jq '.Stacks[0].Outputs[] | select(.OutputKey == "ExternalUrl") | .OutputValue'
