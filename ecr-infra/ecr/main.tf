resource "aws_ecr_repository" "ecr" {
  name = local.ecr_name

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  lifecycle {
    precondition {
      condition     = local.compliant_env != null
      error_message = "terraform.workspace must be one of: test, qa, prod. The supplied module contract maps those to dev, qa, prod tags."
    }
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the 2 most recently pushed images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 2
      }
      action = { type = "expire" }
    }]
  })
}
