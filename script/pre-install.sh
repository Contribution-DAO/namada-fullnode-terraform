#!/bin/bash
echo "\033[0;33m"
echo "==========================================================================================================================="
echo " "
echo "  ██████╗ ██████╗ ███╗   ██╗████████╗██████╗ ██╗██████╗ ██╗   ██╗████████╗██╗ ██████╗ ███╗   ██╗██████╗  █████╗  ██████╗ ";
echo " ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║██╔══██╗██║   ██║╚══██╔══╝██║██╔═══██╗████╗  ██║██╔══██╗██╔══██╗██╔═══██╗";
echo " ██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║██████╔╝██║   ██║   ██║   ██║██║   ██║██╔██╗ ██║██║  ██║███████║██║   ██║";
echo " ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║██╔══██╗██║   ██║   ██║   ██║██║   ██║██║╚██╗██║██║  ██║██╔══██║██║   ██║";
echo " ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║██████╔╝╚██████╔╝   ██║   ██║╚██████╔╝██║ ╚████║██████╔╝██║  ██║╚██████╔╝";
echo "  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ";
                                                                                                                                                                                                 
echo "\033[0;33m"
echo "==========================================================================================================================="                                                                                    
sleep 1

sudo su
export HOME=/root
export USER=$(whoami)
export NAMADA_TAG=${namada_tag}
export CBFT=${cbft}
export NAMADA_CHAIN_ID=${namada_chain_id}

echo "\e[1m\e[32mPre install script to install Namada fullnode with information below ... \e[0m" && sleep 1
echo "\e[1m\e[32m $HOME" 
echo "\e[1m\e[32m $USER" 
echo "\e[1m\e[32m $NAMADA_TAG" 
echo "\e[1m\e[32m $CBFT" 
echo "\e[1m\e[32m $NAMADA_CHAIN_ID"


echo "\e[1m\e[32mInstalling update and libs ... \e[0m" && sleep 1
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config git make libssl-dev libclang-dev libclang-12-dev -y
sudo apt install jq build-essential bsdmainutils ncdu gcc git-core chrony liblz4-tool -y
sudo apt install original-awk uidmap dbus-user-session protobuf-compiler unzip -y


echo "\e[1m\e[32mInstalling Go lang ... \e[0m" && sleep 1
cd $HOME
ver="1.21.3"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
. /$HOME/.bash_profile 
go version

echo "\e[1m\e[32mInstalling Rush ... \e[0m" && sleep 1
cd $HOME
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y 
. /$HOME/.cargo/env
curl https://deb.nodesource.com/setup_18.x | sudo bash
sudo apt install cargo nodejs -y < "/dev/null"  
cargo --version
node -v
  
echo "\e[1m\e[32mInstalling Protobuf ... \e[0m" && sleep 1
cd $HOME && rustup update
PROTOC_ZIP=protoc-23.3-linux-x86_64.zip
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v23.3/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
rm -f $PROTOC_ZIP
protoc --version

echo "\e[1m\e[32mInstalling Namada ... \e[0m" && sleep 1

cd $HOME && git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
make build-release
cargo fix --lib -p namada_apps

echo "\e[1m\e[32mInstalling Comebft ... \e[0m" && sleep 1
cd $HOME && git clone https://github.com/cometbft/cometbft.git && cd cometbft && git checkout $CBFT
make build

cd $HOME  
sudo cp $HOME/cometbft/build/cometbft /usr/local/bin/cometbft
sudo cp "$HOME/namada/target/release/namada" /usr/local/bin/namada
sudo cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac
sudo cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan
sudo cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
sudo cp "$HOME/namada/target/release/namadar" /usr/local/bin/namadar
cometbft version
namada --version

echo "\e[1m\e[32mJoin-network ... \e[0m" && sleep 1
namada client utils join-network --chain-id $NAMADA_CHAIN_ID

echo "\e[1m\e[32mCreating Namadad service ... \e[0m" && sleep 1
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable namadad

sed -i '/^\[ledger\.cometbft\.rpc\]$/,/^\[/ s/laddr = "tcp:\/\/127\.0\.0\.1:26657"/laddr = "tcp:\/\/0.0.0.0:26657"/' "$HOME/.local/share/namada/$NAMADA_CHAIN_ID/config.toml"

echo "\e[1m\e[32mStarting namadad service ... \e[0m" && sleep 1
sudo systemctl restart namadad


echo "\e[1m\e[32mInstaling nginx... \e[0m" && sleep 1
sudo apt-get install nginx -y

cat << EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    # Add index.php to the list if you are using PHP
    index index.html index.htm index.nginx-debian.html;
    server_name _;
    location / {
        proxy_pass http://localhost:26657;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header Host \$host;
    }
}
EOF

# Check for syntax errors
sudo nginx -t

# Restart Nginx to apply the changes
sudo systemctl restart nginx

echo "\e[1m\e[32mNginx installation and reverse proxy configuration complete.\e[0m"