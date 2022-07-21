pipeline{
agent any

environment{
	MAVEN_OPTS="-Xmx512m"
	AWS_CREDS = credentials('aws-credentials')
	AWS_ACCESS_KEY_ID     = "${env.AWS_CREDS_USR}" 
	AWS_SECRET_ACCESS_KEY = "${env.AWS_CREDS_PSW}"
	AWS_DEFAULT_REGION = "ap-south-1"
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
				echo "Compiling ${AWS_ACCESS_KEY_ID}"
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
	stage('Build Docker Image') { 
            steps { 
                script{
                 app = docker.build("gvkr1409/testwebapp","./")
                }
            }
        }
	
	stage('Push Docker Image') {
            steps {
                script{
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                    app.push("${env.BUILD_NUMBER}")
                    app.push("latest")
                    }
                }
            }
        }
	stage("install kubectl"){
		steps{
			sh '''
				
				curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
				chmod +x ./kubectl
				
				# ./kubectl.exe create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:jenkins

#https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
#create kubeconfig file manually
export region_code=ap-south-1
export cluster_name=gvkrsoltuions
export account_id=298776250946

cluster_endpoint=$(aws eks describe-cluster \
    --region $region_code \
    --name $cluster_name \
    --query "cluster.endpoint" \
    --output text)


certificate_data=$(aws eks describe-cluster \
    --region $region_code \
    --name $cluster_name \
    --query "cluster.certificateAuthority.data" \
    --output text)


mkdir -p ~/.kube || true



cat <<EOF> ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $certificate_data
    server: $cluster_endpoint
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
contexts:
- context:
    cluster: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
    user: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
current-context: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
kind: Config
preferences: {}
users:
- name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - --region
        - $region_code
        - eks
        - get-token
        - --cluster-name
        - $cluster_name
        # - "- --role-arn"
        # - "arn:aws:iam::$account_id:role/my-role"
      # env:
        # - name: "AWS_PROFILE"
        #   value: "aws-profile"
EOF
echo "${KUBECONFIG}" > ~/.kube/config


export KUBECONFIG=$KUBECONFIG:~/.kube/config
echo 'export KUBECONFIG=$KUBECONFIG:~/.kube/config' >> ~/.bashrc

				
'''
		}
	}
	stage("Deploy to EKS"){
		steps{
			kubernetesDeploy(
				configs: 'deployment.yaml',
				kubeConfig: [path: '~/.kube/config'],
				//kubeconfigId: 'config',
				//dockerCredentials: [[credentialsId: 'dockerhub-creds', url: 'https://index.docker.io/v1/']],
				secretName: 'docker-creds'
				//enableConfigSubstitution: true
			)
/*				sh """
				
				curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
				chmod +x ./kubectl
				
				kubectl.exe create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:jenkins
				
				./kubectl cluster-info
				
				
				./kubectl get pods
				./kubectl get pods -o wide
				./kubectl get svc
				./kubectl get nodes -o wide
				"""
				*/
				//sh "ansible-playbook deploy.yaml -i hosts"
		}
	}
}
post{
	success{
		archiveArtifacts 'TestWebApp/target/*.war'
	}
}

}
