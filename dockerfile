# Use Ubuntu LTS as the base image
FROM debian:stable-slim

# Set environment variables to non-interactive (this prevents some prompts)
ENV DEBIAN_FRONTEND=non-interactive

# Install curl and other utilities, then install Go
RUN apt-get update && apt-get install -y curl && \
    LATEST_GO_VERSION=$(curl -s https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+\.linux-amd64\.tar\.gz' | head -1) && \
    curl -O https://dl.google.com/go/$LATEST_GO_VERSION && \
    tar -C /usr/local -xzf $LATEST_GO_VERSION && \
    rm $LATEST_GO_VERSION

ENV PATH="/usr/local/go/bin:${PATH}"

# set folder for default installation
RUN mkdir -p /opt/data
WORKDIR /opt/data

# Install any necessary dependencies
RUN apt-get install -y ca-certificates openssl python3 python3-pip python3-setuptools curl git unzip tmux vim make wget libpcap-dev nmap jq

# Add python syslink for compatibility
RUN ln -s -f /usr/bin/python3 /usr/bin/python



# Install Tools
## Amass
RUN go install -v github.com/owasp-amass/amass/v4/...@master

## Asset finder
RUN go install github.com/tomnomnom/assetfinder@latest

## anew
RUN go install -v github.com/tomnomnom/anew@latest

## Findomain
RUN curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip > /tmp/findomain-linux-i386.zip && \
curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-aarch64.zip > /tmp/findomain-aarch64.zip && \
curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-armv7.zip > /tmp/findomain-armv7.zip && \
unzip findomain-linux-i386.zip -d /tmp && chmod +x /tmp/findomain && mv /tmp/findomain /usr/bin/findomain-i386 && \
unzip findomain-aarch64.zip -d /tmp && chmod +x /tmp/findomain && mv /tmp/findomain /usr/bin/findomain-aarch64 && \
unzip findomain-armv7.zip -d /tmp && chmod +x /tmp/findomain && mv /tmp/findomain /usr/bin/findomain-armv7
# RUN wget https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip -O /usr/local/bin/findomain.zip && \
# unzip  /usr/local/bin/findomain.zip -d usr/local/bin/ && \
# chmod +x /usr/local/bin/findomain

## dnsx
RUN go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

## subfinder
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

## gau
RUN go install github.com/lc/gau/v2/cmd/gau@latest

## git-dumper (replaces goop)
RUN pip3 install --break-system-packages git-dumper

## httpx
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

## knock
RUN git clone https://github.com/guelfoweb/knock.git /opt/data/knock &&\
cd /opt/data/knock &&\
pip3 install  --break-system-packages -r requirements.txt && \
chmod +x knockpy.py && \
ln -s -f  $PWD/knockpy.py /usr/bin/knowckpy

## Photon
RUN git clone https://github.com/s0md3v/Photon.git /opt/data/Photon &&\
cd /opt/data/Photon &&\
pip3 install  --break-system-packages -r requirements.txt &&\
chmod +x photon.py &&\
ln -s -f  $PWD/photon.py /usr/bin/photon

## meg
RUN go install github.com/tomnomnom/meg@latest

## waybackurls
RUN go install github.com/tomnomnom/waybackurls@latest 


## Uro
RUN pip3 install --break-system-packages uro

## Nuclei
RUN go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

## massdns
RUN git clone https://github.com/blechschmidt/massdns.git /opt/data/massdns &&\
cd /opt/data/massdns &&\
make &&\
make install &&\
cd ~

# DNS Recon
RUN git clone https://github.com/darkoperator/dnsrecon.git /opt/data/dnsrecon && \
    cd /opt/data/dnsrecon && pip3 install --break-system-packages --ignore-installed . --no-warn-script-location

## PureDNS
RUN go install github.com/d3mondev/puredns/v2@latest

## httprobe
RUN go install github.com/tomnomnom/httprobe@latest

## gowitness
RUN go install github.com/sensepost/gowitness@latest

## uncover
RUN go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest

## Katana
RUN go install -v github.com/projectdiscovery/katana/cmd/katana@latest

## dalfox (replaces Airixss)
RUN go install github.com/hahwul/dalfox/v2@latest

## ffuf (replaces Freq)
RUN go install github.com/ffuf/ffuf/v2@latest

## naabu
RUN go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

## gitleaks
RUN go install github.com/zricethezav/gitleaks/v8@latest

## xurlfind3r (old sigurlfind3r)
RUN go install -v github.com/hueristiq/xurlfind3r/cmd/xurlfind3r@latest

## trufflehog
RUN curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

## ParamSpider
RUN git clone https://github.com/devanshbatham/ParamSpider /opt/data/ParamSpider && \
cd /opt/data/ParamSpider && pip3 install --break-system-packages . && \
ln -s -f  $PWD/paramspider.py /usr/local/bin/paramspider

## Pacu
RUN pip3 install --break-system-packages pacu

## qsreplace
RUN go install github.com/tomnomnom/qsreplace@latest

## unfurl
RUN go install github.com/tomnomnom/unfurl@latest

## notify
RUN go install -v github.com/projectdiscovery/notify/cmd/notify@latest && \
mkdir -p $HOME/.config/notify
COPY ./config/provider-config.yaml /root/.config/notify/provider-config.yaml

LABEL maintainer="Renan Toesqui Magalhaes <renan@seclabs.cc>"

# workdir and volume
WORKDIR /root

# Start a long-running process as the container's command
CMD tail -f /dev/null

