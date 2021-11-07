import os
import logging
import boto3
from botocore.exceptions import ClientError
from pathlib import Path

logger = logging.getLogger("s3_logger")
logger.setLevel(logging.INFO)

class S3Yandex:

    def __init__(self):
        self.service_name='s3'
        self.endpoint_url='https://storage.yandexcloud.net'

    def empty_backet(self, bucket_name: str):
        """Danger! Delete all objects in S3 bucket
        """
        try:
            session = boto3.session.Session()
            s3 = session.resource(service_name=self.service_name, endpoint_url=self.endpoint_url)

            s3.Bucket(bucket_name).objects.delete()
            logging.debug('All objects in S3 bucket {} - deleted!'.format(bucket_name))
        except ClientError as e:
            logging.error(e)
            return False
        return True

    def create_bucket(self, bucket_name):
        """Create an S3 bucket
        """
        try:
            session = boto3.session.Session()
            s3 = session.client(service_name=self.service_name, endpoint_url=self.endpoint_url)
            s3.create_bucket(Bucket=bucket_name)
            logging.debug('Backet {} - создан!'.format(bucket_name))
        except ClientError as e:
            logging.error(e)
            return False
        return True


    def delete_object_by_prefix(self, bucket_name: str, prefix: str):
        """Delete objects in S3 bucket by prefix
        """
        try:
            session = boto3.session.Session()
            s3 = session.client(service_name=self.service_name, endpoint_url=self.endpoint_url)

            bucket_objects = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)

            if 'Contents' in bucket_objects:
                for object in bucket_objects['Contents']:
                    logging.info('Deleting {} ...'.format(object['Key']))
                    s3.delete_object(Bucket=bucket_name, Key=object['Key'])
        except ClientError as e:
            logging.error(e)
            return False
        return True


    def upload_folder(self, folder_path: str, bucket_name: str, bucket_path: str = None):
        """Upload content of folder in S3 bucket
        """
        folder_path = Path(folder_path).resolve()
        for dirpath, _, filenames in os.walk(folder_path):
            for filename in filenames:
                file_path = Path(os.path.join(dirpath, filename))
                relative_path = file_path.relative_to(folder_path).as_posix()

                if bucket_path:
                    relative_path = Path(os.path.join(bucket_path ,relative_path)).resolve().as_posix()

                self.upload_file(str(file_path), bucket_name, str(relative_path)[1:])
                


    def upload_file(self, file_path: str, bucket_name: str, object_name: str = None):
        """Upload a file to an S3 bucket
        """

        # If S3 object_name was not specified, use file_name
        if object_name is None:
            object_name = os.path.basename(file_path)

        # Upload the file
        session = boto3.session.Session()
        s3 = session.client(service_name=self.service_name, endpoint_url=self.endpoint_url)
        try:
            s3.upload_file(file_path, bucket_name, object_name)
            logging.info('File: {} - uploaded in backet: {} by key: {}!'.format(file_path, bucket_name, object_name))
        except ClientError as e:
            logging.error(e)
            return False
        return True

    def list_backet_objects(self, bucket_name: str):
        """List all objects in S3 bucket
        """
        try:
            session = boto3.session.Session()
            s3 = session.resource(service_name=self.service_name, endpoint_url=self.endpoint_url)

            for bucket in s3.buckets.all():
                if bucket.name == bucket_name:
                    for object in bucket.objects.all():
                        print("Object key: {}".format(object.key))
                            
        except ClientError as e:
            logging.error(e)
            return False
        return True

