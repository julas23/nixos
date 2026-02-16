# Security Profile - OSINT/SOCMINT/PenTest Tools

## Overview

This module provides a comprehensive toolkit for:
- **OSINT** (Open Source Intelligence)
- **SOCMINT** (Social Media Intelligence)
- **Network Sniffing & Analysis**
- **Brute Force & Password Cracking**
- **Penetration Testing**
- **Vulnerability Scanning**
- **Privacy & Anonymity**
- **Forensics & Reverse Engineering**

## Installation

Add to your `/etc/nixos/configuration.nix`:

```nix
imports = [
  ./modules/profiles/security.nix
];
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Tool Categories

### 1. OSINT (Open Source Intelligence)

**Web & Domain Intelligence:**
- `theharvester` - Email, subdomain, and name harvesting
- `recon-ng` - Web reconnaissance framework
- `spiderfoot` - OSINT automation tool
- `metagoofil` - Metadata extraction from public documents
- `photon` - Fast web crawler for OSINT
- `whatweb` - Web scanner and fingerprinting
- `wafw00f` - Web Application Firewall detection

**DNS & Subdomain Enumeration:**
- `dnsrecon` - DNS enumeration and reconnaissance
- `fierce` - DNS reconnaissance tool
- `subfinder` - Subdomain discovery tool
- `amass` - In-depth attack surface mapping
- `assetfinder` - Find domains and subdomains

**Social Media & People Search:**
- `sherlock` - Username search across social networks
- `googler` - Google search from terminal

### 2. SOCMINT (Social Media Intelligence)

- `youtube-dl` / `yt-dlp` - Download videos for analysis
- Additional Python-based tools can be installed via pip

### 3. Network Sniffing & Analysis

**Packet Capture:**
- `wireshark` - Network protocol analyzer (GUI)
- `tshark` - Wireshark CLI
- `tcpdump` - Packet analyzer
- `ettercap` - Network sniffer/interceptor
- `bettercap` - Network attack and monitoring framework

**Wireless:**
- `aircrack-ng` - WiFi security auditing suite
- `kismet` - Wireless network detector and sniffer
- `wifite2` - Automated wireless attack tool

**Network Scanning:**
- `nmap` - Network mapper and security scanner
- `masscan` - Fast port scanner
- `zmap` - Fast network scanner
- `rustscan` - Ultra-fast port scanner

### 4. Brute Force & Password Cracking

**Network Service Brute Force:**
- `hydra` - Network logon cracker
- `medusa` - Parallel network login brute-forcer
- `ncrack` - Network authentication cracking
- `patator` - Multi-purpose brute-forcer

**Password Cracking:**
- `john` - John the Ripper password cracker
- `hashcat` - Advanced password recovery
- `crunch` - Wordlist generator
- `cewl` - Custom wordlist generator

### 5. Penetration Testing

**Frameworks:**
- `metasploit` - Penetration testing framework
- `zaproxy` - OWASP ZAP web app scanner

**Web Application Testing:**
- `sqlmap` - SQL injection tool
- `nikto` - Web server scanner
- `wpscan` - WordPress security scanner
- `nuclei` - Vulnerability scanner
- `ffuf` - Fast web fuzzer
- `gobuster` - Directory/file brute-forcer
- `dirb` - Web content scanner
- `wfuzz` - Web application fuzzer

**Exploitation:**
- `exploitdb` / `searchsploit` - Exploit database

### 6. Privacy & Anonymity

**Tor & Proxies:**
- `tor` - The Onion Router
- `tor-browser` - Tor Browser Bundle
- `proxychains-ng` - Proxy chains for anonymity
- `torsocks` - Transparent Tor proxy

**VPN:**
- `openvpn` - VPN client
- `wireguard-tools` - WireGuard VPN tools

### 7. Reconnaissance & Enumeration

- `enum4linux` - SMB enumeration tool
- `smbmap` - SMB share enumeration
- `nbtscan` - NetBIOS scanner
- `snmpwalk` - SNMP enumeration
- `onesixtyone` - SNMP scanner

### 8. Post-Exploitation

- `pwncat` - Post-exploitation framework
- `crackmapexec` - Post-exploitation tool
- `evil-winrm` - WinRM shell for pentesting

### 9. Forensics & Analysis

**File Analysis:**
- `binwalk` - Firmware analysis tool
- `foremost` - File carving tool
- `volatility3` - Memory forensics framework

**Network Forensics:**
- `networkminer` - Network forensic analysis tool

**Steganography:**
- `steghide` - Steganography tool
- `stegseek` - Steghide cracker

### 10. Reverse Engineering

- `radare2` - Reverse engineering framework
- `ghidra` - NSA's reverse engineering tool

### 11. Utilities

**Network:**
- `netcat-gnu` - Network utility
- `socat` - Multipurpose relay
- `hping` - TCP/IP packet assembler/analyzer

**SSL/TLS:**
- `sslscan` - SSL/TLS scanner
- `testssl` - SSL/TLS testing

**Python Security Libraries:**
- `scapy` - Packet manipulation
- `pwntools` - CTF framework
- `requests` - HTTP library
- `beautifulsoup4` - Web scraping

## Usage Examples

### OSINT Reconnaissance

```bash
# Find subdomains
subfinder -d target.com

