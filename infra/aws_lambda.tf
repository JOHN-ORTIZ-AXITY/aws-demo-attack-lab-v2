trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  AWS_REGION: 'us-east-1'
  LAMBDA_FUNCTION_NAME: 'checkov_lambda'
  PACKAGE_NAME: 'lambda_function_payload.zip'

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.x'
      addToPath: true

  - script: |
      python3 -m venv venv
      source venv/bin/activate
      pip install checkov
      deactivate
      cd venv/lib/python3.9/site-packages
      zip -r9 ${OLDPWD}/${PACKAGE_NAME} .
      cd $OLDPWD
      zip -g ${PACKAGE_NAME} lambda_function_payload.py
    displayName: 'Package Lambda and Dependencies'

  - task: AmazonWebServices.aws-vsts-tools.AWSCli@1
    inputs:
      awsCredentials: '<Your AWS Service Connection>'
      regionName: $(AWS_REGION)
      command: 's3 cp $(PACKAGE_NAME) s3://your-s3-bucket/$(PACKAGE_NAME)'

  - task: TerraformInstaller@0
    inputs:
      terraformVersion: '1.1.9'

  - script: |
      terraform init
      terraform plan -out=tfplan
      terraform apply -auto-approve tfplan
    displayName: 'Deploy Lambda with Terraform'