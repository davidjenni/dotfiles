#!/usr/bin/env fish
function fish_greeting
    echo "Welcome to 🐳, $USER!"

    function linux_greeting
        # Debian-based distros:
        if test -f /etc/os-release
            echo (grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
            echo (grep '^VERSION=' /etc/os-release | cut -d= -f2 | tr -d '"')
        else
            echo "Linux"
            echo "unknown version"
        end
    end

    function macos_greeting
        echo (sw_vers -productName)
        echo (sw_vers -productVersion) build (sw_vers -buildVersion)
    end

    function unknown_greeting
        echo "Unknown OS"
        echo "unknown version"
    end

    switch (uname -s)
        case Linux
            set sys_info (linux_greeting)
        case Darwin
            set sys_info (macos_greeting)
        case '*'
    end
    # echo "name: $sys_info[1], version: $sys_info[2]"
    set -l os_name $sys_info[1]
    set -l os_version $sys_info[2]
    set -l kernel_version (uname -r)
    set -l machine_arch (uname -m)

    printf "Host:|$hostname\nOS:|$os_name-$os_version\nKernel:|$kernel_version\nArch:|$machine_arch\n" | column -t -s '|'
    echo "Uptime: $(uptime)"
    echo "Who:"
    echo "$(who -a)"
end
