# **Bastion and Virtual WAN Secured Hub**
[Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) provides secure and seamless Remote Desktop Protocol (RDP) and Secure Shell (SSH) access to virtual machines directly through the Azure Portal. Azure Bastion is provisioned directly into a Virtual Network (VNet) and supports all VMs in the same and peered VNets, and anywhere else provided there is connectivity. Using Azure Bastion eliminates the need to open inbound connectivity to VMs from the internet, thereby reducing the attack surface.

[Azure Virtual WAN Secured Hub](https://learn.microsoft.com/en-us/azure/firewall-manager/secured-virtual-hub) allows organizations to create a hub-and-spoke architecture in Azure and route traffic through the hub. The "Secured" part refers to the integrated security features, such as firewall and threat protection. This service simplifies network architecture, enhances connectivity, and provides built-in security, making it easier for organizations to manage and secure their network traffic.

# The Problem
Users connect inbound to Azure Bastion on its public endpoint via https - either from the Azure portal, or by directly pasting a shareable link in the browser's address bar. Bastion then establishes an RDP or SSH session to the target VM from its private endpoint on the AzureBastionSubnet, to the private ip address of the target. 

However, when Virtual WAN Secured Hub is configured to secure internet traffic through the hub firewall, the Virtual Hub Router programs the default route on all subnets in connected spoke VNETs, pointing to the firewall's loadbalancer address. This uses the same mechanism that Gateways use to program routes, and the route shows in VM effective routes with Source "Virtual Network Gateway". This route is also applied to the AzureBastionSubnet.

![image](/images/vm-eff-rts.png)

When a user now accesses either Bastion or a VM directly on its (instance) public IP, the default route programmed by the Virtual Hub Router pushes return traffic to the hub firewall. As the firewall did not see the inbound traffic (this was directed to the instance public IP), it will drop the return traffic and the sesssion fails.

![image](/images/bastion-secure-hub-problem.png)

Direct inbound access from the internet to Bastion is easily fixed by disabling propagation of the default route from the hub, on the VNET Connection. However, this applies to all subnets  in the spoke, meaning that any VMs in the same spoke vnet as Bastion cannot have internet security via the firewall in the hub. 

![image](/images/disable-def-rt-prop.png)

Another solution would be to attach a UDR containing a route for the client's IP address pointing to internet, to the subnet.

![image](/images/vm-eff-rts-udr.png)

However, Bastion needs direct connectivity to internet from its subnet. To ensure that this is always the case, Azure prevents attaching a User Defined Route (UDR) table to the AzureBastionSubnet and the above fix does not work for Bastion. 

:point_right: VWAN Secured Hub configured to secure internet traffic through the hub firewall breaks Azure Bastion.

# The Solution
Azure Bastion Premium Tier introduces new Session Recording and Private Only features. Bastion Premium is in public preview.

Private Only makes Bastion accessible to clients via a private IP address, taken from the AzureBastionSubnet, only. When this feature is enabled, the Bastion instance does not have a public endpoint.

![image](/images/bastion-premium-portal-private.png)

With Bastion Premium Private Only and the hub firewall's Destination Network Address Translation (DNAT) capability, the problem described above can be mitigated.

![image](/images/bastion-secure-hub-solution.png)

The client targets the firewall's public IP address on port 443. A DNAT rule then translates the public destination address into Bastion's private address and forwards the traffic. As the firewall also Source NATs the traffic (default behaviour for Azure Firewall, third party NVA firewalls may need separate configuration), return traffic from Bastion always goes to the firewall, ensuring traffic symmetry.

![image](/images/dnat-rule.png)

Last piece of the solution is DNS resolution: the FQDN of the Bastion instance needs to resolve the firewall's public IP address. The Private Only feature does not create a public DNS entry. As the bastion.azure.com domain is owned by the Bastion service, Azure users cannot simply create an A records for their Bastion instances. The solution here is to provide location resolution through the client pc's HOSTS file:

- Obtain the Bastion instance's DNS name from the portal.

![image](/images/bastion-dns-name.png)

- Obtain the hub firewall's public ip address.

![image](/images/fw-pub-ip.png)

- Create an entry in the client's HOSTS file. On Windows 11, this is located in C:\Windows\system32\drivers\etc:

![images](/images/hosts.png)

VM's in Spoke VNETs connected to a VWAN Secured Hub configured to secure internet traffic can now be accessed through Bastion.

In the Azure portal, enter the VM's private ip address in the Connect dialog:

![images](/images/connect-vm-portal.png)

Alternatively, create a shareable link, copy it and paste it into the address bar of a new browser window:

![images](/images/connect-vm-link.png)

# Lab #

Log in to Azure Cloud Shell at https://shell.azure.com/ and select Bash.

Ensure Azure CLI and extensions are up to date:
  
    az upgrade --yes
  
If necessary select your target subscription:
  
    az account set --subscription <Name or ID of subscription>

Clone the  GitHub repository: 

    git clone https://github.com/mddazure/bastion-and-secure-hub

Change directory:

    cd .\bastion-and-secure-hub\templates

Deploy the template

    az deployment sub create -n bastion --template-file main.bicep -l swedencentral

Follow the instructions above to create a DNAT rule in the firewall policy, and create an entry in the client VM's HOSTS file.

VM credentials:

    username: AzureAdmin

    password: VwanBas-2024