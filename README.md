# Core Tuner

## ⚠️ Disclaimer / Aviso Legal

> [!CAUTION]
> **Use at your own risk / Use por sua conta e risco.**
> Modifying CPU parameters can damage your hardware.
> Modificar parâmetros de CPU pode danificar seu hardware.

---

### 🇧🇷 Português

**O Core Tuner é uma ferramenta avançada que requer acesso Root para modificar parâmetros do sistema Android.**

* **Sem Garantias:** O desenvolvedor não se responsabiliza por quaisquer danos físicos ao dispositivo (superaquecimento, degradação da bateria) ou perda de dados decorrentes do uso deste software.
* **Hardware:** Este projeto foi desenvolvido e testado primariamente em dispositivos **Snapdragon**. O funcionamento em chipsets **MediaTek** ou **Exynos** não é garantido e pode causar instabilidade.
* **Responsabilidade:** Ao utilizar este app, você entende que está modificando limites de hardware que podem invalidar a garantia do fabricante.

---

### 🇺🇸 English

**Core Tuner is an advanced tool that requires Root access to modify Android system parameters.**

* **No Warranty:** The developer is not responsible for any physical damage to the device (overheating, battery degradation) or data loss resulting from the use of this software.
* **Hardware:** This project was developed and tested primarily on **Snapdragon** devices. Operation on **MediaTek** or **Exynos** chipsets is not guaranteed and may cause instability.
* **Responsability:** By using this app, you understand that you are modifying hardware limits that may void the manufacturer's warranty.

## 🛠️ Requirements & Troubleshooting (ZRAM/Swap)

### 🇧🇷 Português
Para que as funcionalidades de **ZRAM/Swap** funcionem corretamente, o Core Tuner depende de binários específicos do Linux.

1. **BusyBox:** É altamente recomendado ter o BusyBox instalado (via módulo Magisk ou app) para garantir a compatibilidade dos comandos de Shell (`mkswap`, `swapon`, `grep`).
2. **Magisk Mount Namespace:** Em algumas versões do Magisk, é necessário garantir que o app tenha visibilidade global:
    * Abra o **Magisk** > **Configurações**.
    * Selecione **"Namespace de Montagem Global"** (Global Mount Namespace).
    * Reinicie o dispositivo.
*Isso evita que as alterações de swap fiquem isoladas apenas dentro do processo do app.*

---

### 🇺🇸 English
For **ZRAM/Swap** features to work properly, Core Tuner relies on specific Linux binaries.

1. **BusyBox:** It is highly recommended to have BusyBox installed (via Magisk module or app) to ensure compatibility with Shell commands (`mkswap`, `swapon`, `grep`).
2. **Magisk Mount Namespace:** On some Magisk versions, you must ensure that the app has system-wide visibility:
    * Open **Magisk** > **Settings**.
    * Select **"Global Mount Namespace"**.
    * Reboot your device.
*This prevents swap changes from being isolated only within the app's process.*

---

### 🇧🇷 Português
Este app ainda está em desenvolvimento, futuras versões incluirão apks disponibilizados.

### 🇺🇸 English
This app is still in development, future versions are going to include apk releases.

