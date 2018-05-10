This project details how to automate the deployment of App/API composite on AWS ECS using CloudFormation templates in both a single-account as well as a multi-account environment.

# Description
Sample app is composed of:
- React app demoing a fetch to grab some data from the corresponding API
- SpringBoot service acting as API to provide the data requested by the React app

Deployment is done using sidecar-container model where Nginx is used for the app container and Jetty for the api container. Nginx will act as single endpoint for both the React app and the API and will do reverse-proxy to redirect requests to the api to the appropriate container.

Please refer to `build.sh` for commands on how to build the components and the corresponding dockers files as well as how to push the images to an ECR repository (commands to create the ECR repo not included).

Please refer to `provisionSingleAccount.sh` for commands on how to provision the artifacts (ECS cluster and ECS service) using CFN in a single account deployment. It is based on the CFN templates found at https://github.com/nathanpeck/aws-cloudformation-fargate. Topology being used is Public VPC for the cluster and Public Subnet/LB for the service.

Pre-condition to run the provisioning commands is having the dockers available in a repo (tested using ECR).

The provisioned ECS service will include support for auto-scaling, logging and container-level health check (relevant for API container).

Each ECS service will use its own LB with a single listener and rule forwarding the traffic to the Nginx port (that, as stated above, will reverse proxy to API when required).

# Multi-account deployment (based on StackSets)
Multi-account deployment uses [CloudFormation StackSets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html) as a mechanism to have a single admin account containing the stacks definitions and being able to deploy them to multiple target accounts (typically Devo, UAT, Production).

In the architecture being used, the ECR repo containing the dockers images lives in the admin account so the target accounts need permissions to access (pull) the corresponding images while deploying a service in ECS.

Please refer to `provisionMultiAccount.StackSets.sh` for commands on how to setup the required permissions as well as provision the artifacts (permissions, ECS cluster and ECS service) using CFN in a multi-account deployment. Once the initial permissions are set, it uses the same CFN templates to provision the ECS artifacts. Please note it contains commands that are required to be executed only once per admin/target account as well as commands that are intended to be executed every time a new version of a stack is being deployed.

Unfortunately, when updating a stack-set (for example, when a new version of the template is available) it is not possible to selectively update the associated stack instances (*Updating a stack set always touches all stack instances*) so it is not a viable option in our case since we want to control when (following validation) a new version of the stack is promoted to the next stage.

# Multi-account deployment (based on cross-account roles)
As an alternative to StackSets, multi-account deployment can be implemented using [cross-account roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html).

As with StackSets, using cross-account roles you can have a single admin account that will assume a role allowing it to deploy the stacks to an specific target account. By repeating the process of assuming a role and deploying an stack, multiple target accounts can be used.

In the architecture being used, the ECR repo containing the dockers images lives in the admin account so the target accounts need permissions to access (pull) the corresponding images while deploying a service in ECS.

Please refer to `provisionMultiAccount.EnvVars.sh` for commands on how to setup the required permissions as well as provision the artifacts (permissions, ECS cluster and ECS service) using CFN in a multi-account deployment. Once the initial permissions are set, it uses the same CFN templates to provision the ECS artifacts. Please note it contains commands that are required to be executed only once per admin/target account as well as commands that are intended to be executed every time a new version of a stack is being deployed.

# TODO
- Automate the creation of the ECR repo?
- Further restrict permissions in target account
- StackSets implementation -> Recover the option to have a Role input param for the service -> Optional param in service.yml resulting in error when using it in multi-account deployment using stack-sets
- StackSets implementation -> Consider using gating lambdas to control the deployment of stacks when updating stack-sets -> https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-account-gating.html
