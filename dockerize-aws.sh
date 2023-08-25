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

if [ $# -eq 2 ] && [ "$2" == "PUSH" ]; then PUSH="YES"; fi


printf "***************************************************************************\n"
printf "* Building/Pushing Docker Imageas For Version: %s\n" "$1"
printf "***************************************************************************\n"

printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
printf "@ AWS SSO login using profile: " "$AWS_PROFILE\n"
printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
aws sso login --profile "$AWS_PROFILE"

printf "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
printf "@ Docker Auth With AWS\n"
printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
aws ecr-public get-login-password --region "$AWS_REGION" --profile "$AWS_PROFILE" | docker login --username AWS --password-stdin "$AWS_ECR_REPOSITORY"

#printf "\t-->> Building API...\n"
#docker build --no-cache --tag thsa-link-api --file ./api/Dockerfile .
#printf "\t-->> Tagging API\n"
#docker tag thsa-link-api "$AWS_ECR_REPOSITORY"/thsa-link-api:"$TAGVERSION"
#if [ "$PUSH" == "YES" ]; then
#    printf "\t-->> Pushing API\n"
#    docker push "$AWS_ECR_REPOSITORY"/thsa-link-api:"$TAGVERSION"
#else
#	printf "\t-->> NOT Pushing\n"
#fi
#
#printf "\t-->> Building CONSUMER...\n"
#docker build --no-cache --tag thsa-link-consumer --file ./consumer/Dockerfile .
#printf "\t-->> Tagging CONSUMER\n"
#docker tag thsa-link-consumer "$AWS_ECR_REPOSITORY"/thsa-link-consumer:"$TAGVERSION"
#if [ "$PUSH" == "YES" ]; then
#	printf "\t-->> Pushing CONSUMER\n"
#    docker push "$AWS_ECR_REPOSITORY"/thsa-link-consumer:"$TAGVERSION"
#else
#	printf "\t-->> NOT Pushing\n"
#fi
#
#printf "\t-->> Building CQF...\n"
#docker build --no-cache --tag thsa-link-cqf --file ./cqf-ruler/Dockerfile .
#printf "\t-->> Tagging CQF\n"
#docker tag thsa-link-cqf "$AWS_ECR_REPOSITORY"/thsa-link-cqf:"$TAGVERSION"
#if [ "$PUSH" == "YES" ]; then
#	printf "\t-->> Pushing CQF\n"
#    docker push "$AWS_ECR_REPOSITORY"/thsa-link-cqf:"$TAGVERSION"
#else
#	printf "\t-->> NOT Pushing\n"
#fi
#
#printf "\t-->> Building DATA STORE...\n"
#docker build --no-cache --tag thsa-link-datastore --file ./datastore/Dockerfile .
#printf "\t-->> Tagging DATA STORE\n"
#docker tag thsa-link-datastore "$AWS_ECR_REPOSITORY"/thsa-link-datastore:"$TAGVERSION"
#if [ "$PUSH" == "YES" ]; then
#    printf "\t-->> Pushing DATA STORE\n"
#    docker push "$AWS_ECR_REPOSITORY"/thsa-link-datastore:"$TAGVERSION"
#else
#	printf "\t-->> NOT Pushing\n"
#fi

printf "\t-->> Building WEB...\n"
docker build --no-cache --tag thsa-link-web --file ./web/Dockerfile .
printf "\t-->> Tagging WEB\n"
docker tag thsa-link-web "$AWS_ECR_REPOSITORY"/thsa-link-web:"$TAGVERSION"
if [ "$PUSH" == "YES" ]; then
    printf "\t-->> Pushing WEB\n"
    docker push "$AWS_ECR_REPOSITORY"/thsa-link-web:"$TAGVERSION"
else
	printf "\t-->> NOT Pushing\n"
fi