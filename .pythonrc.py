try:
    import readline
    import rlcompleter
except ImmportError:
    print("Need modules \'readline\', \'rlcompleter\'")
else:
    if 'libedit' in readline.__doc__:
        readline.parse_and_bind("bind ^I rl_complete")
    else:
        readline.parse_and_bind("tab: complete")
