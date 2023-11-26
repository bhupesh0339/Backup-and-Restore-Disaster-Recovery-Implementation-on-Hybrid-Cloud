import os
import subprocess
from datetime import datetime
from azure.storage.blob import BlobServiceClient
def lambda_handler(event, context):
    db_host = os.environ['DB_HOST']
    db_user = os.environ['DB_USER']
    db_password = os.environ['DB_PASSWORD']
    db_name = os.environ['DB_NAME']
    azure_sas_token = os.environ['azure_sas_token']
    azure_storage_account_name = os.environ['azureStorageAccountName']
    azure_container_name = os.environ['azureContainerName']
    dump_file_name = datetime.now().strftime("%Y%m%d%H%M%S") + "_dump.sql"
    print(f"Dump file name: {dump_file_name}")
    dump_command = f"./mysqldump --host={db_host} --user={db_user} --password={db_password} --databases {db_name} --tables time_entries --set-gtid-purged=OFF > /tmp/{dump_file_name}"
    print(f"Executing MySQL dump command: {dump_command}")
    subprocess.run(dump_command, shell=True)
    connection_string = f"DefaultEndpointsProtocol=https;AccountName={azure_storage_account_name};SharedAccessSignature={azure_sas_token};EndpointSuffix=core.windows.net"
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    blob_client = blob_service_client.get_blob_client(container=azure_container_name, blob=dump_file_name)
    with open(f"/tmp/{dump_file_name}", "rb") as data:
        blob_client.upload_blob(data)
    print(f"Dump uploaded to Azure Blob Storage: {dump_file_name}")
    os.remove(f"/tmp/{dump_file_name}")
    print("Local dump file cleaned up.")
    print("Lambda function completed.")
    return {
        'statusCode': 200,
        'body': f'Dump {dump_file_name} uploaded to Azure Blob Storage successfully!'
    }
if __name__ == "__main__":
    lambda_handler(None, None)