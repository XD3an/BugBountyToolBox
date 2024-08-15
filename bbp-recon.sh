#!/bin/bash 
# Author: XD3an

# Parameters Parsing
if [ -z "$1" ]; then
    echo "[-] Usage: $0 [domain | /path/to/domains.txt | /path/to/asset.txt]"
    exit 1
fi

command_exists() {
    command -v "$1" &> /dev/null
}

# [Recon Process function]
#
# *Recon Process Flow:
#   1. Domain and Subdomain enumeration
#     - sublist3r
#     - subfinder
#     - httpx-toolkit
#   
#   2. DNS Enumeration
#    - dnsenum
#    - dnsrecon 
#
#   3. Domain and Subdomain Information Gathering
#     - whois
#
#   4. Port Scanning
#     - rustscan
#
#   5. Service Scanning
#     - whatweb
#     - wafw00f
#
#   6. Gathering Sensitive Information and Files
#     - dirsearch
#
#   7. Vulnerability Scanning
#     - nuclei, NucleiFuzzer
#
#   8. Other Tools
#     - Git exposure
#     - waybackurls
#     - *JavaScript
#     - *s3scanner 
#     - *APIs
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
    if command_exists sublist3r; then
        sublist3r -d $domain -o "./recon_$domain/domain_subdomains_enum/sublist3r.txt"
    else
        echo "[-] sublist3r is not installed"
    fi

    # subfinder
    if command_exists -v subfinder; then
        subfinder -d $domain -o "./recon_$domain/domain_subdomains_enum/subfinder.txt"
    else
        echo "[-] subfinder is not installed"
    fi

    # httpx-toolkit
    if command_exists httpx-toolkit; then
        # echo $domain | httpx-toolkit | tee -a "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
        cat "./recon_$domain/domain_subdomains_enum/"* | sort -u | httpx-toolkit -threads 200  | tee -a "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"
    else
        echo "[-] httpx-toolkit is not installed"
    fi
    
    echo "[+] Domain and Subdomain enumeration complete"
    echo

    # ====================================== 2. DNS Enumeration ==========================================
    echo "[*] Starting DNS Enumeration"

    mkdir -p "./recon_$domain/dns_enum"

    # dnsenum
    if command_exists dnsenum; then
        dnsenum $domain --noreverse -o "./recon_$domain/dns_enum/dnsenum.txt"
    else
        echo "[-] dnsenum is not installed"
    fi

    # dnsrecon
    if command_exists dnsrecon; then
        dnsrecon -d $domain  -t std,brt -c "./recon_$domain/dns_enum/dnsrecon.csv"
    else
        echo "[-] dnsrecon is not installed"
    fi

    echo "[+] DNS Enumeration complete"
    echo  

    # ============================ 3. Domain and Subdomain Information Gathering ============================
    echo "[*] Starting Domain and Subdomain Information Gathering"

    mkdir -p "./recon_$domain/info_gathering"

    # whois
    if command_exists whois; then
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
    if command_exists rustscan; then
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

    # ======================================= 5. Service Scanning ==========================================
    echo "[*] Starting Service Scanning"

    mkdir -p "./recon_$domain/service_scanning"

    # whatweb
    if command_exists whatweb; then
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
    if command_exists  wafw00f; then
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

    # ============================= 6. Gathering Sensitive Information and Files =============================
    echo "[*] Starting Gathering Sensitive Information and Files"

    mkdir -p "./recon_$domain/sensitive_info_files"

    # dirsearch
    if command_exists dirsearch; then
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

    # ===================================== 7. Vulnerability Scanning ======================================
    echo "[*] Starting Vulnerability Scanning"

    mkdir -p "./recon_$domain/vuln_scanning"

    # nuclei, NucleiFuzzer
    if command_exists nf; then
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

    # other tools

    mkdir -p "./recon_$domain/other_tools"

    # Git exposure
    echo "[*] Starting Git exposure scanning"
    for subdomain in $(cat "./recon_$domain/domain_subdomains_enum/all_alive_subdomains.txt"); do
        curl -s "https://$subdomain/.git/HEAD" | grep "ref" && echo "https://$subdomain/.git" | tee -a "./recon_$domain/other_tools/git_exposure.txt"
    done
    echo "[+] Git exposure scanning complete"
    echo

    # waybackurls
    echo "[*] Starting waybackurls"
    if command_exists waybackurls; then
        waybackurls $domain | tee -a "./recon_$domain/other_tools/waybackurls.txt"
    else
        echo "[-] waybackurls is not installed"
    fi
    echo "[+] waybackurls complete"
    echo
}


# TODO: Vulnerability Scanning tools
#   - Directory Traversal (Information Leakage): 
#      - dotdotpwn
#   - SQL Injection: 
#      - sqlmap
#   - Cross-Site Scripting: 
#      - XSStrike
#   - Command Injection: 
#      - commix
#   - HTTP Header Injection (HTML Injection and Content Spoofing): 
#      - headi
#   - Template Injection: 
#   - Cross-Site Request Forgery
#   - Server-Side Request Forgery
#   - File Inclusion
#   - Arbitrary File Upload
#   - Unvalidated Redirects and Forwards:
#      - openredirex 
#   - Subdomain Takeover: 
#      - subzy
#   - IDOR (Broken Access Control)
#   - Using Known Vulnerable Components
#   - Security Misconfiguration
#   - ...

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

