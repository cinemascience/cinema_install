#!/bin/bash

parse_args () {
  #TODO: add --help
  while [[ "$1" != "" ]]
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
      -d | --database_file )
        db_file=$2
        shift 2
        ;;
      * )
        echo "Argument $1 not recognized! Exiting..."
        exit 1
        ;;
    esac
  done
}

cleanup () {
  [[ -d ./cinema_install ]] && rm -rf ./cinema_install
  exit $1
}

does_command_exist () {
  if ! command -v "$1" >/dev/null 2>&1; then
    if [[ ! -z $2 ]]; then
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
  if [[ "$2" != "" ]]; then
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
  if ! git clone --depth=1 $github_repo;
  then
    echo "Git clone timed out. Proxy settings may be the reason. Trying again without any proxy settings..."
    if ! git clone -q -c http.proxy="" -c https.proxy="" --depth=1 $github_repo;
    then
      echo "Failed to clone cinema_install. Make sure this works for you and try again:"
      echo "git clone --depth=1 $github_repo'"
      echo "Exiting..."
      cleanup 1
    fi
  fi
  echo "Git clone successful"
}

build_db_string () {
  echo "Building database string..."

  db_file=$1
  # If not database file given, look for directories ending with *.cdb and use those
  if [[ $db_file == "" ]]; then
    # Get all cdb's in current directory
    PWD=`pwd`
    dbs=(`ls -dp $PWD/*.cdb | grep /$ | sed 's/\/$//g'`)
    if [[ "${dbs[0]}" == "" ]];
    then
      echo "No cinema databases were found (directories ending with '.cdb'). Exiting..."
      cleanup 1
    fi
  else
    # Get cdb's from given text file
    if [[ ! -f $db_file ]]; then
      echo "$db_file does not exist. Exiting..."
      cleanup 1
    fi
    dbs=(`cat $db_file`)
  fi

  # Check to see if all cdb's given exist and build python dict
  first="true"
  db_string="["
  for db in ${dbs[@]};
  do
    if [[ ! -d $db ]]; then
      echo "Could not find directory $db. Exiting..."
      cleanup 1
    fi
    if [[ $first = "true" ]];
    then
      first="false"
      db_string="$db_string{\"path\" : \"$db\"}"
    else
      db_string="$db_string, {\"path\" : \"$db\"}"
    fi
  done
  db_string="$db_string]"
}

install_cinema_viewer () {
  echo "Installing cinema_$viewer..."

  # Run the python module
  eval "python3 -c 'import cinema_install.cinstall.install.install as cinema_install;\
    cinema_install.$viewer(\"$PWD/cinema_install/cinstall/cinema.source\", \"$PWD\", \"cinema_$viewer.html\", $db_string)'" 

  cleanup 0
}

# Variables
# Default to install explorer
github_repo="https://github.com/cinemascience/cinema_install.git"
compare="false"
explorer="true"

# Parse arguments
parse_args $@

# Which viewer to install 
if [[ "$compare" == "true" ]]; then
  viewer="compare"
elif [[ "$explorer" == "true" ]]; then
  viewer="explorer"
fi

# Set up databases
if [[ -f $db_file ]]; then
  build_db_string $db_file
else
  build_db_string ""
fi

# TODO: Check for existing cinema viewer

# Git clone cinema_install
does_command_exist git
clone_cinema_install

# Check for Python 3.6
does_command_exist python3
check_version python "`python3 -c 'import sys; print(sys.version)' | awk 'NR==1' | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+).*/\1/g'`" 3.6

# Install cinema_viewer
install_cinema_viewer
