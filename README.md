# watchnmirror
Bash script to watch-n-mirror a source directory to a destination directory with arbitrary ownership

```
# ==========================================
# Watch a source directory and copy files to
# destination directory with the provided
# ownership and privelages. Should be run
# as sudo to enable managing destination
# ownership and priveleges.
# 
# Requires inotifywait to be installed
#
# Arguments 
#   -s, --source
#       Source path
#   -d, --destination
#       Destination path
#   -u, --user
#       User for destination path
#   -g, --group
#       Group for destination path
#
# ==========================================
```
