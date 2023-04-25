cd ${function_path}
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${region}.amazonaws.com
docker build -t ${repository_url}:${image_tag} . 
docker push ${repository_url}:${image_tag}
