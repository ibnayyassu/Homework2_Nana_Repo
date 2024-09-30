import boto3
import schedule

ec2_client=boto3.client('ec2',region_name="us-east-1")


volumes = ec2_client.describe_volumes()
for volume in volumes['Volumes']:
    new_snapshot = ec2_client.create_snapshot(
    VolumeId = volume['VolumeId']
)
    print(new_snapshot)
    