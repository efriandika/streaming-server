#!/usr/bin/env bash

# Entry point to mount s3fs filesystem before exec'ing command.

# Fail on all script errors
set -e
[ "${DEBUG:-false}" == 'true' ] && { set -x; S3FS_DEBUG='-d -d'; }

# Defaults
: ${AWS_S3_AUTHFILE:='/root/.s3fs'}
: ${AWS_S3_MOUNTPOINT:='/opt/data'}
: ${AWS_S3_URL:='https://s3.amazonaws.com'}
: ${AWS_S3_REGION:='us-east-1'}
: ${S3FS_ARGS:=''}

# If no command specified, print error
[ "$1" == "" ] && set -- "$@" bash -c 'echo "Error: Please specify a command to run."; exit 128'

# Configuration checks
if [ -z "$AWS_S3_BUCKET_NAME" ]; then
    echo "Error: AWS_S3_BUCKET_NAME is not specified"
    exit 128
fi

if [ ! -f "${AWS_S3_AUTHFILE}" ] && [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Error: AWS_ACCESS_KEY_ID not specified, or ${AWS_S3_AUTHFILE} not provided"
    exit 128
fi

if [ ! -f "${AWS_S3_AUTHFILE}" ] && [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Error: AWS_SECRET_ACCESS_KEY not specified, or ${AWS_S3_AUTHFILE} not provided"
    exit 128
fi

# Write auth file if it does not exist
if [ ! -f "${AWS_S3_AUTHFILE}" ]; then
   echo "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" > ${AWS_S3_AUTHFILE}
   chmod 400 ${AWS_S3_AUTHFILE}
fi

echo "==> Mounting S3 Filesystem ${AWS_S3_MOUNTPOINT}"
# mkdir -p ${AWS_S3_MOUNTPOINT}

# s3fs mount command
s3fs $S3FS_DEBUG $S3FS_ARGS -o passwd_file=${AWS_S3_AUTHFILE} -o url=${AWS_S3_URL} -o endpoint=${AWS_S3_REGION} ${AWS_S3_BUCKET_NAME} ${AWS_S3_MOUNTPOINT}

# RUN NGINX
nginx
