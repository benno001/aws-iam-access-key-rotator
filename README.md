# AWS IAM access key rotation helper script

## Requirements
- jq

## How to
- Call the `rotate.sh` script with an optional IAM profile (e.g. `./rotate.sh -p work`). If no profile is given, it uses the default profile.
- If all went well, old keys were deleted and new access keys were automatically configured in the ~/.aws/credentials file.

# Important note
Don't use `set -x` on the `rotate.sh` script on a system that saves history. This means AWS secret access keys would (at least) be logged in the shell history file.
