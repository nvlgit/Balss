# Balss


Balss is an easy to use player for audiobook files with chapters such as m4b or mka. The goal of the Balss is that the following capabilities:
* Easy to use chapter time navigation
* Setup playback rate (including setup default playback rate)
* Capability to resume playback last played file from stopped position

![ScreenShot](https://user-images.githubusercontent.com/29505119/43223177-eb86f428-905a-11e8-96fc-e33a66e0a5ac.png)

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

