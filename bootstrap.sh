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
    local orgFile=~/$1
    if [ -s "$orgFile" ]
    then
        echo "Saving $orgFile ..."
        # don't just move, do copy to break any previous soft link
        cp $orgFile $bkpDir/$1
        rm $orgFile
    fi
    ln -s $dotPath/$1 $orgFile
}

# main:
myGitHub='git@github.com:w7cf/dotfiles.git'
declare -a dotFiles=( .bashrc .gitconfig .gitignore .inputrc .pythonrc.py .vimrc );
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

