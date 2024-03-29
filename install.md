# Install Guide
### Prerequisites:
- ArchLinux bootable USB
- Working internet connection

### **Author's note: The information in this document is adapted from Arch Wiki and various other sources and is tested working as of writing this. If necessary, please raise an issue from the issues tab.**

*Please boot into the ISO to proceed*

## Setting keyboard layout

The default keyboard layout/console keymap is US. If you don't want to change the default, skip this step or else if you want to list all available keymaps do:

	$ ls /usr/share/kbd/keymaps/**/*.map.gz

To change to another keymap append a corresponding file name (*from the command above*) to ``loadkeys``, omitting path and file extension.
*Example, to set a German keyboard layout:*

	$ loadkeys de-latin1

## Check network connectivity

Ensure your network interface is listed and enabled:

	$ ip link

### Connect to a network:

- Ethernet—plug in the cable.

- Wi-Fi—authenticate to the wireless network using ``iwctl``.

		$ iwctl
	
	*Connect to your network:

		[iwd]# device list

	Replace *device-name* with the device name from previous command

		[iwd]# station device-name scan
	
	Initiate a scan for networks (note that this command will not output anything):

		[iwd]# station device-name get-networks

	List all available networks:
	
		[iwd]# station device-name get-networks

	Connect to a network (replace *SSID* with the SSID of the network you wish to connect to):

		[iwd]# station device-name connect SSID

