#!/bin/bash

# التأكد من تشغيل السكريبت بصلاحيات root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# مدخلات الهدف ومعلومات الشبكة
read -p "Enter the target network (e.g., 192.168.1.0/24): " TARGET
read -p "Enter a domain name for DNS enumeration (e.g., example.com): " DOMAIN
read -p "Enter a target URL or IP for Nikto (e.g., http://192.168.1.1): " NIKTO_TARGET

# ملف التقرير النهائي
REPORT_DIR="results"
OUTPUT_FILE="${REPORT_DIR}/final_report.html"
mkdir -p $REPORT_DIR

echo "<html><body><h1>Network Scan Report</h1>" > $OUTPUT_FILE

# 1. فحص Nmap
echo "[*] Running Nmap scan..."
mkdir -p ${REPORT_DIR}/nmap
nmap -A -T4 -oN ${REPORT_DIR}/nmap/nmap_scan.txt $TARGET
echo "<h2>Nmap Results</h2><pre>" >> $OUTPUT_FILE
cat ${REPORT_DIR}/nmap/nmap_scan.txt >> $OUTPUT_FILE
echo "</pre>" >> $OUTPUT_FILE

# 2. فحص Enum4linux
echo "[*] Running enum4linux..."
mkdir -p ${REPORT_DIR}/enum4linux
enum4linux -a $TARGET > ${REPORT_DIR}/enum4linux/enum4linux_scan.txt
echo "<h2>Enum4linux Results</h2><pre>" >> $OUTPUT_FILE
cat ${REPORT_DIR}/enum4linux/enum4linux_scan.txt >> $OUTPUT_FILE
echo "</pre>" >> $OUTPUT_FILE

# 3. فحص DNS
echo "[*] Running DNS enumeration..."
mkdir -p ${REPORT_DIR}/dns
echo "Forward Lookup:" > ${REPORT_DIR}/dns/dns_scan.txt
host -t A $DOMAIN >> ${REPORT_DIR}/dns/dns_scan.txt
echo "Reverse Lookup:" >> ${REPORT_DIR}/dns/dns_scan.txt
for ip in $(nmap -sn $TARGET | grep "Nmap scan report" | awk '{print $5}'); do
    host $ip >> ${REPORT_DIR}/dns/dns_scan.txt
done
echo "DNS Zone Transfer Attempt:" >> ${REPORT_DIR}/dns/dns_scan.txt
for ns in $(dig ns $DOMAIN +short); do
    dig axfr $DOMAIN @$ns >> ${REPORT_DIR}/dns/dns_scan.txt
done
echo "<h2>DNS Enumeration Results</h2><pre>" >> $OUTPUT_FILE
cat ${REPORT_DIR}/dns/dns_scan.txt >> $OUTPUT_FILE
echo "</pre>" >> $OUTPUT_FILE

# 4. فحص Nikto
echo "[*] Running Nikto scan..."
mkdir -p ${REPORT_DIR}/nikto
nikto -h $NIKTO_TARGET -output ${REPORT_DIR}/nikto/nikto_scan.txt
echo "<h2>Nikto Results</h2><pre>" >> $OUTPUT_FILE
cat ${REPORT_DIR}/nikto/nikto_scan.txt >> $OUTPUT_FILE
echo "</pre>" >> $OUTPUT_FILE

# 5. فحص Netcat
echo "[*] Running Netcat port tests..."
mkdir -p ${REPORT_DIR}/netcat
read -p "Enter an IP address for Netcat tests: " NETCAT_TARGET
for port in 21 22 23 25 80 443; do
    echo "Testing port $port on $NETCAT_TARGET" >> ${REPORT_DIR}/netcat/netcat_scan.txt
    echo "" | nc -v -w 1 $NETCAT_TARGET $port >> ${REPORT_DIR}/netcat/netcat_scan.txt 2>&1
done
echo "<h2>Netcat Results</h2><pre>" >> $OUTPUT_FILE
cat ${REPORT_DIR}/netcat/netcat_scan.txt >> $OUTPUT_FILE
echo "</pre>" >> $OUTPUT_FILE

# 6. فحص Masscan
echo "[*] Running Masscan for fast port scanning..."
mkdir -p ${REPORT_DIR}/masscan
masscan $TARGET -p1-65535 --rate=1000 -oX ${REPORT_DIR}/masscan/masscan_results.xml
echo "<h2>Masscan Results</h2><pre>" >> $OUTPUT_FILE
cat ${REPORT_DIR}/masscan/masscan_results.xml >> $OUTPUT_FILE
echo "</pre>" >> $OUTPUT_FILE

# 7. فحص Hydra
echo "[*] Running Hydra password brute-force test..."
mkdir -p ${REPORT_DIR}/hydra
hydra -L usernames.txt -P passwords.txt ssh://$NETCAT_TARGET > ${REPORT_DIR}/hydra/hydra_results.txt
echo "<h2>Hydra Results</h2><pre>" >> $OUTPUT_FILE
cat ${REPORT_DIR}/hydra/hydra_results.txt >> $OUTPUT_FILE
echo "</pre>" >> $OUTPUT_FILE

# إنهاء التقرير
echo "</body></html>" >> $OUTPUT_FILE
echo "Scan completed. Final report saved to $OUTPUT_FILE."
