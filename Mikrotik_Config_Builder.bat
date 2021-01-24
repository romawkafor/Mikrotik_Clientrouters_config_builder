@echo off
chcp 65001
color 4F 
echo "IP Address","Port","Remote Channel","CAM NAME","Manufacturer","Username","Password">>%UserProfile%\Desktop\GV.csv
echo "IP Address","Port","Remote Channel","CAM NAME","Manufacturer","Username","Password">>%UserProfile%\Desktop\UP.csv
echo "IP Address","Port","Remote Channel","CAM NAME","Manufacturer","Username","Password">>%UserProfile%\Desktop\SC1.csv
echo "IP Address","Port","Remote Channel","CAM NAME","Manufacturer","Username","Password">>%UserProfile%\Desktop\SC2.csv
set DahuaDescript="Примечание: IP ссылается на IP-адрес,доменное имя, или RTSP-адрес. Значение порта  должно быть в пределах от 1 до 65535. Номер канала должен быть больше 1. Парматер IPC - введите 1. Производитель включает в себя:Dahua,Panasonic,Sony,Dynacolor,Samsung,AXIS,Sanyo,Pelco,Arecont,Onvif,Xunmei,LG,Watchnet,Canon,PSIA,RTSP,AirLive,JVC"
rem Задаю довжину паролю.
set PassLength=14
Rem Нижче генератор паролю
:START
cls
setlocal
set "set[1]=ABCDEFGHIJKLMNOPQRSTUVWXYZ"  &  set "len[1]=26"  &  set "num[1]=0"
set "set[2]=abcdefghijklmnopqrstuvwxyz"  &  set "len[2]=26"  &  set "num[2]=0"
set "set[3]=0123456789"                  &  set "len[3]=10"  &  set "num[3]=0"
setlocal EnableDelayedExpansion

rem Create a list of 10 random numbers between 1 and 4;
rem the condition is that it must be at least one digit of each one

rem Initialize the list with 10 numbers
set "list="
for /L %%i in (1,1,%PassLength%) do (
   set /A rnd=!random! %% 3 + 1
   set "list=!list!!rnd! "
   set /A num[!rnd!]+=1
)

:checkList
rem Check that all digits appear in the list at least one time
set /A mul=num[1]*num[2]*num[3]
if %mul% neq 0 goto listOK

   rem Change elements in the list until fulfill the condition

   rem Remove first element from list
   set /A num[%list:~0,1%]-=1
   set "list=%list:~2%"

   rem Insert new element at end of list
   set /A rnd=%random% %% 4 + 1
   set "list=%list%%rnd% "
   set /A num[%rnd%]+=1

goto checkList
:listOK

rem Generate the password with the sets indicated by the numbers in the list
set "RndAlphaNum="
for %%a in (%list%) do (
   set /A rnd=!random! %% len[%%a]
   for %%r in (!rnd!) do set "RndAlphaNum=!RndAlphaNum!!set[%%a]:~%%r,1!"
)
rem кінець генератора паролю


rem Задаю початкові змінні
set L2TPServer=vpn.company.com
set PassToRouter=1q2w3e4r5t
rem Запитую про змінні
set /p TempNameShop=Введіть ім'я магазину латиницею. Приклад: Kyiv_md_Nezalezhnosti_1 :
set /p ShotNameShop=Введіть коротке ім'я магазину латиницею. Приклад: Kyiv_md_Nezal_1:
set /p CurrilicName=Введіть ім'я магазину Кирилицею. Приклад: Київ Незалежності 1 :
set /p SubnetSufix=Введіть номер підмережі. 10.0.XXX.0 :
set L2TPLogin=%TempNameShop%
set L2TPPass=%RndAlphaNum%

