#!/bin/bash

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "No se pudo determinar tu sistema operativo."
    exit 1
fi

install_apps_ubuntu() {
    # Update repositories
    sudo apt update

    # List of applications and their verification commands
    declare -A apps=( ["vim"]="vim" ["htop"]="htop" ["curl"]="curl" ["wget"]="wget" ["virtualbox"]="virtualbox" ["python3-pip"]="pip3" ["openssh-server"]="sshd" )

    for app in "${!apps[@]}"; do
        if ! is_installed "${apps[$app]}"; then
            sudo apt install -y "$app"
        else
            echo "$app is already installed."
        fi
    done

    sudo apt install -y vim htop curl wget virtualbox python3-pip openssh-server git net-tools scp

    # Docker and Docker Compose installation
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Ansible
    if ! is_installed "ansible"; then
        sudo apt-add-repository -y ppa:ansible/ansible
        sudo apt update
        sudo apt install -y ansible
    else
        echo "Ansible is already installed."
    fi

    # Visual Studio Code
    if ! is_installed "code"; then
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt update
        sudo apt install -y code
    else
        echo "Visual Studio Code is already installed."
    fi

    # Google Chrome
    if ! is_installed "google-chrome"; then
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install -y ./google-chrome-stable_current_amd64.deb
        rm google-chrome-stable_current_amd64.deb
    else
        echo "Google Chrome is already installed."
    fi


    # Opera
    wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
    echo | sudo add-apt-repository "deb [arch=i386,amd64] https://deb.opera.com/opera-stable/ stable non-free"

    sudo apt update
    echo | sudo DEBIAN_FRONTEND=noninteractive apt-get install -y opera-stable


    # Lens (Kubernetes IDE)
    sudo snap install kontena-lens --classic

    # pgAdmin
    curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -
    sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
    echo | sudo DEBIAN_FRONTEND=noninteractive apt-get install -y pgadmin4-desktop

    # Postman
    sudo snap install postman
}

install_apps_centos() {
    sudo yum install -y vim htop curl wget virtualbox python3-pip openssh-server git

    # Docker y Docker Compose
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    sudo curl -L "https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compos

    # Ansible
    if ! is_installed "ansible"; then
        sudo yum install -y ansible
    else
        echo "Ansible is already installed."
    fi

    # Visual Studio Code
    if ! is_installed "code"; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo yum check-update
        sudo yum install -y code
    else
        echo "Visual Studio Code is already installed."
    fi

    # Instalación de Google Chrome
    sudo yum install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

    # Opera y Lens no están disponibles directamente a través de yum, así que se omiten en esta sección. Puedes descargarlos manualmente desde sus sitios web oficiales si es necesario.

    # Installation of pgAdmin
    sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    sudo yum install -y pgadmin4-desktop

    # Installation of Postman
    wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
    tar -xzf postman.tar.gz -C /opt
    ln -s /opt/Postman/Postman /usr/bin/postman
    rm postman.tar.gz

}

if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
    install_apps_ubuntu
elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
    install_apps_centos
else
    echo "This distribution it's not suported by this script."
    exit 1
fi

echo "Instalación completada."

