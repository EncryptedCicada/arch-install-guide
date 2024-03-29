# Post Install Guide

### These are my instructions/steps to customize your setup.

## Install openvpn add-on for gnome network settings

        $ sudo pacman -S networkmanager-openvpn

## Aesthetic pacman output

Edit `/etc/pacman.conf` and append/uncomment the following lines under `#Misc options`

        ...
        ILoveCandy
        Color
        CheckSpace
        ParallelDownloads = 5
        ...

**Note:** `ParallelDownloads` should be uncommented only if your internet speed is good enough to handle it. It can be incremented/decremented based on your system.

## Changing system shell

To set `Xsh` as default shell where `X` can be fi/z/da etc shell prefixes for fish/zsh/dash, do:
        
        $ chsh -s /usr/bin/Xsh

_TIP:_ For a barely modified fish shell copy needed contents from `config.fish` file in this repository and add them to the end of `~/.config/fish/config.fish`. If you want garuda like `fish` shell prompt, copy file `starship.toml` from config folder of this repository and paste it in `~/.config` on your PC (requires `starship` package to be installed).

For installing `zsh` or any other shell (bash is preinstalled), do (replace zsh with shell name):

        $ paru -S zsh

For the changes to take effect, Logout and login once. For `zsh` go through the setup  and select defaults to start with.

## Customizing zsh shell using [`prezto`](https://github.com/sorin-ionescu/prezto/tree/master)

Get necessary packages for customizing shell

        $ paru -S prezto-git

Make sure the current working directory is the home directory using:

        $ cd ~

Edit and add the following lines to the `.zpreztorc` file:

        zstyle ':prezto:load' pmodule 'node' 'history' 'syntax-highlighting' 'history-substring-search' 'autosuggestions' 'utility' 'git' 'node' 'completion' 'prompt'
        zstyle ':prezto:module:prompt' theme 'pure'
        zstyle ':prezto:module:terminal' auto-title 'yes'

It is recommended to restart your PC for the changes to take effect. Please refer to prezto repository for instruction on how to change themes and customise other aspects of the shell.

## Customizing bash prompt using [`starship`](https://starship.rs/)

Get necessary packages for customizing prompt

        $ paru -S starship ttf-iosevka-nerd

To setup starship prompt on bash do:

        $ cd ~/
        $ nano .bashrc

Append the lines at the end of the file

        eval "$(starship init bash)"

Save and exit (`Ctrl+X` followed by `Shift+Y` and `RETURN`). This takes effect on subsequent terminal launches (Reboot preferred)

