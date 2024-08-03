#!/bin/bash 
# Author: XD3an

# Parameters Parsing
if [ -z "$1" ]; then
    echo "[-] Usage: $0 [domain | /path/to/domains.txt | /path/to/asset.txt]"
    exit 1
fi

# [Recon Process func]
#
# *Recon Process Flow:
#   1. Domain and Subdomain enumeration
#     - sublist3r
#     - subfinder
#     - httpx-toolkit
#
#   2. Domain and Subdomain Information Gathering
#     - whois
#
#   3. Port Scanning
#     - rustscan
#
#   4. Service Scanning
#     - whatweb
#     - wafw00f
#
#   5. Gathering Sensitive Information and Files
#     - dirsearch
#
#   6. Vulnerability Scanning
#     - nuclei, NucleiFuzzer
#
# This is the basic flow of the recon process. You can add more tools and steps as per your requirement.
#

recon_domain() {

    local domain=$1

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

    # httpx-toolkit
    if command -v httpx-toolkit &> /dev/null; then
        # echo $domain | httpx-toolkit | tee -a "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
        cat "./recon_$domain/domain_subdomains_enum/"* | sort -u | httpx-toolkit -threads 200  | tee -a "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
    else
        echo "[-] httpx-toolkit is not installed"
    fi
    
    echo "[+] Domain and Subdomain enumeration complete"
    echo

    # ============================ 2. Domain and Subdomain Information Gathering ============================
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

    # ======================================== 3. Port Scanning ============================================
    echo "[*] Starting Port Scanning"

    mkdir -p "./recon_$domain/port_scanning"

    # rustscan
    if command -v rustscan &> /dev/null; then
        if [ ! -f "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt" ]; then
            echo "[-] all_alive_subdomains.txt not found: No such file or directory"
        else
            while IFS= read -r subdomain; do
                pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
                rustscan -a $pure_subdomain --ulimit 5000 | tee -a "./recon_$domain/port_scanning/rustscan.txt"
            done < "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
        fi
    else
        echo "[-] rustscan is not installed"
    fi

    echo "[+] Port Scanning complete"
    echo

    # ======================================= 4. Service Scanning ==========================================
    echo "[*] Starting Service Scanning"

    mkdir -p "./recon_$domain/service_scanning"

    # whatweb
    if command -v whatweb &> /dev/null; then
        if [ ! -f "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt" ]; then
            echo "[-] all_alive_subdomains.txt not found: No such file or directory"
        else 
            while IFS= read -r subdomain; do
                whatweb $subdomain | tee -a "./recon_$domain/service_scanning/whatweb.txt"
            done < "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
        fi
    else
        echo "[-] whatweb is not installed"
    fi

    # wafw00f
    if command -v  wafw00f &> /dev/null; then
        if [ ! -f "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt" ]; then
            echo "[-] alive_subdomains.txt not found: No such file or directory"
        else
            while IFS= read -r subdomain; do
                wafw00f $subdomain | tee -a "./recon_$domain/service_scanning/wafw00f.txt"
            done < "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
        fi
    else
        echo "[-] wafw00f is not installed"
    fi

    echo "[+] Service Scanning complete"
    echo

    # ============================= 5. Gathering Sensitive Information and Files =============================
    echo "[*] Starting Gathering Sensitive Information and Files"

    mkdir -p "./recon_$domain/sensitive_info_files"

    # dirsearch
    if command -v dirsearch &> /dev/null; then
        if [ ! -f "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt" ]; then
            echo "[-] alive_subdomains.txt not found: No such file or directory"
        else
            while IFS= read -r subdomain; do
                pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
                dirsearch -u $pure_subdomain -x 500,502,429,404,400 -R 5 --random-agent -t 100 -F -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,sql.gz,zip,sql.tar.gz,swp,swp~,tar,tar,tar.bz2,tar.gz,txt,zip,xml,json -o "./recon_$domain/sensitive_info_files/_dirsearch_$pure_subdomain"
            done < "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
        fi
        rm -rf "./reports/"
        cat "./recon_$domain/sensitive_info_files/"* | tee -a "./recon_$domain/sensitive_info_files/dirsearch.txt"
        rm -rf "./recon_$domain/sensitive_info_files/_dirsearch_"*
    else
        echo "[-] dirsearch is not installed"
    fi
    echo "[+] Gathering Sensitive Information and Files complete"
    echo

    # ===================================== 6. Vulnerability Scanning ======================================
    echo "[*] Starting Vulnerability Scanning"

    mkdir -p "./recon_$domain/vuln_scanning"

    # nuclei, NucleiFuzzer
    if command -v nf &> /dev/null; then
        if [ ! -f "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt" ]; then
            echo "[-] alive_subdomains.txt not found: No such file or directory"
        else
            while IFS= read -r subdomain; do
                # remove 'http://' or 'https://'
                pure_subdomain=$(echo $subdomain | sed 's/http[s]*:\/\///')
                nf -d $pure_subdomain | tee -a "./recon_$domain/vuln_scanning/nf_$pure_subdomain.txt"
            done < "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
        fi
    else
        echo "[-] NucleiFuzzer is not installed"
    fi
    echo "[+] Vulnerability Scanning complete"
    echo
}


# TODO: Add more tools and steps as per your requirement
# other tools
# - waybackurls
# - paramspider
# screenshot

# Check if the input is a domain or a file
if [ -f "$1" ]; then
    echo "[*] Recon => Reading domains from file: $1"
    while IFS= read -r domain; do
		pure_domain=$(echo $domain | sed 's/http[s]*:\/\///')
        echo "[*]    \\__ Target domain: $pure_domain"
        recon_domain $pure_domain
    done < "$1"
else
    echo "[*] Recon -> Target domain: $1"
    domain=$1
    recon_domain $domain
fi

