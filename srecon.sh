#!/bin/bash

if [ -z "$1" ]; then
    echo "[-] Usage: $0 [domain]"
    exit 1
fi

domain=$1

# Create a directory for the domain
mkdir -p "./recon_$domain"
cd "./$domain" 
echo "[*] All files will be put in \"./recon_$domain\""

# 1. Domain and Subdomain enumeration
echo "[*] Starting Domain and Subdomain enumeration"
# sublist3r
sublist3r -d $domain -o "./recon_$domain/sublist3r.txt"
# subfinder
subfinder -d $domain -o "./recon_$domain/subdomain.txt"
# amass
amass enum -passive -d $domain -o "./recon_$domain/amass.txt"
cat "./recon_$domain/sublist3r.txt" "./recon_$domain/subdomain.txt" "./recon_$domain/amass.txt" | sort -u > "./recon_$domain/all_subdomains.txt"
echo "[+] Domain and Subdomain enumeration complete"

# 2. Checking alive subdomain
echo "[*] Checking alive subdomain"
# httpx-toolkit
cat "./recon_$domain/all_subdomains.txt" | httpx-toolkit -o "./recon_$domain/alive_subdomains.txt"
echo "[+] Checking alive subdomain complete"

# 3. WHOIS Information Gathering
echo "[*] Starting WHOIS Information Gathering"
# whois
whois $domain > "./recon_$domain/whois.txt"
echo "[+] WHOIS Information Gathering complete"

# 4. Port Scanning
echo "[*] Starting Port Scanning"
while IFS= read -r subdomain; do
    masscan -p1-65535 $subdomain --rate 1000 -oG "./recon_$domain/masscan.txt"
done < "./recon_$domain/alive_subdomains.txt"
echo "[+] Port Scanning complete"

# 5. Service Scanning
echo "[*] Starting Service Scanning"
# whatweb
while IFS= read -r subdomain; do
    whatweb $subdomain > "./recon_$domain/whatweb.txt"
done < "./recon_$domain/alive_subdomains.txt"
echo "[+] Service Scanning complete"

# 6. other tools
# waybackurls
echo "[*] Starting other tools"
cat "./recon_$domain/alive_subdomains.txt" | waybackurls > "./recon_$domain/waybackurls.txt"
# paramspider
paramspider -d $domain | tee -a "./recon_$domain/paramspider.txt"

# 7. Vulnerability Scanning
echo "[*] Starting Vulnerability Scanning"
# nuclei、NucleiFuzzer
nf -d $domain | tee -a "./recon_$domain/nf.txt"
echo "[+] Vulnerability Scanning complete"