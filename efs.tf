resource "aws_efs_file_system" "zcp_control_plane_csi" {
  encrypted = true
  tags      = {
    Name        = "${local.cluster_name}"
    Terraform   = "true"
    Environment = "dev"
    CreatedBy   = "taejune"
  }
}

resource "aws_efs_access_point" "zcp_control_plane_csi" {
  file_system_id = aws_efs_file_system.zcp_control_plane_csi.id
  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
    path = "/dynamic_provisioning"

  }

  tags = {
    Name        = "${local.cluster_name}"
    Terraform   = "true"
    Environment = "dev"
    CreatedBy   = "taejune"
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.zcp_control_plane_csi.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_security_group" "zcp_control_plane_csi" {
  name        = "eks-efs-sg-${local.cluster_name}"
  description = "NFS access to EFS from EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-efs-sg-${local.cluster_name}"
    Terraform   = "true"
    Environment = "dev"
    CreatedBy   = "taejune"
  }
}

resource "aws_efs_mount_target" "zcp_control_plane_csi" {
  file_system_id  = aws_efs_file_system.zcp_control_plane_csi.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.zcp_control_plane_csi.id]
}
