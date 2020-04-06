#!/bin/bash

parse_args () {
  while [ "$1" != "" ]
  do
    case $1 in
      -c | --compare )
        shift
        compare=true
        ;;
      -e | --explorer )
        shift
        explorer=true
        ;;
      * )
        echo "Argument $1 not recognized! Exiting..."
        exit 1
        ;;
    esac
  done
}

cleanup () {
  [ -d ./cinema_install ] && rm -rf ./cinema_install
  exit $1
}

does_command_exist () {
  if ! command -v "$1" >/dev/null 2>&1; then
    if [ ! -z $2 ]; then
      echo "$1 was not found. Checking for $2..."
      sleep 1
      if ! command -v "$2" >/dev/null 2>&1; then
        echo "$1 and $2 were not found. At least one must be installed and added to your \$PATH"
        sleep 1
        cleanup 1
      else
        echo "$2 was found. Using $2..."
        sleep 1
        alias $1=$2
      fi
    else
      echo "$1 is not installed. It must be installed and added to your \$PATH"
      sleep 1
      cleanup 1
    fi
  fi
}

check_version () {
  if [ "$2" != "" ]; then
    if echo $2 $3 | awk '{ exit ($1 >= $2) }'; then
      echo "$1 of at least version $3 is needed. $2 is currently installed."
      sleep 1
      cleanup 1
    fi
  else
    echo "$1 version could not be found. Check if it is installed."
    sleep 1
    cleanup 1
  fi
}

clone_cinema_install () {
  echo "Cloning cinema_install repository..."
  if ! git clone --branch=wip_simple_install --depth=1 $github_repo;
  then
    echo "Git clone timed out. Proxy settings may be the reason. Trying again without any proxy settings..."
    if ! git clone -q -c http.proxy="" -c https.proxy="" --branch=wip_simple_install --depth=1 $github_repo;
    then
      echo "Failed to clone cinema_install. Make sure this works for you and try again:"
      echo "git clone --branch=wip_simple_install --depth=1 $github_repo'"
      echo "Exiting..."
      cleanup 1
    fi
  fi
  echo "Git clone successful"
}

install_cinema_viewer () {
  echo "Installing cinema_$viewer..."

  # Get all cdb's in current directory
  PWD=`pwd`
  dbs=(`ls -dp $PWD/*.cdb | grep /$ | sed 's/\/$//g'`)

  # Build a python dict string for all cdb's in current directory
  first="true"
  db_string="["
  for db in ${dbs[@]};
  do
    if [ $first = "true" ];
    then
      first="false"
      db_string="$db_string{\"path\" : \"$db\"}"
    else
      db_string="$db_string, {\"path\" : \"$db\"}"
    fi
  done
  db_string="$db_string]"

  # Run the python module
  eval "python3 -c 'import cinema_install.cinstall.install.install as cinema_install;\
    cinema_install.$viewer(\"$PWD/cinema_install/cinstall/cinema.source\", \"$PWD\", \"cinema_$viewer.html\", $db_string)'" 

  cleanup 0
  
  #TODO: not sure if needed
#  if ./cinema 2>/dev/null >/dev/null; then
#    echo "cinema_lib successfully installed! To use it:"
#    echo "cd `pwd`"
#    echo "./cinema"
#  else
#    echo "cinema_lib was not successfully installed!"
#    echo "Here is the error. Consider submitting an issue to $github_page"
#    ./cinema
#    cd ../
#    cleanup
#  fi
}

# Variables
# Default to install explorer
github_repo="https://github.com/EthanS94/cinema_install.git"
compare="false"
explorer="true"

# Parse arguments
parse_args $@

# Which viewer to install 
if [ "$compare" == "true" ]; then
  viewer="compare"
elif [ "$explorer" == "true" ]; then
  viewer="explorer"
fi

# Check for existing cinema viewer
# TODO: Not sure if this is needed or not
#if [ -d ./cinema ]; then
#  echo "Looks like a cinema viewer is already installed here!"
#  echo "If you want to reinstall, move to a new install location or remove `pwd`/cinema"
#  exit 1
#fi

# Git clone cinema_install
does_command_exist git
clone_cinema_install

# Check for Python 3.6
does_command_exist python3
check_version python "`python3 -c 'import sys; print(sys.version)' | awk 'NR==1' | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+).*/\1/g'`" 3.6

# Install cinema_viewer
install_cinema_viewer