- Mobile broadband modem—connect to the mobile network with the ``mmcli`` utility.
	
	List the modems and find the modem's index:
	
		$ mmcli -L

	Look for ``/org/freedesktop/ModemManager1/Modem/MODEM_INDEX``
	
	Connect to the mobile network (Replace internet.myisp.example with your ISP's provided APN):

		$ mmcli -m MODEM_INDEX --simple-connect="apn=internet.myisp.example"

	If a user name and password is required, set them accordingly:

		$ mmcli -m MODEM_INDEX --simple-connect="apn=internet.myisp.example,user=user_name,password=your_password"

Proceed after getting a working internet connection.

## Partitioning

List available/detected drives with:

	$ fdisk -l

Select the drive where you want to install the system (``/dev/sdX`` where 'X' can be anything. I have ``nvme0n1`` in my case instead of ``sdX``)

	$ DRIVE=/dev/nvme0n1

Wipe disk

	$ sgdisk --zap-all $DRIVE

Create partitions (Change values of partitions accordingly by modifying the command. I've a 3GiB EFI partition, 16GiB Swap, and the rest is my root partition)

	$ sgdisk --clear \
	        --new=1:0:+3G --typecode=1:ef00 --change-name=1:EFI \
	        --new=2:0:+16GiB --typecode=2:8200 --change-name=2:swap \
	        --new=3:0:0 --typecode=3:8300 --change-name=3:system \
	          $DRIVE

View and verify the partion table
	
	$ lsblk -o +PARTLABEL

Format EFI Partition

	$ mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

Make and enable swap
	
	$ mkswap -L swap /dev/disk/by-partlabel/swap
	$ swapon -L swap

Format system partition as btrfs and create subvolumes

	$ mkfs.btrfs --label system /dev/disk/by-partlabel/system
	$ o_btrfs=defaults,ssd,noatime,autodefrag,space_cache=v2,discard=async
	$ mount -t btrfs LABEL=system /mnt
	$ btrfs subvolume create /mnt/@
	$ btrfs subvolume create /mnt/@home
	$ btrfs subvolume create /mnt/@srv
	$ btrfs subvolume create /mnt/@log
	$ btrfs subvolume create /mnt/@tmp
	$ btrfs subvolume create /mnt/@root
	$ btrfs subvolume create /mnt/@cache
	$ btrfs subvolume create /mnt/@pkg
	$ btrfs subvolume create /mnt/@.snapshots

Unmount system partiton

	$ umount -R /mnt

Re-mount system partition with correct parameters and mount points for subvolumes

	$ mount -o subvol=@,$o_btrfs LABEL=system /mnt
	$ mkdir /mnt/{boot,home,var,root,srv}
	$ mkdir /mnt/var/{log,tmp,cache}
	$ mkdir /mnt/.snapshots
	$ mount -o subvol=@home,$o_btrfs LABEL=system /mnt/home
	$ mount -o subvol=@srv,$o_btrfs LABEL=system /mnt/srv
	$ mount -o subvol=@root,$o_btrfs LABEL=system /mnt/root
	$ mount -o subvol=@log,$o_btrfs LABEL=system /mnt/var/log
	$ mount -o subvol=@tmp,$o_btrfs LABEL=system /mnt/var/tmp
	$ mount -o subvol=@cache,$o_btrfs LABEL=system /mnt/var/cache
	$ mkdir /mnt/var/cache/pacman
	$ mkdir /mnt/var/cache/pacman/pkg
	$ mount -o subvol=@pkg,$o_btrfs LABEL=system /mnt/var/cache/pacman/pkg
	$ mount -o subvol=@.snapshots,$o_btrfs LABEL=system /mnt/.snapshots

Mount boot partition
	
	$ mount LABEL=EFI /mnt/boot

## Install base system

	$ pacstrap /mnt base linux linux-firmware linux-headers btrfs-progs wpa_supplicant networkmanager mkinitcpio neovim sudo nano git base-devel

## Generate fstab

	$ genfstab -L -p /mnt >> /mnt/etc/fstab

Check fstab

	$ cat /mnt/etc/fstab

## Chroot into installed system

	$ arch-chroot /mnt

### Date and time setup

Turn on NTP synchronization

	$ timedatectl set-ntp true

List timezones and pick one

	$ timedatectl list-timezones

Finally set your timezone replacing ``Asia/Kolkata`` with what you picked

	$ timedatectl set-timezone Asia/Kolkata

	$ ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

Set hardware clock from system clock

	$ hwclock --systohc

### Setup locales

Edit /etc/locale.gen and uncomment ``en_IN``, ``en_GB.UTF8`` and other needed locales (my locales are India specific and fallback locale is UK Eng, please google your own locales)

	$ nano /etc/locale.gen

Uncomment the required lines (*Example of my setup*):

	...
	en_GB.UTF-8 UTF-8  
	#en_GB ISO-8859-1  
	...
	#en_IL UTF-8  
	en_IN UTF-8  
	...

Generate the locales by running:

	$ locale-gen

Create the ``/etc/locale.conf`` file

	$ nano /etc/locale.conf

Set the ``LANG`` variable accordingly (Paste the following lines making your own edits):
	
	LANG=en_IN.UTF-8
	LANGUAGE=en_IN:en_GB:en
	LC_TIME=en_IN.UTF-8

Save and exit.

Set the keyboard layout for console by editing ``/etc/vconsole.conf``:

	$ nano /etc/vconsole.conf

Example:

	KEYMAP=us

### Setup hostname

Hostname is the name of your PC on the network. Set hostname replacing ``myhostname`` for your desired hostname:

	$ hostnamectl set-hostname myhostname

Set hostname and setup ``/etc/hosts`` file

	$ echo myhostname > /etc/hostname

Edit ``/etc/hosts`` file

	$ nano /etc/hosts

Append the following lines

	127.0.0.1       localhost
	::1             localhost
	127.0.1.1       myhostname.localhost  myhostname

### Accounts setup

*NOTE*: Some people including me can skip the next step if they don't want to setup a password for root account. Some distros like Ubuntu do this by default to prevent newbies from breaking the system and to prevent root exploits. This guide still covers steps to provide elevated privilege to the standard user using sudo.

Setup root password (Process to disable root password is described later)

	$ passwd

Add a user account (replace ``username`` with your username)

	$ USER=username
	$ useradd -m -G wheel $USER
	$ passwd $USER

Edit the sudoers file to give access to added user for elevated previlidges:

	$ EDITOR=nano visudo

Find and uncomment the line ``# %wheel ALL=(ALL) ALL``.
The edited line should look like:

	%wheel ALL=(ALL) ALL

### Install necessary packages

	$ pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber gnome-firmware bpytop cups \
          ttf-liberation noto-fonts noto-fonts-emoji bash-completion curl wget qt5-wayland \
          qt6-wayland glfw-wayland android-tools asp bat bluez-utils bluez qemu-desktop libvirt edk2-ovmf \
	  dnsmasq iptables-nft virt-manager hunspell-en_gb libreoffice-fresh hyphen-en flatpak ccache \
	  gdb glibc wireless-regdb jdk-openjdk man-db meld micro mpd neofetch obs-studio papirus-icon-theme \
	  pdfarranger qt5ct reflector uget img2pdf libva-vdpau-driver dmidecode swtpm firewalld gamemode

Install graphics drivers (some drivers are specific to AMD Cards)

	$ pacman -S mesa vulkan-radeon vulkan-mesa-layers xf86-video-amdgpu libva-mesa-driver mesa-vdpau

### Install an AUR Helper

Login as ``$USER`` and install the ``paru`` AUR helper

	$ su $USER
	$ cd ~/
	$ mkdir {Downloads,Documents,Videos,Pictures,Music,Applications}
	$ cd Downloads
	$ git clone https://aur.archlinux.org/paru-bin.git
	$ cd paru-bin
	$ makepkg -si

After installation is successful, run:

	$ paru --gendb
	$ cd ~/Downloads
	$ rm -rf paru-bin

Use ``paru`` to install essential packages from AUR

	$ paru -S brave-bin heroic-games-launcher-bin pfetch nerd-fonts-cascadia-code \
        nerd-fonts-fira-code nerd-fonts-jetbrains-mono nerd-fonts-sf-mono switcheroo-control \
	teams-insiders tangram timeshift visual-studio-code-bin

Exit user account

	$ exit
	
Install microcode packages for your CPU (replace amd with intel if you have an intel CPU)

	$ pacman -S amd-ucode

Add ``$USER`` to ``libvirt`` group

	$ usermod -aG libvirt $USER

### ``Initramfs`` changes

Enable KMS for your GPU

	$ nano /etc/mkinitcpio.conf

*NOTE:* If you're installing a desktop environment like Gnome, sometimes GDM doesn't start automatically. Setting KMS is neccessary in that case.

Edit the line that has ``MODULES=()`` and add the following in the beginning just after the bracket (Replace ``amdgpu`` with your driver module):

	MODULES=(amdgpu ...)

Replace busybox init with systemd while in the ``mkinitcpio.conf`` file. The line ``HOOKS=(...)`` should look like:

	HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block btrfs filesystems fsck)

Generate initramfs

	$ mkinitcpio -P
	
### Installing bootloader

**NOTE:** This guide includes 2 options for bootloaders, ``GRUB`` and ``systemd-boot``. Follow the respective section to install either of them.

- Installing ``systemd-boot`` bootloader

		$ bootctl --path=/boot install

	Configuring loader

	*TIP:* A basic loader configuration file is located at */usr/share/systemd/bootctl/loader.conf*

		$ nano /boot/loader/loader.conf

	Add the following lines to the file (Do not use TAB in the file. Only SPACES are recognised)

		default archlinux.conf
		editor no
		auto-entries 1
		auto-firmware 1
		console-mode max
		
	Adding loader entries

	*TIP:* An example entry file is located at ``/usr/share/systemd/bootctl/arch.conf``

		$ cd /boot/loader/entries
		$ archlinux.conf archlinux-fallback.conf
		
	Edit the default entry

		$ nano archlinux.conf

	Add the following lines to the file

		title Arch Linux
		linux /vmlinuz-linux
		initrd /amd-ucode.img
		initrd /initramfs-linux.img
		options root="LABEL=system" rw rootflags=subvol=/@

	Edit fallback entry

		$ nano archlinux-fallback.conf

	Add the following lines to the file

		title Arch Linux (fallback initramfs)
		linux /vmlinuz-linux
		initrd /amd-ucode.img
		initrd /initramfs-linux-fallback.img
		options root="LABEL=system" rw rootflags=subvol=/@

	*NOTE:* Make sure to replace the line in both entries with amd-ucode.img with whatever you have installed earlier. Please remove the line in you have not installed anything.

	Enable automatic updates of systemd-boot bootloader

		$ systemctl enable systemd-boot-update.service

- Installing ``GRUB`` bootloader

		$ pacman -S grub dosfstools efibootmgr os-prober mtools

	Install grub to *esp* partition

		$ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

	Setup basic grub config

		$ grub-mkconfig -o /boot/grub/grub.cfg

**General TIP 1:** To hide all kernel messages popping up on screen at boot time append the following to the kernel command line after ``rw``.

	quiet splash vt.global_cursor_default=0 loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3

- For ``systemd-boot`` do

		$ nano /boot/loader/entries/entry_name.conf

	Edit the options line like

		options root="LABEL=system" rw rootflags=subvol=/@ quiet splash vt.global_cursor_default=0 loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3

	Repeat this for other entries if you like.

- For ``GRUB`` do
		
		$ nano /etc/default/grub

	Edit the ``GRUB_CMDLINE_LINUX_DEFAULT`` line like

		GRUB_CMDLINE_LINUX_DEFAULT="quiet splash vt.global_cursor_default=0 loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3"

	Regenerate the config

		$ grub-mkconfig -o /boot/grub/grub.cfg

**General TIP 2:** If your system supports hibernate (suspend-to-disk) add the following line to your kernel command line parameters before logging specifiers like ``quiet/splash``.
	
	resume=/dev/swap-partition

**General TIP 3:** If your system has an AMD CPU, Zen2 and above (please check for prerequisites on google), and you want to enable AMD P-State driver, add amd_pstate=active to the commandline. It is recommended to install the `linux-zen` kernel and `linux-zen-headers` packages to use AMD P-State and make the following changes to separate loader entry files for this kernel.
	
	options root="LABEL=system" rw rootflags=subvol=/@ quiet ... rd.udev.log_level=3 amd_pstate=active

### Enable extra repos

Enable ``multilib`` repo

	$ nano /etc/pacman.conf

Look for line that says '#[multilib]'
Uncomment the line and the ``Include`` statement that follows. It should look like:

	...
	[multilib]
	Include = /etc/pacman.d/mirrorlist
	...

Install packages having dependencies on multilib repo

	$ su $USER
	$ paru -Sy wine-staging wine-gecko wine-mono winetricks bottles vkd3d proton-ge-custom-bin
	$ exit

### Disk Improvements

**Warning:** Users need to be certain that their SSD supports TRIM before attempting to use it. Data loss can occur otherwise!

To verify TRIM support, run:

	$ lsblk --discard

Check the values of DISC-GRAN (discard granularity) and DISC-MAX (discard max bytes) columns. Non-zero values indicate TRIM support.

If your disk has trim support then enable fstrim timer

	$ systemctl enable fstrim.timer

### Enable essential services

Enable bluetooth, ssh, firewall, libvirt, NTP, Network Manager, and CUPS Socket Detection services

	$ systemctl enable bluetooth
	$ systemctl enable sshd
	$ systemctl enable firewalld
	$ systemctl enable libvirtd
	$ systemctl enable systemd-timesyncd
	$ systemctl enable NetworkManager
	$ systemctl enable cups.socket

### Install Desktop

Install WM/DM of choice. *Example to install Gnome:*

	$ pacman -S gnome

Enable the display manager (replace 'gdm' with your desktop specific login manager service):

	$ systemctl enable gdm

Install Gnome specific packages:

	$ pacman -S geary gnome-connections gnome-mines gnome-sound-recorder gnome-tweaks gnome-usage power-profiles-daemon
	
### Install timeshift-autosnap

	$ su $USER
	$ paru -S timeshift-autosnap
	$ exit

### Disable root password

**NOTE:** Do not do this if you have not created any user yet.

For people who wish to disable password for root account do

	$ sudo usermod -p '!' root

This sets root to have a disabled password.

### Exit chroot

	$ exit
Or do ``Ctrl+D``

## Unmount all partitions

	$ umount -R /mnt

## Reboot into the newly installed system type:

	$ reboot

Alternatively, to shutdown
	
	$ shutdown now

Remember to remove the installation medium and then login into the new system with the user/root account.

Proceed to the [post-install](https://github.com/EncryptedCicada/arch-install-guide/blob/main/post-install.md) guide to continue.
