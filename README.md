Tool Name
==========
> ncp-check_1.4.sh - 리눅스 서버 정보 수집 및 진단을 위한 스크립트 <br>

Current Version
===============
> version number : 1.4
    
Description
============
> vm-checker.sh 는 리눅스 서버 (CentOS / Ubuntu) 서버의  상태 확인과 문제 진단을 위하여  리눅스 서버의 소프트웨어와 하드웨어 정보를 수집한다.<br>
> 결과물은 tar.gz 파일로 압축되어 BTS 시스템에 자동으로 ISSUE의 첨부파일로 전달된다. <br>
> linux-explorer.sh라는 tool을 참고로 하였으며  Naver Cloud Platform의 환경에 맞게  리팩토링 되고 수정되었습니다. <br>
> 해당 작업을 통해 얻을 수 있는 benefit, 목적은 <br>
>> 사용자 VM에 성능상의 이슈나 알 수 없는 오작동으로 문의가 들어왔을 때  vm-checker 실행을 통해 vm의 에러 로그와 성능 이슈를  빠르게 찾아서 해결하기 위함임.<br>
>> 예) iptables를 이용해 포트포워딩 설정을 했는데  정상동작을 하지 않는다. -> /proc/sys/net/ipv4/ip_forward 설정 정보 확인을 통해 사용자 실수 확인 <br>
     
Rerference
===========
> 오픈소스인  linux-explorer.sh 를 참고하여 제작 <br>
> License : GLPv2 <br>


스크립트 실행
==========
<pre><code>
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
</code></pre>
