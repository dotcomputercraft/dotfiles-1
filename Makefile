INSTALL_FILES := ackrc autojump config gemrc gitconfig gitignore.global gvimrc hgrc irbrc lib oh-my-zsh pdbrc pentadactyl pentadactylrc railsrc screenrc subversion/servers vim vimrc vimpagerrc Xresources zlogin zshenv
# zshrc needs to get installed after submodules have been initialized
INSTALL_FILES_AFTER_SM := zshrc

install: install_files init_submodules install_files_after_sm

# Target to install a copy of .dotfiles, where Git is not available
# (e.g. distributed with rsync)
install_checkout: install_files install_files_after_sm

init_submodules:
	# Requires e.g. git 1.7.5.4
	git submodule update --init --recursive

install_files: $(addprefix ~/.,$(INSTALL_FILES))
install_files_after_sm: $(addprefix ~/.,$(INSTALL_FILES_AFTER_SM))
~/.%: %
	@echo ln -sfn $< $@
	@test -e $@ && echo "Skipping existing target: $@" || { mkdir -p $(shell dirname $@) && ln -sfn ${PWD}/$< $@ ; }

install_ppa:
	# TODO: make it work with missing apt-add-repository (Debian Squeeze)
	sudo apt-add-repository ppa:git-core/ppa

install_programs:
	sudo apt-get update
	sudo apt-get install aptitude
	sudo aptitude install console-terminus git rake vim-gnome xfonts-terminus xfonts-terminus-oblique exuberant-ctags
	# extra
	sudo aptitude install ttf-mscorefonts-installer
install_zsh:
	sudo aptitude install zsh

install_programs_rpm: install_zsh_rpm
	sudo yum install git rubygem-rake ctags
install_zsh_rpm:
	sudo yum install zsh

ZSH_PATH := /bin/zsh
ifneq ($(wildcard /usr/bin/zsh),)
	ZSH_PATH := /usr/bin/zsh
endif
ifneq ($(wildcard /usr/local/bin/zsh),)
	ZSH_PATH := /usr/local/bin/zsh
endif

setup: install_zsh setup_zsh
setup_zsh:
	# changing shell to zsh, if $$ZSH is empty (set by oh-my-zsh/dotfiles)
	[ "$(shell getent passwd $$USER | cut -f7 -d:)" != "${ZSH_PATH}" -o "$(shell zsh -i -c env|grep '^ZSH=')" != "" ] && chsh -s ${ZSH_PATH}
