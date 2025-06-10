#!/bin/bash

# Lokacija privremene datoteke
TMP_RULES="/tmp/iptables-backup.rules"

# GitHub RAW URL
GITHUB_RAW_URL="https://raw.githubusercontent.com/netsolutionpro/antiskener/main/iptables-backup.rules"

# Funkcija za provjeru i instalaciju paketa
install_if_missing() {
    if ! command -v "$1" &> /dev/null; then
        echo "[+] Instaliram $1..."
        apt update && apt install -y "$1"
    fi
}

# Provjera root privilegija
if [[ $EUID -ne 0 ]]; then
   echo "[!] Pokreni skriptu kao root."
   exit 1
fi

# Provjeri curl i iptables-restore
install_if_missing curl
install_if_missing iptables

# Skidanje pravila
echo "[+] Preuzimam iptables pravila s GitHuba..."
curl -s -o "$TMP_RULES" "$GITHUB_RAW_URL"

# Provjera fajla
if [[ ! -s "$TMP_RULES" ]]; then
    echo "[!] Greška: Pravila nisu preuzeta ili je fajl prazan."
    exit 1
fi

# Učitavanje pravila
echo "[+] Učitavam iptables pravila..."
iptables-restore < "$TMP_RULES"

# Rezultat
if [[ $? -eq 0 ]]; then
    echo "[✔] Pravila su uspješno učitana u iptables."
else
    echo "[!] Došlo je do greške prilikom učitavanja pravila."
    exit 1
fi
