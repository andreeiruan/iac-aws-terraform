#!/bin/bash
set -x

cp  $PWD/artifacts.templates/appspec.template.yaml $PWD/artifacts.templates/appspec.yaml
cp  $PWD/artifacts.templates/taskdef.template.json $PWD/artifacts.templates/taskdef.json

sed -i "s|SED_CONTAINER_NAME|${CONTAINER_NAME}|g" $PWD/artifacts.templates/appspec.yaml

sed -i "s|SED_EXEC_ROLE_ARN|${EXEC_TASK_ROLE_ARN}|g" $PWD/artifacts.templates/taskdef.json
sed -i "s|SED_CONTAINER_NAME|${CONTAINER_NAME}|g" $PWD/artifacts.templates/taskdef.json
sed -i "s|SED_TASK_FAMILY|${TASK_FAMILY}|g" $PWD/artifacts.templates/taskdef.json

FILE_YML=$(base64 $PWD/artifacts.templates/appspec.yaml | tr -d '[:space:]')
FILE_JSON=$(base64 $PWD/artifacts.templates/taskdef.json | tr -d '[:space:]')

aws codecommit put-file --repository-name $REPO_NAME --branch-name master --commit-message "update artifacts" --file-path appspec.yaml --file-content $FILE_YML --file-mode NORMAL --profile ezops --region us-west-1

sleep 30

COMMIT_ID=$(aws codecommit get-branch --repository-name $REPO_NAME --branch-name master | jq '.branch' | jq '.commitId' | tr -d '"')

aws codecommit put-file --repository-name $REPO_NAME --branch-name master --parent-commit-id $COMMIT_ID --commit-message "update artifacts" --file-path taskdef.json --file-content $FILE_JSON --file-mode NORMAL --profile ezops --region us-west-1

rm -f $PWD/artifacts.templates/appspec.yaml
rm -f $PWD/artifacts.templates/taskdef.json