# Harvest emails and subdomains
theharvester -d target.com -b all

# OSINT automation
spiderfoot -s target.com

# Username search across social networks
sherlock username123
```

### Network Scanning

```bash
# Fast port scan
rustscan -a target.com

# Detailed nmap scan
nmap -sV -sC -p- target.com

# Massive fast scan
masscan -p1-65535 10.0.0.0/8 --rate=10000
```

### Web Application Testing

```bash
# Directory brute force
gobuster dir -u https://target.com -w /path/to/wordlist.txt

# SQL injection testing
sqlmap -u "https://target.com/page?id=1" --batch

# Web vulnerability scanner
nikto -h https://target.com

# Fast fuzzing
ffuf -u https://target.com/FUZZ -w wordlist.txt
```

### Password Cracking

```bash
# Brute force SSH
hydra -l admin -P passwords.txt ssh://target.com

# Crack password hashes
john --wordlist=/path/to/wordlist.txt hashes.txt

# GPU-accelerated cracking
hashcat -m 0 -a 0 hashes.txt wordlist.txt
```

### Wireless Security

```bash
# Monitor mode
airmon-ng start wlan0

# Capture handshake
airodump-ng wlan0mon

# Crack WPA/WPA2
aircrack-ng -w wordlist.txt capture.cap
```

### Packet Capture

```bash
# Capture packets (requires root or wireshark group)
wireshark

# CLI packet capture
tshark -i eth0 -w capture.pcap

# Filter and analyze
tcpdump -i eth0 'port 80 or port 443'
```

### Anonymity

```bash
# Route through Tor
proxychains-ng firefox

# Tor browser
tor-browser

# Check Tor connection
curl --socks5 localhost:9050 https://check.torproject.org
```

## Security & Legal Warnings

⚠️ **IMPORTANT LEGAL NOTICE** ⚠️

These tools are provided for:
- **Authorized security research**
- **Penetration testing with written permission**
- **Educational purposes in controlled environments**
- **Testing your own systems**

**Unauthorized use is ILLEGAL and may result in:**
- Criminal prosecution
- Civil lawsuits
- Imprisonment
- Fines

**Always:**
1. Get written authorization before testing
2. Stay within the scope of engagement
3. Follow responsible disclosure practices
4. Respect privacy and data protection laws
5. Document all activities

**Never:**
1. Test systems without permission
2. Access data you're not authorized to see
3. Cause damage or disruption
4. Use for malicious purposes

## Additional Setup

### Metasploit Database

To use Metasploit with database support:

```bash
# Initialize database
msfdb init

# Start Metasploit
msfconsole
```

### Wordlists

Download common wordlists:

```bash
# SecLists (comprehensive)
git clone https://github.com/danielmiessler/SecLists.git ~/wordlists/seclists

# RockYou
wget https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -P ~/wordlists/
```

### Enable IP Forwarding (for MITM)

Edit `/etc/nixos/modules/profiles/security.nix`:

```nix
boot.kernel.sysctl = {
  "net.ipv4.ip_forward" = 1;  # Enable
};
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Directories Created

The module automatically creates:
- `~/osint` - OSINT investigation data
- `~/pentest` - Penetration testing reports
- `~/wordlists` - Password and fuzzing wordlists
- `~/.msf4` - Metasploit configuration

## User Groups

Your user is automatically added to:
- `wireshark` - Packet capture without root
- `dialout` - Serial device access (hardware hacking)

## Resources

### Learning
- [OSINT Framework](https://osintframework.com/)
- [HackTricks](https://book.hacktricks.xyz/)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [GTFOBins](https://gtfobins.github.io/)

### Certifications
- CEH (Certified Ethical Hacker)
- OSCP (Offensive Security Certified Professional)
- GPEN (GIAC Penetration Tester)
- eJPT (eLearnSecurity Junior Penetration Tester)

### Practice Platforms
- [HackTheBox](https://www.hackthebox.com/)
- [TryHackMe](https://tryhackme.com/)
- [PentesterLab](https://pentesterlab.com/)
- [VulnHub](https://www.vulnhub.com/)

## Troubleshooting

### Wireshark: Permission Denied

```bash
# Add user to wireshark group (already done by module)
sudo usermod -a -G wireshark $USER

# Logout and login again
```

### Metasploit: Database Connection Failed

```bash
# Reinitialize database
msfdb reinit

# Check PostgreSQL status
systemctl status postgresql
```

### Tor: Connection Failed

```bash
# Enable Tor service
sudo systemctl enable --now tor

# Check status
systemctl status tor
```

## Support

For issues or questions:
1. Check tool documentation: `man <tool>` or `<tool> --help`
2. Review tool's GitHub repository
3. Consult security forums (Reddit r/netsec, r/AskNetsec)
4. Join security Discord servers

## License

This configuration is provided as-is for educational and authorized security research purposes only.

---

**Remember: With great power comes great responsibility. Use these tools ethically and legally.**
