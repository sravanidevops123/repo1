pipeline{
agent any

options {
        ansiColor('xterm')
}
	
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
	
	stage("Copying Private Key"){
		steps{
		withCredentials([file(credentialsId: 'myLap-pemkey', variable: 'privateKey')]) {
	   		sh '''
if [ -f "myLap.pem" ]
then
echo "File found"
else
cat $privateKey > myLap.pem
chmod 400 myLap.pem || true
fi
			
			'''
			}
		}
	}
	
	stage("Terraform Plan"){
		steps{
			sh '''	
				alias tf="terraform"
				tf init
				tf plan
				tf destroy -auto-approve || true
				tf apply -auto-approve || true
			'''
		}
	}
	stage("Deploy using Terraform"){
		input {
        	        message "Should we continue?"
               		ok "Yes, we should."
                	submitter "alice,bob"
                	parameters {
                	    string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
                	}
            	}
		steps{
			sh """
				tf destroy -auto-approve || true
				tf apply -auto-approve || true
			"""
		}
	}
}
post{
	success{
		archiveArtifacts 'TestWebApp/target/*.war'
	}
}

}
