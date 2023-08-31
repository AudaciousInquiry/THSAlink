#!/bin/bash

if [ -z "$1" ]
	then
		echo "Image Tag Version Not Specified... exiting..."
		exit
fi

TAGVERSION=$1
AWS_REGION="us-east-1"
AWS_PROFILE="starhie"
AWS_ECR_REPOSITORY="public.ecr.aws/k2c9h9v2"
PUSH="NO"


declare -a image_tags=("thsa-link-api:./api/Dockerfile"
"thsa-link-consumer:./consumer/Dockerfile"
"thsa-link-cqf:./cqf-ruler/Dockerfile"
"thsa-link-datastore:./datastore/Dockerfile"
"thsa-link-web:./web/Dockerfile"
"thsa-link-cli-refresh-patient-list:./cli/docker/refresh-patient-list/Dockerfile"
"thsa-link-cli-generate-and-submit:./cli/docker/generate-and-submit/Dockerfile"
"thsa-link-cli-expunge-data:./cli/docker/expunge-data/Dockerfile")

if [ $# -eq 2 ] && [ "$2" == "PUSH" ]; then PUSH="YES"; fi

printf "***************************************************************************\n"
printf "* Building/Pushing Docker Imageas For Version: %s\n" "$1"
printf "***************************************************************************\n"

printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
printf "@ AWS SSO login using profile: %s\n" "$AWS_PROFILE"
printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
aws sso login --profile "$AWS_PROFILE"

printf "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
printf "@ Docker Auth With AWS\n"
printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
aws ecr-public get-login-password --region "$AWS_REGION" --profile "$AWS_PROFILE" | docker login --username AWS --password-stdin "$AWS_ECR_REPOSITORY"

for t in "${image_tags[@]}"
do
  image_tag="${t%%:*}"
  docker_file="${t##*:}"

  printf "\t-->> Building %s...\n" "$image_tag"
  docker build --no-cache --tag "$image_tag" --file "$docker_file" .
  printf "\t-->> Tagging %s\n" "$image_tag"
  docker tag "$image_tag" "$AWS_ECR_REPOSITORY"/"$image_tag":"$TAGVERSION"
  if [ "$PUSH" == "YES" ]; then
      printf "\t-->> Pushing %s\n" "$image_tag"
      docker push "$AWS_ECR_REPOSITORY"/"$image_tag":"$TAGVERSION"
  else
    printf "\t-->> NOT Pushing\n"
  fi
done