LN   := ln -sf
DOTS := $(HOME)/bang/dots
CONF := $(HOME)/.config

mime:
	-rm -rf "$(CONF)/mimeapps.list"
	-$(LN) "$(DOTS)/mimeapps.list" "$(CONF)/mimeapps.list"
mango:
	-rm -rf "$(CONF)/mango"
	-$(LN) "$(DOTS)/mango" "$(CONF)/mango"
mpv:
	-rm -rf "$(CONF)/mpv"
	-$(LN) "$(DOTS)/mpv" "$(CONF)/mpv"
foot:
	-rm -rf "$(CONF)/foot"
	-$(LN) "$(DOTS)/foot" "$(CONF)/foot"
waybar:
	-rm -rf "$(CONF)/waybar"
	-$(LN) "$(DOTS)/waybar" "$(CONF)/waybar"
pkgit:
	-rm -rf "$(CONF)/pkgit"
	-$(LN) "$(DOTS)/pkgit" "$(CONF)/pkgit"
swayimg:
	-rm -rf "$(CONF)/swayimg"
	-$(LN) "$(DOTS)/swayimg" "$(CONF)/swayimg"
bashrc:
	-rm -rf "$(HOME)/.bashrc"
	-$(LN) "$(DOTS)/.bashrc" "$(HOME)/.bashrc"
tmux:
	-rm -rf "$(HOME)/.tmux.conf"
	-$(LN) "$(DOTS)/.tmux.conf" "$(HOME)/.tmux.conf"
rdfm:
	-rm -rf "$(CONF)/rdfm"
	-$(LN) "$(DOTS)/rdfm" "$(CONF)/rdfm"
