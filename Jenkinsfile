pipeline {
    agent any
    
    tools {
        jdk 'jdk11'
        maven 'Maven 3.9.6'
    }
    
    environment {
        APP_NAME = 'MSA-Member' // 각 프로젝트마다 변경 필요
        GITHUB_REPO = 'https://github.com/pang2moa/MSA-Member.git' // 각 프로젝트마다 변경 필요
        BRANCH_NAME = 'master' // 또는 원하는 브랜치 이름
        SERVER_USER = 'appuser'
        SERVER_IP = '222.108.42.200'
        DEPLOY_PATH = '/opt/springapps/MSA-Member'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: "${BRANCH_NAME}", url: "${GITHUB_REPO}"
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    def jarFile = findFiles(glob: 'target/*.jar')[0]
                    
                    // 기존 프로세스 종료
                    sh """
                        PID=\$(pgrep -f ${APP_NAME})
                        if [ ! -z "\$PID" ]; then
                            echo "Stopping process \$PID"
                            kill \$PID
                            sleep 5
                            if ps -p \$PID > /dev/null; then
                                echo "Force stopping process \$PID"
                                kill -9 \$PID
                            fi
                        else
                            echo "No process found for ${APP_NAME}"
                        fi
                    """
                    
                    // 새 JAR 파일 복사
                    sh "cp ${jarFile.path} ${DEPLOY_PATH}/${APP_NAME}.jar"
                    
                    // 새 프로세스 시작
                    sh """
                        nohup java -jar ${DEPLOY_PATH}/${APP_NAME}.jar > ${DEPLOY_PATH}/${APP_NAME}.log 2>&1 &
                        echo \$! > ${DEPLOY_PATH}/${APP_NAME}.pid
                    """
                    
                    // 프로세스 시작 확인
                    sh """
                        sleep 10
                        if ps -p \$(cat ${DEPLOY_PATH}/${APP_NAME}.pid) > /dev/null; then
                            echo "${APP_NAME} started successfully"
                        else
                            echo "${APP_NAME} failed to start"
                            exit 1
                        fi
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}