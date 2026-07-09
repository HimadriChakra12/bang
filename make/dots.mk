LN   := ln -sf
DOTS := $(HOME)/bang/dots
CONF := $(HOME)/.config

mime:
	-$(LN) "$(DOTS)/mimeapps.list" "$(CONF)/mimeapps.list"
mango:
	-$(LN) "$(DOTS)/mango" "$(CONF)/mango"
mpv:
	-$(LN) "$(DOTS)/mpv" "$(CONF)/mpv"
foot:
	-$(LN) "$(DOTS)/foot" "$(CONF)/foot"
waybar:
	-$(LN) "$(DOTS)/waybar" "$(CONF)/waybar"
pkgit:
	-$(LN) "$(DOTS)/pkgit" "$(CONF)/pkgit"
swayimg:
	-$(LN) "$(DOTS)/swayimg" "$(CONF)/swayimg"
bashrc:
	-$(LN) "$(DOTS)/.bashrc" "$(HOME)/.bashrc"
tmux:
	-$(LN) "$(DOTS)/.tmux.conf" "$(HOME)/.tmux.conf"
