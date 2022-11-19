#!/usr/bin/env bash

if [ "${USER}" = "root" ]; then
	# shellcheck disable=2016
	echo 'Do not run script as root to preserve ${USER}!' >&2
	exit 1
fi

dnf="sudo dnf -y"
user_home=$HOME

rpmfusion=("https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" "rpmfusion-nonfree-release-tainted")
packages=(kitty zsh vim nvim exa wofi eww fontconfig lxpolkit git git-delta cargo npm node python pip)
drivers=(intel-media-driver libva-intel-drivers broadcom-wl)

$dnf install "${rpmfusion[@]}"
$dnf install "${packages[@]}"

$dnf install "${drivers[@]}"
$dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"

$dnf groupupdate core
$dnf groupupdate sound-and-video
$dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

$dnf groupupdate "C Development Tools and Libraries"

git clone "https://github.com/Daxtorim/Dotfiles.git" "${user_home}/Dotfiles"
. "${user_home}/Dotfiles/shell-env"

# Lunarvim
echo "# Installing Lunarvim ###########################################"
lvim_installer=$(mktemp)
curl -s "https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh" --output "$lvim_installer"
chmod +x "$lvim_installer"
LV_BRANCH='release-1.2/neovim-0.8' "${lvim_installer} -y"
rm -f "$lvim_installer"


# Hyprland
echo "# Installing Hyprland ###########################################"
$dnf install meson cmake "pkgconfig(cairo)" "pkgconfig(egl)" "pkgconfig(gbm)" "pkgconfig(gl)" "pkgconfig(glesv2)" "pkgconfig(libdrm)" "pkgconfig(libinput)" "pkgconfig(libseat)" "pkgconfig(libudev)" "pkgconfig(pango)" "pkgconfig(pangocairo)" "pkgconfig(pixman-1)" "pkgconfig(vulkan)" "pkgconfig(wayland-client)" "pkgconfig(wayland-protocols)" "pkgconfig(wayland-scanner)" "pkgconfig(wayland-server)" "pkgconfig(xcb)" "pkgconfig(xcb-icccm)" "pkgconfig(xcb-renderutil)" "pkgconfig(xkbcommon)" "pkgconfig(xwayland)" glslang-devel
hyprland_dir="${user_home}/Documents/Repositories/Hyprland"
mkdir -p "$hyprland_dir"
git clone --recursive https://github.com/hyprwm/Hyprland "$hyprland_dir"
cd "$hyprland_dir" || exit
sudo make install
cd ~ || exit
sudo cp "${user_home}/Dotfiles/hypr/.local/share/hypr/hyprland_wrapped.desktop" "/usr/share/applications"


"${user_home}/Dotfiles/update.sh --refresh"
