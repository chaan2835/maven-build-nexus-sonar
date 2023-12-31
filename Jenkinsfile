def nexus_url = "3.7.55.27"
pipeline {
    agent any
    tools {
        maven 'maven_3.6.3'
    }

    // environment {
    //     DOCKER_USERNAME = credentials('docker-credentials').username
    //     DOCKER_PASSWORD = credentials('docker-credentials').password
    // }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: "8"))
    }

    stages {
        stage("Maven-Build") {
            steps {
                sh "mvn clean package"
            }
            post {
                success {
                    ansiColor("blue") {
                        echo "############################ Archiving the Artifacts ########################"
                        archiveArtifacts artifacts: "**/target/*.war"
                    }
                }
            }
        }

        stage("Uploading Artifact to Nexus") {
            steps {
                script {
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
                    nexusArtifactUploader artifacts: [
                        [artifactId: "${artifactId}",
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

        stage("Sonar Code Analysis") {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonar-creds') {
                        sh "mvn sonar:sonar"
                    }
                }
            }
        }

        stage("S3 Upload") {
            steps {
                s3Upload consoleLogLevel: 'INFO',
                        dontSetBuildResultOnFailure: false,
                        dontWaitForConcurrentBuildCompletion: false,
                        entries: [
                            [bucket: 'jenkins-s3-uploader',
                             excludedFile: '',
                             flatten: false,
                             gzipFiles: false,
                             keepForever: false,
                             managedArtifacts: false,
                             noUploadOnFailure: false,
                             selectedRegion: 'ap-south-1',
                             showDirectlyInBrowser: false,
                             sourceFile: '**/target/*.war',
                             storageClass: 'STANDARD',
                             uploadFromSlave: false,
                             useServerSideEncryption: false
                            ]
                        ], pluginFailureResultConstraint: 'FAILURE',
                        profileName: 'jenkins-s3-uploader',
                        userMetadata: []
            }
        }

        stage("Docker") {
            steps {

                echo ">>>>>>>>>>>>>>>>>>>>>> Stopping  Containers <<<<<<<<<<<<<<<<"
                // sh 'docker stop $(docker ps -q)'
                // sh 'docker rm -f --force $(docker ps -aq)'
                sh 'docker image prune -a --force'

                // echo ">>>>>>>>>>>>>>>>>>>>>>removing-existing-images<<<<<<<<<<<<<<<<"
                // sh 'docker rmi -f $(docker images -q)'

                // echo ">>>>>>>>>>>>>>>>>>>>>>>>>>removing-existing-containers<<<<<<<<<<<<<<<<<<<<"
                // sh 'docker rm -f $(docker ps -aq)'

                echo ">>>>>>>>>>>>>>>>>>>Docker-Image-Build<<<<<<<<<<<<<<<<<<<<<<<<"
                sh "docker build -t chaan2835/${env.JOB_NAME}:v${env.BUILD_NUMBER} ."

                echo ">>>>>>>>>>>>>>>>>>>>Docker-Login<<<<<<<<<<<<<<<<<<<<<<<<"
                withCredentials([string(credentialsId: 'docker-creds', variable: 'Docker')]) {
                    sh "docker login -u chaan2835 -p ${Docker}"
                }
                echo ">>>>>>>>>>>>>>>>>>>>>>>>Docker-Image-Push-To-Docker-Hub<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh "docker push chaan2835/${env.JOB_NAME}:v${env.BUILD_NUMBER}"

                echo ">>>>>>>>>>>>>>>>>>>>starting-docker-container<<<<<<<<<<<<<<<<<<<"
                sh "docker run -p 80:80 -d --name ${env.JOB_NAME}-${env.BUILD_NUMBER} chaan2835/${env.JOB_NAME}:v${env.BUILD_NUMBER}"
                // script{
                //   def DOCKER_CONTAINER_PORT = env.BUILD_NUMBER.toInteger()
                //   echo "Docker_container_port---->$DOCKER_CONTAINER_PORT"
                // }
            }
        }
    }

    post {
        always {
            slackSend channel: '#jenkins-job-status', message: "Hey! there here is your jenkins job status\nStatus-{currentBuild.currentResult} ${env.JOB_NAME} ${env.BUILD_NUMBER} ${env.BUILD_URL}"
        }
    }
}
