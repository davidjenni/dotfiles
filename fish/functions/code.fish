function code
    set -l appName "Visual Studio Code"
    if test (count $argv) -eq 0
        open -a $appName
    else
        if string match '/*' $argv
            echo "absolute path"
            set -g fileOrFolder $argv[1]
        else
            echo "relative path"
            set -g fileOrFolder (pwd)/$argv[1]
        end
        echo "fileOrFolder = $fileOrFolder"
        open -a $appName --args "$fileOrFolder"
    end
end
