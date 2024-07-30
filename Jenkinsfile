pipeline {
    agent any
    
    environment {
        APP_NAME = 'MSA-Member'
        DEPLOY_PATH = '/opt/springapps/MSA-Member'
        JENKINS_USER = 'appuser'  // 실제 Jenkins 실행 사용자 이름으로 변경하세요
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    // Maven build 명령 추가 (필요한 경우)
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    try {
                        def jarFiles = findFiles(glob: 'target/*.jar')
                        if (jarFiles.length == 0) {
                            error "No JAR files found in target directory"
                        }
                        def jarFile = jarFiles[0]
                        echo "Found JAR file: ${jarFile.name}"
                        
                        sh """
                            sudo mkdir -p ${DEPLOY_PATH}
                            sudo cp ${jarFile.path} ${DEPLOY_PATH}/${APP_NAME}.jar
                            sudo chown ${JENKINS_USER}:${JENKINS_USER} ${DEPLOY_PATH}/${APP_NAME}.jar
                            sudo chmod 755 ${DEPLOY_PATH}/${APP_NAME}.jar
                        """
                        
                        echo "JAR file deployed successfully"
                    } catch (Exception e) {
                        echo "Deployment failed: ${e.getMessage()}"
                        error "Deployment stage failed"
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh "ls -l ${DEPLOY_PATH}/${APP_NAME}.jar"
                    echo "Deployment verified"
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline finished. Check logs for details."
        }
        success {
            echo "Pipeline succeeded"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}