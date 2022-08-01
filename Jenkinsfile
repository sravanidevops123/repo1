pipeline{
agent any
	
environment{
	MAVEN_OPTS="-Xmx512m"
	AWS_CREDS = credentials('aws-credentials')
	AWS_ACCESS_KEY_ID     = "${env.AWS_CREDS_USR}" 
	AWS_SECRET_ACCESS_KEY = "${env.AWS_CREDS_PSW}"
	AWS_DEFAULT_REGION = "ap-south-1"
}

tools {
    	maven 'maven-3.6.3'
	jdk 'JDK8u221'
	terraform 'terraform-0.14.5'
    }
	
stages{
	stage("Compiling"){
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
	
	stage("Copying Private Key"){
		steps{
		withCredentials([file(credentialsId: 'myLap-pemkey', variable: 'privateKey')]) {
	   		sh '''
if [ -f "myLap.pem" ]
then
echo "Specified file found in current Working Directory"
else
echo "Specified file not found in current Working Directory"
echo "Loading the private key"
cat $privateKey > myLap.pem
chmod 400 myLap.pem || true
fi
			
			'''
			}
		}
	}
	
	stage("Terraform Init & Plan"){
		steps{
			sh '''	
				terraform init
				terraform plan
			'''
		}
	}
	stage("Provision & Deploy"){
		input {
        	        message "Should we continue?"
               		ok "Yes, we should."
                	parameters {
                	    string(name: 'PERSON', defaultValue: '${env.BUILD_USER}', description: 'Give the Person Name')
                	}
            	}
		steps{
			sh '''
			sudo yum install jq -y
terraform output -json my_instance_id | jq -r . > old_instance_data

terraform state rm aws_instance.web

terraform plan -destroy 

terraform destroy -auto-approve || true

terraform plan

terraform apply -auto-approve || true

sleep 120s

terraform output -json my_publi_dns | jq -r . | head -1 > new_instance_data

new_url=`head -1 new_instance_data`

#status_code=$(curl --write-out %{http_code} --silent --output /dev/null $new_url:8080/TestWebApp)
status_code=$(curl -Is $new_url:8080/TestWebApp/ | head -1 | awk '{print $2}')
if [[ $status_code -ne 200 ]] ; then
  terraform destroy
  old_instance_id=`head -1 old_instance_data`
  terraform import aws_instance.web $old_instance_id
  echo "Latest version of Application not deployed successfully so restoring it to old version"
  exit 0
else
  echo "Application deployed successfully and the status code is $status_code"
  
  cd old_data
  terraform init
  old_instance_id=`head -1 old_instance_data`
  terraform import aws_instance.web $old_instance_id
  echo "Destroying old Version deployed Servers"
  terraform destroy -auto-approve || true
  exit 0
#  echo "Site status changed to $status_code" | mail -s "SITE STATUS CHECKER" "my_email@email.com" -r "STATUS_CHECKER"

fi
			'''
		}
	}
}
post{
	success{
		archiveArtifacts 'TestWebApp/target/*.war'
	}
}

}
