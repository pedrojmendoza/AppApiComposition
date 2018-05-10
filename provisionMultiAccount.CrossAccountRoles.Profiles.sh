# https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html
# https://docs.aws.amazon.com/cli/latest/userguide/cli-roles.html
# https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence
#
# admin account -> 264359801351 -> contains the ECR repo and EC2 instance where Jenkins is running
# target account -> 193690196962 -> contains the VPC/LB and ECS cluster/service, pulls from the ECR repo
# profile to access target account -> menpedro1

# preconditions - execute once on each target account to create cross-account role (note you need to have the corresponding profiles created to access each target account)
aws cloudformation create-stack --stack-name CrossAccountTarget --template-body file://cross_account_target_role.yml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=AdministratorAccountId,ParameterValue=264359801351 --profile menpedro1

# preconditions - execute once on each target account to grant permissions to access ECR repos (note you need to first edit the ecr_policy.json to add the target account id to authorize it)
aws ecr set-repository-policy --repository-name ok-app --policy-text file://ecr_policy.json
aws ecr set-repository-policy --repository-name ok-api --policy-text file://ecr_policy.json

# create new profile in Jenkins' EC2 instance
# assumes $HOME/.aws/config exists and the role being added does NOT exist
# assumes the IAM Role being used by the EC2 instance running Jenkins has sts:AssumeRole on the target's account role
cat <<EOT >> $HOME/.aws/config
[profile crossaccountrole-1]
role_arn = arn:aws:iam::193690196962:role/AWSCloudFormationCrossAccountExecutionRole
credential_source=Ec2InstanceMetadata
EOT

# issue CFN commands on Jenkins' EC2 instance
aws cloudformation create-stack --stack-name OkCluster --template-body file://cluster.yml --capabilities CAPABILITY_IAM --profile crossaccountrole-1 --region us-east-1
aws cloudformation create-stack --stack-name OkService1 --template-body file://service.yml --capabilities CAPABILITY_IAM --profile crossaccountrole-1 --region us-east-1 --parameters \
  ParameterKey=StackName,ParameterValue=OkCluster \
  ParameterKey=ServiceName,ParameterValue=OkService1 \
  ParameterKey=AppImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-app:latest \
  ParameterKey=ApiImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-api:latest

# remove temporary credentials
rm -r $HOME/.aws/cli/cache
