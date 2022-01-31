<powershell>
${pre_userdata}

[string]$EKSBinDir = "$env:ProgramFiles\Amazon\EKS"
[string]$EKSBootstrapScriptName = 'Start-EKSBootstrap.ps1'
[string]$EKSBootstrapScriptFile = "$EKSBinDir\$EKSBootstrapScriptName"
& $EKSBootstrapScriptFile -EKSClusterName ${eks_cluster_id} -KubeletExtraArgs '${kubelet_extra_args}' 3>&1 4>&1 5>&1 6>&1
$LastError = if ($?) { 0 } else { $Error[0].Exception.HResult }

$disk_to_adjust = Get-Disk | Select-Object Number,Size,PartitionStyle | Where-Object PartitionStyle -Match RAW
if ($disk_to_adjust -ne $null) {
  [int64] $partition_mbr_max_size = 2199023255552
  $partition_style = "MBR"

  if ($disk_to_adjust.Size -gt $partition_mbr_max_size) {
    $partition_style = "GPT"
  }

  Initialize-Disk -Number $disk_to_adjust.Number -PartitionStyle $partition_style
  New-Partition -DiskNumber $disk_to_adjust.Number -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS
}

${post_userdata}
</powershell>
