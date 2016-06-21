from quaive/ploneintranet-base:venus
maintainer guido.stevens@cosent.net
run locale-gen en_US.UTF-8 nl_NL@euro
run useradd -m -d /app app && echo "app:app" | chpasswd && adduser app sudo
run mkdir /.npm && chown app.app /.npm
run mkdir /.config && chown app.app /.config
run mkdir /.cache && chown app.app /.cache
run mkdir /.local && chown app.app /.local
run echo venus > /etc/debian_chroot
cmd ["/bin/bash"]
