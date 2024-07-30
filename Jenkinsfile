pipeline {
    agent any
    
    environment {
        APP_NAME = 'MSA-Member'
        DEPLOY_PATH = '/opt/springapps/MSA-Member'
        JENKINS_USER = 'appuser'
    }
    
    stages {
        stage('Build') {
            steps {
                script {
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
        
        stage('Start Application') {
            steps {
                script {
                    try {
                        sh """
                            sudo pkill -f ${APP_NAME}.jar || true
                            sudo -u ${JENKINS_USER} nohup java -jar ${DEPLOY_PATH}/${APP_NAME}.jar > ${DEPLOY_PATH}/${APP_NAME}.log 2>&1 &
                            echo \$! > ${DEPLOY_PATH}/${APP_NAME}.pid
                        """
                        echo "Application started successfully"
                    } catch (Exception e) {
                        echo "Application start failed: ${e.getMessage()}"
                        error "Application start failed"
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh "ls -l ${DEPLOY_PATH}/${APP_NAME}.jar"
                    sh "ps aux | grep ${APP_NAME}.jar"
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