_TIP:_ See more presets [here](https://starship.rs/presets/).

## Configure reflector

Reflector is a utility that when enabled to run periodicallty, automatically sorts the fastest mirrors by region and adds them to the pacman mirrorlist. This helps keep pacman downloads fast.

Open terminal and run

        $ sudo nano /etc/xdg/reflector/reflector.conf

Append the following lines to the file

        --save /etc/pacman.d/mirrorlist
        --country India,Pakistan,China,Hong\ Kong,Bangladesh,Singapore,
        --protocol http,https
        --latest 5
        --age 12

Save and close the file.

Enable reflector service

        $ sudo systemctl enable reflector.timer

To run reflector, do:

        $ sudo systemctl start reflector.timer

## Setup specific for Dell G5 SE 

There are two ways to control fans on this device, [DellG5SE-Fan-Linux](https://github.com/DavidLapous/DellG5SE-Fan-Linux) or [nbfc-linux](https://github.com/nbfc-linux/nbfc-linux). Please read through the sources to check what is best for you.

### To use DellG5SE-Fan-Linux

        $ paru -S dell-g5se-fanctl

And enable the sleep service:

        $ sudo systemctl enable dell-g5se-fanctl-sleep.service

### To use NBFC Linux

Enable the `dell-smm-hwmon` module in kernel by creating the following file:

        $ sudo touch /etc/modules-load.d/dell-smm-hwmon.conf

Open the file for editing

        $ sudo nano /etc/modules-load.d/dell-smm-hwmon.conf
        
Append the following line in the file

        dell-smm-hwmon

Save and exit the file.

Create and edit a `.conf` file as follows

        $ sudo nano /etc/modprobe.d/dell-smm-hwmon.conf

Add the following lines in the file before saving and exiting

        # This file must be at /etc/modprobe.d/
        options dell-smm-hwmon restricted=0 ignore_dmi=1

Install `nbfc-linux` for fan control
        
        $ paru -S dmidecode nbfc-linux

Enter configs directory for nbfc-linux:

        $ cd /usr/share/nbfc/configs/

Find the config file

        $ ls | grep "Dell\ G5\ SE\ 5505.json"

If the output is like `Dell G5 SE 5505.json` then skip this step otherwise do:

        $ sudo wget https://raw.githubusercontent.com/EncryptedCicada/arch-install-guide-Dell-G5-SE/main/config/nbfc-linux/Dell%20G5%20SE%205505.json
        $ cd ~/

Set the config and start `nbfc`

        $ sudo nbfc config --set "Dell G5 SE 5505"
        $ sudo nbfc start

Enable `nbfc` startup at boot

        $ sudo systemctl enable nbfc_service

**NOTE:** S3 sleep (Suspend-to-RAM) can be enabled via bios injection, see readme for more information

## Enable wayland

### For chromium based browsers (might be redundant in the future)

- Open browser and enter `chrome://flags` in the `URL`  
- Change flag `Preferred Ozone platform` to `Auto`
- If using pipewire (we are, in this guide) also change `WebRTC PipeWire support` to `Enabled`

### For Firefox

        $ cd ~/.config
        
If the folder doesn't exist make it with
        
        $ cd ~/ && mkdir .config && cd .config

Check if `environment.d` folder exists with `$ ls | grep "environment.d"`

If it doesn't exists then make the directory with `$ mkdir environment.d`
        
Enter the directory
        
        $ cd environment.d

Check if `envvars.conf` exists with `$ ls | grep "envvars.conf"`

If it doesn't exist then make file with `$ touch envvars.conf`

Edit the `envvars.conf` file

        $ nano envvars.conf

Add the following line

        MOZ_ENABLE_WAYLAND=1

**NOTE:** No other display managers except `GDM` (for Gnome) and `SDDM` (for KDE Plasma) supporting Wayland sessions provide support for sourcing systemd user environment variables yet. Hence, this method can only work with Gnome or KDE Plasma.
        
## Install ccache

        $ sudo pacman -S ccache

For extra setup read https://wiki.archlinux.org/title/ccache

## Install adwaita style theme for qt applications

        $ sudo pacman -S adwaita-qt5 adwaita-qt6
        
Edit systemd user environment variables config

        $ nano ~/.config/environment.d/envvars.conf

Append the following lines to the file

        QT_SELECT=6
        QT_QPA_PLATFORM=wayland
        QT_QPA_PLATFORM_PLUGIN_PATH=/usr/lib/qt/plugins
        QT_QPA_PLATFORMTHEME=qt5ct

_TIP:_ Reference `envvars.conf` file is located [here](https://github.com/EncryptedCicada/arch-install-guide-Dell-G5-SE/raw/main/config/environment.d/envvars.conf)

## Setup plymouth

Install necessary packages

        $ paru -S plymouth

Append `plymouth` to the `HOOKS` in `/etc/mkinitcpio.conf` after `base` and `systemd` for it to function

        $ sudo nano /etc/mkinitcpio.conf

The resulting line should look like

        HOOKS=(base systemd plymouth ...)

The Kernel Command line must have the following parameters (already set during [installing the bootloader](https://github.com/EncryptedCicada/arch-install-guide/blob/main/install.md#installing-bootloader) in `Install Guide`):

        quiet splash vt.global_cursor_default=0

Install extra plymouth themes from AUR, for example

        $ paru -S plymouth-theme-sweet-arch-git

See all installed themes with

        $ plymouth-set-default-theme -l

Change the default theme(`spinner`) with something else by editing the `plymouthd.conf` located in `/etc/plymouth/` to your theme listed by the previous command

        $ sudo nano /etc/plymouth/plymouthd.conf

Example setup can be like:

        [Daemon]
        Theme=sweet-arch
        ShowDelay=0
        DeviceTimeout=8

Initrd must be regenerated after changing the theme for it to take affect with the following command (change `sweet-arch` to the theme you're setting)

        $ sudo plymouth-set-default-theme -R sweet-arch

**NOTE:** On systems that boot quickly, you may only see a flicker of your splash theme before your DM or login prompt is ready. You can set `ShowDelay` to an interval (in seconds) longer than your boot time to prevent this.

## Customize grub

Download catpuccin theme for grub (you can search for other themes on google and follow those steps)

        $ cd ~/Downloads && git clone https://github.com/catppuccin/grub.git && cd grub
        $ sudo cp -r src/* /usr/share/grub/themes/
        
Uncomment and edit `GRUB_THEME`option in `/etc/default/grub` like

        $ sudo nano /etc/default/grub

And change the line to:

        GRUB_THEME="/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt"
        
Update grub

        $ sudo grub-mkconfig -o /boot/grub/grub.cfg

## Keychron keyboards setup

**For Fn row fix**

Create and edit `hid_apple.conf` in `/etc/modprobe.d`

        $ sudo touch /etc/modprobe.d/hid_apple.conf
        $ sudo nano /etc/modprobe.d/hid_apple.conf
        
Add the following lines to the file 

        options hid_apple fnmode=2
        
Regenerate initramfs
        
        $ sudo mkinitcpio -P

**For enabling bluetooth fast connect**

Uncomment and set line `FastConnectable` in `/etc/bluetooth/main.conf` to `true`

        $ sudo nano /etc/bluetooth/main.conf
        
The line should look like:

        FastConnectable = true
        
_Reboot for the changes to take effect_

## Adding entensions to Gnome
       
- Install the `extension-manager` app to manage extensions:

        $ paru -S extension-manager

- Alternatively you can install the following package:

        $ paru -S chrome-gnome-shell

  Subsequently add the extension to chrome/chromium based browsers from [here](https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep), then go to [extentions.gnome.org](extentions.gnome.org) to add extentions to gnome

### My curated extensions:

1. [Blur My Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
2. [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/)
3. [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
4. [Vitals](https://extensions.gnome.org/extension/1460/vitals/)
5. [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/)
6. [Gamemode](https://extensions.gnome.org/extension/1852/gamemode/)

_TIP:_ Visit github pages of respective extensions to know more

## Install flatpaks for some applications

Search for each package in the gnome software app and install from there.

Some useful application:

- Clapper
- Fragments
- Login Manager Settings
