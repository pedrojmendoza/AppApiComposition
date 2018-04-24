aws cloudformation create-stack --stack-name OKCluster --template-body file://cluster.yml --capabilities CAPABILITY_IAM
aws cloudformation create-stack --stack-name OKService1 --template-body file://service.yml --parameters \
  ParameterKey=StackName,ParameterValue=OKCluster
  ParameterKey=ServiceName,ParameterValue=OKService1
  ParameterKey=ImageUrl,ParameterValue=...
aws cloudformation describe-stacks --stack-name OKCluster | jq '.Stacks[0].Outputs[] | select(.OutputKey == "ExternalUrl") | .OutputValue'
