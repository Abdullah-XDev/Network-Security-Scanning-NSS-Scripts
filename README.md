![Alt text](NSS.webp)

# Network Security Scanning Script

This script performs a comprehensive network security scan, including Nmap, Enum4linux, DNS enumeration, Nikto, Netcat, Masscan, and Hydra brute-force testing. It generates an HTML report containing all the results for further analysis.

## Features
- **Nmap Scan:** Performs an extensive network scan with OS detection, version detection, script scanning, and traceroute.
- **Enum4linux:** Gathers information from Windows machines using SMB.
- **DNS Enumeration:** Performs forward and reverse DNS lookups, and attempts DNS zone transfer.
- **Nikto:** Scans for web server vulnerabilities.
- **Netcat Port Scanning:** Tests common ports on a target.
- **Masscan:** Performs a fast port scan for the entire target range.
- **Hydra Brute-force Attack:** Attempts password brute-forcing using a list of usernames and passwords via SSH.

## Prerequisites
Ensure you have the following tools installed on your Debian-based system:
- Nmap
- Enum4linux
- DNS tools (e.g., host, dig)
- Nikto
- Netcat
- Masscan
- Hydra

## Install Tools (If Not Installed)
Run the following commands to install the necessary tools on a Debian-based system:

```bash
sudo apt update
sudo apt install nmap enum4linux dnsutils nikto netcat masscan hydra
```
## Usage
Steps:
1. Clone the repository:
```bash
https://github.com/Abdullah-XDev/Network-Security-Scanning-NSS-Scripts.git
```
2. Navigate to the project directory:
```bash
cd Network-Security-Scanning-NSS-Scripts
```
3. Make the script executable:
```bash
chmod +x scan_script.sh
```
4. Run the script as root:
```bash
sudo ./scan_script.sh
```
5. Follow the prompts to enter the target network, domain for DNS enumeration, and target URL/IP for the Nikto scan.

6. After the scan is completed, a report will be saved as an HTML file in the results directory.

  The final report will include:

1.Nmap results
2.Enum4linux results
3.DNS enumeration results
4.Nikto scan results
5.Netcat port testing results
6.Masscan results
7.Hydra brute-force results
## Disclaimer
This script is for educational purposes only. Unauthorized use against networks you do not own or have explicit permission to test is illegal. Use responsibly and within the confines of the law.
