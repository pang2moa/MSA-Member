pipeline {
    agent any
    
    environment {
        APP_NAME = 'MSA-Member'
        DEPLOY_PATH = '/opt/springapps/MSA-Member'
    }
    
    stages {
        stage('Preparation') {
            steps {
                script {
                    echo "Starting pipeline for ${APP_NAME}"
                    sh 'java -version'
                    sh 'mvn -version'
                }
            }
        }
        
        stage('Checkout') {
            steps {
                script {
                    try {
                        checkout scm
                        echo "Checkout successful"
                    } catch (Exception e) {
                        echo "Checkout failed: ${e.getMessage()}"
                        error "Checkout stage failed"
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    try {
                        sh 'mvn clean package -DskipTests'
                        echo "Build successful"
                    } catch (Exception e) {
                        echo "Build failed: ${e.getMessage()}"
                        error "Build stage failed"
                    }
                }
            }
        }
        
        stage('Terminate Existing Processes') {
            steps {
                script {
                    try {
                        def processFound = false
                        def result = sh(script: "pgrep -f '${DEPLOY_PATH}/${APP_NAME}.jar'", returnStatus: true)
                        
                        if (result == 0) {
                            processFound = true
                            sh """
                                PIDs=\$(pgrep -f '${DEPLOY_PATH}/${APP_NAME}.jar')
                                echo "Found processes: \$PIDs"
                                for PID in \$PIDs
                                do
                                    echo "Attempting to stop process \$PID"
                                    kill \$PID
                                    sleep 5
                                    if ps -p \$PID > /dev/null; then
                                        echo "Process \$PID did not stop, attempting force kill"
                                        kill -9 \$PID
                                    fi
                                done
                            """
                        } else {
                            echo "No processes found for ${APP_NAME}"
                        }

                        // 모든 프로세스가 종료되었는지 다시 확인
                        result = sh(script: "pgrep -f '${DEPLOY_PATH}/${APP_NAME}.jar'", returnStatus: true)
                        if (result == 0) {
                            error "Failed to terminate all processes for ${APP_NAME}"
                        } else {
                            echo "All processes for ${APP_NAME} have been terminated successfully"
                        }
                    } catch (Exception e) {
                        echo "Error during process termination: ${e.getMessage()}"
                        error "Process termination stage failed"
                    }
                }
            }
        }
        
         stage('Prepare Deploy Directory') {
                    steps {
                        script {
                            sh """
                                if [ ! -d "${DEPLOY_PATH}" ]; then
                                    echo "Creating deploy directory: ${DEPLOY_PATH}"
                                    mkdir -p ${DEPLOY_PATH}
                                else
                                    echo "Deploy directory already exists: ${DEPLOY_PATH}"
                                fi
                            """
                        }
                    }
                }
        
                stage('Deploy') {
                    steps {
                        script {
                            try {
                                def jarFile = findFiles(glob: 'target/*.jar')[0]
                                sh "cp ${jarFile.path} ${DEPLOY_PATH}/${APP_NAME}.jar"
                                sh """
                                    nohup java -jar ${DEPLOY_PATH}/${APP_NAME}.jar > ${DEPLOY_PATH}/${APP_NAME}.log 2>&1 &
                                    echo \$! > ${DEPLOY_PATH}/${APP_NAME}.pid
                                """
                                echo "Deployment successful"
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
                    try {
                        sh """
                            sleep 10
                            if ps -p \$(cat ${DEPLOY_PATH}/${APP_NAME}.pid) > /dev/null; then
                                echo "${APP_NAME} is running"
                            else
                                echo "${APP_NAME} is not running"
                                exit 1
                            fi
                        """
                        echo "Deployment verification successful"
                    } catch (Exception e) {
                        echo "Deployment verification failed: ${e.getMessage()}"
                        error "Deployment verification stage failed"
                    }
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