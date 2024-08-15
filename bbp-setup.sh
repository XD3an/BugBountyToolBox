#!/bin/bash
# Author: XD3an

clear

echo '#######################################################################'
echo '#                     Bug Bounty ToolBox Setup                        #'
echo '#######################################################################'
echo

# color
GREEN="\e[32m"
RED="\e[31m"
BOLD="\e[1m"
RESET="\e[0m"


# check if the current user has root privileges
if [ "$(id -u)" -eq 0 ]; then
    echo "${GREEN}${BOLD}[+] OK. The script will install the tools.${RESET}"
else
    echo "${RED}${BOLD}[-] Root privileges are required${RESET}"
    exit
fi


# update & upgrade
echo "${GREEN}${BOLD}[*] Upgrading All Packages now...${RESET}";
if apt update -y; then
	echo "${GREEN}${BOLD}[+] package lists updated successfully.${RESET}"
else
	echo "${RED}${BOLD}[-] failed to update package lists.${RESET}"
	exit
fi

if apt upgrade -y; then
	echo "${GREEN}${BOLD}[+] All packages upgraded successfully.${RESET}"
else
	echo "${RED}${BOLD}[-] failed to update package lists.${RESET}"
	exit
fi

mkdir -p "./.bbp-toolbox"
echo "${GREEN}${BOLD}[*] All File will be put on \"./.bbp-toolbox\""
read -p "Press enter to continue..." foobar
echo

#================================================================
#                  Main Bug Bounty ToolBox Setup 				
#================================================================

# python3
echo "${GREEN}${BOLD}[*] Install \"Python3\"${RESET}";
apt install python3 -y
echo "${BOLD}"; python3 --version; echo "${RESET}";
echo

# git
echo "${GREEN}${BOLD}[*] Install \"git\"${RESET}"
apt install git -y
echo "${BOLD}"; git --version; echo "${RESET}";
echo

# go
echo "${GREEN}${BOLD}[*] Install \"go\"${RESET}"
apt install golang-go -y
echo "${BOLD}"; go version; echo "${RESET}";
echo

# nmap
echo "${GREEN}${BOLD}[*] Install \"nmap\"${RESET}"
apt install nmap -y
echo "${BOLD}"; nmap --version; echo "${RESET}";
echo

# amass
echo "${GREEN}${BOLD}[*] Install \"amass\"${RESET}"
apt install amass -y
echo "${BOLD}"; amass --version; echo "${RESET}";
echo

# subfinder
echo "${GREEN}${BOLD}[*] Install \"subfinder\"${RESET}"
apt install subfinder -y
echo "${BOLD}"; subfinder --version; echo "${RESET}";
echo

# sublist3r
echo "${GREEN}${BOLD}[*] Install \"sublist3r\"${RESET}"
apt install sublist3r -y
echo "${BOLD}"; sublist3r --version; echo "${RESET}";
echo

# masscan
echo "${GREEN}${BOLD}[*] Install \"masscan\"${RESET}"
apt install masscan -y
echo "${BOLD}"; masscan --version; echo "${RESET}";
echo

# rustscan
echo "${GREEN}${BOLD}[*] Install \"rustscan\"${RESET}"
apt install rustscan -y
echo "${BOLD}"; rustscan --version; echo "${RESET}";
echo

# dnseum
echo "${GREEN}${BOLD}[*] Install \"dnseum\"${RESET}"
apt install dnseum -y
echo "${BOLD}"; dnseum --version; echo "${RESET}";
echo

# whatweb
echo "${GREEN}${BOLD}[*] Install \"whatweb\"${RESET}"
apt install whatweb -y
echo "${BOLD}"; whatweb --version; echo "${RESET}";
echo

# dirsearch
echo "${GREEN}${BOLD}[*] Install \"dirsearch\"${RESET}"
apt install dirsearch -y
echo "${BOLD}"; dirsearch --version; echo "${RESET}";
echo

# ffuf
echo "${GREEN}${BOLD}[*] Install \"ffuf\"${RESET}"
apt install ffuf -y
echo "${BOLD}"; ffuf --version; echo "${RESET}";
echo

# wafw00f
echo "${GREEN}${BOLD}[*] Install \"wafw00f\"${RESET}"
apt install wafw00f -y
echo "${BOLD}"; wafw00f --version; echo "${RESET}";
echo

# wpscan
echo "${GREEN}${BOLD}[*] Install \"wpscan\"${RESET}"
apt install wpscan -y
echo "${BOLD}"; wpscan --version; echo "${RESET}";
echo

# joomscan
echo "${GREEN}${BOLD}[*] Install \"joomscan\"${RESET}"
apt install joomscan -y
echo "${BOLD}"; joomscan --version; echo "${RESET}";
echo

# nuclei
echo "${GREEN}${BOLD}[*] Install \"nuclei\"${RESET}"
apt install nuclei -y
echo "${BOLD}"; nuclei --version; echo "${RESET}";
echo

# nikto
echo "${GREEN}${BOLD}[*] Install \"nikto\"${RESET}"
apt install nikto -y
echo "${BOLD}"; nikto --version; echo "${RESET}";
echo

