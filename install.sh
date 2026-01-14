#!/bin/bash

### ============================
### 0. Instalar OpenJDK 11
### ============================
echo "☕ Instalando OpenJDK 17..."
sudo apt update
sudo apt install -y openjdk-17-jdk

# Verifica a instalação do Java
if java -version &>/dev/null; then
    echo "✅ OpenJDK 11 instalado com sucesso!"
else
    echo "❌ Falha na instalação do OpenJDK 11."
    exit 1
fi

### ============================
### 1. Instalação do NVM + Node
### ============================

echo "🚀 Iniciando a instalação do NVM..."

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

if [ $? -eq 0 ]; then
    echo "✅ NVM instalado com sucesso!"
else
    echo "❌ Houve um erro na instalação do NVM."
    exit 1
fi

# Carrega o NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verifica e instala o Node.js se necessário
if nvm ls node | grep -q 'N/A'; then
    echo "🔧 Node.js não encontrado. Instalando..."
    nvm install node
    if [ $? -eq 0 ]; then
        echo "✅ Node.js instalado com sucesso!"
    else
        echo "❌ Falha ao instalar o Node.js."
        exit 1
    fi
else
    echo "✅ Node.js já está instalado:"
    nvm current
fi

### ============================
### 2. Instalação do Postman
### ============================

echo "🧪 Verificando instalação do Postman..."

if [ -f "/opt/Postman/Postman" ]; then
    echo "✅ Postman já está instalado em /opt/Postman"
else
    echo "⬇️ Instalando Postman..."

    wget https://dl.pstmn.io/download/latest/linux_64 -O postman-linux-x64.tar.gz
    tar -xvzf postman-linux-x64.tar.gz
    sudo mv Postman /opt/Postman
    sudo ln -sf /opt/Postman/Postman /usr/bin/postman

    mkdir -p ~/.local/share/applications

    cat <<EOF > ~/.local/share/applications/postman.desktop
[Desktop Entry]
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Type=Application
Categories=Development;
EOF

    chmod +x ~/.local/share/applications/postman.desktop
    rm -f postman-linux-x64.tar.gz

    echo "✅ Postman instalado com sucesso e adicionado ao menu!"
fi

### ============================
### 3. Instalação do SQL Developer
### ============================

echo "⬇️ Baixando SQL Developer..."

wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-24.3.1.347.1826-no-jre.zip

echo "📦 Extraindo SQL Developer..."
unzip sqldeveloper-24.3.1.347.1826-no-jre.zip

echo "📁 Movendo para /opt..."
sudo mv sqldeveloper /opt/

echo "🔐 Dando permissão ao script..."
sudo chmod +x /opt/sqldeveloper/sqldeveloper.sh

echo "🚀 Executando SQL Developer pela primeira vez..."
sudo sh /opt/sqldeveloper/sqldeveloper.sh &

echo "🌳 Instalando tree..."
sudo apt update && sudo apt install -y tree

echo "🔧 Adicionando SQL Developer ao PATH..."
echo 'export PATH=$PATH:/opt/sqldeveloper' >> ~/.bashrc
source ~/.bashrc

echo "📂 Criando atalho no menu de aplicativos..."
mkdir -p ~/.local/share/applications/
cat <<EOF > ~/.local/share/applications/sqldeveloper.desktop
[Desktop Entry]
Name=SQL Developer
Comment=Ferramenta de Desenvolvimento para Oracle SQL
Exec=/opt/sqldeveloper/sqldeveloper.sh
Icon=/opt/sqldeveloper/icon.png
Terminal=false
Type=Application
Categories=Development;Database;
EOF

chmod +x ~/.local/share/applications/sqldeveloper.desktop
update-desktop-database ~/.local/share/applications/

rm -f sqldeveloper-24.3.1.347.1826-no-jre.zip

echo "✅ SQL Developer instalado e adicionado ao menu!"

### ============================
### 1. Instalação do android-studio
### ============================

echo "🚀 Iniciando a instalação do adbdroid-studio..."

wget -qO- https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.2.2.8/android-studio-2025.2.2.8-linux.tar.gz
tar -xvzf android-studio-2025.2.2.8-linux.tar.gz

sudo mv android-studio /opt/
cd /opt/android-studio

sudo chmod +x ./bin/studio.s


sudo tee /usr/share/applications/android-studio.desktop > /dev/null <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=IDE para desenvolvimento Android
Exec=/opt/android-studio/bin/studio.sh
Icon=/opt/android-studio/bin/studio.png
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF

sudo chmod +x /usr/share/applications/android-studio.desktop
update-desktop-database /usr/share/applications

### ============================
### Finalização
### ============================

echo "🎉 Todos os componentes foram instalados com sucesso!"

