#Stack name is inside the JSON parameters file
#Create the infrastructure and the eks cluster
aws cloudformation create-stack --region=us-west-2 --template-body file://eks-capstone-cluster.yaml --cli-input-json file://eks-capstone-parameters.json --capabilities CAPABILITY_IAM

#Update stack if needed
#aws cloudformation update-stack --region=us-west-2 file://eks-capstone-cluster.yaml --cli-input-json file://eks-capstone-parameters.json --capabilities CAPABILITY_IAM

#Delete stack if needed
#aws cloudformation delete-stack --cli-input-json file://eks-capstone-parameters.json