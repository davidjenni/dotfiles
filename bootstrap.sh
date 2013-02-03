#!/bin/bash
this="$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")"

createBackupDir() {
    local _thisTime=`date "+%y%m%d-%H%M%S"`
    local _bkpDir=~/dotFiles.$_thisTime

    mkdir $_bkpDir
    echo $_bkpDir
}

getRepository() {
    pushd ~
    local repo=$1
    echo "Cloning git repo from: $repo"
    echo "      into local repo: $dotPath"
    git clone $repo $dotPath
    cd $dotPath
    git submodule update --init
    popd
}

saveLink() {
    local orgFile=~/.$1
    if [ -s "$orgFile" ]
    then
        echo "Saving $orgFile ..."
        # don't just move, do copy to break any previous soft link
        cp $orgFile $bkpDir/$1
        rm -f $orgFile
    fi
    ln $dotPath/$1 $orgFile
}

# main:
myGitHub='https://github.com/davidjenni/dotfiles.git'
declare -a dotFiles=( bashrc gitconfig gitignore inputrc pythonrc.py tmux.conf vimrc )
#dotPath=$(dirname $this)
dotPath=~/dotfiles

getRepository $myGitHub

bkpDir=$(createBackupDir)
echo Original dot files will be saved away under: $bkpDir
echo

for aFile in "${dotFiles[@]}"
do
    saveLink $aFile
done

cat << EndOfSecrets > ~/.secrets
# Set your git user info in .secrets and source it from your shell startup:
export GIT_AUTHOR_NAME='<add-your-name'
export GIT_AUTHOR_EMAIL='<add-your-email>'
export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITTER_EMAIL=$GIT_COMMITTER_EMAIL
EndOfSecrets

echo Make sure to edit ~/.secrets and customize to your name and email for GIT

