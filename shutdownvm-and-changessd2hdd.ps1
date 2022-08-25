$subscriptionid = Get-AzSubscription | Out-GridView -OutputMode:Single -Title "Select your Azure Subscription"
Select-AzSubscription -Subscription $subscriptionid.Id

$tenantid = Get-AzSubscription | Out-GridView -OutputMode:Single -Title "Select your Azure Subscription"
Select-AzSubscription -Subscription $tenantid.Id

#Connect-AzAccount -SubscriptionId $subscriptionid -Tenant $tenantid

###stop aadc

# Name of the resource group that contains the VM
#$rgname = Get-AzResourceGroup | Out-GridView -OutputMode:Single -Title "Choose RG"
#$rgname = $rgname.ResourceGroupName

# Name of the your virtual machine
$vm = Get-AzVM | Out-GridView -OutputMode:Single -Title "Choose VM"
$vmName = $vm.Name
$rgname = $vm.ResourceGroupName

# Choose between Standard_LRS, StandardSSD_LRS and Premium_LRS based on your scenario
$storageType = 'Standard_LRS'

# Premium capable size
# Required only if converting storage from Standard to Premium
#$size = 'Standard_D2as_v2'

# Stop and deallocate the VM before changing the size
Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force
pause 20
$vm = Get-AzVM -Name $vmName -resourceGroupName $rgName


# Change the VM size to a size that supports Premium storage
# Skip this step if converting storage from Premium to Standard
#$vm.HardwareProfile.VmSize = $size
#Update-AzVM -VM $vm -ResourceGroupName $rgName

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

#Start-AzVM -ResourceGroupName $rgName -Name $vmName