pipeline{
agent any

environment{
	MAVEN_OPTS="-Xmx512m"
}
/*
tools {
    maven 'maven-3.6.3'
		jdk 'JDK8u221'
    }

parameters { choice(name: 'ENV', choices: ['qa', 'perf', 'uat'], description: 'Select the environment to deploy') }	
	
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
/*
  stage("Static Code Analysis"){
		steps{
			dir('TestWebApp'){
			echo "Generatating Artifact"
			sh "mvn sonar:sonar -Dsonar.login=myAuthenticationToken "
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
/*
  stage("Deploy to Nexus"){
		steps{
			dir('TestWebApp'){
			echo "Deploying Artifact to Nexus"
			sh "mvn deploy"
			}
		}
	}
*/
	stage("Deploy to Host"){
		steps{
			echo "Deploying into Docker"
			//sh "ansible-playbook deploy.yaml"
			sh "ansible-playbook deploy.yaml --limit '${ENV}' -i hosts"
		}
	}
}
post{
	success{
		archiveArtifacts 'TestWebApp/target/*.war'
	}
}

}
