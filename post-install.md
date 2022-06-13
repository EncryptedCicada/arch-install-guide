# Post Install Script

### These are my instructions/steps to customize your setup.

## Install more packages for gnome

        $ sudo pacman -S gnome-software-packagekit-plugin networkmanager-openvpn

## Aesthetic pacman output

Edit ``/etc/pacman.conf`` and append/uncomment the following lines under ``#Misc options``

        ...
        ILoveCandy
        Color
        CheckSpace
        ParallelDownloads = 5
        ...

**Note:** ``ParallelDownloads`` should be uncommented only if your internet speed is good enough to handle it. It can be incremented/decremented based on your system.

## Changing system shell

To set ``Xsh`` as default shell where ``X`` can be fi/z/da etc shell prefixes for fish/zsh/dash, do:
        
        $ chsh -s /usr/bin/Xsh

_TIP:_ For a barely modified fish shell copy needed contents from ``config.fish`` file in this repository and add them to the end of ``~/.config/fish/config.fish``

For fish or zsh shell also install ``pkgfile``
        
        $ sudo pacman -S pkgfile

Start ``pkgfile`` autoupdate timer	

        $ sudo systemctl enable pkgfile-update.timer

If installing ``zsh``, do:

        $ paru -S zsh fzf zsh-syntax-highlighting zsh-autosuggestions zsh-completions zsh-history-substring-search pkgfile

For the changes to take effect, Logout and login once and open terminal again to go through the setup for zsh (select defaults to start with)

Edit ``.zshrc``

        $ nano ~/.zshrc

Append the following lines at the respective sections or at the end of the file

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

_TIP:_ If you want garuda like ``zsh`` or ``fish`` shell prompt, copy file ``starship.toml`` from config folder of this repository and paste it in ``~/.config`` on your PC.

## Customizing bash prompt using starship

Get necessary packages for customizing terminal

        $ paru -S starship ttf-iosevka-nerd

To setup starship prompt on bash do:

        $ cd ~/
        $ nano .bashrc

Append the lines at the end of the file

        eval "$(starship init bash)"

Save and exit (``Ctrl+X`` followed by ``Shift+Y`` and ``RETURN``). This takes effect on subsequent terminal launches (Reboot preferred)

