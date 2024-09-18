Connect-MsolService
$FileLogdate = (Get-Date -f yyyy-MM-dd_HH_mm)
$FileName = "MFARegistrationStatus-"+$FileLogDate+".csv"
if (Test-Path $FileName) 
{
  Remove-Item $FileName
}
$groupNames = @()

# Enter file path to file containing groups
$groups = (Import-Csv -Path "REPLACE GROUP FILE PATH")


foreach ($group in $groups) {
    Write-Output($group)
    $users=(Get-ADGroupMember -Identity $group.GroupName -Recursive| where {$_.objectclass -eq 'user'} | Get-ADUser -Properties userPrincipalName, name, department, physicalDeliveryOfficeName, Company, lastLogondate, Enabled, PasswordNeverExpires)
    foreach ($user in $users.userPrincipalName) {
      $mfaoptions = (Get-MSolUser -UserPrincipalName $user | select {($_.StrongAuthenticationMethods).MethodType})
      $users | where {$_.UserPrincipalName -eq $user} | select @{Name="group"; Expression={$group}}, userPrincipalName, name, department , PhysicalDeliveryOfficeName, lastLogondate, Enabled, PasswordNeverExpires, @{Name="MFAOptions"; Expression={$mfaoptions.'($_.StrongAuthenticationMethods).MethodType'}} | Export-Csv -append -path $FileName -NoTypeInformation
    }
} 
