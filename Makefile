include make/command.mk
include make/pkg.mk

PATH        := $(HOME)/pkg:$(PATH)
PKG         = $(HOME)/pkg

help:
	@echo "	make reflector [Reflector Setup]"
	@echo "	make pkg       [Pkg Setup]"
	@echo "	make firefox   [Firefox Setup]"
	@echo "	make wallpaper [Wallpaper Setup]"
	@echo "	make nvim      [Nvim Setup]"
	@echo "	make remove    [Remove Unwanted Packages]"
	@echo "	make clean     [Root Clean]"


reflector:
	@echo "Installing reflector..."
	@$(PACMAN) -S $(NOC) reflector
	@echo "Backing up current mirrorlist..."
	@sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
	@echo "Generating optimized mirrorlist..."
	@sudo reflector $(REFARG)
	@echo "Enabling reflector systemd timer..."
	@$(CTL) enable reflector.timer
	@$(CTL) start reflector.timer
	@$(PACMAN) -Syy
	@echo "Mirrorlist updated and automatic updates enabled."

makepath:
	mkdir -p $(PKG)
	cd $(PKG)

makepkg: $(addprefix $(PKG)/,$(MAKEREPOS))
$(PKG)/%:
	@[ -d $@ ] || $(GG) $(URL)/$* $@;
	@cd $@ && $(MAKE_INSTALL)

inpkg: $(addprefix $(PKG)/.in-,$(INREPOS))
$(PKG)/.in-%:
	@[ -d $(PKG)/$* ] || $(GG) $(URL)/$* $(PKG)/$*;
	@cd $(PKG)/$* && $(INSH)
	@touch $@

remove:
	$(PACMAN) -R $(PKGRM)

pkg: makepath makepkg inpkg remove

dots:
	$(SH) dots.sh

firefox:
	@$(GG) --no-single-branch $(URL)/$(USC) $(PKG)/$(USC)
	@cd $(PKG)/$(USC) && for branch in $$(git branch -r | grep -v HEAD | grep -v master | grep -v main | sed 's/origin\///'); do git checkout -b $$branch origin/$$branch; done
	@git checkout -b main
	@bash firefox.sh

nvim:
	@$(PACMAN) -S $(NEED) nvim
	@$(GG) $(URL)/himstart.nvim  $HOME/.config/nvim

wallpaper:
	@swaybg -i $(HOME)/bang/Standing.png -m fill &

clean:
	sudo paccache -r
	$(PACMAN) -Scc --noconfirm
	@orphans=$$($(PACMAN) -Qtdq); \
	if [ -n "$$orphans" ]; then \
		$(PACMAN) -Rns $(NOC) $$orphans; \
	else \
		echo "No orphaned packages found."; \
	fi
	sudo journalctl --vacuum-size=500M
	sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;
	sudo rm -rf /tmp/* /var/tmp/*
	if command -v docker &> /dev/null; then \
		echo "[6/10] Pruning unused Docker objects..."; \
		sudo docker system prune -a --volumes -f; \
	fi
	sudo rm -rf /var/cache/*
	sudo find /root -type f -size +50M -exec ls -lh {} \; | awk '{ print $$9 ": " $$5 }'
	sudo du -hxd1 /opt | sort -h | awk '$$1 ~ /[0-9]M|G/ {print}'

all: reflector pkg dots firefox nvim wallpaper
.PHONY: reflector makepath makepkg inpkg pkg remove dots firefox nvim wallpaper clean
