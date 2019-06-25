오픈소스인  linux-explorer.sh 를 참고하여 제작
License : GLPv2
스트립트 내용 (vm-check-v2.tar.gz)
사용법 예시 :  ./ncp.checker.v4.sh -t network
   -d Target directory for explorer files 
   -t [hardware] [software] [configs] [cluster] [disks] [network] [general] [all] 
   -v Verbose output 
   -s Verify Package Installation 
   -h This help message 
   -l  light version (SUMMARY only)
** 스크립트 실행 **
[root@docker-no1 ~]# ./ncp-check_1.4.sh
[*] Starting gathering process. 
============================================= 
[*] First system check 
============================================= 
1. make sure this is a linux system 
- Linux 
2. Ensure that we are the root user 
- root user 
3. check disk usage (로그 생성에 필요한 여유 disk를 체크하여 부족하면 스크립트 실행 중지됨)
- Disk usage is 34% 
- vmcheck script can be tested 

[*] Section - Finding Commands 
=============================================
[*] Check OS type : CentOS
=============================================
[*] Section - System Package Check (해당 package가 없으면 자동 설치된다.)
============================================= 
1. traceroute found 
2. nmap found 
3. sysstat found

[*] Removing Old Directory : /opt/ncp_vmcheck 
=============================================
[*] Section - Agreement 
============================================= 
NCP Checker Version (version 1.4) 

This command will collect diagnostic and configuration information from 
this CentOS Enterprise Linux system and installed applications. 

The generated archive may contain data considered sensitive and its 
content should be reviewed by the originating organization before being 
passed to any third party.

********************************************************************** 
Are you sure to continue? (Y/N) : Y (사용자 입력정보)
********************************************************************** 

Input Key : Y 

********************************************************************** 
Personal information (고객 식별을 위해 고객의 메일 아이디를 입력하도록 요청)
********************************************************************** 

NCP Account id : jinkyu.yoon@navercorp.com (사용자 입력한 메일 아이ㄴ)
Environment ( TEST / DEV / PROD ) : PROD (사용자 입력정보)
********************************************************************** 

[*] Section - NCP Instance information 
============================================= 
[*] You have selected "ALL" 
============================================= 
[*] Section - Disk Section Checks 
============================================= 
[*] Section - Systems Log 
============================================= 
[*] Section - Networking   (네트워크 상태 및 성능 체크를 위한 테스트 실행)
============================================= 
1. Pinging default gateway to check for LAN connectivity 
2. Pinging private subnet gateway to check for LAN connectivity 
3. Pinging first DNS server in resolv.conf (10.250.255.11) to check name resolution 
4. Pinging www.google.com to check for internet connection. 
5. Pinging www.naver.com to check for internet connection. 
6. Traceroute infomation 
7. Checking for HTTP Connectivity 
8. Server Port Scanning... 

[*] Section - Performance/System 
============================================= 
1. ps information 
2. ps tree information 
3. lsof information 
4. loadavg information 
5. vmstat information 
6. mpstat information 
7. pidstat information 
8. iostat information

[*] Section - NTP 
=============================================
[*] Section - Copy etc 
=============================================
[*] Section - tar (결과를 tar 파일로 압축)
============================================= 
1. The Support File is : /opt/ncp_vmcheck/ncp_docker-no1_20190619.tar.gz (파일 naming rule : ncp_hostName_date.tar.gz)
2. The Ticket ID is : 266 (Mantis BTS에 생성되는 ticket ID)

[*] Removing Old Directory : /opt/ncp_vmcheck/ncp_docker-no1_20190619 (결과를 저장되는 경로, tar 파일은 mantisBT에 자동 업그레이드 된다.)
============================================= 
[*] Completed gathering process. 
=============================================
