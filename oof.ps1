clear-host

$AutoUpdate = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$AutoUpdate.NotificationLevel = 4
$AutoUpdate.Save()

$resultcode= @{0="Not Started"; 1="In Progress"; 2="Succeeded"; 3="Succeeded With Errors"; 4="Failed" ; 5="Aborted" }
$updateSession = new-object -com "Microsoft.Update.Session"
$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates
if ($Updates -ne 0) {
    $downloader = $updateSession.CreateUpdateDownloader()
    $downloader.Updates = $Updates

    write-progress -Activity 'Updating' -Status "Downloading $($downloader.Updates.count) updates"
    $Result= $downloader.Download()
    if (($Result.Hresult -eq 0) -and (($result.resultCode -eq 2) -or ($result.resultCode -eq 3)) ) {
        $updatesToInstall = New-object -com "Microsoft.Update.UpdateColl"
        
        $Updates | where {$_.isdownloaded} | foreach-Object {$updatesToInstall.Add($_) | out-null }
        $installer = $updateSession.CreateUpdateInstaller()
        $installer.Updates = $updatesToInstall

        write-progress -Activity 'Updating' -Status "Installing $($Installer.Updates.count) updates"
        $installationResult = $installer.Install()
        $Global:counter=-1
        $installer.updates | Format-Table -autosize -property Title,EulaAccepted,@{label='Result';
            expression={$ResultCode[$installationResult.GetUpdateResult($Global:Counter++).resultCode ] }} 
        if ($autoRestart -and $installationResult.rebootRequired) { shutdown.exe /t 0 /r }
        if ($ShutdownAfterUpdate) {shutdown.exe /t 0 /s }
    }
}

auditpol /set /category:* /success:enable /failure:enable

NetSh Advfirewall set allprofiles state on

