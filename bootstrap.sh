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
    if [ -s $targetFile ]
    then
        #echo "Saving $targetFile ..."
        # don't just move, do copy to break any previous soft link
        cp $targetFile $bkpDir/
        rm -f $targetFile
    fi
    ln -sf $srcFile $targetFile
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
            echo "defualt user"
            _gitUser=$_defaultGitUser
        fi

        cat << EndOfSecrets > $_gitSecretsFile
export GIT_AUTHOR_NAME='$_gitUser'
export GIT_AUTHOR_EMAIL='$_gitEmail'
export GIT_COMMITTER_NAME=\$GIT_AUTHOR_NAME
export GIT_COMMITTER_EMAIL=\$GIT_AUTHOR_EMAIL
EndOfSecrets

        echo "Git secrets file created: $_gitSecretsFile"
    fi

    bkpDir=$(createBackupDir)
    echo Original dot files will be saved away under: $bkpDir
    echo

    saveLink $dotPath/gitconfig $HOME/.gitconfig
    saveLink $dotPath/hgrc $HOME/.hgrc
    saveLink $dotPath/vimrc $HOME/.vimrc

    saveLink $dotPath/bash/os.gitconfig $HOME/.os.gitconfig
    saveLink $dotPath/bash/os.hgrc $HOME/.os.hgrc
    saveLink $dotPath/bash/bashrc $HOME/.bashrc
    saveLink $dotPath/bash/inputrc $HOME/.inputrc
    saveLink $dotPath/bash/pythonrc.py $HOME/.pythonrc.py
    saveLink $dotPath/bash/tmux.conf $HOME/.tmux.conf
}

# main:
if [ $1 = "setup" ]; then
    doSetup
else
    getRepository $myGitHub
    echo do clean setup
    doSetup
fi

