#!/bin/sh
KEYFILE=/root/tarsnap.key
USER=ben
USERHOME=/home/ben

echo "Decrypting the tarsnap key, enter root password:"
su --command "mv $KEYFILE `echo $KEYFILE`.old && gpg --output $KEYFILE --decrypt tarsnap.key.gpg"
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
WPA_SUPPLICANT_ARCHIVE="$(sudo tarsnap --list-archives --keyfile $KEYFILE | grep wpa_supplicant | sort | tail -1)"
cd / && sudo tarsnap -xf $WPA_SUPPLICANT_ARCHIVE --keyfile $KEYFILE

cd $USERHOME && git clone --bare git@bitbucket.org:socksy/dotfiles.git $USERHOME/.cfg
if [ $? != 0 ]; then
  echo "Dotfiles already have been cloned in $USERHOME"
  exit 1
fi;


# already in the .zshrc so no need to worry about the locality here
function config {
  /usr/bin/env git --git-dir=$USERHOME/.cfg/ --work-tree=$USERHOME $@
}

config checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles successfully";
else
  echo "Backing up pre-existing files.";
  mkdir -p .config-backup
  config checkout 2>&1 | egrep "\s\s+" | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no

# Vim should work from first run due to how vimrc is written
echo "Installing spacemacs for .emacs.d"
git clone https://github.com/syl20bnr/spacemacs $USERHOME/.emacs.d

sudo ln -s $USERHOME/.vim /root/.vim
sudo ln -s $USERHOME/.vimrc /root/.vimrc
sudo ln -s $USERHOME/.gitconfig /root/.gitconfig

