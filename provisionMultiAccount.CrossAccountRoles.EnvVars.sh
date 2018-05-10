# https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html
# https://docs.aws.amazon.com/cli/latest/userguide/cli-roles.html
# https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#config-settings-and-precedence
#
# admin account -> 264359801351 -> contains the ECR repo and EC2 instance where Jenkins is running
# target account -> 193690196962 -> contains the VPC/LB and ECS cluster/service, pulls from the ECR repo
# profile to access target account -> menpedro1
# role being used by Jenkins' EC2 instance -> Jenkins-EC2InstanceRole-RC5Y16KSJ024

# preconditions - execute once on each target account to create cross-account role (note you need to have the corresponding profiles created to access each target account)
aws cloudformation create-stack --stack-name CrossAccountTarget --template-body file://cross_account_target_role.yml --capabilities CAPABILITY_NAMED_IAM --profile menpedro1 --parameters \
  ParameterKey=AuthorizedAccountId,ParameterValue=264359801351 \
  ParameterKey=AuthorizedRoleName,ParameterValue=Jenkins-EC2InstanceRole-RC5Y16KSJ024

# preconditions - execute once on each target account to grant permissions to access ECR repos (note you need to first edit the ecr_policy.json to add the target account id to authorize it)
aws ecr set-repository-policy --repository-name ok-app --policy-text file://ecr_policy.json
aws ecr set-repository-policy --repository-name ok-api --policy-text file://ecr_policy.json

# on every stack deployment - obtain temporary credentials in admin account (assumes role being used by Jenkins have sts:AssumeRole on *)
ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn "arn:aws:iam::193690196962:role/AWSCloudFormationCrossAccountExecutionRole" --role-session-name "session1")

# on every stack deployment - set env vars based on temporary credentials
export AWS_ACCESS_KEY_ID=$(echo $ASSUME_ROLE_OUTPUT | jq ".Credentials.AccessKeyId" -r)
export AWS_SECRET_ACCESS_KEY=$(echo $ASSUME_ROLE_OUTPUT | jq ".Credentials.SecretAccessKey" -r)
export AWS_SESSION_TOKEN=$(echo $ASSUME_ROLE_OUTPUT | jq ".Credentials.SessionToken" -r)

# on every stack deployment - issue CFN commands on Jenkins' EC2 instance
aws cloudformation create-stack --stack-name OkCluster --template-body file://cluster.yml --capabilities CAPABILITY_IAM --region us-east-1
aws cloudformation create-stack --stack-name OkService1 --template-body file://service.yml --capabilities CAPABILITY_IAM --region us-east-1 --parameters \
  ParameterKey=StackName,ParameterValue=OkCluster \
  ParameterKey=ServiceName,ParameterValue=OkService1 \
  ParameterKey=AppImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-app:latest \
  ParameterKey=ApiImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-api:latest
