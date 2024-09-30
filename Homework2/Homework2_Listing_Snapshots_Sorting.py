import boto3
from operator import itemgetter #This module is used to sort the snapshots based on the time. It was imported automatically because of tabbing.

ec2_client = boto3.client('ec2', region_name="us-east-1")

snapshots = ec2_client.describe_snapshots(
    OwnerIds=['self'],
)

sorted_by_date = sorted(snapshots['Snapshots'], key=itemgetter('StartTime'), reverse = True)   #Since itemgetter is a module it has to be imported

for snap in snapshots['Snapshots']:
    print(snap['StartTime'])

print('#####################')

for snap in sorted_by_date:
    print(snap['StartTime'])