@ECHO OFF
SETLOCAL EnableDelayedExpansion

:MAIN_MENU
CLS
ECHO ===== Windows PE Tool =====
ECHO:
ECHO    1) Install Windows
ECHO    2) Bypass Windows 11 Requirement Check
ECHO:
ECHO    3) Start DiskPart
ECHO    4) Run chkdsk
ECHO    5) DISM Capture Image
ECHO:
ECHO    6) Initialize Network
ECHO    7) Show Network Information
ECHO    8) Configure Network
ECHO    9) Enable Firewall
ECHO    10) Disable Firewall
ECHO:
ECHO    11) Reboot
ECHO    12) Shutdown
ECHO    13) Exit to Command Line
ECHO:
SET sel=N
SET /P sel=Enter number to select an option: 
IF %sel%==1 GOTO INSTALL_WIN_MOUNTSMB
IF %sel%==2 GOTO BYPASS_W11_CHK
IF %sel%==3 GOTO START_DISKPART
IF %sel%==4 GOTO CHKDSK_VOL
IF %sel%==5 GOTO DISM_CAPTURE_IMAGE_CAPDIR
IF %sel%==6 GOTO INIT_NET
IF %sel%==7 GOTO IPCONFIG
IF %sel%==8 GOTO CONFIG_NETWORK_NIC
IF %sel%==9 GOTO FIREWALL_ENABLE
IF %sel%==10 GOTO FIREWALL_DISABLE
IF %sel%==11 GOTO REBOOT
IF %sel%==12 GOTO SHUTDOWN
IF %sel%==13 GOTO EXIT_CMD
IF %sel%==v GOTO VERSION
GOTO MAIN_MENU

:INSTALL_WIN_MOUNTSMB
CLS
ECHO ===== Install Windows =====
ECHO:
ECHO Mount SMB share to extracted Windows installers. 
ECHO Enter the path to the SMB share. Such as \\10.0.1.11\WinInstall
ECHO:
SET smbshare=
SET /P smbshare=Enter SMB path (Empty to cancel): 
IF [%smbshare%]==[] GOTO INSTALL_WIN_EXIT
ECHO You'll be prompted for authorization below
net use Z: %smbshare%
GOTO INSTALL_WIN_VER

:INSTALL_WIN_VER
CLS
SET folderCnt=0
FOR /f "eol=: delims=" %%F IN ('dir /b /ad Z:\') DO (
  SET /a folderCnt+=1
  SET "folder!folderCnt!=%%F"
)
ECHO ===== Install Windows =====
ECHO:
ECHO Select the installer to run.
ECHO:
FOR /l %%N IN (1 1 %folderCnt%) DO ECHO     %%N) !folder%%N!
ECHO:
SET sel=
SET /P sel=Enter number to select an option (Anything else to cancel): 
IF "!folder%sel%!"=="" GOTO INSTALL_WIN_EXIT
SET setup=Z:\!folder%sel%!\setup.exe
GOTO INSTALL_WIN_CONFIRM

:INSTALL_WIN_CONFIRM
CLS
ECHO ===== Install Windows =====
ECHO:
ECHO The following Windows installer will be started:
ECHO %setup%
ECHO:
ECHO You can now add additional arguments to the command now.
ECHO:
SET addargs=+
SET /P addargs=Enter additional arguments (Empty if not required, - to cancel): 
IF %addargs%==- GOTO INSTALL_WIN_EXIT
IF %addargs%==+ SET addargs=
GOTO INSTALL_WIN_EXEC

:INSTALL_WIN_EXEC
CLS
ECHO ===== Install Windows =====
ECHO:
ECHO Execute Windows Installer:
ECHO %setup% %addargs%
ECHO:
"%setup%" %addargs%
PAUSE
GOTO INSTALL_WIN_EXIT

:INSTALL_WIN_EXIT
net delete Z:
GOTO MAIN_MENU

:BYPASS_W11_CHK
CLS
ECHO ===== Bypass Windows 11 Requirement Check =====
ECHO:
REG ADD HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1
REG ADD HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1
REG ADD HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1
REG ADD HKLM\SYSTEM\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 1
ECHO:
PAUSE
GOTO MAIN_MENU

:START_DISKPART
CLS
ECHO ===== DiskPart =====
ECHO:
ECHO Starting DiskPart
diskpart.exe
GOTO MAIN_MENU

:CHKDSK_VOL
CLS
ECHO ===== Check Disk Utility =====
ECHO:
ECHO Enter the volume to check. Such as D:
ECHO:
ECHO Driver letter assignments:
ECHO lis vol > diskpart_lisvol.txt
diskpart /s diskpart_lisvol.txt
DEL diskpart_lisvol.txt
ECHO:
SET vol=
SET /P vol=Enter volume (Empty to cancel): 
IF [%vol%]==[] GOTO MAIN_MENU
GOTO CHKDSK_FIX

