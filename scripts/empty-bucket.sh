#!/bin/bash

OBJECTS="$(aws s3api list-object-versions  --bucket "${BUCKET_NAME}" --output=json  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

HAS_OBJECTS="$(echo ${OBJECTS} | jq '.Objects')"

if [[ -n $HAS_OBJECTS ]]
then
  aws s3api delete-objects --bucket "${BUCKET_NAME}" --delete "$(aws s3api list-object-versions --bucket "${BUCKET_NAME}" --output=json  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
else
  echo "bucket is empty"
fi
