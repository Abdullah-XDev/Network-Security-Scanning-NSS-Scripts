#!/bin/bash

# Check if root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Define target network (customize this)
read -p "Enter the target network (e.g., 192.168.1.0/24): " TARGET

# Output file
OUTPUT_FILE="result"
echo "Saving scan results to $OUTPUT_FILE"
echo "Network Scan Results" > $OUTPUT_FILE
echo "=====================" >> $OUTPUT_FILE

# Step 1: Nmap Scan
echo "[*] Running Nmap scan..."
nmap -A -T4 -oN nmap_scan.txt $TARGET
echo -e "\n[Nmap Results]\n" >> $OUTPUT_FILE
cat nmap_scan.txt >> $OUTPUT_FILE

# Step 2: Enum4linux
echo "[*] Running enum4linux..."
enum4linux -a $TARGET > enum4linux_scan.txt
echo -e "\n[Enum4linux Results]\n" >> $OUTPUT_FILE
cat enum4linux_scan.txt >> $OUTPUT_FILE

# Step 3: DNS Enumeration
echo "[*] Running DNS Enumeration..."
read -p "Enter a domain name for DNS enumeration (e.g., example.com): " DOMAIN
echo -e "\n[DNS Enumeration Results]\n" >> $OUTPUT_FILE
echo "Forward Lookup:" >> $OUTPUT_FILE
host -t A $DOMAIN >> $OUTPUT_FILE
echo "Reverse Lookup:" >> $OUTPUT_FILE
for ip in $(nmap -sn $TARGET | grep "Nmap scan report" | awk '{print $5}'); do
    host $ip >> $OUTPUT_FILE
done
echo "DNS Zone Transfer Attempt:" >> $OUTPUT_FILE
for ns in $(dig ns $DOMAIN +short); do
    dig axfr $DOMAIN @$ns >> $OUTPUT_FILE
done

# Step 4: Nikto Web Server Scan
echo "[*] Running Nikto scan..."
read -p "Enter target URL or IP for Nikto scan (e.g., http://192.168.1.1): " NIKTO_TARGET
nikto -h $NIKTO_TARGET -output nikto_scan.txt
echo -e "\n[Nikto Results]\n" >> $OUTPUT_FILE
cat nikto_scan.txt >> $OUTPUT_FILE

# Step 5: Netcat Scans
echo "[*] Running Netcat port tests..."
read -p "Enter an IP address for Netcat tests: " NETCAT_TARGET
for port in 21 22 23 25 80 443; do
    echo "Testing port $port on $NETCAT_TARGET" >> netcat_scan.txt
    echo "" | nc -v -w 1 $NETCAT_TARGET $port >> netcat_scan.txt 2>&1
done
echo -e "\n[Netcat Results]\n" >> $OUTPUT_FILE
cat netcat_scan.txt >> $OUTPUT_FILE

# Notify user of completion
echo "Scan completed. Results saved to $OUTPUT_FILE."
