#!/bin/bash

# This script automates the process of finding subdomains for a given domain and removing duplicate entries.

# Check if the provided domain is valid
if [ -z "$1" ]; then
    echo "Please provide a valid domain name!"
    exit
fi

domain="$1"

# Make sure all required tools are installed
for tool in "assetfinder" "amass" "subfinder" "sublist3r" "aquatone" "findomain" "crt.sh" "certspotter" "dnsrecon" "dnscan"
do
    if [ $(command -v "$tool") ]; then
        echo "$tool is installed"
    else
        echo "$tool is not installed, installing..."
        apt-get install -y "$tool"
    fi
done

# Run the tools to find subdomains
assetfinder -subs-only "$domain" | tee -a subdomains.txt
amass enum -d "$domain" | tee -a subdomains.txt
subfinder -d "$domain" | tee -a subdomains.txt
sublist3r -d "$domain" -o output.txt
cat output.txt | tee -a subdomains.txt
rm output.txt
aquatone -d "$domain" | tee -a subdomains.txt
findomain -t "$domain" | tee -a subdomains.txt
crt.sh | sed 's/\*\.//g' | sed '/^$/d' | grep "$domain" | tee -a subdomains.txt
certspotter "$domain" | sed 's/\*\.//g' | sed '/^$/d' | grep "$domain" | tee -a subdomains.txt
dnsrecon -d "$domain" -t brt | tee -a subdomains.txt
dnscan -r "$domain" | tee -a subdomains.txt


# Remove duplicate entries
sort -u subdomains.txt -o subdomains.txt

# Output the final result
cat subdomains.txt
