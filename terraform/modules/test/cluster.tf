resource "aws_eks_cluster" "example" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.example-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.example-cluster.id}"]
    subnet_ids         = ["${aws_subnet.example.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.example-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.example-cluster-AmazonEKSServicePolicy",
  ]
}
