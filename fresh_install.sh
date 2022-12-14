#!/usr/bin/env bash
# shellcheck disable=1091

main()
{
	install_packages

	git clone --depth=1 "https://github.com/Daxtorim/Dotfiles.git" "${_INSTALL_HOME}/Dotfiles"
	sudo chsh -s "$(command -v zsh)" "${_INSTALL_USER}"

	. "${_INSTALL_HOME}/Dotfiles/shell-env"

	echo
	echo
	echo "##########################################################"
	echo "#                   Installing Rust                      #"
	echo "##########################################################"
	rust_installer=$(mktemp)
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs --output "${rust_installer}" || exit 11
	chmod +x "${rust_installer}"
	"${rust_installer}" -y --no-modify-path --default-toolchain nightly --profile default
	rm -f "${rust_installer}"

	echo
	echo
	echo "##########################################################"
	echo "#                 Installing Lunarvim                    #"
	echo "##########################################################"
	lvim_installer=$(mktemp)
	curl -sSf "https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh" --output "${lvim_installer}" || exit 11
	chmod +x "${lvim_installer}"
	LV_BRANCH='release-1.2/neovim-0.8' "${lvim_installer}" -y
	rm -f "${lvim_installer}"

	echo
	echo
	echo "##########################################################"
	echo "#                 Installing Hyprland                    #"
	echo "##########################################################"
	case "${_INSTALL_DISTRO}" in
		arch | endeavouros)
			sudo pacman --needed --noconfirm -S gdb ninja meson gcc cmake libxcb xcb-proto xcb-util xcb-util-errors xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland
			hyprland_dir="${_INSTALL_HOME}/Documents/Repositories/Hyprland"
			mkdir -p "${hyprland_dir}"
			git clone --recursive https://github.com/hyprwm/Hyprland "${hyprland_dir}"
			cd "${hyprland_dir}" || exit 10
			sudo make install || exit 11
			sudo cp "${_INSTALL_HOME}/Dotfiles/hypr/.local/share/hypr/hyprland_wrapped.desktop" "/usr/share/wayland-sessions/"
			;;

		fedora)
			sudo dnf copr enable kasion/Hyprland-git
			sudo dnf install hyprland "libdrm-2.4.114"
			;;
	esac

	echo
	echo
	echo "##########################################################"
	echo "#         Installing Elkowar's whacky widgets            #"
	echo "##########################################################"
	case "${_INSTALL_DISTRO}" in
		arch | endeavouros)
			sudo pacman --needed --noconfirm -S gtk-layer-shell
			;;
		fedora)
			sudo dnf install gtk-layer-shell
			;;
	esac
	eww_dir="${_INSTALL_HOME}/Documents/Repositories/eww"
	mkdir -p "${eww_dir}"
	git clone https://github.com/elkowar/eww.git "${eww_dir}"
	cd "${eww_dir}" || exit 10
	cargo build --release --no-default-features --features=wayland || exit 11
	cp target/release/eww "${_INSTALL_HOME}/.cargo/bin"

	# tell system to use temporary IPv6 addresses
	messages=(
		"# generate and use temporary addresses (RFC3041)"
		"# valid_lft=48h | prefered_lft=12h"
		"# preferred is intentionally misspelled"
		""
		"net.ipv6.conf.all.accept_ra=1"
		"net.ipv6.conf.all.addr_gen_mode=3"
		"net.ipv6.conf.all.use_tempaddr=2"
		"net.ipv6.conf.all.temp_prefered_lft=43200"
		"net.ipv6.conf.all.temp_valid_lft=172800"
		""
		"net.ipv6.conf.default.accept_ra=1"
		"net.ipv6.conf.default.addr_gen_mode=3"
		"net.ipv6.conf.default.use_tempaddr=2"
		"net.ipv6.conf.default.temp_prefered_lft=43200"
		"net.ipv6.conf.default.temp_valid_lft=172800"
	)
	printf "%s\n" "${messages[@]}" | sudo tee "/etc/sysctl.d/40-ipv6.conf" > /dev/null

	"${_INSTALL_HOME}/Dotfiles/update.sh" --stow-everything

	echo
	echo
	echo "############"
	echo "#   DONE   #"
	echo "############"
	echo
	echo "You might want to reboot as a final step!"
}

install_packages()
{

	case "${_INSTALL_DISTRO}" in
		fedora)
			rpmfusion=("https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" "rpmfusion-nonfree-release-tainted")
			packages=(kitty zsh vim neovim exa wofi dunst fontconfig lxpolkit blueman git git-delta npm node python pip)
			drivers=(intel-media-driver libva-intel-drivers broadcom-wl bluez bluez-utils)

			dnf="sudo dnf -y"

			$dnf install "${rpmfusion[@]}"
			$dnf upgrade
			$dnf install "${packages[@]}"

			wget "https://github.com/winterheart/broadcom-bt-firmware/releases/download/v12.0.1.1105_p4/broadcom-bt-firmware-12.0.1.1105.rpm"
			$dnf install "${drivers[@]}" "broadcom-bt-firmware-12.0.1.1105.rpm"
			$dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"
			rm -f "broadcom-bt-firmware-12.0.1.1105.rpm"

			$dnf groupupdate core
			$dnf groupupdate sound-and-video
			$dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
			$dnf groupupdate "C Development Tools and Libraries"
			;;

		arch | endeavouros)
			packages=(yay flatpak stow kitty zsh vim neovim exa wofi dunst fontconfig lxsession bluez bluez-utils blueman git git-delta npm nodejs python python-pip)

			pkg="sudo pacman --needed --noconfirm -S"

			$pkg -yu              # update
			$pkg "${packages[@]}" # install
			;;

	esac

}

keep_sudo_cached()
{
	while true; do
		sudo -v
		sleep 60
	done
}

setup()
{

	if [ "${EUID}" -eq 0 ]; then
		echo "Do not run script as root to preserve USER variable!"
	else
		_INSTALL_USER=$USER
		_INSTALL_HOME=$HOME

		distro_id=$(grep "^ID=" /etc/os-release)
		_INSTALL_DISTRO=${distro_id#*=}

		# Will need elevated privileges later
		sudo -v || exit 1
		keep_sudo_cached &
		PID=$!

		kill_pid()
		{
			kill "$PID"
			exit
		}

		trap kill_pid INT

		main

		kill_pid
	fi
}

setup
