This project details how to automate the deployment of App/API composite on AWS ECS using CloudFormation templates.

Sample app is composed of:
- React app demoing a fetch to grab some data from the corresponding API
- SpringBoot service acting as API to provide the data requested by the React app

Deployment is done using sidecar-container model where Nginx is used for the app container and Jetty for the api container. Nginx will act as single endpoint for both the app and the api and will do reverse-proxy to redirect requests to the api to the appropriate container.

Please refer to `test.sh` for commands on how to build the components and the corresponding dockers files as well as how to push the images to an ECR repository (commands to create the ECR repo not included).

Please refer to `provisionClusterAndService.sh` for commands on how to provision the artifacts (ECS cluster and ECS service) using CFN. It is based on the CFN templates found at https://github.com/nathanpeck/aws-cloudformation-fargate. Topology being used is Public VPC for the cluster and Public Subnet/LB for the service.

Pre-condition to run the provisioning commands is having the dockers available in a repo (tested using ECR).

The provisioned ECS service will include support for auto-scaling and each ECS service will use its own LB with a single listener and rule forwarding the traffic to the Nginx port.