:CHKDSK_FIX
CLS
ECHO ===== Check Disk Utility =====
ECHO:
ECHO Should chkdsk fix the error on disk?
ECHO:
ECHO    1) Yes (/F)
ECHO    2) No
ECHO:
SET sel=N
SET /P sel=Enter number to select an option (Anything else to cancel): 
SET fix=
IF %sel%==1 SET fix=Y
IF %sel%==2 SET fix=N
IF [%fix%]==[] GOTO MAIN_MENU
IF %fix%==Y SET fix=/F
IF %fix%==N SET fix=
GOTO CHKDSK_CONFIRM

:CHKDSK_CONFIRM
CLS
ECHO ===== Check Disk Utility =====
ECHO:
ECHO The following chkdsk command will be executed:
ECHO chkdsk %fix% %vol%
ECHO:
ECHO You can now add additional arguments to the command now.
ECHO:
SET addargs=+
SET /P addargs=Enter additional arguments (Empty if not required, - to cancel): 
IF %addargs%==- GOTO MAIN_MENU
IF %addargs%==+ SET addargs=
GOTO CHKDSK_EXEC

:CHKDSK_EXEC
CLS
ECHO ===== Check Disk Utility =====
ECHO:
ECHO Execute chkdsk:
ECHO chkdsk %fix% %addargs% %vol%
ECHO:
chkdsk %fix% %addargs% %vol%
PAUSE
GOTO MAIN_MENU

:DISM_CAPTURE_IMAGE_CAPDIR
CLS
ECHO ===== DISM Capture Image =====
ECHO:
ECHO Enter the directory to capture. Such as D:\
ECHO:
ECHO Driver letter assignments:
ECHO lis vol > diskpart_lisvol.txt
diskpart /s diskpart_lisvol.txt
DEL diskpart_lisvol.txt
ECHO:
SET capdir=
SET /P capdir=Enter directory (Empty to cancel): 
IF [%capdir%]==[] GOTO DISM_CAPTURE_EXIT
GOTO DISM_CAPTURE_IMAGE_MOUNTSMB

:DISM_CAPTURE_IMAGE_MOUNTSMB
CLS
ECHO ===== DISM Capture Image =====
ECHO:
ECHO Mount the SMB share to save the captured image. 
ECHO Enter the path to the SMB share. Such as \\10.0.1.11\Share
ECHO:
SET smbshare=
SET /P smbshare=Enter SMB path (Empty to cancel): 
IF [%smbshare%]==[] GOTO DISM_CAPTURE_EXIT
ECHO You'll be prompted for authorization below
net use Y: %smbshare%
GOTO DISM_CAPTURE_IMAGE_IMAGEFILE

:DISM_CAPTURE_IMAGE_IMAGEFILE
CLS
ECHO ===== DISM Capture Image =====
ECHO:
ECHO Enter the location to save the captured image.
ECHO Do not include drive letters to the target location.
ECHO:
SET imgfile=
SET /P imgfile=Enter image file (Empty to cancel): 
IF [%imgfile%]==[] GOTO DISM_CAPTURE_EXIT
SET imgfile=Y:\%imgfile%
GOTO DISM_CAPTURE_IMAGE_NAME

:DISM_CAPTURE_IMAGE_NAME
CLS
ECHO ===== DISM Capture Image =====
ECHO:
ECHO Enter the name of the image.
ECHO:
SET /P name=Enter image name: 
GOTO DISM_CAPTURE_IMAGE_COMPRESS

:DISM_CAPTURE_IMAGE_COMPRESS
CLS
ECHO ===== DISM Capture Image =====
ECHO:
ECHO Select the compression level for the image.
ECHO:
ECHO    1) Maximum
ECHO    2) Fast
ECHO    3) None
ECHO:
SET sel=N
SET /P sel=Enter number to select an option (Anything else to cancel): 
SET compress=
IF %sel%==1 SET compress=max
IF %sel%==2 SET compress=fast
IF %sel%==3 SET compress=none
IF [%compress%]==[] GOTO DISM_CAPTURE_EXIT
GOTO DISM_CAPTURE_CONFIRM

:DISM_CAPTURE_CONFIRM
CLS
ECHO ===== DISM Capture Image =====
ECHO:
ECHO The following DISM command will be executed:
ECHO Dism /Capture-Image /Compress:%compress% /ImageFile:"%imgfile%" /CaptureDir:%capdir% /Name:"%name%"
ECHO:
ECHO You can now add additional arguments to the command now.
ECHO:
SET addargs=+
SET /P addargs=Enter additional arguments (Empty if not required, - to cancel):
IF %addargs%==- GOTO DISM_CAPTURE_EXIT
IF %addargs%==+ SET addargs=
GOTO DISM_CAPTURE_EXEC

