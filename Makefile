PATH        := $(HOME)/pkg:$(PATH)

help:
	@echo "	make reflector [Reflector Setup]"
	@echo "	make pkg       [Pkg Setup]"
	@echo "	make pacstall  [Pacman Packages]"
	@echo "	make firefox   [Firefox Setup]"
	@echo "	make wallpaper [Wallpaper Setup]"
	@echo "	make nvim      [Nvim Setup]"
	@echo "	make remove    [Remove Unwanted Packages]"
	@echo "	make clean     [Root Clean]"

include make/command.mk
include make/pkg.mk
include make/dots.mk

dots: mime  mango  mpv  foot  waybar  pkgit  swayimg  bashrc

reflector:
	sudo cp $(DOTS)/pacman.conf /etc/pacman.conf
	@$(PACMAN) -Syyu
	@echo "Installing reflector..."
	@$(PACMAN) -S $(NOC) reflector
	@echo "Backing up current mirrorlist..."
	@sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
	@echo "Generating optimized mirrorlist..."
	@sudo reflector $(REFARG)
	@echo "Enabling reflector systemd timer..."
	@$(CTL) enable reflector.timer
	@$(CTL) start reflector.timer
	@$(PACMAN) -Syyu
	@echo "Mirrorlist updated and automatic updates enabled."

makepath:
	mkdir -p $(PKG)
	cd $(PKG)

mkpkg: $(addprefix $(PKG)/,$(MAKEREPOS))
$(PKG)/%:
	@[ -d $@ ] || $(GG) $(URL)/$* $@;
	@cd $@ && $(MAKE) && $(MAKEIN)

inpkg: $(addprefix $(PKG)/.in-,$(INREPOS))
$(PKG)/.in-%:
	@[ -d $(PKG)/$* ] || $(GG) $(URL)/$* $(PKG)/$*;
	@cd $(PKG)/$* && $(INSH)
	@touch $@

remove:
	-@$(PACMAN) -Rns $(PKGRM)

pkg: pacstall inpkg makepath mkpkg 

firefox:
	@$(GG) --no-single-branch $(URL)/$(USC) $(PKG)/$(USC)
	@cd $(PKG)/$(USC) && for branch in $$(git branch -r | grep -v HEAD | grep -v master | grep -v main | sed 's/origin\///'); do git checkout -b $$branch origin/$$branch; done
	@git checkout -b main
	@bash $(PKG)/userChrome/firefox.sh

nvim:
	@$(PACMAN) -S $(NEED) nvim
	@$(GG) $(URL)/himstart.nvim  $(HOME)/.config/nvim

wallpaper:
	@swaybg -i $(HOME)/bang/Standing.png -m fill &

clean:
	-sudo paccache -r
	-$(PACMAN) -Scc --noconfirm
	-@orphans=$$($(PACMAN) -Qtdq); \
	if [ -n "$$orphans" ]; then \
		$(PACMAN) -Rns $(NOC) $$orphans; \
	else \
		echo "No orphaned packages found."; \
	fi
	-sudo journalctl --vacuum-size=500M
	-sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
	-sudo rm -rf /tmp/* /var/tmp/*
	-if command -v docker &> /dev/null; then \
		echo "[6/10] Pruning unused Docker objects..."; \
		sudo docker system prune -a --volumes -f; \
	fi
	-sudo rm -rf /var/cache/*
	-sudo find /root -type f -size +50M -exec ls -lh {} \; | awk '{ print $$9 ": " $$5 }'
	-sudo du -hxd1 /opt | sort -h | awk '$$1 ~ /[0-9]M|G/ {print}'

homeclean:
	rm $(HOME)/Documents
	rm $(HOME)/Scripts
	rm $(HOME)/Backgorunds
	rm $(HOME)/Musics
	rm $(HOME)/Videos

timezone:
	sudo timedatectl set-timezone Asia/Dhaka

all: reflector pkg dots firefox nvim wallpaper remove homeclean

.PHONY: reflector makepath makepkg inpkg pkg remove dots firefox nvim wallpaper clean
