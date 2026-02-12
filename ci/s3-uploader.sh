#!/usr/bin/env bash
# Usage: ./s3_cp_no_checks.sh ACCESS_KEY_ENV_VAR SECRET_KEY_ENV_VAR S3_BUCKET S3_PATH FILE_PATH

ACCESS_VAR_NAME="$1"
SECRET_VAR_NAME="$2"
S3_BUCKET="$3"
S3_PATH="$4"
FILE_PATH="$5"

ACCESS_KEY="${!ACCESS_VAR_NAME}"
SECRET_KEY="${!SECRET_VAR_NAME}"

S3_URI="s3://${S3_BUCKET%/}/${S3_PATH#/}"

python3 << EOF
import boto3
import os

# Set credentials from bash variables
os.environ['AWS_ACCESS_KEY_ID'] = "$ACCESS_KEY"
os.environ['AWS_SECRET_ACCESS_KEY'] = "$SECRET_KEY"

s3 = boto3.client('s3',
    aws_access_key_id="$ACCESS_KEY",
    aws_secret_access_key="$SECRET_KEY"
)

bucket = "$S3_BUCKET".rstrip('/')
path = "$S3_PATH".lstrip('/')
file_path = "$FILE_PATH"

try:
    s3.upload_file(file_path, bucket, path)
    print(f"✓ Successfully uploaded to $S3_URI")
except Exception as e:
    print(f"✗ Upload failed: {e}")
    exit(1)
EOF

echo "Upload attempted to $S3_URI"