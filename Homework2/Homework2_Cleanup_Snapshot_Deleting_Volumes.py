import boto3
from operator import itemgetter #This module is used to sort the snapshots based on the time. It was imported automatically because of tabbing.
#import snap

ec2_client = boto3.client('ec2', region_name="us-east-1")

volumes = ec2_client.describe_volumes(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': ['prod']  #prod - because thats what we chose for making snapshots
        }
    ]
)

for volume in volumes['Volumes']:
    snapshots = ec2_client.describe_snapshots(
    OwnerIds=['self'],
    Filters=[
        {
            'Name': 'tag:volume-id',
            'Values': [volume['VolumeId']]  #volume- because thats what we chose for creating it through Instances0
        }
    ]
)

sorted_by_date = sorted(snapshots['Snapshots'], key=itemgetter('StartTime'), reverse = True)   #Since itemgetter is a module it has to be imported

for snapshots in sorted_by_date[2:]:
    #delete snapshot by skipping the first 2 in iteration
    #print(snapshots['SnapshotId'])
    #print(snapshots['StartTime'])
    response = ec2_client.delete_snapshot(SnapshotId=snapshots['SnapshotId'])
    
    print(response)
    
    