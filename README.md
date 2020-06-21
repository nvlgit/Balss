# Balss


Balss is an easy to use player for audiobook files with chapters such as m4b or mka. The goal of the Balss is that the following capabilities:
* Easy to use chapter time navigation
* Setup playback rate (including setup default playback rate)
* Capability to resume playback last played file from stopped position

![ScreenShot](https://user-images.githubusercontent.com/29505119/46797894-10a78e80-cd59-11e8-8c1f-7d3041870cf9.png)

### Building and Installation

```bash
git clone https://gitlab.com/nvlgit/Balss.git && cd Balss
meson builddir --prefix=/usr && cd builddir
ninja
su -c 'ninja install'
```

### Build Dependencies
* gtk+-3.0 >= 3.22
* libmpv >= 0.28
* meson

### Run Dependencies
* libmpv >= 0.28


## Flatpak Building and Installation

Make temp dir
```bash
mkdir temp && cd temp
```
Build
```bash
wget https://gitlab.com/nvlgit/Balss/raw/master/com.gitlab.nvlgit.Balss.yml
flatpak-builder build-dir com.gitlab.nvlgit.Balss.yml
flatpak build-export my-repo build-dir
flatpak build-bundle my-repo Balss.flatpak com.gitlab.nvlgit.Balss
```
Install
```bash
flatpak install Balss.flatpak
```
Remove temp dir
```bash
cd .. && rm -R temp
```
