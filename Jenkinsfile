pipeline{
agent any

environment{
	MAVEN_OPTS="-Xmx512m"
}
	
parameters { choice(name: 'ENV', choices: ['qa', 'perf', 'uat'], description: 'Select the environment to deploy') }	
/*
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
			withCredentials([string(credentialsId: 'Sonarqube-creds', variable: 'TOKEN')]) {
			dir('TestWebApp'){
			echo "Sending Test reports to SonarQube"
				sh "mvn sonar:sonar -Dsonar.login=${TOKEN}"
					}
				}
			}
		}
	}
	
	 stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }

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
			withCredentials([usernamePassword(credentialsId: 'Nexus-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
			dir('TestWebApp'){
			echo "Deploying Artifact to Nexus"
			sh "mvn deploy -Dserver.username=${USERNAME} -Dserver.password=${PASSWORD}"
			}
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
	stage("Deploy to Host"){
		steps{
			echo "Deploying into Docker"
			//sh "ansible-playbook deploy.yaml"
			sh "ansible-playbook deploy.yaml -i hosts"
		}
	}
}
post{
	success{
		archiveArtifacts 'TestWebApp/target/*.war'
	}
}

}
