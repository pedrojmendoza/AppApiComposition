# run React app in local mode
cd app
npm start

# run SpringBoot service in local mode
cd api
mvn package
java -jar target/myspringboot-0.0.1-SNAPSHOT.jar

# build/dockrize/run React app
cd app
npm run build && docker build -t ok-app .
docker run --rm -d -p 80:80 ok-app
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome http://localhost

# build/dockrize/run SpringBoot service
cd api
mvn package && docker build --build-arg JAR_FILE=target/myspringboot-0.0.1-SNAPSHOT.jar -t ok-api .
docker run --rm -d -p 8080:8080 ok-api
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome http://localhost:8080/api

# stop all running containers
docker stop $(docker ps -aq)

# run using docker-compose (assume images are avail)
docker-compose up -d
docker-compose ps
docker-compose down

# ecr
$(aws ecr get-login --no-include-email --region us-east-1)

docker tag ok-app:latest 264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-app:latest
docker push 264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-app:latest

docker tag ok-api:latest 264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-api:latest
docker push 264359801351.dkr.ecr.us-east-1.amazonaws.com/ok-api:latest

# ecs
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome http://<service_dns>/
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome http://<service_dns>/app1

# load test -> to test scale-out, scale-in
# tested from an EC2 instance to avoid netw saturation
# when deploying the service's stack, set the TargetCpuUtilization to 10 so it can more easily reach the scale-out threshold
ab -n 1000000 -c 500 http://<service_dns>/api
