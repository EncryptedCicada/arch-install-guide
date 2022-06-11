#These are my steps to achieve my personal setup

#Edit /etc/pacman.conf and append the following lines under '#Misc options'
...
ILoveCandy
Color
CheckSpace
ParallelDownloads = 5
...

#Get necessary packages for customizing terminal
$ paru -S starship nerd-fonts-complete

#To set Xsh as default shell where x can be fi/z/da etc shell prefixes, do:
#chsh -s /usr/bin/Xsh

#For a barely modified fish shell copy needed contents from config.fish file in this repository and add them to the end of ~/.config/fish/config.fish	
#For fish or zsh shell also install 'pkgfile'
#sudo pacman -S pkgfile
#Start pkgfile autoupdate timer	
#sudo systemctl enable pkgfile-update.timer
#If installing zsh, do:
#paru -S zsh fzf zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search pkgfile
#For the changes to take effect, Logout and login once, open terminal,
#go through the setup for zsh, select defaults to start with and then run and append the code block that follows:
nano ~/.zshrc
...
## Plugins section: Enable fish style features
# Use syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Use autosuggestion
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#Use history substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Use fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Arch Linux command-not-found support, you must have package pkgfile installed
# https://wiki.archlinux.org/index.php/Pkgfile#.22Command_not_found.22_hook
[[ -e /usr/share/doc/pkgfile/command-not-found.zsh ]] && source /usr/share/doc/pkgfile/command-not-found.zsh

# Run neofetch at start
if [ -f /usr/bin/neofetch ]
then
        neofetch
fi

# Activate starship prompt if present
if [ -f /usr/bin/starship ]
then
        eval "$(starship init zsh)"
fi
...

#If you want garuda like zsh or fish shell prompt, copy file starship.toml from config folder of this repository and paste it in ~/.config on your PC.

#To setup starship (installed earlier) prompt on bash do:
cd ~/
nano .bashrc
#Append the following lines at the end of the file
...
eval "$(starship init bash)"
...
#Save and exit. Takes effect on subsequent terminal launches (Reboot preferred)
#To see more presets go to https://starship.rs/presets/

#Open terminal and run
sudo nano /etc/xdg/reflector/reflector.conf
#Append the following lines to the file
...
--save /etc/pacman.d/mirrorlist
--country India,Pakistan
--protocol https
--latest 5
...
#Save and close the file and run:
sudo systemctl enable reflector.timer

#Open timeshift and complete the initial setup

#Temperature monitoring and fan control for Dell G5 SE 5505
sudo nano /etc/modules-load.d/dell-smm-hwmon.conf
#Append the following lines
...
dell-smm-hwmon
...
#Save and exit the file. Create another file and append the proceeding lines:
sudo nano /etc/modprobe.d/dell-smm-hwmon.conf
...
# This file must be at /etc/modprobe.d/
options dell-smm-hwmon restricted=0 ignore_dmi=1
...
#To install nbfc-linux
paru -S dmidecode nbfc-linux
#Enter configs directory for nbfc-linux:
cd /usr/share/nbfc/configs/
#Find the config file
ls | grep "Dell\ G5\ SE\ 5505.json"
#If the comand returns the file then skip the next step otherwise do:
sudo wget https://raw.githubusercontent.com/EncryptedCicada/arch-install-guide-Dell-G5-SE/main/config/nbfc-linux/Dell%20G5%20SE%205505.json
cd ~/
#Set the config and start nbfc
sudo nbfc config --set "Dell G5 SE 5505"
sudo nbfc start
#Enable nbfc startup at boot
sudo systemctl enable nbfc_service

#S3 sleep (Suspend-to-RAM) can be enabled via bios injection, read readme for more information

#To enable wayland on browsers:
#For chromium based browsers
#Open browser and go to chrome://flags
#Change flag 'Preferred Ozone platform' to 'Auto'
#If using pipewire (we are, in this guide) also change 'WebRTC PipeWire support' to 'Enabled'
#For Firefox do
cd ~/.config
#If the folder doesn't exist make it with
#cd ~/ && mkdir .config && cd .config
#Check if environment.d folder exists
ls | grep "environment.d"
#If it doesn't exists then do
#mkdir environment.d
cd environment.d
#Check if envvars.conf exists
ls | grep "envvars.conf"
#If it doesn't exist then do
#touch envvars.conf
nano envvars.conf
#Add the following lines
...
MOZ_ENABLE_WAYLAND=1
...
NOTE: No other display managers except GDM (for Gnome) and SDDM (for KDE Plasma) supporting Wayland sessions
        provide support for sourcing systemd user environment variables yet (as of the latest commit).
        
#Install ccache
sudo pacman -S ccache
#For extra setup read (https://wiki.archlinux.org/title/ccache)

#Install adwaita style theme for qt applications
sudo pacman -S adwaita-qt5 adwaita-qt6
#Edit systemd user environment variables config
nano ~/.config/environment.d/envvars.conf
#Append the following lines to the file:
...
QT_SELECT=6
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORM_PLUGIN_PATH=/usr/lib/qt/plugins
QT_QPA_PLATFORMTHEME=qt5ct
...

#Pre-setup envvars.conf file is located at https://github.com/EncryptedCicada/arch-install-guide-Dell-G5-SE/raw/main/config/environment.d/envvars.conf

#To setup plymouth:
paru -S plymouth-git gdm-plymouth
#Append plymouth to the HOOKS in /etc/mkinitcpio.conf after base and systemd for it to function
sudo nvim /etc/mkinitcpio.conf
#The resulting line should look like:
...
HOOKS=(base systemd plymouth ...)
...

#Install extra plymouth themes from AUR, for example:
paru -S plymouth-theme-sweet-arch-git
#See all installed themes with:
plymouth-set-default-theme -l
#Change the default theme(spinner) with something else by editing the plymouthd.conf located in /etc/plymouth/ to your theme listed by the previous command:
sudo nvim /etc/plymouth/plymouthd.conf
#Example setup can be like:
...
[Daemon]
Theme=sweet-arch
ShowDelay=0
DeviceTimeout=8
...
#initrd must be regenerated after changing the theme for it to take affect with the following command
#change 'sweet-arch' to the theme you're setting:
sudo plymouth-set-default-theme -R sweet-arch
NOTE: On systems that boot quickly, you may only see a flicker of your splash theme before your DM or login prompt is ready.
#You can set ShowDelay to an interval (in seconds) longer than your boot time to prevent this flicker and only show a blank screen.

#To add and work with extensions on gnome
#First install the native connector for extentions to work with:
paru -S chrome-gnome-shell
#Install the extension-manager app (recommended):
paru -S extension-manager

#Alternatively you can do the following:
#Add extension to chrome/chromium based browsers like brave from https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep
#Go to extentions.gnome.org to add extentions to gnome
#My personally curated extensions (add one at a time and click install when prompted):
1. Blur My Shell
2. Just Perfection
3. Espresso
4. Vitals
5. GSConnect
6. Gamemode
#Visit github pages of respective extensions to know more
