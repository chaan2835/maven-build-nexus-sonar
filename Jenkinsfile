def nexus_url = "35.154.99.146"
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

   stage("Uploading Artifact to nexus") {
    steps {
      script{
          def pom = readMavenPom file: 'pom.xml'
          def artifactId = pom.artifactId
          def groupId = pom.groupId
          def version = pom.version
          def packaging = pom.packaging
          echo "#####################################################################"
          echo "ArtifactId: ${artifactId}"
          echo "Groupid: ${groupId}"
          echo "version: ${version}"
          echo "packaging: ${packaging}"
          echo "######################################################################"
            nexusArtifactUploader artifacts:
        [
          [ artifactId: "${artifactId}",
            classifier: '',
            file: "target/${artifactId}-${version}.war",
            type: "${packaging}"
          ]
        ],
         credentialsId: 'nexus-creds',
         groupId: "${groupId}",
         nexusUrl: "${nexus_url}:8081",
         nexusVersion: 'nexus3',
         protocol: 'http',
         repository: 'fav-places',
         version: "${version}"
        }

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
    stage("Docker-login"){
      steps{
          sh "docker login -u chaan2835 -pChandra@2835"
          sh "docker build -t chaan2835/fav-places ."
          sh "docker push chaan2835/fav-places"
        script{
          def DOCKER_CONTAINER_PORT = env.BUILD_NUMBER.toInteger()
          echo "DOCKER_CONTAINER_PORT:$DOCKER_CONTAINER_PORT"
          sh "docker run -p ${DOCKER_CONTAINER_PORT}:8080 -d --name ${env.JOB_NAME}-${env.BUILD_NUMBER} chaan2835/fav-places"
         }
      }
    }
  }
}
