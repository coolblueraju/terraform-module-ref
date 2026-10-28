output "cluster_endpoint" { description="Writer endpoint for the Aurora PostgreSQL cluster."; value=aws_rds_cluster.rds.endpoint }
output "cluster_read_endpoint" { description="Reader endpoint for the Aurora PostgreSQL cluster."; value=aws_rds_cluster.rds.reader_endpoint }
