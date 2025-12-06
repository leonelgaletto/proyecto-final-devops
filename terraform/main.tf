# --- BLOQUE 1: CONFIGURACIÓN ---
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- BLOQUE DE DIAGNÓSTICO (¡NUEVO!) ---
# Le pedimos a AWS: "¿Quién soy? ¿Con qué cuenta estoy hablando?"
data "aws_caller_identity" "current" {}


# --- BLOQUE 2: FIREWALL (SECURITY GROUP) ---
resource "aws_security_group" "web_sg" {
  name        = "proyecto1-sg"
  description = "Firewall para el Proyecto 1 (permite SSH y HTTP)"

  # Permite SSH (puerto 22) desde cualquier IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite HTTP (puerto 80) desde cualquier IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# --- ¡¡AQUÍ ESTÁ LA CORRECCIÓN!! ---
  
  # Permite Grafana (puerto 3000) desde cualquier IP
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite Prometheus (puerto 9090) desde cualquier IP
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- BLOQUE 3: BUSCAR LA IMAGEN (AMI) DE UBUNTU ---
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}


# --- BLOQUE 4: EL SERVIDOR (INSTANCIA EC2) ---
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Parte de la capa gratuita de AWS
  key_name      = "mi-llave-aws." # El nombre de la llave que importamos
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  # Este script se correrá la primera vez que arranque el servidor
  user_data     = file("install_docker.sh")

  tags = {
    Name = "Servidor Proyecto 1"
  }
}

# --- BLOQUE 5: OUTPUT (SALIDA) ---
output "public_ip" {
  description = "La IP pública de nuestro servidor web"
  value       = aws_instance.web_server.public_ip
}

# --- OUTPUT DE DIAGNÓSTICO (¡NUEVO!) ---
# Le pedimos a Terraform que nos muestre el ID de la cuenta que está usando.
output "terraform_account_id" {
  description = "El ID de la cuenta que Terraform está usando"
  value       = data.aws_caller_identity.current.account_id
}
