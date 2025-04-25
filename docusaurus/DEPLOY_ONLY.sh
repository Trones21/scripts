#!/bin/bash

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install and configure AWS CLI."
    exit 1
fi

# Define variables
BUILD_DIR="./build"
S3_BUCKET=""
S3_PATH="s3://$S3_BUCKET"

# Delete files from previous build (to avoid duplication/conflicts) 
echo "Cleaning up bucket"
aws s3 rm "$S3_PATH" --recursive

# Upload files to S3
echo "Uploading contents of $BUILD_DIR to $S3_PATH"
aws s3 cp "$BUILD_DIR" "$S3_PATH" --recursive

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "Upload successful."
else
    echo "Upload failed."
    exit 1
fi
