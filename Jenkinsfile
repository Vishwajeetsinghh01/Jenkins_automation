stage('Task 1: Provisioning') {
    steps {
        script {
            // Build the server automatically
            sh 'terraform apply -auto-approve'
            
            // Save the IP address into a variable called INSTANCE_IP
            env.INSTANCE_IP = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
            
            // Save the ID into a variable called INSTANCE_ID
            env.INSTANCE_ID = sh(script: 'terraform output -raw instance_id', returnStdout: true).trim()
        }
    }
}

stage('Task 2: Inventory') {
    steps {
        script {
            // Write the header [splunk]
            sh "echo '[splunk]' > dynamic_inventory.ini"
            // Write the IP address under it
            sh "echo '${env.INSTANCE_IP} ansible_user=ec2-user' >> dynamic_inventory.ini"
        }
    }
}


stage('Task 3: Health Check') {
    steps {
        script {
            // This command pauses until the server is 100% ready
            sh "aws ec2 wait instance-status-ok --instance-ids ${env.INSTANCE_ID}"
        }
    }
}

stage('Task 4: Splunk Install') {
    steps {
        // Run the install playbook
        ansiblePlaybook(
            playbook: 'playbooks/splunk.yml',
            inventory: 'dynamic_inventory.ini'
        )
        // Run the test playbook
        ansiblePlaybook(
            playbook: 'playbooks/test-splunk.yml',
            inventory: 'dynamic_inventory.ini'
        )
    }
}


stage('Task 5: Destroy') {
    steps {
        // Ask the human permission
        input message: 'Destroy now?', ok: 'Yes'
        sh 'terraform destroy -auto-approve'
    }
}
post { 
    // If the pipeline fails, destroy it anyway!
    failure { 
        sh 'terraform destroy -auto-approve' 
    } 
}