_TIP:_ See more presets [here](https://starship.rs/presets/).

## Configure reflector

Reflector is a utility that when enabled to run periodicallty, automatically sorts the fastest mirrors by region and adds them to the pacman mirrorlist. This helps keep pacman downloads fast.

Open terminal and run

        $ sudo nano /etc/xdg/reflector/reflector.conf

Append the following lines to the file

        --save /etc/pacman.d/mirrorlist
        --country India,Pakistan
        --protocol https
        --latest 5

Save and close the file.

Enable reflector service

        $ sudo systemctl enable reflector.timer

## Configure timeshift and autosnaps

Install ``timeshift-autosnap`` package if not already installed

        $ paru -S timeshift-autosnap

Open ``timeshift`` and complete the initial setup

For ``timeshift-autosnap`` backups appearing in grub automatically install ``grub-btrfs``

        $ sudo pacman -S grub-btrfs

## Setup specific for Dell G5 SE 

For temperature monitoring and fan control enable the ``dell-smm-hwmon`` module in kernel

        $ sudo nano /etc/modules-load.d/dell-smm-hwmon.conf
        
Append the following line in the file

        dell-smm-hwmon

Save and exit the file.

Create a ``.conf`` file

        $ sudo nano /etc/modprobe.d/dell-smm-hwmon.conf

Add the following lines in the file before saving and exiting

        # This file must be at /etc/modprobe.d/
        options dell-smm-hwmon restricted=0 ignore_dmi=1

Install ``nbfc-linux`` for fan control
        
        $ paru -S dmidecode nbfc-linux

Enter configs directory for nbfc-linux:

        $ cd /usr/share/nbfc/configs/

Find the config file

        $ ls | grep "Dell\ G5\ SE\ 5505.json"

If the output is like ``Dell G5 SE 5505.json`` then skip this step otherwise do:

        $ sudo wget https://raw.githubusercontent.com/EncryptedCicada/arch-install-guide-Dell-G5-SE/main/config/nbfc-linux/Dell%20G5%20SE%205505.json
        $ cd ~/

Set the config and start ``nbfc``

        $ sudo nbfc config --set "Dell G5 SE 5505"
        $ sudo nbfc start

Enable ``nbfc`` startup at boot

        $ sudo systemctl enable nbfc_service

**NOTE:** S3 sleep (Suspend-to-RAM) can be enabled via bios injection, see readme for more information

## Enable wayland

### For chromium based browsers

- Open browser and enter ``chrome://flags`` in the ``URL``  
- Change flag ``Preferred Ozone platform`` to ``Auto``
- If using pipewire (we are, in this guide) also change ``WebRTC PipeWire support`` to ``Enabled``

### For Firefox

        $ cd ~/.config
        
If the folder doesn't exist make it with
        
        $ cd ~/ && mkdir .config && cd .config

Check if ``environment.d`` folder exists with ``$ ls | grep "environment.d"``

If it doesn't exists then make the directory with ``$ mkdir environment.d``
        
Enter the directory
        
        $ cd environment.d

Check if ``envvars.conf`` exists with ``$ ls | grep "envvars.conf"``

If it doesn't exist then make file with ``$ touch envvars.conf``

Edit the ``envvars.conf`` file

        $ nano envvars.conf

Add the following line

        MOZ_ENABLE_WAYLAND=1

**NOTE:** No other display managers except ``GDM`` (for Gnome) and ``SDDM`` (for KDE Plasma) supporting Wayland sessions provide support for sourcing systemd user environment variables yet. Hence, this method can only work with Gnome or KDE Plasma.
        
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

_TIP:_ Reference ``envvars.conf`` file is located [here](https://github.com/EncryptedCicada/arch-install-guide-Dell-G5-SE/raw/main/config/environment.d/envvars.conf)

## Setup plymouth

Install necessary packages

        $ paru -S plymouth-git gdm-plymouth

Append `sd-plymouth` to the ``HOOKS`` in ``/etc/mkinitcpio.conf`` after ``base`` and ``systemd`` for it to function

        $ sudo nano /etc/mkinitcpio.conf

The resulting line should look like

        HOOKS=(base systemd sd-plymouth ...)

The Kernel Command line must have the following parameters (already set during [installing the bootloader](https://github.com/EncryptedCicada/arch-install-guide/blob/main/install-script.md#installing-bootloader) in ``Install Script``):

        quiet splash vt.global_cursor_default=0

Install extra plymouth themes from AUR, for example

        $ paru -S plymouth-theme-sweet-arch-git

See all installed themes with

        $ plymouth-set-default-theme -l

Change the default theme(``spinner``) with something else by editing the ``plymouthd.conf`` located in ``/etc/plymouth/`` to your theme listed by the previous command

        $ sudo nano /etc/plymouth/plymouthd.conf

Example setup can be like:

        [Daemon]
        Theme=sweet-arch
        ShowDelay=0
        DeviceTimeout=8

Initrd must be regenerated after changing the theme for it to take affect with the following command (change ``sweet-arch`` to the theme you're setting)

        $ sudo plymouth-set-default-theme -R sweet-arch

**NOTE:** On systems that boot quickly, you may only see a flicker of your splash theme before your DM or login prompt is ready. You can set ``ShowDelay`` to an interval (in seconds) longer than your boot time to prevent this.

## Adding entensions to Gnome

To add and work with extensions on gnome first install the native connector for extentions to work

        $ paru -S chrome-gnome-shell
        
Install the ``extension-manager`` app to manage extensions:

        $ paru -S extension-manager

Alternatively you can do the following:

- Add the extension to chrome/chromium based browsers from [here](https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep)
- Go to [extentions.gnome.org](extentions.gnome.org) to add extentions to gnome

### My curated extensions:

1. [Blur My Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)
2. [Just Perfection](https://extensions.gnome.org/extension/3843/just-perfection/)
3. [Espresso](https://extensions.gnome.org/extension/4135/espresso/)
4. [Vitals](https://extensions.gnome.org/extension/1460/vitals/)
5. [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/)
6. [Gamemode](https://extensions.gnome.org/extension/1852/gamemode/)

_TIP:_ Visit github pages of respective extensions to know more

## Install flatpaks for some applications

Search for each package in the gnome software app and install from there

        clapper
        fractal
        fragments
        gdm settings
        dynamic wallpaper
        gnome text editor
