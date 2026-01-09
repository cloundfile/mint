#!/usr/bin/env bash
set -e

# =============================
# Configurações
# =============================
LLAMA_DIR="/opt/llama.cpp"
MODEL_NAME="Qwen-1_8B.Q4_K_M.gguf"
MODEL_PATH="/opt/models/$MODEL_NAME"
SERVICE_NAME="millena"
API_PORT=1234
CTX_SIZE=1024
THREADS=$(nproc)

# =============================
# Passo 1: Instalar dependências
# =============================
echo "[1/7] Instalando dependências..."
sudo apt update
sudo apt install -y build-essential git cmake python3 python3-pip

# =============================
# Passo 2: Clonar llama.cpp se não existir
# =============================
if [ ! -d "$LLAMA_DIR" ]; then
    echo "[2/7] Clonando llama.cpp em $LLAMA_DIR..."
    sudo git clone https://github.com/ggml-org/llama.cpp.git "$LLAMA_DIR"
fi

# =============================
# Passo 3: Criar pasta de build e compilar
# =============================
echo "[3/7] Compilando llama.cpp..."
cd "$LLAMA_DIR"
mkdir -p build
cd build
cmake ..
cmake --build . --config Release

# =============================
# Passo 4: Criar pasta de modelos
# =============================
echo "[4/7] Criando pasta de modelos..."
sudo mkdir -p /opt/models
if [ ! -f "$MODEL_PATH" ]; then
    echo "[!] Atenção: coloque o arquivo $MODEL_NAME em /opt/models antes de iniciar o serviço."
fi

# =============================
# Passo 5: Criar script de inicialização
# =============================
echo "[5/7] Criando script /opt/millena.sh..."
sudo tee /opt/millena.sh > /dev/null <<EOF
#!/usr/bin/env bash
set -e

BIN="$LLAMA_DIR/build/bin/llama-server"
MODEL="$MODEL_PATH"
PORT=$API_PORT
THREADS=$THREADS
CTX=$CTX_SIZE

exec "\$BIN" \\
  -m "\$MODEL" \\
  --port "\$PORT" \\
  --ctx-size "\$CTX" \\
  -t "\$THREADS"
EOF

sudo chmod +x /opt/millena.sh

# =============================
# Passo 6: Criar serviço systemd
# =============================
echo "[6/7] Criando serviço systemd $SERVICE_NAME.service..."
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=Qwen 1.8B API (llama.cpp)
After=network.target

[Service]
ExecStart=/opt/millena.sh
User=$USER
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME

# =============================
# Passo 7: Iniciar serviço
# =============================
echo "[7/7] Iniciando serviço..."
sudo systemctl restart $SERVICE_NAME
sudo systemctl status $SERVICE_NAME --no-pager

echo "✅ Instalação concluída! A API deve estar rodando na porta $API_PORT."
echo "Use: curl -X POST http://localhost:$API_PORT/completion -H 'Content-Type: application/json' -d '{\"prompt\":\"Olá\",\"n_predict\":32}'"