# gitleaks
echo "${GREEN}${BOLD}[*] Install \"gitleaks\"${RESET}"
apt install gitleaks -y
echo "${BOLD}"; gitleaks --version; echo "${RESET}";
echo

# httpx-toolkit
echo "${GREEN}${BOLD}[*] Install \"httpx-toolkit\"${RESET}"
apt install httpx-toolkit -y
echo "${BOLD}"; httpx-toolkit --version; echo "${RESET}";
echo

# NucleiFuzzer
echo "${GREEN}${BOLD}[*] Install \"NucleiFuzzer\"${RESET}"
git clone https://github.com/XD3an/NucleiFuzzer ./.bbp-toolbox/NucleiFuzzer; cd ./.bbp-toolbox/NucleiFuzzer; chmod +x install.sh; ./install.sh; cd ../..
echo

# 1. Weak Password
# https://github.com/ihebski/DefaultCreds-cheat-sheet
echo "${GREEN}${BOLD}[*] Download \"DefaultCreds-cheat-sheet\"${RESET}"
git clone https://github.com/ihebski/DefaultCreds-cheat-sheet ./.bbp-toolbox/DefaultCreds-cheat-sheet
echo

# https://github.com/danielmiessler/SecLists
echo "${GREEN}${BOLD}[*] Install \"Seclists\"${RESET}"
apt install seclists -y
#echo "${BOLD}"; seclists -h echo "${RESET}";
echo

# 2. Directory Traversal (Information Leakage)
# https://github.com/wireghoul/dotdotpwn
echo "${GREEN}${BOLD}[*] Install \"dotdotpwn\"${RESET}"
apt install dotdotpwn -y
echo

# https://github.com/m4ll0k/SecretFinder
echo "${GREEN}${BOLD}[*] Install \"SecretFinder\"${RESET}"
git clone https://github.com/m4ll0k/SecretFinder.git ./.bbp-toolbox/SecretFinder
echo

# 3. SQL Injection
# https://github.com/sqlmapproject/sqlmap
echo "${GREEN}${BOLD}[*] Install \"sqlmap\"${RESET}"
apt install sqlmap -y
echo "${BOLD}"; sqlmap --version; echo "${RESET}";
echo

# 4. Cross-Site Scripting
# https://github.com/s0md3v/XSStrike
echo "${GREEN}${BOLD}[*] Install \"XSSStrike\"${RESET}"
git clone https://github.com/s0md3v/XSStrike ./.bbp-toolbox/XSStrike
echo

# 5. Subdomain Takeover
# https://github.com/PentestPad/subzy
echo "${GREEN}${BOLD}[*] Install \"subzy\"${RESET}"
go install -v github.com/LukaSikic/subzy@latest
cp ~/go/bin/subzy /usr/bin/
echo "${BOLD}"; subzy --version; echo "${RESET}";
echo

# others
# https://github.com/swisskyrepo/PayloadsAllTheThings
echo "${GREEN}${BOLD}[*] Download \"PayloadAllThings\"${RESET}"
git clone https://github.com/swisskyrepo/PayloadsAllTheThings ./.bbp-toolbox/PayloadAllThings
echo

# https://github.com/s0md3v/Arjun
echo "${GREEN}${BOLD}[*] Install \"Arjun\"${RESET}"
git clone https://github.com/s0md3v/Arjun ./.bbp-toolbox/Arjun
echo

# https://github.com/lc/gau
echo "${GREEN}${BOLD}[*] Install \"gau\"${RESET}"
go install github.com/lc/gau/v2/cmd/gau@latest
echo "${BOLD}"; gau --version; echo "${RESET}";
echo

# https://github.com/ameenmaali/urldedupe
echo "${GREEN}${BOLD}[*] Install \"urldedupe\"${RESET}"
git clone https://github.com/ameenmaali/urldedupe.git ./.bbp-toolbox/urldedupe ; cd urldedupe; cmake CMakeLists.txt; make; cd ../..
echo

# waybackurls
echo "${GREEN}${BOLD}[*] Install \"waybackurls\"${RESET}"
go install github.com/tomnomnom/waybackurls@latest
echo "${BOLD}"; waybackurls --version; echo "${RESET}";
echo

# https://github.com/tomnomnom/gf
echo "${GREEN}${BOLD}[*] Install \"gf\"${RESET}"
go install github.com/tomnomnom/gf@latest cp ~/go/bin/gf /usr/bin/
echo "${BOLD}"; gf -h; echo "${RESET}";
echo

# https://github.com/1ndianl33t/Gf-Patterns
echo "${GREEN}${BOLD}[*] Download \"Gf-Patterns\"${RESET}"
git clone https://github.com/1ndianl33t/Gf-Patterns ./.bbp-toolbox/Gf-Patterns
mkdir ~/.gf; cp ./.bbp-toolbox/Gf-Patterns/*.json ~/.gf
echo

# paramspider
echo "${GREEN}${BOLD}[*] Install \"paramspider\"${RESET}"
git clone https://github.com/devanshbatham/ParamSpider ./.bbp-toolbox/ParamSpider; cd ./.bbp-toolbox/ParamSpider; pip3 install .; cd ../..
echo
