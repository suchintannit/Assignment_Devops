
resource "aws_instance" "Application" {
  ami           = "ami-03f0544597f43a91d"
  instance_type = "t2.micro"
  key_name = "Desktop-key"
  tags = {
    Name = "master"
  }
  provisioner "file" {
    source      = "./frontend.sh"
    destination = "/home/ubuntu/frontend.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
  }
  provisioner "file" {
    source      = "./backend.sh"
    destination = "/home/ubuntu/backend.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
  }
provisioner "file" {
    source      = "./db-sql.sql"
    destination = "/home/ubuntu/db-sql.sql"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
  }
provisioner "remote-exec" {
   connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
    inline = [
      "./backend.sh",
      "./frontend.sh",
    ]
  }  

  }
