# Cinema installation repository

Modules that help install Cinema viewers

# Quick install command (WIP):
This command will install a cinema_explorer (default) or cinema_compare viewer in the current directory:

With [curl](https://curl.haxx.se/):
Use cinema_explorer:
```
curl -s "https://raw.githubusercontent.com/EthanS94/cinema_install/wip_simple_install/install.sh" | bash /dev/stdin --explorer
```
Use cinema_compare:
```
curl -s "https://raw.githubusercontent.com/EthanS94/cinema_install/wip_simple_install/install.sh" | bash /dev/stdin --compare
```

With [wget](https://www.gnu.org/software/wget/):
Use cinema_explorer:
```
wget -qO - "https://raw.githubusercontent.com/EthanS94/cinema_install/wip_simple_install/install.sh" | bash /dev/stdin --explorer
```
Use cinema_compare:
```
wget -qO - "https://raw.githubusercontent.com/EthanS94/cinema_install/wip_simple_install/install.sh" | bash /dev/stdin --compare
```

# Specify the databases 
To specify databases, point the script at a text file containing the full path to each database.
```
curl -s "https://raw.githubusercontent.com/EthanS94/cinema_install/wip_simple_install/install.sh" | bash /dev/stdin --database_file /path/to/database_file
```

Databases should be separated by a newline. Example database_file contents:
```text
/home/tmp/some_directory/cinemadatabase1
/home/tmp/different_directory/cinemadatabase2
/home/tmp/cinemadatabase3
```

If a database file isn't given, the script will look in your current directory for any directories ending with `*.cdb` and use those.
