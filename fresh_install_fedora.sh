#!/usr/bin/env bash
# shellcheck disable=1091

if [ "${USER}" = "root" ]; then
	# shellcheck disable=2016
	echo 'Do not run script as root to preserve ${USER}!' >&2
	exit 1
fi

dnf="sudo dnf -y"
user_home=$HOME

rpmfusion=("https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" "rpmfusion-nonfree-release-tainted")
packages=(kitty zsh vim neovim exa wofi dunst fontconfig lxpolkit blueman git git-delta npm node python pip)
drivers=(intel-media-driver libva-intel-drivers broadcom-wl bluez bluez-utils)

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

git clone "https://github.com/Daxtorim/Dotfiles.git" "${user_home}/Dotfiles"
. "${user_home}/Dotfiles/shell-env"

echo
echo
echo "##########################################################"
echo "#                   Installing Rust                      #"
echo "##########################################################"
rust_installer=$(mktemp)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs --output "${rust_installer}" || exit 11
chmod +x "${rust_installer}"
${rust_installer} -y --no-modify-path --default-toolchain nightly --profile default
rm -f "${rust_installer}"

echo
echo
echo "##########################################################"
echo "#                 Installing Lunarvim                    #"
echo "##########################################################"
lvim_installer=$(mktemp)
curl -sSf "https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh" --output "${lvim_installer}" || exit 11
chmod +x "$lvim_installer"
LV_BRANCH='release-1.2/neovim-0.8' "${lvim_installer}" -y
rm -f "$lvim_installer"

echo
echo
echo "##########################################################"
echo "#                 Installing Hyprland                    #"
echo "##########################################################"
$dnf install meson cmake "pkgconfig(cairo)" "pkgconfig(egl)" "pkgconfig(gbm)" "pkgconfig(gl)" "pkgconfig(glesv2)" "pkgconfig(libdrm)" "pkgconfig(libinput)" "pkgconfig(libseat)" "pkgconfig(libudev)" "pkgconfig(pango)" "pkgconfig(pangocairo)" "pkgconfig(pixman-1)" "pkgconfig(vulkan)" "pkgconfig(wayland-client)" "pkgconfig(wayland-protocols)" "pkgconfig(wayland-scanner)" "pkgconfig(wayland-server)" "pkgconfig(xcb)" "pkgconfig(xcb-icccm)" "pkgconfig(xcb-renderutil)" "pkgconfig(xkbcommon)" "pkgconfig(xwayland)" glslang-devel
hyprland_dir="${user_home}/Documents/Repositories/Hyprland"
mkdir -p "$hyprland_dir"
git clone --recursive https://github.com/hyprwm/Hyprland "$hyprland_dir"
cd "$hyprland_dir" || exit 10
sudo make install || exit 11
cd ~ || exit 10
sudo cp "${user_home}/Dotfiles/hypr/.local/share/hypr/hyprland_wrapped.desktop" "/usr/share/applications"

echo
echo
echo "##########################################################"
echo "#         Installing Elkowar's whacky widgets            #"
echo "##########################################################"
eww_dir="${user_home}/Documents/Repositories/eww"
git clone https://github.com/elkowar/eww.git "${eww_dir}"
cd "${eww_dir}" || exit 10
cargo build --release --no-default-features --features=wayland || exit 11
cp target/release/eww "${user_home}/.cargo/bin"
cd || exit 10

# tell system to use temporary IPv6 addresses
sudo tee -a "/etc/sysctl.d/40-ipv6.conf" &> /dev/null << EOF

# generate and use temporary addresses (RFC3041)
# valid_lft=48h | prefered_lft=12h
# preferred is intentionally misspelled

net.ipv6.conf.all.accept_ra=1
net.ipv6.conf.all.addr_gen_mode=3
net.ipv6.conf.all.use_tempaddr=2
net.ipv6.conf.all.temp_prefered_lft=43200
net.ipv6.conf.all.temp_valid_lft=172800

net.ipv6.conf.default.accept_ra=1
net.ipv6.conf.default.addr_gen_mode=3
net.ipv6.conf.default.use_tempaddr=2
net.ipv6.conf.default.temp_prefered_lft=43200
net.ipv6.conf.default.temp_valid_lft=172800
EOF

"${user_home}/Dotfiles/update.sh --refresh"
sudo reboot
