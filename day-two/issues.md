# Issues in EKS

After setting up public EKS Cluster, I tried to deploy a private EKS cluster with terraform.

EKS Managed Node group took around 30-32 minutes to complete, with final output as error

```bash
waiting for EKS Node Group (xxxxx-jazz-muxxxx:first-eks-ng) create: unexpected state 'CREATE_FAILED', wanted target 'ACTIVE'. last error: i-0013xxxxxxxe5aa1, i-0e99xxxxxxxxx1: NodeCreationFailure: Instances failed to join the kubernetes cluster
```

I had received similar error in public cluster as well. There the reason was that worker nodes in private subnet were not able to reach Public API Server Endpoint.
It was resolved by deploying NAT Gateway in Public Subnets.

But the issue in private EKS cluster was different. Everything is private here. What could be the reason.

I spent the whole day debugging, troubleshooting, asking ChatGPT about the errors. And ofcourse waiting for the terraform to complete the operation.

Almost till the end of the day, I was running in wrong direction, adding VPC endpoints for several services, inspecting Security group rules. Doubting whether
the Security Group Rules created by EKS was faulty. And after several back and forth debugging, and narrowing the issue, I decided to ssh into the worker node
from bastion host in the public subnet, and view logs of Kubelet. Upon getting inside the worker node, I found that kubelet was not running and will not run.
Nodeadm was the service handling worker nodes management.

Inspecting /etc/systemd/system directory, I found `nodeadm-run.service`, `nodeadm-config.service`. Upon inspecting `nodeadm-run.service` file, The line

```bash
ExecStart=/usr/bin/nodeadm init --skip config --config-source imds://user-data --config-source file:///etc/eks/nodeadm.d/ --config-cache /run/eks/nodeadm/config.json
```

Well the config directory `/etc/eks/nodeadm.d/` was present, but no config file was present inside. Then I inspected `nodeadm-config.service` file and the service's
logs. Upon inspecting log, I found the main culprit.

```bash
SDK 2026/08/21 10:38:13 DEBUG retrying request EC2/DescribeInstances, atte>
Aug 21 10:39:03 localhost nodeadm[2716]: SDK 2026/08/21 10:39:03 DEBUG retrying request EC2/DescribeInstances, atte>
Aug 21 10:39:53 localhost nodeadm[2716]: SDK 2026/08/21 10:39:53 DEBUG retrying request EC2/DescribeInstances, atte>
Aug 21 10:40:43 localhost nodeadm[2716]: SDK 2026/08/21 10:40:43 DEBUG retrying request EC2/DescribeInstances, atte>
Aug 21 10:41:33 localhost nodeadm[2716]: SDK 2026/08/21 10:41:33 DEBUG retrying request EC2/DescribeInstances, atte>
Aug 21 10:41:46 localhost nodeadm[2716]: SDK 2026/08/21 10:41:46 DEBUG request failed with unretryable error https >
Aug 21 10:41:46 localhost nodeadm[2716]: fatal cli/main.go:35 Command failed {"error": "expected err to be of type >
Aug 21 10:41:46 localhost systemd[1]: nodeadm-config.service: Main process exited, code=exited, status=1/FAILURE
Aug 21 10:41:46 localhost systemd[1]: nodeadm-config.service: Failed with result 'exit-code'.
Aug 21 10:41:46 localhost systemd[1]: Failed to start nodeadm-config.service - EKS Nodeadm Config.
```

So, the request to EC2/DescribeInstances API was failing in `nodeadm-config.service` unit. Then I added VPC Endpoint for `ec2` service. And re-deployed the terraform
configuration.
