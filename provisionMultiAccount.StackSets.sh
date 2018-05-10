# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/RepositoryPolicyExamples.html
#
# admin account -> 264359801351 -> contains the ECR repo as well as the stacksets
# target account -> 193690196962 -> contains the VPC/LB and ECS cluster/service, pulls from the ECR repo
# profile to access admin account -> default
# profile to access target account -> menpedro1

# preconditions - execute once on the admin account
aws cloudformation create-stack --stack-name StackSetsAdmin --template-body file://multi_account_admin_role.yml --capabilities CAPABILITY_NAMED_IAM

# preconditions - execute once on each target account (note you need to have the corresponding profiles created to access each target account)
aws cloudformation create-stack --stack-name StackSetsTarget --template-body file://multi_account_target_role.yml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=AdministratorAccountId,ParameterValue=264359801351 --profile menpedro1

# preconditions - execute once on each target account (note you need to first edit the ecr_policy.json to add the target account id to authorize it)
aws ecr set-repository-policy --repository-name ok-app --policy-text file://ecr_policy.json
aws ecr set-repository-policy --repository-name ok-api --policy-text file://ecr_policy.json

# for each stack - create stackset
aws cloudformation create-stack-set --stack-set-name OkCluster --template-body file://cluster.yml --capabilities CAPABILITY_IAM
aws cloudformation create-stack-set --stack-set-name OkService1 --template-body file://service.yml --capabilities CAPABILITY_IAM --parameters \
  ParameterKey=StackName,ParameterValue=OkCluster \
  ParameterKey=ServiceName,ParameterValue=OkService1 \
  ParameterKey=AppImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-app:latest \
  ParameterKey=ApiImageUrl,ParameterValue=264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-api:latest

# for each stack and target account - create stack (note you will need to obtain the cluster's stack name (see below) as a pre-condition to create the service's stack)
aws cloudformation create-stack-instances --stack-set-name OkCluster --accounts '["193690196962"]' --regions '["us-east-1"]' --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=1
aws cloudformation create-stack-instances --stack-set-name OkService1 --accounts '["193690196962"]' --regions '["us-east-1"]' --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=1 --parameter-overrides \
  ParameterKey=StackName,ParameterValue=StackSet-OkCluster-8fa87e2d-b2a9-4877-959f-242298007045

# describe stack (required to grab the stack name and use it as input param for additional stacks when required)
aws cloudformation describe-stack-instance --stack-set-name OkCluster --stack-instance-account 193690196962 --stack-instance-region us-east-1

# update stackset (but do NOT update corresponding stacks -> not working)
#aws cloudformation update-stack-set --stack-set-name OkCluster --template-body file://cluster.yml --capabilities CAPABILITY_IAM --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=0

# delete stack
aws cloudformation delete-stack-instances --stack-set-name OkService1 --accounts '["193690196962"]' --regions '["us-east-1"]' --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=1 --no-retain-stacks
aws cloudformation delete-stack-instances --stack-set-name OkCluster --accounts '["193690196962"]' --regions '["us-east-1"]' --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=1 --no-retain-stacks

# delete stackset
aws cloudformation delete-stack-set --stack-set-name OkService1
aws cloudformation delete-stack-set --stack-set-name OkCluster
