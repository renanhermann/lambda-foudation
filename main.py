import boto3
import os

# Inicializa os clientes EC2 e RDS
ec2_client = boto3.client('ec2')
rds_client = boto3.client('rds')

# IDs dos recursos via variáveis de ambiente
EC2_INSTANCE_IDS = os.getenv("EC2_INSTANCE_IDS", "").split(',')
RDS_INSTANCE_IDS = os.getenv("RDS_INSTANCE_IDS", "").split(',')

def lambda_handler(event, context):
    action = event.get("action")  # 'stop' ou 'start'
    
    if action == "stop":
        stop_resources()
    elif action == "start":
        start_resources()
    else:
        raise ValueError("Ação inválida: 'action' deve ser 'stop' ou 'start'")
    
    return {
        "statusCode": 200,
        "body": f"Recursos {action} executados com sucesso."
    }

def stop_resources():
    # Desliga EC2
    if EC2_INSTANCE_IDS:
        ec2_client.stop_instances(InstanceIds=EC2_INSTANCE_IDS)
        print(f"EC2 Instances {EC2_INSTANCE_IDS} foram desligadas.")
    
    # Desliga RDS
    for db_id in RDS_INSTANCE_IDS:
        rds_client.stop_db_instance(DBInstanceIdentifier=db_id)
        print(f"RDS Instance {db_id} foi desligada.")

def start_resources():
    # Liga EC2
    if EC2_INSTANCE_IDS:
        ec2_client.start_instances(InstanceIds=EC2_INSTANCE_IDS)
        print(f"EC2 Instances {EC2_INSTANCE_IDS} foram ligadas.")
    
    # Liga RDS
    for db_id in RDS_INSTANCE_IDS:
        rds_client.start_db_instance(DBInstanceIdentifier=db_id)
        print(f"RDS Instance {db_id} foi ligada.")
