import boto3

ec2_client = boto3.client('ec2', region_name="us-east-1")

snapshots = ec2_client.describe_snapshots(
    OwnerIds=['self'],
)

print(snapshots['Snapshots'])
