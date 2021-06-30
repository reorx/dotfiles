===========
My Dotfiles
===========

Inspired and borrowed much from `mathiasbynens's dotfiles
<https://github.com/mathiasbynens/dotfiles>`_.


Installation
============

You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with `~/dotfiles` as a symlink.) The bootstrapper script will pull in the latest version and copy the files to your home folder::

    git clone https://github.com/mathiasbynens/dotfiles.git && cd dotfiles && ./bootstrap.sh

To update, `cd` into your local `dotfiles` repository and then::

    ./bootstrap.sh init

Alternatively, to update while avoiding the confirmation prompt::

    ./bootstrap.sh init -f

If you just want to reset one dotfile target, use `reset`::

    ./bootstrap.sh reset zsh

To update later on, just run that command again.


TODO
====

- Python working environment deployment
    * Python source code download and install, basic Python working environment implementation (easy_install, virtualenv . etc).

- complete user customizable prompts in `init` command
    * store user choices in file, read from it later in other commands


DONE
====
- check and install software before dotfiles are linked.
- deal with oh-my-zsh in zsh implementation.


Relationship between .profile, .bash_profile, .bashrc
=====================================================

Below are quotes from two articles:

    `.bash_profile vs .bashrc
    <http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html>`_.

    `An Explanation of .bashrc and .bash_profile
    <http://hacktux.com/bash/bashrc/bash_profile>`_.


According to the bash man page, .bash_profile is executed for login shells, while .bashrc is executed for interactive non-login shells.

When you login (type username and password) via console, either sitting at the machine, or remotely via ssh: .bash_profile is executed to configure your shell before the initial command prompt.

But, if you've already logged into your machine and open a new terminal window (xterm) inside Gnome or KDE, then .bashrc is executed before the window command prompt. .bashrc is also run when you start a new bash instance by typing /bin/bash in a terminal.

Say, you'd like to print some lengthy diagnostic information about your machine each time you login (load average, memory usage, current users, etc). You only want to see it on login, so you only want to place this in your .bash_profile. If you put it in your .bashrc, you'd see it every time you open a new terminal window.

An exception to the terminal window guidelines is Mac OS X's Terminal.app, which runs a login shell by default for each new terminal window, calling .bash_profile instead of .bashrc. Other GUI terminal emulators may do the same, but most tend not to.

Most of the time you don't want to maintain two separate config files for login and non-login shells -- when you set a PATH, you want it to apply to both. You can fix this by sourcing .bashrc from your .bash_profile file, then putting PATH and common settings in .bashrc.


To do this, add the following lines to .bash_profile::

    if [ -f ~/.bashrc ]; then
       source ~/.bashrc
    fi

Now when you login to your machine from a console .bashrc will be called.

Login Shells (.bash_profile)

A login shell is a bash shell that is started with - or --login. The following are examples that will invoke a login shell::

    sudo su -

    bash --login

    ssh user@host

When BASH is invoked as a login shell, the following files are executed in the displayed order.

/etc/profile

~/.bash_profile

~/.bash_login

~/.profile


Although ~/.bashrc is not listed here, most default ~/.bash_profile scripts run ~/.bashrc.

Purely Interactive Shells (.bashrc)

Interactive shells are those not invoked with -c and whose standard input and output are connected to a terminal. Interactive shells do not need to be login shells. Here are some examples that will evoke an interactive shell that is not a login shell::

    sudo su

    bash

    ssh user@host /path/to/command

In this case of an interactive but non-login shell, only ~/.bashrc is executed. In most cases, the default ~/.bashrc script executes the system's /etc/bashrc.

Non-interactive shells

Non-interactive shells do not automatically execute any scripts like ~/.bashrc or ~/.bash_profile. Here are some examples of non-interactive shells::

    su user -c /path/to/command

    bash -c /path/to/command


Be warned that you should never echo output to the screen in a ~/.bashrc file. Otherwise, commands like `ssh user@host /path/to/command` will echo output unrelated to the command called.


.. _BashMan: http://linux.die.net/man/1/bash

__ BashMan_

From `Bash Man Page`__
======================

Files

``/bin/bash``
    The bash executable

``/etc/profile``
    The systemwide initialization file,
    executed for login shells

``~/.bash_profile``
    The personal initialization file,
    executed for login shells

``~/.bashrc``
    The individual per-interactive-shell startup file

``~/.bash_logout``
    The individual login shell cleanup file, executed when a login shell exits

``~/.inputrc``
    Individual readline initialization file

Proper way to implement on windows
----------------------------------

1. clone to $HOME

2. cmd::

    mklink /H _vimrc dotfiles\vimrc

    mklink /J .vim dotfiles\vim
