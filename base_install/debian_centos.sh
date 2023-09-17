#!/bin/bash

# Function to check if a command exists
is_installed() {
    command -v "$1" &> /dev/null
}

# Installation functions

install_git_and_config() {
    echo "Installing and configuring Git..."
    
    # Git installation
    if ! is_installed "git"; then
        sudo apt install -y git
    else
        echo "Git is already installed."
    fi
    
    local git_email=$(git config --global user.email)
    local git_name=$(git config --global user.name)

    # Setup git user info if not present
    if [[ -z "$git_email" ]]; then
        echo "Setting global Git email to default: xussof@gmail.com"
        git config --global user.email "xussof@gmail.com"
    fi

    if [[ -z "$git_name" ]]; then
        echo "Setting global Git name to default: xussof"
        git config --global user.name "xussof"
    fi

    # Add gitall alias
    if ! grep -q "alias gitall=" ~/.bashrc; then
        echo "alias gitall='git add . --all && git commit -m \"Gitall\" && git push'" >> ~/.bashrc
        source ~/.bashrc
        echo "Alias gitall added and .bashrc sourced."
    else
        echo "Alias gitall already exists in .bashrc."
    fi
}

install_kubectl() {
    echo "Installing kubectl..."
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
}

install_aws_cli() {
    echo "Installing AWS CLI..."
    pip3 install awscli --upgrade --user
    local aws_path="export PATH=$PATH:~/.local/bin/"
    if ! grep -q "$aws_path" ~/.bashrc; then
        echo "$aws_path" >> ~/.bashrc
        source ~/.bashrc
    fi
}

install_azure_cli() {
    echo "Installing Azure CLI..."
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
    sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-get update
    sudo apt-get install azure-cli
}

install_helm() {
    echo "Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
}

install_apps_ubuntu() {
    sudo apt update

    local apps=( "vim" "htop" "curl" "wget" "virtualbox" "python3-pip" "openssh-server" "net-tools" "scp" )
    for app in "${apps[@]}"; do
        if ! is_installed "$app"; then
            sudo apt install -y "$app"
        else
            echo "$app is already installed."
        fi
    done


    # Docker and Docker Compose installation
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    install_kubectl
    install_aws_cli
    install_azure_cli
    install_helm
}

main() {
    if [ ! -f /etc/os-release ]; then
        echo "No se pudo determinar tu sistema operativo."
        exit 1
    fi

    . /etc/os-release

    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        install_apps_ubuntu
    else
        echo "This distribution is not supported by this script."
        exit 1
    fi

    echo "Instalación completada."
}

main
