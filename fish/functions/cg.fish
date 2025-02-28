# cd to git root:
function cg
    set rootDir (git rev-parse --show-toplevel 2>&1)
    if test $status -eq 0
        cd $rootDir
    else
       echo "Not in a git repo."
    end
end
