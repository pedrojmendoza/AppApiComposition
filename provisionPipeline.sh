aws cloudformation create-stack --stack-name ok-project1-pipeline --template-body file://pipeline.yml --capabilities CAPABILITY_NAMED_IAM --parameters \
  ParameterKey=ProjectName,ParameterValue=ok-project1 \
  ParameterKey=OAuthToken,ParameterValue=<your_github_token>
