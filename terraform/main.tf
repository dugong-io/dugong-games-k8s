# Create s3 bucket for terraform remote state

resource "aws_s3_bucket" "dugong_game_k8s_state" {
  bucket = "terraform-dugong-game-k8s-state"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
	enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
	rule {
	  apply_server_side_encryption_by_default {
		sse_algorithm = "AES256"
	  }
	}
  }
}

# Create a dynamodb table for locking the state file - top level
resource "aws_dynamodb_table" "terraform_dugong_game_k8s_locks" {
  name         = "terraform-dugong-game-k8s-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Create a dynamodb table for locking the state file - infra level
# Create s3 bucket for terraform remote state

resource "aws_s3_bucket" "dugong_game_k8s_state-infra" {
  bucket = "terraform-dugong-game-k8s-state-infra"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
	enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
	rule {
	  apply_server_side_encryption_by_default {
		sse_algorithm = "AES256"
	  }
	}
  }
}

# Create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "terraform_dugong_game_k8s_locks-infra" {
  name         = "terraform-dugong-game-k8s-locks-infra"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# Create a dynamodb table for locking the state file - service level
# Create s3 bucket for terraform remote state

resource "aws_s3_bucket" "dugong_game_k8s_state-infra-service" {
  bucket = "terraform-dugong-game-k8s-state-infra-service"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
	enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
	rule {
	  apply_server_side_encryption_by_default {
		sse_algorithm = "AES256"
	  }
	}
  }
}

# Create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "terraform_dugong_game_k8s_locks-infra-service" {
  name         = "terraform-dugong-game-k8s-locks-infra-service"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# create the s3 bucket that will store useful values
resource "aws_s3_bucket" "terraform_dugong_s3_outputs" {
  bucket = "terraform-dugong-s3-outputs"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
	enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
	rule {
	  apply_server_side_encryption_by_default {
		sse_algorithm = "AES256"
	  }
	}
  }
}

# Set terraform to use remote state
terraform {
  backend "s3" {
    bucket         = "terraform-dugong-game-k8s-state"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-dugong-game-k8s-locks"
    encrypt        = true
  }
}