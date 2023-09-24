data "aws_iam_policy" "backup_policy" {
  name = "AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "restore_policy" {
  name = "AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_vault" "backup_vault" {
  name        = "${lower(var.environment)}-backup-vault"
  # kms_key_arn = data.aws_kms_key.current.arn
  tags = {
    Environment = var.environment
  }
}

resource "aws_backup_plan" "ec2_backup_plan" {
  name = "${lower(var.environment)}-ec2-backup-plan"

  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 18 * * ? *)"
    start_window      = 60
    completion_window = 300

    lifecycle {
      delete_after = 30
    }

    recovery_point_tags = {
      Environment = var.environment
    }
  }

  tags = {
    Name        = "${title(lower(var.environment))} EC2 Backup Plan"
    Environment = var.environment
  }
}

resource "aws_backup_selection" "backup_selection" {
  iam_role_arn = aws_iam_role.backup_service_role.arn
  name         = "${lower(var.environment)}-ec2-backup-selection"
  plan_id      = aws_backup_plan.ec2_backup_plan.id

  resources = concat(
    values({ for k, v in merge(aws_instance.app, aws_instance.mongodb, aws_instance.elasticsearch, aws_instance.web) : k => v.arn }),
    [aws_instance.opsmanager.arn],
  )

}

resource "aws_iam_role" "backup_service_role" {
  name = "AWSBackupDefaultServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_service_role-backup_policy-attach" {
  role       = aws_iam_role.backup_service_role.name
  policy_arn = data.aws_iam_policy.backup_policy.arn
}
resource "aws_iam_role_policy_attachment" "backup_service_role-restore_policy-attach" {
  role       = aws_iam_role.backup_service_role.name
  policy_arn = data.aws_iam_policy.restore_policy.arn
}