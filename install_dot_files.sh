#!/usr/bin/env bash
set -x
KEYFILE="${TARSNAP_KEYFILE-/root/tarsnap.key}"
USER="${DOTFILES_USER-ben}"
USERHOME="${DOTFILES_USERHOME-/home/ben}"

# NB must be gpg v1!
command -v gpg >/dev/null 2>&1 || { echo "gpg not found, aborting" >&2; exit 1;}
command -v tarsnap >/dev/null 2>&1 || { echo "tarsnap not found, aborting" >&2; exit 1;}
command -v yadm >/dev/null 2>&1 || { echo "yadm not found, aborting" >&2; exit 1;}

echo "Decrypting the tarsnap key, enter root password:"
#su --command "mv $KEYFILE `echo $KEYFILE`.old && gpg --output $KEYFILE --decrypt tarsnap.key.gpg"
if [ $? != 0 ]; then
  echo "Failed decrypting tarsnap key, please check if $KEYFILE exists and has 700 permissions."
  exit 1
fi;

sudo chmod 700 $KEYFILE

# Gets the last version backed up of secrets on tarsnap
ARCHIVE="$(sudo tarsnap --list-archives --keyfile $KEYFILE | grep benixos-secrets | sort | tail -1)"
# Writes over existing files
mkdir -p $USERHOME && cd $USERHOME && sudo tarsnap -xf $ARCHIVE --keyfile $KEYFILE
sudo tarsnap -tf $ARCHIVE --keyfile $KEYFILE | xargs chown $USER

# Wifi Passwords
#WPA_SUPPLICANT_ARCHIVE="$(sudo tarsnap --list-archives --keyfile $KEYFILE | grep wpa_supplicant | sort | tail -1)"
#cd / && sudo tarsnap -xf $WPA_SUPPLICANT_ARCHIVE --keyfile $KEYFILE
# TODO use declarative network manager networks with sops or age secrets

yadm clone git@github.com:socksy/dotfiles.git
if [ $? != 0 ]; then
  echo "Error cloning dotfiles, aborting"
  exit 1
fi;

# Vim should work from first run due to how vimrc is written
echo "Installing Doom for .emacs.d"
git clone git@github.com:doomemacs/doomemacs.git $USERHOME/.emacs.d

sudo ln -s $USERHOME/.vim /root/.vim
sudo ln -s $USERHOME/.vimrc /root/.vimrc
mkdir -p /root/.config
sudo ln -s $USERHOME/.config/nvim /root/.config/nvim
sudo ln -s $USERHOME/.gitconfig /root/.gitconfig

