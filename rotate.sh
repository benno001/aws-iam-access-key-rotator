#!/bin/bash

profile=''

print_usage() {
	echo "Usage: ./rotate.sh [-p profile]"
}

while getopts 'p:' flag; do
	case "${flag}" in
	p) profile="${OPTARG}" ;;
	*)
		print_usage
		exit 1
		;;
	esac
done

PROFILE=${profile:-default}

IDENTITY=$(aws sts get-caller-identity --profile "$PROFILE")

STATUS=$?

if [ "$STATUS" -gt 0 ]; then
	echo "Couldn't get caller identity"
	exit 1
fi

echo "Renewing access keys as $IDENTITY"

# Check if jq is installed
if ! hash jq; then
	echo "Can't find jq. Is it installed?"
	exit 1
fi

read -r KEY_COUNT < <(aws iam list-access-keys --profile "$PROFILE" | jq '.AccessKeyMetadata | length')

if [ -z "$KEY_COUNT" ]; then
	echo "Couldn't retrieve keys."
	exit 1
fi

if [ "$KEY_COUNT" -gt 1 ]; then
	echo "More than one access key present. Don't know which one to rotate."
	exit 1
fi

read -r OLD_ACCESS_KEY < <(aws iam list-access-keys --profile "$PROFILE" | jq -r '.AccessKeyMetadata[0].AccessKeyId')

read -r ACCESS_KEY_ID SECRET_KEY < <(aws iam create-access-key --profile "$PROFILE" | jq -r '.AccessKey | "\(.AccessKeyId) \(.SecretAccessKey)"')

STATUS=$?

if [ "$STATUS" -gt 0 ]; then
	echo "Couldn't create key"
	exit 1
fi

aws iam update-access-key --access-key-id "$OLD_ACCESS_KEY" --status Inactive --profile "$PROFILE"

aws iam list-access-keys --profile "$PROFILE"
aws iam delete-access-key --access-key-id "$OLD_ACCESS_KEY" --profile "$PROFILE"

aws configure set aws_access_key_id "$ACCESS_KEY_ID" --profile "$PROFILE"
aws configure set aws_secret_access_key "$SECRET_KEY" --profile "$PROFILE"

echo "Deleted access key $OLD_ACCESS_KEY for profile $PROFILE"
echo "New access key ID: $ACCESS_KEY_ID"
