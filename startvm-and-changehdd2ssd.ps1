#select sub
$subscriptionid = Get-AzSubscription | Out-GridView -OutputMode:Single -Title "Select your Azure Subscription"
Select-AzSubscription -Subscription $subscriptionid.Id


# Name of the your virtual machine
$vm = Get-AzVM | Out-GridView -OutputMode:Single -Title "Choose VM"
$vmName = $vm.Name
$rgname = $vm.ResourceGroupName

# Choose between Standard_LRS, StandardSSD_LRS and Premium_LRS based on your scenario
$storageType = 'Premium_LRS'
#$storageType = 'Standard_LRS'


# Premium capable size
# Required only if converting storage from Standard to Premium
#$size = 'Standard_D2as_v2'

$vm = Get-AzVM -Name $vmName -resourceGroupName $rgName

# Get all disks in the resource group of the VM
$vmDisks = Get-AzDisk -ResourceGroupName $rgName 

$vm

# For disks that belong to the selected VM, convert to Premium storage
foreach ($disk in $vmDisks)
{
    if ($disk.ManagedBy -eq $vm.Id)
    {
        $disk.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
        $disk | Update-AzDisk
    }
}

Start-AzVM -ResourceGroupName $rgName -Name $vmName