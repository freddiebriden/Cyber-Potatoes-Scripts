echo Checking if script contains Administrative rights...
net sessions
if %errorlevel%==0 (
echo Succes
) else (
echo No admin, please run with Administrative rights...
pause
exit
)

REM Firewall
NetSh Advfirewall set allprofiles state on
auditpol /set /category:* /success:enable /failure:enable   
netsh advfirewall firewall add rule name="BlockSSH" protocol=TCP
dir=out remoteport=22 action=block
netsh advfirewall firewall add rule name="BlockTelnet" protocol=TCP
dir=out remoteport=23 action=block

REM Account Policies
REM Password Policy
net accounts /lockoutthreshold:5 /MNPWLEN:8 /MAXPWAGE:30 /MINPAWAGE:1 /UNIQUEPW:5
echo going to password policy 
start secpol.msc /wait
net accounts /minpwlen:10
net accounts /maxpwage:30
net accounts /minpwage:1

REM Services
net start
servicesstarted.txt
net start | findstr Remote Registry
if %errorlevel%==0 (
	echo Remote Registry is running!
	echo Attempting to stop...
	net stop RemoteRegistry
	sc config RemoteRegistry start=disabled
	if %errorlevel%==1 echo Stop failed... sorry...
) else ( 
	echo Remote Registry is already indicating stopped.
)

REM Application Security Settings

REM Application Updates

REM Defensive Countermeasrues

REM Local Policies

REM Operating System Settings

REM Operating System Updates

REM Policy Violation: Prohibited Files

REM Policy Violation: Unwanted Software

REM Service Auditing

REM Enable Windows Defender
Reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v EnableAntiSpyware /t REG_DWORD /d 1 /f

REM User Auditing

REM Windows Automatic Updates
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 3 /f
REM use powershell

REM Flushing DNS
ipconfig /flushdns
