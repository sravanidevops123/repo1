pipeline{
agent any

environment{
	MAVEN_OPTS="-Xmx512m"
}
/*	
parameters { choice(name: 'ENV', choices: ['qa', 'perf', 'uat'], description: 'Select the environment to deploy') }	

tools {
    maven 'maven-3.6.3'
		jdk 'JDK8u221'
    }

	
	
triggers {
  GenericTrigger(causeString: 'Generic Cause because of new Commit appeared', regexpFilterExpression: '', regexpFilterText: '', token: '1212', tokenCredentialId: '')
}
*/
stages{
	stage("Compile"){
		steps{
			dir('TestWebApp'){
			echo "Compiling"
			sh "mvn compile"
			}
		}
	}
	stage("Testing"){
		steps{
			dir('TestWebApp'){
			echo "Running Test Cases"
			sh "mvn test"
			}
		}
	}
	
  	stage("Static Code Analysis"){
		steps{
		   withSonarQubeEnv('Sonarqube') {
			withCredentials([string(credentialsId: 'My-sonar-token', variable: 'TOKEN')]) {
			dir('TestWebApp'){
			echo "Sending Test reports to SonarQube"
				sh "mvn sonar:sonar -Dsonar.host.url=http://3.110.218.66:31485/ -Dsonar.login=${TOKEN} -X "
					}
				}
			}
		}
	}
/*	
	 stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }
*/
	stage("Packaging"){
		steps{
			dir('TestWebApp'){
			echo "Generatating Artifact"
			sh "mvn package"
			}
		}
	}
  stage("Deploy to Nexus"){
		steps{
			//withCredentials([usernamePassword(credentialsId: 'Nexus-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
			dir('TestWebApp'){
			echo "Deploying Artifact to Nexus"
			sh "mvn deploy -Dserver.username='admin' -Dserver.password='admin' -s settings.xml"
			//}
		}
	}
  }
/*
	stage("Hosts File"){
		when { equals expected: 'qa', actual: "${ENV}" }
		steps{
sh '''
#if [["${ENV}" == qa]]
#then
echo "13.208.241.61 ansible_user='sravs' ansible_password='Devops@123' ansible_ssh_common_args='-o StrictHostKeyChecking=no'" > hosts

#elif [["${ENV}" == perf]]
#then
#echo "15.152.33.17 ansible_user='sravs' ansible_password='Devops@123' ansible_ssh_common_args='-o StrictHostKeyChecking=no'"> hosts

#elif [["${ENV}" == uat]]
#then
#echo "localhost ansible_user='sravs' ansible_password='Devops@123' ansible_ssh_common_args='-o StrictHostKeyChecking=no'" > hosts
#else
#echo "entered wrong parameter"
#echo ""> hosts
#fi

cat hosts
'''
		}
	}
*/
	stage("Deploy to EKS"){
		steps{
			withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'access_key', passwordVariable: 'secret_key')]) {
				sh """
				sudo yum install awscli -y
				aws --version
				aws configure set aws_access_key_id ${access_key}
				aws configure set aws_secret_access_key ${secret_key}
				aws configure set default.region ap-south-1
				
				curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
				chmod +x ./kubectl
				
				aws eks describe-cluster --name gvkrsoltuions --query cluster.status
				aws eks update-kubeconfig --name gvkrsoltuions
				./kubectl cluster-info
				
				echo "Building Docker Image"
				docker build -t testwebapp:v1 .
				
				./kubectl delete pod/test
				
				echo "Deploying into k8s"
				./kubectl run test --image=testwebapp:v1 --port=8080
				./kubectl expose pod test --port=9090 --target-port=8080 --type=NodePort || true
				
				./kubectl get pods
				./kubectl get pods -o wide
				./kubectl get svc
				"""
				//sh "ansible-playbook deploy.yaml -i hosts"
			}
		}
	}
}
post{
	success{
		archiveArtifacts 'TestWebApp/target/*.war'
	}
}

}
