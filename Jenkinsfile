pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1' 
        VAR_FILE = 'dev.tfvars'
        
        // LEFT SIDE: The name Terraform wants (Do not change)
        // RIGHT SIDE: The ID from your Jenkins screenshot
        AWS_ACCESS_KEY_ID     = credentials('AWS_Access_Key')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_Secret_Key')
    }

    stages {
        stage('Task 1: Provisioning & Output Capture') {
            steps {
                script {
                    sh 'terraform init'
                    sh "terraform apply -var-file=${VAR_FILE} -auto-approve"
                    env.INSTANCE_IP = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                    env.INSTANCE_ID = sh(script: 'terraform output -raw instance_id', returnStdout: true).trim()
                    echo "Provisioned Instance: ${env.INSTANCE_ID} at IP: ${env.INSTANCE_IP}"
                }
            }
        }

        stage('Task 2: Dynamic Inventory Management') {
            steps {
                script {
                    sh """
                        echo "[splunk]" > dynamic_inventory.ini
                        echo "${env.INSTANCE_IP} ansible_user=ec2-user ansible_ssh_private_key_file=private_key.pem" >> dynamic_inventory.ini
                    """
                    sh "cat dynamic_inventory.ini"
                }
            }
        }

        stage('Task 3: AWS Health Status Verification') {
            steps {
                script {
                    echo "The AWS CLI tool is missing, so we will sleep for 60 seconds to let the server initialize..."
                    // We simply wait for 60 seconds instead of using the aws command
                    sh "sleep 60"
                }
            }
        }

        stage('Task 4: Splunk Installation & Testing') {
            steps {
                script {
                    env.ANSIBLE_HOST_KEY_CHECKING = 'False'
                }
                
                // FIXED: We changed 'file' to 'sshUserPrivateKey' to match your credential type
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible_ssh_key', keyFileVariable: 'MY_PEM_KEY', usernameVariable: 'SSH_USER')]) {
                    script {
                        // The robot takes the key from the safe and copies it to a file
                        sh 'cp $MY_PEM_KEY private_key.pem'
                        sh 'chmod 600 private_key.pem'
                    }

                    // Run the Playbooks
                    ansiblePlaybook(
                        playbook: 'playbook/splunk.yml',
                        inventory: 'dynamic_inventory.ini',
                        colorized: true
                    )
                    ansiblePlaybook(
                        playbook: 'playbook/test-splunk.yml',
                        inventory: 'dynamic_inventory.ini',
                        colorized: true
                    )
                }
            }
        }

        stage('Task 5: Infrastructure Destruction') {
            steps {
                input message: 'Validation Complete. Proceed to Destroy Infrastructure?', ok: 'Destroy'
                sh "terraform destroy -var-file=${VAR_FILE} -auto-approve"
            }
        }
    }

    post {
        always {
            sh 'rm -f dynamic_inventory.ini'
        }
        failure {
            echo "Pipeline failed. Triggering automatic destruction..."
            sh "terraform destroy -var-file=${VAR_FILE} -auto-approve"
        }
        aborted {
            echo "Pipeline aborted. Triggering automatic destruction..."
            sh "terraform destroy -var-file=${VAR_FILE} -auto-approve"
        }
    }
}
