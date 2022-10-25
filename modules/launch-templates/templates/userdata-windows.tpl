<powershell>
${pre_userdata}

# Deal with extra new disks
$disks_to_adjust = Get-Disk | Select-Object Number,Size,PartitionStyle | Where-Object PartitionStyle -Match RAW
if ($disks_to_adjust -ne $null) {
  [int64] $partition_mbr_max_size = 2199023255552
  $partition_style = "MBR"

  foreach ($disk in $disks_to_adjust) {
    if ($disk.Size -gt $partition_mbr_max_size) {
      $partition_style = "GPT"
    }

    Initialize-Disk -Number $disk.Number -PartitionStyle $partition_style
    New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS
  }
}

# Redirect Docker files to new the disk
Stop-Service -Name "docker" -Force -NoWait

$dockerdataredirect = @'
{
    "data-root": "D:\\ProgramData\\Docker"
}
'@

$daemon_file = "C:\ProgramData\docker\config\daemon.json"
$directory = "D:\ProgramData\docker"
New-Item $directory -ItemType Directory
New-Item $daemon_file -ItemType File
Add-Content $daemon_file $dockerdataredirect

Start-Service -Name "docker"

# Bootstrap and join the cluster
[string]$EKSBinDir = "$env:ProgramFiles\Amazon\EKS"
[string]$EKSBootstrapScriptName = 'Start-EKSBootstrap.ps1'
[string]$EKSBootstrapScriptFile = "$EKSBinDir\$EKSBootstrapScriptName"
& $EKSBootstrapScriptFile -EKSClusterName ${eks_cluster_id} -KubeletExtraArgs '${kubelet_extra_args}' 3>&1 4>&1 5>&1 6>&1
$LastError = if ($?) { 0 } else { $Error[0].Exception.HResult }

${post_userdata}
</powershell>
