#!/bin/bash
# Author: XD3an

# Parameters Parsing
if [ -z "$1" ]; then
    echo "[-] Usage: $0 [domain]"
    exit 1
fi

domain=$1

# Create a directory for the domain
mkdir -p "./recon_$domain"
echo "[*] All files will be put in \"./recon_$domain\""

# ================================= 1. Domain and Subdomain enumeration =================================
echo "[*] Starting Domain and Subdomain enumeration"
# sublist3r
if command -v sublist3r &> /dev/null; then
    sublist3r -d $domain -o "./recon_$domain/sublist3r.txt"
else
    echo "[-] sublist3r is not installed"
fi
# subfinder
if command -v subfinder &> /dev/null; then
    subfinder -d $domain -o "./recon_$domain/subfinder.txt"
else
    echo "[-] subfinder is not installed"
fi
cat "./recon_$domain/sublist3r.txt" "./recon_$domain/subfinder.txt" | sort -u > "./recon_$domain/all_subdomains.txt"
echo "[+] Domain and Subdomain enumeration complete"

# ===================================== 2. Checking alive subdomain =====================================
echo "[*] Checking alive subdomain"
# httpx-toolkit
if command -v httpx-toolkit &> /dev/null; then
    httpx-toolkit -l "./recon_$domain/all_subdomains.txt" -o "./recon_$domain/alive_subdomains.txt"
else
    echo "[-] httpx-toolkit is not installed"
fi
echo "[+] Checking alive subdomain complete"

# ============================ 3. Domain and Subdomain Information Gathering ============================
echo "[*] Starting Domain and Subdomain Information Gathering"
# whois
if command -v whois &> /dev/null; then
    while IFS= read -r subdomain; do
        whois $subdomain | tee -a "./recon_$domain/whois.txt"
    done < "./recon_$domain/alive_subdomains.txt"
else
    echo "[-] whois is not installed"
fi
echo "[+] Domain and Subdomain Information Gathering complete"

# ======================================== 4. Port Scanning ============================================
echo "[*] Starting Port Scanning"
# rustscan
if command -v rustscan &> /dev/null; then
    if [ ! -f "./recon_$domain/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else 
        while IFS= read -r subdomain; do
            pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
            rustscan -a $pure_subdomain | tee -a "./recon_$domain/rustscan.txt"
        done < "./recon_$domain/alive_subdomains.txt"
    fi
else
    echo "[-] rustscan is not installed"
fi
echo "[+] Port Scanning complete"

# ======================================= 5. Service Scanning ==========================================
echo "[*] Starting Service Scanning"
# whatweb
if command -v whatweb &> /dev/null; then
    if [ ! -f "./recon_$domain/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else 
        while IFS= read -r subdomain; do
            whatweb $subdomain | tee -a "./recon_$domain/whatweb.txt"
        done < "./recon_$domain/alive_subdomains.txt"
    fi
else
    echo "[-] whatweb is not installed"
fi

# wafw00f
if command -v  wafw00f &> /dev/null; then
    if [ ! -f "./recon_$domain/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else
        while IFS= read -r subdomain; do
            wafw00f $subdomain | tee -a "./recon_$domain/wafw00f.txt"
        done < "./recon_$domain/alive_subdomains.txt"
    fi
else
    echo "[-] wafw00f is not installed"
fi

echo "[+] Service Scanning complete"

# ============================= 6. Gathering Sentive Information and Files =============================
# dirsearch
echo "[*] Starting Gathering Sentive Information and Files"
if command -v dirsearch &> /dev/null; then
    if [ ! -f "./recon_$domain/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else
        while IFS= read -r subdomain; do
            pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
            dirsearch -u $pure_subdomain -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,sql.gz,zip,sql.tar.gz,swp,swp~,tar,tar,tar.bz2,tar.gz,txt,zip,xml,json -o "./recon_$domain/dirsearch_$pure_subdomain.txt"
        done < "./recon_$domain/alive_subdomains.txt"
    fi
    cat ./recon_$domain/dirsearch_*.txt > ./reports/dirsearch.txt
    rm -rf ./reports/*
    rm -rf ./recon_$domain/dirsearch_*.txt
else
    echo "[-] dirsearch is not installed"
fi
echo "[+] Gathering Sentive Information and Files complete"

# ===================================== 7. Vulnerability Scanning ======================================
echo "[*] Starting Vulnerability Scanning"
# nuclei, NucleiFuzzer
if command -v nf &> /dev/null; then
    if [ ! -f "./recon_$domain/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else
        while IFS= read -r subdomain; do
            # remove 'http://' or 'https://'
            pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
            nf -d $pure_subdomain | tee -a "./recon_$domain/nf_$pure_subdomain.txt"
        done < "./recon_$domain/alive_subdomains.txt"
    fi
else
    echo "[-] NucleiFuzzer is not installed"
fi
echo "[+] Vulnerability Scanning complete"

# other tools
# - waybackurls
# - paramspider
