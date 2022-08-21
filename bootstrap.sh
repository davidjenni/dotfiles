#!/bin/bash
this="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"

myGitHub='https://github.com/davidjenni/dotfiles.git'
dotPath=$HOME/dotfiles


createBackupDir() {
    local _thisTime=`date "+%y%m%d-%H%M%S"`
    local _bkpDir=$HOME/bootstrapBackups-$_thisTime

    mkdir $_bkpDir
    echo $_bkpDir
}

getRepository() {
    pushd $HOME
    local repo=$1
    echo "Cloning git repo from: $repo"
    echo "      into local repo: $dotPath"
    git clone --recursive $repo $dotPath
    popd
}

saveLink() {
    local srcFile=$1
    local targetFile=$2
    if [ -s "$targetFile" ]
    then
        # don't just move, do copy to break any previous soft link
        cp -vL "$targetFile" $bkpDir/
        rm -f "$targetFile"
    fi
    ln -sf $srcFile "$targetFile"
}

saveLinkRecursive() {
    local srcFile=$1
    local targetDirParent=$2
    local targetDir="${targetDirParent}/$3"
    if [ -d $targetDir ]
    then
        # don't just move, do copy to break any previous soft link
        cp -vLR $targetDir $bkpDir/
        if [ -L $targetDir ]
        then
            # don't rm recursively since the symbolic link is only a file level link
            rm -f $targetDir
        else
            rm -rf $targetDir
        fi
    fi
    ln -sf $srcFile $targetDirParent
}

doSetup() {
    # generate git secrets file:
    local _gitSecretsFile=$HOME/.gitSecrets.sh
    local _gitEmail
    echo "Enter email address to be used with Git (empty string will skip creating $_gitSecretsFile)."
    echo "   email: \c"
    read _gitEmail
    if [ "$_gitEmail" != "" ]; then
        local _defaultGitUser=$USER@`hostname -s`
        local _gitUser
        echo "Enter user name to be used with Git (default is $_defaultGitUser)."
        echo "    name: \c"
        read _gitUser
        if [ "$_gitUser" = "" ]; then
            echo "default user"
            _gitUser=$_defaultGitUser
        fi

        cat << EndOfSecrets > $_gitSecretsFile
export GIT_AUTHOR_NAME="$_gitUser"
export GIT_AUTHOR_EMAIL="$_gitEmail"
export GIT_COMMITTER_NAME=\$GIT_AUTHOR_NAME
export GIT_COMMITTER_EMAIL=\$GIT_AUTHOR_EMAIL
EndOfSecrets

        echo "Git secrets file created: $_gitSecretsFile"
    fi

    bkpDir=$(createBackupDir)
    echo Original dot files will be saved away under: $bkpDir
    echo

    saveLink $dotPath/gitconfig $HOME/.gitconfig
    # neovim
    local nvimDir=$HOME/.config/nvim
    if [ ! -d "$nvimDir" ] ; then
        mkdir -p $nvimDir
    fi
    saveLink $dotPath/init.lua $nvimDir/init.lua
    # local vscodeDir="$HOME/Library/Application Support/Code/User"
    # if [ -d "$vscodeDir" ] ; then
    #     saveLink $dotPath/code.user.settings.json "$HOME/settings.json"
    # fi

    saveLink $dotPath/bash/os.gitconfig $HOME/.os.gitconfig
    saveLink $dotPath/bash/os.hgrc $HOME/.os.hgrc
    saveLink $dotPath/bash/profile $HOME/.profile
    saveLink $dotPath/bash/bashrc $HOME/.bashrc
    saveLink $dotPath/bash/inputrc $HOME/.inputrc
    saveLink $dotPath/bash/pythonrc.py $HOME/.pythonrc.py
    saveLink $dotPath/bash/tmux.conf $HOME/.tmux.conf
    saveLink $dotPath/bash/liquidpromptrc $HOME/.liquidpromptrc

    # fish:
    local fishConfigDir=~/.config/fish
    if [ ! -d "$fishConfigDir" ] ; then
        mkdir -p $fishConfigDir
    fi
    saveLink $dotPath/fish/config.fish $fishConfigDir/config.fish
    saveLinkRecursive $dotPath/fish/functions $fishConfigDir functions
}

# main:
if [ $1 = "setup" ]; then
    doSetup
else
    getRepository $myGitHub
    echo do clean setup
    doSetup
fi

