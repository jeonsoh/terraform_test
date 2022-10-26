#!/usr/bin/env bash
set -e

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
mfa_serial=""
mfa_seed=""

token="$(oathtool -b --totp $mfa_seed)"
cred="$(aws sts get-session-token --serial-number $mfa_serial --token-code $token)"

export AWS_ACCESS_KEY_ID="$(echo $cred | jq -r '.Credentials.AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(echo $cred | jq -r '.Credentials.SecretAccessKey')"
export AWS_SESSION_TOKEN="$(echo $cred | jq -r '.Credentials.SessionToken')"

assume_cred="$(aws sts assume-role --role-arn "" --role-session-name "")"

access_key="$(echo $assume_cred | jq .Credentials.AccessKeyId)"
secret_key="$(echo $assume_cred | jq .Credentials.SecretAccessKey)"
session_tok="$(echo $assume_cred | jq .Credentials.SessionToken)"
expiration="$(echo $assume_cred | jq .Credentials.Expiration)"

printf '{"Version":1,"AccessKeyId":%s,"SecretAccessKey":%s,"SessionToken":%s,"Expiration":%s}' "$access_key" "$secret_key" "$session_tok" "$expiration"
