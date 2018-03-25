#!/bin/bash
# A script for checking out all repos in a directory

# Stop when error occurs
set -e 

OLDPWD=$(pwd)

function get_absolute(){
    echo `cd $1 && pwd`
}

function is_absolute(){
    if [[ "$1" = /* ]];
    then
        echo "absolute"
    else
        echo ""
    fi
}

function checkout_a_repo(){
    repo_url=$1
    destion_dir=$2
    echo "svn checkout $1 $2"
    svn checkout "$1" "$2" >/dev/null
}

# Check out all repos in directory $1
function checkout_all(){
    root_directory=$(get_absolute $1)
    destination_root=$2
    if [[ -z ${destination_root} ]]; then 
        echo "No destination directory is provided, using current directory as the root destination directory."
        echo
        destination_root="."
    fi
    if [[ ! -d ${root_directory} ]]; then 
        echo "${root_directory} does not exists"
        exit 
    fi
    if [[ -z $(is_absolute ${root_directory}) ]]; then 
        echo "${root_directory} is not a absolute path"
        echo "Currently, we only support absolute path"
        exit
    fi
    echo "Got root directory: ${root_directory}"
    cd ${OLDPWD}
    for subdir in `ls -d ${root_directory}/*`; do 
        repo=$(basename $subdir)
        echo "Got repo: ${repo}"
        checkout_a_repo "file://${root_directory}/${repo}" "${destination_root}/${repo}"
    done
}

function usage(){
    me=`basename "$0"`
    echo "This script automatically checks out all repos in a local svn repo site."
    echo -e "\nUsage:\n./$me [OPTION]"
    echo "This script provides the following argument options"
    echo -e "\t-h\t\tdisplay help information."
    echo -e "\t-r\t\troot path of the ropos (e.g., /Users/lgong/repo), please do not add \"file://\"."
    echo -e "\t-o\t\tdestination directory."
    echo 
    echo 
    echo "Note that \"./repo\" is used as the repo root path if not provided, current path is used as the destination root directory."
    echo

    exit
}


while getopts hr:o: option;
do
    case "${option}" in
        h) 
            usage 
            ;;
        r)
            repo_root=$OPTARG
            ;;
        o)  
            destination_root=$OPTARG
            ;;
        \?)
            echo "Wrong arguments" >&2
            ;;
    esac
done

if [[ -z "$repo_root" ]]; then 
    echo "No root directory for the repos is provided, we use \"./repos\""
    echo
    repo_root="./repos"
fi 

checkout_all "${repo_root}" "${destination_root}"

echo
echo
echo "All repos were successfully checked out. Enjoy them!"

exit