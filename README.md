# Julas NixOS Configuration

Este repositório contém as minhas configurações NixOS unificadas para múltiplos dispositivos (Laptop HP, Thinkpad, Ryzen Desktop e Servidor de IA).

## 🚀 Instalação Rápida

Após dar o boot pelo Live USB do NixOS, siga os passos abaixo:

### 1. Conectar à Internet
Se você estiver usando Wi-Fi, utilize o comando interativo:
```bash
nmtui
```
*Ou via comando direto:*
```bash
nmcli device wifi connect "NOME_DA_REDE" password "SUA_SENHA"
```

### 2. Executar o Instalador
Uma vez conectado, execute o comando abaixo para iniciar o provisionamento automático:

```bash
curl -L https://raw.githubusercontent.com/julas23/nixos/main/install.sh -o install.sh && chmod +x install.sh && sudo ./install.sh
```

## 🛠️ O que o script faz?
1. **Particionamento**: Configura o disco selecionado (EFI + Root).
2. **Clonagem**: Baixa este repositório em `/mnt/etc/nixos`.
3. **Hardware**: Gera o `hardware-configuration.nix` localmente.
4. **Configuração**: Pergunta seu usuário, hostname, GPU e Desktop desejado.
5. **Instalação**: Finaliza com o `nixos-install`.

## 🖥️ Ambientes Suportados
- **Desktops**: Cosmic, Hyprland, Gnome, XFCE, Mate, i3, Awesome.
- **Hardware**: AMDGPU, NVIDIA, Intel, VM.
- **Serviços**: Docker, Ollama (AI), PostgreSQL, Stable Diffusion.
