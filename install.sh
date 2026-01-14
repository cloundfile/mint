

#!/bin/bash

set -e

### ============================
### 0. Instalar OpenJDK 17
### ============================
echo "☕ Instalando OpenJDK 17..."

sudo apt update
sudo apt install -y openjdk-17-jdk

if java -version &>/dev/null; then
    echo "✅ OpenJDK 17 instalado com sucesso!"
else
    echo "❌ Falha na instalação do OpenJDK 17."
    exit 1
fi

### ============================
### 1. Instalação do NVM + Node.js
### ============================
echo "🚀 Iniciando a instalação do NVM..."

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if command -v nvm &>/dev/null; then
    echo "✅ NVM instalado com sucesso!"
else
    echo "❌ Erro ao instalar o NVM."
    exit 1
fi

if ! command -v node &>/dev/null; then
    echo "🔧 Node.js não encontrado. Instalando..."
    nvm install node
else
    echo "✅ Node.js já instalado: $(node -v)"
fi

### ============================
### 2. Instalação do Postman
### ============================
echo "🧪 Verificando instalação do Postman..."

if [ -x "/opt/Postman/Postman" ]; then
    echo "✅ Postman já está instalado."
else
    echo "⬇️ Instalando Postman..."

    wget https://dl.pstmn.io/download/latest/linux_64 -O postman-linux-x64.tar.gz
    tar -xzf postman-linux-x64.tar.gz
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
Terminal=false
EOF

    chmod +x ~/.local/share/applications/postman.desktop
    rm -f postman-linux-x64.tar.gz

    echo "✅ Postman instalado com sucesso!"
fi

### ============================
### 3. Instalação do SQL Developer
### ============================
echo "⬇️ Instalando SQL Developer..."

wget --no-cookies --no-check-certificate \
--header "Cookie: oraclelicense=accept-securebackup-cookie" \
https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-24.3.1.347.1826-no-jre.zip

unzip -q sqldeveloper-24.3.1.347.1826-no-jre.zip
sudo mv sqldeveloper /opt/
sudo chmod +x /opt/sqldeveloper/sqldeveloper.sh

sudo apt install -y tree

echo 'export PATH=$PATH:/opt/sqldeveloper' >> ~/.bashrc

mkdir -p ~/.local/share/applications
cat <<EOF > ~/.local/share/applications/sqldeveloper.desktop
[Desktop Entry]
Name=SQL Developer
Comment=Ferramenta Oracle SQL
Exec=/opt/sqldeveloper/sqldeveloper.sh
Icon=/opt/sqldeveloper/icon.png
Terminal=false
Type=Application
Categories=Development;Database;
EOF

chmod +x ~/.local/share/applications/sqldeveloper.desktop
update-desktop-database ~/.local/share/applications

rm -f sqldeveloper-24.3.1.347.1826-no-jre.zip

echo "✅ SQL Developer instalado com sucesso!"

### ============================
### 4. Instalação do Android Studio
### ============================
echo "🚀 Instalando Android Studio..."

wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.2.2.8/android-studio-2025.2.2.8-linux.tar.gz
tar -xzf android-studio-2025.2.2.8-linux.tar.gz

sudo mv android-studio /opt/
sudo chmod +x /opt/android-studio/bin/studio.sh

sudo tee /usr/share/applications/android-studio.desktop > /dev/null <<EOF
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
sudo update-desktop-database /usr/share/applications

echo "✅ Android Studio instalado com sucesso!"

### ============================
### Finalização
### ============================
echo "🎉 Ambiente de desenvolvimento configurado com sucesso!"
