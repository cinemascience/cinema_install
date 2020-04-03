# Cinema installation repository

Modules that help install Cinema viewers

# Quick install command (WIP):
For this to work, cd to a directory with any number of cinema databases (directories whose name ends with \*.cdb)
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
