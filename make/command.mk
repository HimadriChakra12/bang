CTL         = sudo systemctl
GG          = git clone
PACMAN      = sudo pacman
NEED        = --needed
NOC         = --noconfirm

REFARG 		= \
			  --country "Singapore,India,Japan,South Korea,Hong Kong" \
			  --protocol https \
			  --latest 20 \
			  --sort rate \
			  --threads 20 \
			  --save /etc/pacman.d/mirrorlist
