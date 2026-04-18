# Core Tuner 🚀

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

---

## 🚀 Arquitetura de Persistência / Persistence Architecture

### 🇧🇷 Português
Para garantir máxima eficiência e performance, o Core Tuner utiliza uma **arquitetura híbrida**. Isso elimina a necessidade de serviços pesados rodando em segundo plano no Android.

1.  **Core Tuner App (APK):** Interface para controle e monitoramento em tempo real. Salva suas configurações em `/data/core_tuner`.
2.  **Core Tuner Persistence (Módulo Magisk):** Script de baixo nível que aplica os valores salvos durante o processo de boot (`init`), garantindo que seus tweaks sobrevivam ao reiniciar o aparelho.

**Instalação:**
1.  Instale o APK do Core Tuner.
2.  Instale o arquivo `core_tuner_persistence.zip` via Magisk e reinicie o dispositivo.
3.  Configure seus tweaks no app; eles serão aplicados instantaneamente e persistirão em todo boot.

---

### 🇺🇸 English
To ensure maximum efficiency and performance, Core Tuner uses a **hybrid architecture**. This eliminates the need for heavy background services running on Android.

1.  **Core Tuner App (APK):** UI for real-time control and monitoring. Saves your settings to `/data/core_tuner`.
2.  **Core Tuner Persistence (Magisk Module):** Low-level script that applies saved values during the boot process (`init`), ensuring your tweaks survive device reboots.

**Installation:**
1.  Install the Core Tuner APK.
2.  Install the `core_tuner_persistence.zip` file via Magisk and reboot your device.
3.  Configure your tweaks in the app; they will be applied instantly and persist on every boot.

---

## 🛠️ Requirements & Troubleshooting (ZRAM/Swap)

### 🇧🇷 Português
Para que as funcionalidades de **ZRAM/Swap** funcionem corretamente:

1.  **BusyBox:** É altamente recomendado ter o BusyBox instalado (via módulo Magisk ou app) para garantir a compatibilidade dos comandos de Shell (`mkswap`, `swapon`, `grep`).
2.  **Módulo de Persistência:** Certifique-se de que o módulo Magisk incluído nas releases está ativo para que o Swappiness e o Governor persistam após o reboot.
3.  **Magisk Mount Namespace:** Em algumas versões do Magisk, é necessário garantir que o app tenha visibilidade global:
    * Abra o **Magisk** > **Configurações**.
    * Selecione **"Namespace de Montagem Global"** (Global Mount Namespace).
    * Reinicie o dispositivo.

---

### 🇺🇸 English
For **ZRAM/Swap** features to work properly:

1.  **BusyBox:** It is highly recommended to have BusyBox installed (via Magisk module or app) to ensure compatibility with Shell commands (`mkswap`, `swapon`, `grep`).
2.  **Persistence Module:** Ensure the included Magisk module is active so that Swappiness and Governor settings persist after reboot.
3.  **Magisk Mount Namespace:** On some Magisk versions, you must ensure that the app has system-wide visibility:
    * Open **Magisk** > **Settings**.
    * Select **"Global Mount Namespace"**.
    * Reboot your device.

---

### 🇧🇷 Português
Este app ainda está em desenvolvimento.

### 🇺🇸 English
This app is still in development.