pipeline{
  agent any
  tools {
    maven 'maven_3.6.3'
  }

  options{
    timestamps()
    // ansiColor('xterm')
    buildDiscarder(logRotator(numToKeepStr:"8"))
  }
  stages{
    stage("Maven-Build"){
      steps{
          sh "mvn clean package"
      }
      post {
        success {
          ansiColor("blue"){
          echo "############################ Archiving the Artifacts ########################"
          archiveArtifacts artifacts: "**/target/*.war"
          }
        }
      }
    }

   stage("Uploading Artifact") {
    steps {
        nexusArtifactUploader artifacts:
        [
          [ artifactId: 'favourite-places',
            classifier: '',
            file: 'target/favourite-places-1-SNAPSHOT.war',
            type: 'war'
          ]
        ],
         credentialsId: 'nexus-creds',
         groupId: 'icic',
         nexusUrl: '15.206.189.45:8081',
         nexusVersion: 'nexus3',
         protocol: 'http',
         repository: 'fav-places',
         version: '1-${BUILD_NUMBER}-SNAPSHOT'
      }
    }
    stage ("sonar-code-analysis"){
      steps{
        script{
          withSonarQubeEnv(credentialsId: 'sonar-creds') {
              sh "mvn sonar:sonar"
          }
        }
      }
    }
  }
}
