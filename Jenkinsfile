pipeline {
    agent any

    stages {

       stage('SCM Checkout') {
            steps {
                git credentialsId: '8e237d54-cc07-4aad-a3fe-51855a4d84c1', url: 'https://github.com/pramodk05/java_maven_jenkins.git'
            }
        }

        stage('Compile Stage') {
            steps {
                withMaven(maven : 'maven_3.6') {
                    sh 'mvn clean compile'
                }
            }
        }


        stage('Test Stage') {
            steps {
                withMaven(maven : 'maven_3.6') {
                    sh 'mvn test'
                }
            }
        }


        stage('Create the Build artifacts Stage (Package)') {
            steps {
                withMaven(maven : 'maven_3.6') {
                    sh 'mvn package'
                }
            }
        }

        stage ('Generating Tomcat SSH keys') {
            steps {
                sh """
                if [ ! -f ${WORKSPACE}/tomcat_ec2_key ]; then
                    ssh-keygen -f ${WORKSPACE}/tomcat_ec2_key -N ""
                fi
                """
            }
        }

        stage ('Building AMI using Packer') {
            steps {
                    sh '''#!/bin/bash
                    echo This is copied via Packer template > welcome.txt
                    echo #!/bin/bash > example.sh
                    echo echo "This script is execute via Packer Build" >> example.sh
                    packer build pack*.json 2>&1 | tee packer_output.txt
                    '''
            }
        }

        stage ('Terraform Setup') {
            steps {
                script {
                    def tfHome = tool name: 'Terraform_0.12.6', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'

                }
            sh 'terraform --version'

            }
        }
        
        stage ('Terraform Apply') {
            steps {
                sh '''#!/bin/bash
                      AMI_ID=`tail -2 packer_output.txt | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }'`
                      echo "AMI ID is: $AMI_ID"
                      terraform init $WORKSPACE
                      terraform plan -var ami_id=$AMI_ID
                      terraform apply -var ami_id=$AMI_ID --auto-approve
                '''
            }
        }

        stage ('Setting up Host variables') {
            steps {
                sh """
                    terraform output -json tomcat_public_dns | cut -d '"' -f2 > tc_pub_dns.txt
                    terraform output -json tomcat_private_dns | cut -d '"' -f2 > tc_pri_dns.txt
                    terraform output -json tomcat_public_ip | cut -d '"' -f2 > tc_pub_ip.txt
                    terraform output -json tomcat_private_ip | cut -d '"' -f2 > tc_pri_ip.txt
                    sed -n '1p' < /opt/pup_setup_tf/ec2_private_dns.txt > pup_master_pri_dns.txt
                    sed -n '1p' < /opt/pup_setup_tf/ec2_private_ip.txt > pup_master_pri_ip.txt
                """
            }
        }

        stage ('Setting up puppet node on Tomcat server') {
            steps {
                sh './tc_pup_agent_setup.sh'
            }
        }

    }
}

