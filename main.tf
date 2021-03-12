resource "aws_efs_file_system" "this" {
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "" ? [] : [1]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }

  tags = {
    Name = var.file_system_name
  }
}

resource "aws_efs_access_point" "this" {
  for_each       = var.access_points
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    gid = lookup(each.value, "user_gid", lookup(var.access_points_defaults, "user_gid"))
    uid = lookup(each.value, "user_uid", lookup(var.access_points_defaults, "user_uid"))
  }

  root_directory {
    path = "/${each.key}"
    creation_info {
      owner_gid   = lookup(each.value, "user_gid", lookup(var.access_points_defaults, "user_gid"))
      owner_uid   = lookup(each.value, "user_uid", lookup(var.access_points_defaults, "user_uid"))
      permissions = lookup(each.value, "permission", lookup(var.access_points_defaults, "permission"))
    }
  }

  tags = {
    Name = each.key
  }
}