rem Створюю Адресу тунелю (Адреса мережі + 1)
set /A AltSubnetSufix=%SubnetSufix%
set /A AltSubnetSufix=%AltSubnetSufix%+1
rem Генерую скрипт
echo user set admin password=%PassToRouter%>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /system identity set name="%TempNameShop%">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /system ntp client set enabled=yes primary-ntp=62.149.0.30 secondary-ntp=129.6.15.28>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /system routerboard settings set auto-upgrade=yes>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /system routerboard settings set force-backup-booter=yes>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge add name=WORK_LAN>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge add name=INTERNET_LAN>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip dhcp-client add interface=ether1 add-default-route=yes use-peer-dns=yes use-peer-ntp=no disabled=no comment="Defoult from Roman Pereviznyk">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip address add address=10.0.%SubnetSufix%.1/24 interface=WORK_LAN network=10.0.%SubnetSufix%.0>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip address add address=192.168.10.1/24 interface=INTERNET_LAN network=192.168.10.0>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip dns set allow-remote-requests=yes servers=8.8.8.8,194.44.214.214,208.67.222.222,8.8.4.4,194.44.214.40,208.67.220.220>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip dhcp-server network add address=10.0.%SubnetSufix%.0/24 gateway=10.0.%SubnetSufix%.1 dns-server=10.0.%SubnetSufix%.1,8.8.8.8>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=192.168.10.1,8.8.8.8>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip pool add name=WORK_LAN_POOL ranges=10.0.%SubnetSufix%.100-10.0.%SubnetSufix%.200>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip pool add name=INTERNET_LAN_POOL ranges=192.168.10.100-192.168.10.200>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip dhcp-server add name=DHCP_WORK interface=WORK_LAN lease-time=08:00:00 address-pool=WORK_LAN_POOL authoritative=yes bootp-support=static disabled=no>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip dhcp-server add name=DHCP_INTERNET interface=INTERNET_LAN lease-time=08:00:00 address-pool=INTERNET_LAN_POOL authoritative=yes bootp-support=static disabled=no>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface l2tp-client add name="l2tp_to_Office" connect-to=%L2TPServer% user="%L2TPLogin%@vpn.company.com" password="%L2TPPass%" allow=mschap2 disabled=no>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip route add dst-address=10.0.0.0/24 gateway=l2tp_to_Office type=unicast distance=1 scope=30 target-scope=10 comment="Route to General Office">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip route rule add src-address=192.168.10.0/24 dst-address=10.0.0.0/24 action=unreachable comment="Disable INTERNET_LAN to General Office">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip route rule add src-address=10.0.%SubnetSufix%.0/24 dst-address=192.168.10.0/24 action=unreachable comment="Disable WORK_LAN to INTERNET_LAN">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip route rule add src-address=192.168.10.0/24 dst-address=10.0.%SubnetSufix%.0/24 action=unreachable comment="Disable INTERNET_LAN to WORK_LAN">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall nat add out-interface=ether1 chain=srcnat action=masquerade comment="Defoult from Roman Pereviznyk">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall nat add out-interface=l2tp_to_Office chain=srcnat action=masquerade disabled=yes comment=NAT_to_Office>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall filter add chain=input action=accept protocol=icmp log=no comment="accept ICMP">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall filter add chain=input action=accept connection-state=established,related log=no comment="accept established,related">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall filter add chain=input action=drop in-interface=ether1 log=no comment="drop all from WAN">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall filter add chain=forward action=fasttrack-connection connection-state=established,related log=no comment=fasttrack>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall filter add chain=forward action=accept connection-state=established,related log=no comment="accept established,related">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall filter add chain=forward action=drop connection-state=invalid log=no comment="drop invalid">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip firewall filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface=ether1 log=no comment="drop all from WAN not DSTNATed">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /system package update set channel=long-term>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface eoip add disabled=yes name="EOIP_to_Office" tunnel-id=%SubnetSufix% local-address=172.16.0.%AltSubnetSufix% remote-address=172.16.0.1>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface list add exclude=dynamic name=discover>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface list member add interface=WORK_LAN list=discover>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface list member add interface=EOIP_to_Office list=discover>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip neighbor discovery-settings set discover-interface-list=discover>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /tool mac-server set allowed-interface-list=discover>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /tool mac-server mac-winbox set allowed-interface-list=discover>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface wireless security-profiles add name=SECURITY_INTERNET_AP authentication-types=wpa2-psk unicast-ciphers=aes-ccm group-ciphers=aes-ccm wpa2-pre-shared-key=freeinternet mode=dynamic-keys>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface wireless security-profiles add name=SECURITY_WORK_AP authentication-types=wpa2-psk unicast-ciphers=aes-ccm group-ciphers=aes-ccm wpa2-pre-shared-key=Reelystrongpassword mode=dynamic-keys>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface wireless set wlan1 disabled=no mode=ap-bridge band=2ghz-b/g/n channel-width=20/40mhz-Ce frequency=2422 ssid=WORK_NETWORK security-profile=SECURITY_WORK_AP wireless-protocol=unspecified wmm-support=enabled country=ukraine default-authentication=yes default-forwarding=yes>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface wireless add master-interface=wlan1 mode=ap-bridge ssid=INTERNET disabled=no security-profile=SECURITY_INTERNET_AP;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo :delay 10;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge port add interface=wlan1 bridge=WORK_LAN;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo :delay 5;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge port add interface=wlan2 bridge=INTERNET_LAN;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo :delay 2;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip service disable numbers=0,1,5,7;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip service set ssh address=10.0.%SubnetSufix%.0/24,172.16.0.0/24;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip service set winbox address=10.0.%SubnetSufix%.0/24,172.16.0.0/24;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ip service set www address=10.0.%SubnetSufix%.0/24,172.16.0.0/24;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /tool bandwidth-server set enabled=no;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /system script add name=reboot source="/system reboot";>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /system script add name=backup2ftp source=":local name value=[/system identity get name]; /system backup save name=\$name; /export file=\$name; /tool fetch address=10.0.0.9 user=MicrotikBackupUser password=mWvfJyxGFzia5Nzu mode=ftp dst-path=(\"/rsc/\".\$name.\".rsc\") src-path=(\$name.\".rsc\") upload=yes; /tool fetch address=10.0.0.9 user=MicrotikBackupUser password=mWvfJyxGFzia5Nzu mode=ftp dst-path=(\"/backup/\".\$name.\".backup\") src-path=(\$name.\".backup\") upload=yes; /file remove (\$name.\".backup\"); /file remove (\$name.\".rsc\");">>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo :delay 5;>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge port add interface=ether2 bridge=WORK_LAN>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge port add interface=ether3 bridge=WORK_LAN>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge port add interface=ether4 bridge=WORK_LAN>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface bridge port add interface=ether5 bridge=WORK_LAN>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /interface ethernet poe set ether5 poe-out=off>>%UserProfile%\Desktop\MTSCRIPT-%TempNameShop%.txt
echo /ppp secret add name="%L2TPLogin%@vpn.company.com" password="%L2TPPass%" service=l2tp profile=L2TP local-address=172.16.0.1 remote-address=172.16.0.%AltSubnetSufix%>>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
echo /interface l2tp-server add name="Tunnel to %L2TPLogin%" user=%L2TPLogin%@vpn.company.com>>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
echo /interface eoip add name="EOIP tunnel to %TempNameShop%" tunnel-id=%SubnetSufix% local-address=172.16.0.1 remote-address=172.16.0.%AltSubnetSufix%>>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
echo /ip route add dst-address=10.0.%SubnetSufix%.0/24 gateway=172.16.0.%AltSubnetSufix% pref-src=172.16.0.1 comment="Route to %L2TPLogin%">>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
echo /ip dns static add name=gv.%ShotNameShop%.cctv address=10.0.%SubnetSufix%.10>>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
echo /ip dns static add name=up.%ShotNameShop%.cctv address=10.0.%SubnetSufix%.20>>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
echo /ip dns static add name=sc1.%ShotNameShop%.cctv address=10.0.%SubnetSufix%.30>>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
echo /ip dns static add name=sc2.%ShotNameShop%.cctv address=10.0.%SubnetSufix%.40>>%UserProfile%\Desktop\Core_MT_SCRIPT.txt
chcp 1251
echo "gv.%ShotNameShop%.cctv","37777","1","%CurrilicName%","Dahua","admin","1Q2W3E4R5T6Y">>%UserProfile%\Desktop\GV.csv
echo "up.%ShotNameShop%.cctv","37777","1","%CurrilicName%","Dahua","admin","1Q2W3E4R5T6Y">>%UserProfile%\Desktop\UP.csv
echo "sc1.%ShotNameShop%.cctv","37777","1","%CurrilicName%","Dahua","admin","1Q2W3E4R5T6Y">>%UserProfile%\Desktop\SC1.csv
echo "sc2.%ShotNameShop%.cctv","37777","1","%CurrilicName%","Dahua","admin","1Q2W3E4R5T6Y">>%UserProfile%\Desktop\SC2.csv
chcp 65001
cls
echo Конфігурація для клієнта та сервера успішно створена. Файли знаходяться на робочому столі.
echo Вам необхідно створити ще Користувачів на FTP та відповідні папки з ім'ям магазину:
echo Login FTP: %L2TPLogin% ; FTP Password: %L2TPPass%
echo.
echo.
echo Також не забудьте дописати скрипт на сервері який обробляє і складає фото на FTP.
CHOICE /N /C yn /M "Створити ще одну конфігурацію? Y - так, N - ні"
if %errorlevel%==1 GoTO START
if %errorlevel%==2 GoTo Exit
:Exit
chcp 1251
echo %DahuaDescript%>>%UserProfile%\Desktop\GV.csv
echo %DahuaDescript%>>%UserProfile%\Desktop\UP.csv
echo %DahuaDescript%>>%UserProfile%\Desktop\SC1.csv
echo %DahuaDescript%>>%UserProfile%\Desktop\SC2.csv
Exit

