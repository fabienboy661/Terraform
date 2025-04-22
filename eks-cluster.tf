provider "kubernetes" {
#    load_config_file = false
   host =  data.aws_eks_cluster.myapp-cluster.endpoint
   token = data.aws_eks_cluster_auth.myapp-cluster.token
   cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certicate_authority.0.data)
}       

data "aws_eks_cluster" "myapp-cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.31"

  subnet_ids = module.myapp-vpc.private_subnets     
  vpc_id = module.myapp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "myapp"
  }

  self_managed_node_groups = {
    worker_group_1 = {
        name                          = "myapp-worker-group-1"
        instance_type                 = "t2.micro"
        min_size                      = 1
        max_size                      = 3
        asg_desired_capacity          = 2
        create_launch_template        = true
        launch_template_use_name_prefix = false
    },
    worker_group_2 = {
        name                          = "myapp-worker-group-2"
        instance_type                 = "t2.medium"
        min_size                      = 1
        max_size                      = 2
        asg_desired_capacity          = 1
        create_launch_template        = true
        launch_template_use_name_prefix = false
    }
  }
}