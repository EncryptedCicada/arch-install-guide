# Arch Linux install guide

This guide aims to be the all-in-one beginner's setup guide for a non nerd who just wants an arch system setup and running with a little bit of eye candy too. It comes with all the info and commands with examples and notes to educate the user about the consecuences and affects of their commands. This is a personalized guide which can easily be modified where it needs to be and the steps for the same are mentioned within the guide. If in any way the end user gets hung up, he/she may visit [wiki.archlinux.org](https://wiki.archlinux.org)!

To start with the guide go to [`install.md`](https://github.com/EncryptedCicada/arch-install-guide/blob/main/install.md)

## Table of contents
* [General info](#general-info)
* [Reference specs](#my-laptop-specs)
* [Source](#sources)
* [Known issues](#known-issues)
* [TODO](#todo)
* [Disclaimer](#disclaimerwarning)

## General info
* Vanilla Arch
* Based on Gnome
* Difficulty level: Easy
* Filesystem: Btrfs(subvolumes) without encryption
* Plymouth and gnome-extensions included
* AUR helper: Paru

## My laptop specs
* Dell G5 15 SE 5505
* Ryzen 5 4600H
* Radeon RX 5600M
* 8Gb RAM (don't thrash me for this, I'll upgrade soon)
* Smartshift enabled
* Stock settings (will repaste and repad soon)
* BIOS 1.11.0

## Sources
* [ArchWiki](https://wiki.archlinux.org) - Arch Wiki is by far the most detailed and helpful piece of resource for someone finding it hard to follow this guide as this guide has been cherry-picked from the wiki.
* Web - Certain elements of the guide needed external web references for it to work properly or to enable me to understand the significance of some parts of the guide thoroughly.

## Known issues
### For people with the exact same hardware setup as mine: 
  * Problem: You may experience random system freezes. These are caused by improper implementation of drivers for our dGPU. The problem is that our dGPU turns off when not used and sometimes fails to wake up correctly and hence freezes the system. We have to restart the graphic stack to recover from it. That being said, it is a work in progress and is steadily improving.
  > Solution: add `amdgpu.runpm=0` to your kernel parameters to disable amdgpu's power management and hence preventing dGPU from sleeping at all. Edit the `/boot/loader/entries/archlinux.conf` and add `amdgpu.runpm=0` at the end of the `options` line w.r.t. this guide. Personally, I've not used this solution for a while and have occasional to no freezes as of kernel 5.12.14 (apart from 5.12.13 which has a gpu bug). Sticking to the latest stable kernel should improve stability.
To restart safely in the event of a freeze you may want to enable SysRq on your system. To do this, add a file '99-sysctl.conf' to '/etc/sysctl.d/' and append 'kernel.sysrq=1' and save it. This will enable you to safely reboot your system in case of a freeze with the following keystroke combination: `Ctrl+Alt+prtsc+R+E+I+S+U+B` [holding Ctrl+Alt+prtsc press the letters in the order one at a time]. For more info visit the [ArchWiki page on SysRq](https://wiki.archlinux.org/title/Keyboard_shortcuts#Kernel_(SysRq)).
  * Problem: The Dell G5SE-5505 laptop isn't working with usual fan managers. This results in higher operating temperatures in most cases.
  > Solution 1: [nbfc-linux](https://github.com/nbfc-linux/nbfc-linux) using steps in post-install script
  
  > Solution 2: [DellG5SE-Fan-Linux](https://github.com/DavidLapous/DellG5SE-Fan-Linux) by [DavidLapous](https://github.com/DavidLapous)

  * Problem: Dell hasn't enabled S3 sleep or Suspend-to-RAM feature in this laptop OOTB and to get it working we have to do bios injection.
  > Solution: [BIOS injection to enable S3 sleep guide](https://www.reddit.com/r/DellG5SE/comments/kpg3ez/how_to_disable_smartshift_and_enable_s3_sleep/)
  
### For others:
  * There might be hardware/software differences due to which device specific issues may arise. Please research about your device before making changes.
  * Some Dell users of XPS and inspiron series and/or devices of other vendors on older uefi firmware may not be able to run linux. The problem is with how the firmware handles the disk drives. This may/maynot be solved with a bios update.

## Todo
- [ ] Add screenshots
- Expand the guide to cover more tweaks and improvements.
  - [x] Add instructions to enable native wayland support in browsers
  - [x] Include bash prompt customisation instructions (using starship)
  - [ ] Include zsh install instructions and simple customization using prezto
  - [ ] Include instructions to setup encryption

## Disclaimer:warning:
This guide presumes that the user will be thorough with the text before beginning to execute the guide. If you think it's gonna mess up if you execute a random command, chances are it will actually mess everything up. Be careful with your keystrokes! I am, in no way responsible for the harm done to your PC resulting from not following the guide correctly and/or modifying the contents of the guide for personal use without prior knowledge of the consequences. That being said, this guide has been personally tested to account for any errors and I've successfully built my system using this guide. If there are any mistakes or errors in the guide, please open an issue for the same.
