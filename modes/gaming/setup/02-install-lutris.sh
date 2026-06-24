#!/usr/bin/env bash
#
# Installs Lutris via its official PPA — Ubuntu's universe package is
# typically several versions behind, and Lutris' install-script database
# (the thing that auto-fixes known-troublesome non-Steam Windows apps) is
# tied to the app version, so staying current matters here.

set -euo pipefail

echo -e "\033[36mAdding the Lutris PPA...\033[0m"
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo apt-get update

echo -e "\033[36mInstalling Lutris...\033[0m"
sudo apt-get install -y lutris

echo -e "\033[32mLutris installed. Launch with: lutris\033[0m"
