#!/usr/bin/env bash
set -euo pipefail
echo "============================================="
echo "-----| CLONNING FLUTTER |-----"
echo "============================================="
if [[ ! -d "$HOME/flutter" ]]; then
  git clone https://github.com/flutter/flutter.git -b stable ~/flutter
fi

echo "============================================="
echo "-----| INSTALL FVM |-----"
echo "============================================="
if [[ "$SHELL" != "$(command -v fvm)" ]]; then
  curl -fsSL https://fvm.app/install.sh | bash
fi

echo "============================================="
echo "-----| INSTALL ANDROID DEV ENV |-----"
echo "============================================="
mkdir -p ~/Android/cmdline-tools
cd ~/Android/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-9477386_latest.zip
rm -rf cmdline-tools latest
mv cmdline-tools latest
sdkmanager --licenses 
sdkmanager "platform-tools"
sdkmanager "platforms;android-36"
sdkmanager "build-tools;28.0.3"
sdkmanager "system-images;android-34;google_apis;x86_64"
sdkmanager "emulator"

echo "============================================="
echo "-----| INSTALL ANDROID AVD |-----"
echo "============================================="
avdmanager create avd \
    -n "Pixel_6_API_34" \
    -k "system-images;android-34;google_apis;x86_64" \
    -d "pixel_6"
avdmanager list avd
echo "hw.keyboard=yes" >> ~/.android/avd/Pixel_6_API_34.avd/config.ini
echo "hw.gpu.enabled=yes" >> ~/.android/avd/Pixel_6_API_34.avd/config.ini

echo "============================================="
echo "-----| CONFIGURE ANDROID UDEV |-----"
echo "============================================="
sudo usermod -aG adbusers $USER
newgrp adbusers
sudo systemctl restart systemd-udevd

