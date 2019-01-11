#┌┬┐┌─┐┌─┐┌┬┐┌─┐┬─┐
#│││├─┤└─┐ │ ├┤ ├┬┘
#┴ ┴┴ ┴└─┘ ┴ └─┘┴└─

resource "aws_security_group" "example-cluster" {
  name        = "terraform-eks-example-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.example.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "eks-terraform-example"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "example-cluster-ingress-workstation-https" {
  cidr_blocks       = ["174.89.44.133/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.example-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

#┬ ┬┌─┐┬─┐┬┌─┌─┐┬─┐
#││││ │├┬┘├┴┐├┤ ├┬┘
#└┴┘└─┘┴└─┴ ┴└─┘┴└─

resource "aws_security_group" "example-node" {
  name        = "terraform-eks-example-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.example.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-example-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "example-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.example-node.id}"
  source_security_group_id = "${aws_security_group.example-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "example-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.example-node.id}"
  source_security_group_id = "${aws_security_group.example-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "example-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.example-cluster.id}"
  source_security_group_id = "${aws_security_group.example-node.id}"
  to_port                  = 443
  type                     = "ingress"
}
