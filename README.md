# AWS IAM access key rotation helper script

## Requirements

- jq
- aws cli

## How to

- Call the `rotate.sh` script with an optional IAM profile (e.g. `./rotate.sh -p work`). If no profile is given, it uses the default profile.
- If all went well, old keys were deleted and new access keys were automatically configured in the ~/.aws/credentials file.

### Cron

Edit crontab via `crontab -e`, and add a line for each profile you want to auto-rotate. For example, if you have two profiles, use something akin to the following to rotate at 9.00, 9.03 and 9.06 every day (arbitrarily set):

```bash
# m h  dom mon dow   command
0 9 * * * /home/user/tools/aws-iam-access-key-rotator/rotate.sh -p default
3 9 * * * /home/user/tools/aws-iam-access-key-rotator/rotate.sh -p personal
6 9 * * * /home/user/tools/aws-iam-access-key-rotator/rotate.sh -p work
```

# Important notes

Assumes that your credentials are stored in `~/.aws/credentials`.

Don't use `set -x` on the `rotate.sh` script on a system that saves history. This means AWS secret access keys would (at least) be logged in the shell history file.
