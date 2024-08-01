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

mkdir -p "./recon_$domain/domain_subdomains_enum"

# sublist3r
if command -v sublist3r &> /dev/null; then
    sublist3r -d $domain -o "./recon_$domain/domain_subdomains_enum/sublist3r.txt"
else
    echo "[-] sublist3r is not installed"
fi
# subfinder
if command -v subfinder &> /dev/null; then
    subfinder -d $domain -o "./recon_$domain/domain_subdomains_enum/subfinder.txt"
else
    echo "[-] subfinder is not installed"
fi
cat "./recon_$domain/domain_subdomains_enum/sublist3r.txt" "./recon_$domain/domain_subdomains_enum/subfinder.txt" | sort -u > "./recon_$domain/domain_subdomains_enum/all_subdomains.txt"
echo "[+] Domain and Subdomain enumeration complete"
echo

# ===================================== 2. Checking alive subdomain =====================================
echo "[*] Checking alive subdomain"
# httpx-toolkit
if command -v httpx-toolkit &> /dev/null; then
    httpx-toolkit -l "./recon_$domain/domain_subdomains_enum/all_subdomains.txt" -o "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt"
else
    echo "[-] httpx-toolkit is not installed"
fi
echo "[+] Checking alive subdomain complete"
echo

# ============================ 3. Domain and Subdomain Information Gathering ============================
echo "[*] Starting Domain and Subdomain Information Gathering"

mkdir -p "./recon_$domain/info_gathering"

# whois
if command -v whois &> /dev/null; then
    whois $domain | tee -a "./recon_$domain/info_gathering/whois.txt"
else
    echo "[-] whois is not installed"
fi
echo "[+] Domain and Subdomain Information Gathering complete"
echo

# ======================================== 4. Port Scanning ============================================
echo "[*] Starting Port Scanning"

mkdir -p "./recon_$domain/port_scanning"

# rustscan
if command -v rustscan &> /dev/null; then
    rustscan -a $domain --ulimit 5000 | tee -a "./recon_$domain/port_scanning/rustscan.txt"
else
    echo "[-] rustscan is not installed"
fi
echo "[+] Port Scanning complete"
echo

# ======================================= 5. Service Scanning ==========================================
echo "[*] Starting Service Scanning"

mkdir -p "./recon_$domain/service_scanning"

# whatweb
if command -v whatweb &> /dev/null; then
    if [ ! -f "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else 
        while IFS= read -r subdomain; do
            whatweb $subdomain | tee -a "./recon_$domain/service_scanning/whatweb.txt"
        done < "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt"
    fi
else
    echo "[-] whatweb is not installed"
fi

# wafw00f
if command -v  wafw00f &> /dev/null; then
    if [ ! -f "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else
        while IFS= read -r subdomain; do
            wafw00f $subdomain | tee -a "./recon_$domain/service_scanning/wafw00f.txt"
        done < "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt"
    fi
else
    echo "[-] wafw00f is not installed"
fi

echo "[+] Service Scanning complete"
echo

# ============================= 6. Gathering Sentive Information and Files =============================
echo "[*] Starting Gathering Sentive Information and Files"

mkdir -p "./recon_$domain/sentive_info_files"

# dirsearch
if command -v dirsearch &> /dev/null; then
    if [ ! -f "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else
        while IFS= read -r subdomain; do
            pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
            dirsearch -u $pure_subdomain -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,sql.gz,zip,sql.tar.gz,swp,swp~,tar,tar,tar.bz2,tar.gz,txt,zip,xml,json -o "./recon_$domain/sentive_info_files/dirsearch_$pure_subdomain.txt"
        done < "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt"
    fi
    cat ./recon_$domain/sentive_info_files/dirsearch_*.txt > ./recon_$domain/sentive_info_files/dirsearch_all.txt
    rm -rf ./reports/*
    rm -rf ./recon_$domain/sentive_info_files/dirsearch_*.txt
else
    echo "[-] dirsearch is not installed"
fi
echo "[+] Gathering Sentive Information and Files complete"
echo

# ===================================== 7. Vulnerability Scanning ======================================
echo "[*] Starting Vulnerability Scanning"

mkdir -p "./recon_$domain/vuln_scanning"

# nuclei, NucleiFuzzer
if command -v nf &> /dev/null; then
    if [ ! -f "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt" ]; then
        echo "[-] alive_subdomains.txt not found: No such file or directory"
    else
        while IFS= read -r subdomain; do
            # remove 'http://' or 'https://'
            pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
            nf -d $pure_subdomain | tee -a "./recon_$domain/vuln_scanning/nf_$pure_subdomain.txt"
        done < "./recon_$domain/domain_subdomains_enum/alive_subdomains.txt"
    fi
else
    echo "[-] NucleiFuzzer is not installed"
fi
echo "[+] Vulnerability Scanning complete"
echo

# other tools
# - waybackurls
# - paramspider
