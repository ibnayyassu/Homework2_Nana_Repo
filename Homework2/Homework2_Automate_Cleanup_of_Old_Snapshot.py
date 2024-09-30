import boto3

ec2_client = boto3.client('ec2', region_name="us-east-1")

ec2_client.describe_snapshots(
    OwnerIds=['self'],
    Filters=[
        {
            'Name': 'volume-id',
            'Values': ['vol-0e6a8f7e7e7e7e7e7']
        }
    ]
)


snapshots = ec2_client.describe_snapshots(
    OwnerIds=['self'],
    Filters=[
        {
            'Name': 'volume-id',
            'Values': ['vol-0e6a8f7e7e7e7e7e7']
        }
    ]
)