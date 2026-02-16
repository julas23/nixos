# Security, OSINT, SOCMINT, and PenTest Tools Configuration
# Comprehensive toolkit for intelligence gathering, penetration testing, and security research
#
# USAGE:
# Add to configuration.nix imports:
#   ./modules/profiles/security.nix
#
# WARNING: These tools are for authorized security research and testing only.
# Unauthorized use may be illegal. Use responsibly and ethically.

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    #### 1. OSINT (Open Source Intelligence)
    
    # Web & Domain Intelligence
    theharvester              # Email, subdomain, and name harvesting
    recon-ng                  # Web reconnaissance framework
    spiderfoot                # OSINT automation tool
    metagoofil                # Metadata extraction from public documents
    photon                    # Fast web crawler for OSINT
    whatweb                   # Web scanner and fingerprinting
    wafw00f                   # Web Application Firewall detection
    
    # DNS & Subdomain Enumeration
    dnsrecon                  # DNS enumeration and reconnaissance
    fierce                    # DNS reconnaissance tool
    subfinder                 # Subdomain discovery tool
    amass                     # In-depth attack surface mapping
    assetfinder               # Find domains and subdomains
    
    # Social Media & People Search
    sherlock                  # Username search across social networks
    # twint                   # Twitter intelligence tool (Python package)
    # social-analyzer         # Social media analysis
    
    # Search Engine Tools
    googler                   # Google search from terminal
    
    #### 2. SOCMINT (Social Media Intelligence)
    
    # Instagram
    # instaloader             # Instagram downloader and OSINT tool
    
    # General Social Media
    youtube-dl                # Download videos for analysis
    yt-dlp                    # Enhanced youtube-dl fork
    
    #### 3. NETWORK SNIFFING & ANALYSIS
    
    # Packet Capture & Analysis
    wireshark                 # Network protocol analyzer (GUI)
    tshark                    # Wireshark CLI
    tcpdump                   # Packet analyzer
    ettercap                  # Network sniffer/interceptor
    bettercap                 # Network attack and monitoring framework
    
    # Wireless
    aircrack-ng               # WiFi security auditing suite
    kismet                    # Wireless network detector and sniffer
    wifite2                   # Automated wireless attack tool
    
    # Network Scanning
    masscan                   # Fast port scanner
    zmap                      # Fast network scanner
    unicornscan               # Asynchronous network scanner
    
    #### 4. BRUTE FORCE & PASSWORD CRACKING
    
    # Network Service Brute Force
    hydra                     # Network logon cracker
    medusa                    # Parallel network login brute-forcer
    ncrack                    # Network authentication cracking
    patator                   # Multi-purpose brute-forcer
    
    # Password Cracking
    john                      # John the Ripper password cracker
    hashcat                   # Advanced password recovery
    hashcat-utils             # Hashcat utilities
    
    # Password Lists & Generation
    crunch                    # Wordlist generator
    cewl                      # Custom wordlist generator
    
    #### 5. PENETRATION TESTING FRAMEWORKS
    
    # Main Frameworks
    metasploit                # Penetration testing framework
    # burpsuite              # Web application security testing (requires manual install)
    zaproxy                   # OWASP ZAP - Web app scanner
    
    # Web Application Testing
    sqlmap                    # SQL injection tool
    nikto                     # Web server scanner
    wpscan                    # WordPress security scanner
    nuclei                    # Vulnerability scanner
    ffuf                      # Fast web fuzzer
    gobuster                  # Directory/file brute-forcer
    dirb                      # Web content scanner
    wfuzz                     # Web application fuzzer
    
    # Exploitation Tools
    exploitdb                 # Exploit database
    searchsploit              # Exploit-DB search tool
    
    #### 6. VULNERABILITY SCANNING
    
    nmap                      # Network mapper and security scanner
    nmap-formatter            # Nmap output formatter
    rustscan                  # Fast port scanner (Rust-based)
    lynis                     # Security auditing tool
    
    #### 7. PRIVACY & ANONYMITY
    
    # Tor & Proxies
    tor                       # The Onion Router
    tor-browser               # Tor Browser Bundle
    proxychains-ng            # Proxy chains for anonymity
    torsocks                  # Transparent Tor proxy
    
    # VPN & Tunneling
    openvpn                   # VPN client
    wireguard-tools           # WireGuard VPN tools
    
    #### 8. RECONNAISSANCE & ENUMERATION
    
    # Network Enumeration
    enum4linux                # SMB enumeration tool
    smbmap                    # SMB share enumeration
    nbtscan                   # NetBIOS scanner
    
    # Service Enumeration
    snmpwalk                  # SNMP enumeration
    onesixtyone               # SNMP scanner
    
    #### 9. SOCIAL ENGINEERING
    
    # Phishing & SE Frameworks
    # set                     # Social Engineering Toolkit (requires manual setup)
    # gophish                 # Phishing framework
    
    #### 10. POST-EXPLOITATION
    
    # Privilege Escalation
    pwncat                    # Post-exploitation framework
    
    # Lateral Movement
    crackmapexec              # Post-exploitation tool
    evil-winrm                # WinRM shell for pentesting
    
    #### 11. FORENSICS & ANALYSIS
    
    # File Analysis
    binwalk                   # Firmware analysis tool
    foremost                  # File carving tool
    volatility3               # Memory forensics framework
    
    # Network Forensics
    networkminer              # Network forensic analysis tool
    
    # Steganography
    steghide                  # Steganography tool
    stegseek                  # Steghide cracker
    
    #### 12. REVERSE ENGINEERING
    
    radare2                   # Reverse engineering framework
    ghidra                    # NSA's reverse engineering tool
    
    #### 13. UTILITIES & HELPERS
    
    # Encoding/Decoding
    base64                    # Base64 encoding/decoding
    
    # Network Utilities
    netcat-gnu                # Network utility
    socat                     # Multipurpose relay
    hping                     # TCP/IP packet assembler/analyzer
    
    # SSL/TLS Tools
    sslscan                   # SSL/TLS scanner
    testssl                   # SSL/TLS testing
    
    # Git Tools for Security Research
    git                       # Version control
    gh                        # GitHub CLI
    
    # Python for Security Scripts
    python3Full               # Python 3 with all modules
    python3Packages.pip       # Python package installer
    python3Packages.requests  # HTTP library
    python3Packages.beautifulsoup4  # Web scraping
    python3Packages.scapy     # Packet manipulation
    python3Packages.pwntools  # CTF framework
    
    # General Utilities
    curl                      # HTTP client
    wget                      # File downloader
    jq                        # JSON processor
    yq                        # YAML processor
    ripgrep                   # Fast grep alternative
    fd                        # Fast find alternative
    
  ];

  # Enable necessary services for security tools
  
  # Wireshark: Allow non-root users to capture packets
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  
  # Enable Tor service (disabled by default, enable manually if needed)
  # services.tor.enable = true;
  # services.tor.client.enable = true;
  
  # Enable I2P (disabled by default)
  # services.i2pd.enable = true;
  
  # Metasploit database (PostgreSQL)
  # services.postgresql.enable = true;
  # services.postgresql.package = pkgs.postgresql_15;
  
  # Security-related kernel parameters
  boot.kernel.sysctl = {
    # Enable IP forwarding (useful for MITM attacks in controlled environments)
    "net.ipv4.ip_forward" = 0;  # Set to 1 to enable
    
    # Disable ICMP redirects (security hardening)
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };
  
  # Add user to necessary groups for security tools
  users.users.${config.system.config.user.name} = {
    extraGroups = [ 
      "wireshark"   # Packet capture
      "dialout"     # Serial device access (for hardware hacking)
    ];
  };
  
  # Environment variables for security tools
  environment.variables = {
    # Metasploit
    MSF_DATABASE_CONFIG = "/home/${config.system.config.user.name}/.msf4/database.yml";
  };
  
  # Create directories for security tools
  system.activationScripts.securityDirs = ''
    mkdir -p /home/${config.system.config.user.name}/.msf4
    mkdir -p /home/${config.system.config.user.name}/osint
    mkdir -p /home/${config.system.config.user.name}/pentest
    mkdir -p /home/${config.system.config.user.name}/wordlists
    chown -R ${config.system.config.user.name}:users /home/${config.system.config.user.name}/.msf4
    chown -R ${config.system.config.user.name}:users /home/${config.system.config.user.name}/osint
    chown -R ${config.system.config.user.name}:users /home/${config.system.config.user.name}/pentest
    chown -R ${config.system.config.user.name}:users /home/${config.system.config.user.name}/wordlists
  '';
}