:DISM_CAPTURE_EXEC
CLS
ECHO ===== DISM Capture Image =====
ECHO:
ECHO Execute DISM:
ECHO Dism /Capture-Image /Compress:%compress% /ImageFile:"%imgfile%" /CaptureDir:%capdir% /Name:"%name%" %addargs%
ECHO:
Dism /Capture-Image /Compress:%compress% /ImageFile:"%imgfile%" /CaptureDir:%capdir% /Name:"%name%" %addargs%
PAUSE
GOTO DISM_CAPTURE_EXIT

:DISM_CAPTURE_EXIT
net use /delete Y:
GOTO MAIN_MENU

:INIT_NET
CLS
ECHO ===== Initialize Network =====
ECHO:
Wpeutil InitializeNetwork /NoWait
GOTO MAIN_MENU

:IPCONFIG
CLS
ECHO ===== Network Information =====
ECHO:
ipconfig /all
PAUSE
GOTO MAIN_MENU

:CONFIG_NETWORK_NIC
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Enter the name of the network interface to configure. Such as Ethernet0.
ECHO:
ECHO Interfaces:
netsh int show int
ECHO:
SET nic=
SET /P nic=Enter the name of the interface (Blank else to cancel): 
IF [%nic%]==[] GOTO MAIN_MENU
GOTO CONFIG_NETWORK_IP

:CONFIG_NETWORK_IP
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Enter the IP address for interface %nic%.
ECHO Leave blank for DHCP.
ECHO:
SET ip=
SET /P ip=Enter IP address (Blank for DHCP): 
IF [%ip%]==[] GOTO CONFIG_NETWORK_DHCP_EXEC
GOTO CONFIG_NETWORK_SUBNET

:CONFIG_NETWORK_SUBNET
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Enter the subnet mask for interface %nic%.
ECHO:
SET mask=
SET /P mask=Enter subnet mask (Anything else to cancel): 
IF [%mask%]==[] GOTO MAIN_MENU
GOTO CONFIG_NETWORK_GW

:CONFIG_NETWORK_GW
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Enter the default gateway for interface %nic%.
ECHO:
SET gw=
SET /P gw=Enter default gateway (Anything else to cancel): 
IF [%gw%]==[] GOTO MAIN_MENU
GOTO CONFIG_NETWORK_STATIC_EXEC

:CONFIG_NETWORK_STATIC_EXEC
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Setting static IP address.
netsh int ip set address "%nic%" static %ip% %mask% %gw%
GOTO CONFIG_NETWORK_DNS

:CONFIG_NETWORK_DHCP_EXEC
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Setting DHCP.
netsh int ip set address "%nic%" dhcp
GOTO CONFIG_NETWORK_DNS

:CONFIG_NETWORK_DNS
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Enter DNS server address.
ECHO Leave blank for DHCP/unset.
ECHO:
SET dns=
SET /P dns=Enter DNS server address (Blank for DHCP/unset): 
IF [%dns%]==[] GOTO CONFIG_NETWORK_DNS_DHCP_EXEC
GOTO CONFIG_NETWORK_DNS_MAN_EXEC

:CONFIG_NETWORK_DNS_DHCP_EXEC
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Setting DHCP DNS.
netsh int ip set dnsservers "%nic%" dhcp
GOTO MAIN_MENU

:CONFIG_NETWORK_DNS_MAN_EXEC
CLS
ECHO ===== Configure Network Interface =====
ECHO:
ECHO Setting manual DNS.
netsh int ip set dnsservers "%nic%" static %dns% primary
GOTO MAIN_MENU

:FIREWALL_ENABLE
CLS
ECHO ===== Enable Firewall =====
ECHO:
Wpeutil EnableFirewall
PAUSE
GOTO MAIN_MENU

:FIREWALL_DISABLE
CLS
ECHO ===== Disable Firewall =====
ECHO:
Wpeutil DisableFirewall
PAUSE
GOTO MAIN_MENU

:REBOOT
CLS
ECHO ===== Reboot =====
ECHO:
Wpeutil Reboot
GOTO EXIT_CMD

:SHUTDOWN
CLS
ECHO ===== Shutdown =====
ECHO:
Wpeutil Shutdown
GOTO EXIT_CMD

:EXIT_CMD
ECHO:
ECHO Quitting to command line.
ECHO You can open Windows PE Tool again by running "winpetool"
EXIT /B

:VERSION
CLS
ECHO ===== Version =====
ECHO:
ECHO Windows PE Tool v1.0 - 20220626
ECHO Made with <3 by JellyKuo
ECHO:
PAUSE
GOTO MAIN_MENU
