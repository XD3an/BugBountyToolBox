#!/bin/bash

if [ -z "$1" ]; then
    echo "[-] Usage: $0 [domain]"
    exit 1
fi

domain=$1

# Create a directory for the domain
mkdir -p "./recon_$domain"
echo "[*] All files will be put in \"./recon_$domain\""

# 1. Domain and Subdomain enumeration
echo "[*] Starting Domain and Subdomain enumeration"
# sublist3r
if [ sublist3r ]; then
    sublist3r -d $domain -o "./recon_$domain/sublist3r.txt"
else
    echo "[-] sublist3r is not installed"
fi
# subfinder
if [ subfinder ]; then
    subfinder -d $domain -o "./recon_$domain/subfinder.txt"
else
    echo "[-] subfinder is not installed"
fi
cat "./recon_$domain/sublist3r.txt" "./recon_$domain/subfinder.txt" | sort -u > "./recon_$domain/all_subdomains.txt"
echo "[+] Domain and Subdomain enumeration complete"

# 2. Checking alive subdomain
echo "[*] Checking alive subdomain"
# httpx-toolkit
if [ httpx-toolkit ]; then
    httpx-toolkit -l "./recon_$domain/all_subdomains.txt" -o "./recon_$domain/alive_subdomains.txt"
else
    echo "[-] httpx-toolkit is not installed"
fi
echo "[+] Checking alive subdomain complete"

# 3. Domain and Subdomain Information Gathering
echo "[*] Starting Domain and Subdomain Information Gathering"
# whois
if [ whois ]; then
    while IFS= read -r subdomain; do
        whois $subdomain > "./recon_$domain/whois.txt"
    done < "./recon_$domain/alive_subdomains.txt"
else
    echo "[-] whois is not installed"
fi
echo "[+] Domain and Subdomain Information Gathering complete"

# 4. Port Scanning
echo "[*] Starting Port Scanning"
# rustscan
if [ rustscan ]; then
    while IFS= read -r subdomain; do
        rustscan -a $subdomain -o "./recon_$domain/rustscan.txt"
    done < "./recon_$domain/alive_subdomains.txt"
else
    echo "[-] rustscan is not installed"
fi
echo "[+] Port Scanning complete"

# 5. Service Scanning
echo "[*] Starting Service Scanning"
# whatweb
if [ whatweb ]; then
    while IFS= read -r subdomain; do
        whatweb $subdomain > "./recon_$domain/whatweb.txt"
    done < "./recon_$domain/alive_subdomains.txt"
else
    echo "[-] whatweb is not installed"
fi
echo "[+] Service Scanning complete"

# 6. Gathering Sentive Information and Files
# dirsearch
echo "[*] Starting Gathering Sentive Information and Files"
if [ dirsearch ]; then
    while IFS= read -r subdomain; do
        dirsearch -u $subdomain -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,sql.gz,zip,sql.tar.gz,swp,swp~,tar,tar,tar.bz2,tar.gz,txt,zip,xml,json -o "./recon_$domain/dirsearch.txt"
    done < "./recon_$domain/alive_subdomains.txt"
else
    echo "[-] dirsearch is not installed"
fi
echo "[+] Gathering Sentive Information and Files complete"

# 7. Vulnerability Scanning
echo "[*] Starting Vulnerability Scanning"
# nuclei、NucleiFuzzer
if [ nf ]; then
    nf -d $domain | tee -a "./recon_$domain/nf.txt"
else
    echo "[-] NucleiFuzzer is not installed"
fi
echo "[+] Vulnerability Scanning complete"

# other tools
# echo "[*] Starting other tools"
# # waybackurls
# if [ waybackurls ]; then
#     cat "./recon_$domain/alive_subdomains.txt" | waybackurls > "./recon_$domain/waybackurls.txt"
# else
#     echo "[-] waybackurls is not installed"
# fi
# # paramspider
# if [ paramspider ]; then
#     paramspider -d $domain | tee -a "./recon_$domain/paramspider.txt"
# else
#     echo "[-] paramspider is not installed"
# fi
