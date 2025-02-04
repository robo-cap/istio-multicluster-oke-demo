module "oke" {
  source = "oracle-terraform-modules/oke/oci"
  # networking
  providers = {
    oci.home = oci.home
  }

  tenancy_id             = var.tenancy_id
  compartment_id         = var.compartment_id
  network_compartment_id = var.network_compartment_id

  # Common
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path

  create_vcn               = true
  assign_dns               = true
  local_peering_gateways   = {}
  lockdown_default_seclist = true
  vcn_cidrs                = ["10.0.0.0/16"]
  vcn_dns_label            = "oke"
  vcn_name                 = "oke"

  # Subnets
  subnets = {
    bastion  = { newbits = 13, netnum = 0, dns_label = "bastion", create = "always" }
    operator = { newbits = 13, netnum = 1, dns_label = "operator", create = "always" }
    cp       = { newbits = 13, netnum = 3, dns_label = "cpp", create = "always" }
    int_lb   = { newbits = 11, netnum = 16, dns_label = "ilb", create = "always" }
    pub_lb   = { newbits = 11, netnum = 17, dns_label = "plb", create = "always" }
    workers  = { newbits = 2, netnum = 1, dns_label = "workers", create = "always" }
    pods     = { newbits = 2, netnum = 2, dns_label = "pods", create = "always" }
  }

  # Dynamic routing gateway (DRG)
  create_drg       = false # true/*false
  drg_display_name = "drg"
  drg_id           = null
  remote_peering_connections = {
  }
  # Routing
  ig_route_table_id = null # Optional ID of existing internet gateway route table
  internet_gateway_route_rules = [
    #   {
    #     destination       = "192.168.0.0/16" # Route Rule Destination CIDR
    #     destination_type  = "CIDR_BLOCK"     # only CIDR_BLOCK is supported at the moment
    #     network_entity_id = "drg"            # for internet_gateway_route_rules input variable, you can use special strings "drg", "internet_gateway" or pass a valid OCID using string or any Named Values
    #     description       = "Terraformed - User added Routing Rule: To drg provided to this module. drg_id, if available, is automatically retrieved with keyword drg"
    #   },
  ]

  nat_gateway_public_ip_id = null
  nat_route_table_id       = null # Optional ID of existing NAT gateway route table
  nat_gateway_route_rules = [
    # {
    #   destination       = "192.168.0.0/16" # Route Rule Destination CIDR
    #   destination_type  = "CIDR_BLOCK"     # only CIDR_BLOCK is supported at the moment
    #   network_entity_id = "drg"            # for nat_gateway_route_rules input variable, you can use special strings "drg", "nat_gateway" or pass a valid OCID using string or any Named Values
    #   description       = "Terraformed - User added Routing Rule: To drg provided to this module. drg_id, if available, is automatically retrieved with keyword drg"
    # },
  ]

  nsgs = {
    bastion  = { create = "always" }
    operator = { create = "always" }
    cp       = { create = "always" }
    int_lb   = { create = "always" }
    pub_lb   = { create = "always" }
    workers  = { create = "always" }
    pods     = { create = "always" }
  }

  # bastion
  create_bastion           = false
  bastion_allowed_cidrs    = ["0.0.0.0/0"]
  bastion_image_os         = "Oracle Autonomous Linux"
  bastion_image_os_version = "8"
  bastion_image_type       = "platform"
  bastion_is_public        = true
  bastion_nsg_ids          = []
  bastion_upgrade          = false
  bastion_user             = "opc"

  bastion_shape = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }

  # operator
  create_operator                = false
  operator_cloud_init            = []
  operator_image_os              = "Oracle Linux"
  operator_image_os_version      = "9"
  operator_image_type            = "platform"
  operator_install_k9s           = true
  operator_install_istioctl      = true
  operator_nsg_ids               = []
  operator_pv_transit_encryption = false
  operator_upgrade               = false
  operator_user                  = "opc"

  operator_shape = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }

  # iam
  create_iam_autoscaler_policy = "auto" // never/*auto/always
  create_iam_kms_policy        = "auto" // never/*auto/always
  create_iam_operator_policy   = "auto" // never/*auto/always
  create_iam_resources         = false
  create_iam_worker_policy     = "auto" // never/*auto/always

  create_iam_tag_namespace = false // true/*false
  create_iam_defined_tags  = false // true/*false
  tag_namespace            = "oke"
  use_defined_tags         = false // true/*false

  # cluster
  create_cluster     = true
  cluster_name       = "oke"
  cni_type           = "flannel"
  kubernetes_version = "v1.30.1"
  pods_cidr          = "10.244.0.0/16"
  services_cidr      = "10.96.0.0/16"
  cluster_type       = "enhanced"

  # Worker pool defaults
  #worker_pool_size = 0
  worker_pool_mode = "node-pool" # Must be node-pool

  # Worker defaults
  await_node_readiness              = "none"
  worker_block_volume_type          = "paravirtualized"
  worker_disable_default_cloud_init = false
  worker_image_os                   = "Oracle Linux"
  worker_image_os_version           = "8"
  worker_image_type                 = "oke"
  worker_is_public                  = false
  worker_node_labels                = {}
  worker_nsg_ids                    = []
  worker_pv_transit_encryption      = false

  worker_shape = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 2,  # Ignored for non-Flex shapes
    memory           = 16, # Ignored for non-Flex shapes
    boot_volume_size = 50
  }

  # autoscaler
  cluster_autoscaler_install           = false
  cluster_autoscaler_namespace         = "kube-system"
  cluster_autoscaler_helm_version      = "9.24.0"
  cluster_autoscaler_helm_values       = {}
  cluster_autoscaler_helm_values_files = []

  worker_pools = {
    np1 = {
      shape              = "VM.Standard.E4.Flex",
      ocpus              = 2,
      memory             = 16,
      size               = 2,
      boot_volume_size   = 50,
      kubernetes_version = "v1.30.1"
      cloud_init = [
        {
          content      = "${path.module}/load_kernel_modules.sh"
          content_type = "text/x-shellscript",
          filename     = "20-kernel-modules.yml"
        }
      ]
    }
  }

  # Security
  allow_node_port_access            = false
  allow_pod_internet_access         = true
  allow_worker_internet_access      = true
  allow_worker_ssh_access           = true
  control_plane_allowed_cidrs       = ["0.0.0.0/0"]
  control_plane_is_public           = true
  assign_public_ip_to_control_plane = true
  enable_waf                        = false
  load_balancers                    = "both"
  preferred_load_balancer           = "public"

  # See https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
  # Protocols: All = "all"; ICMP = 1; TCP  = 6; UDP  = 17
  # Source/destination type: NSG ID: "NETWORK_SECURITY_GROUP"; CIDR range: "CIDR_BLOCK"
  allow_rules_internal_lb = {
    # "Allow TCP ingress to internal load balancers for port 8080 from VCN" : {
    #   protocol = 6, port = 8080, source = "10.0.0.0/16", source_type = "CIDR_BLOCK",
    # },
  }

  allow_rules_public_lb = {
    "Allow all ingress to public load balancers  from anywhere" : {
      protocol = "all", port = 0, source = "0.0.0.0/0", source_type = "CIDR_BLOCK",
    }
  }

}