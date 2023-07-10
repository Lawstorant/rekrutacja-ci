#! /bin/bash

# detect parameters
case $1 in
    --version)
        APPLICATION_VERSION="$2"
        shift
        shift
        ;;

    --branch)
        APPLICATION_BRANCH="$2"
        shift
        shift
        ;;
esac

if [[ -z $APPLICATION_VERSION ]]; then
    echo "Application version ws not set! Exiting..."
    exit(1)
fi

# possibly, we would need to configure git here
# to enable pushing to repository
git clone git@github.com:Lawstorant/rekrutacja-function.git
cd rekrutacja-function

# check if the branch variable was set and checkout
[[ -n APPLICATION_BRANCH ]] && git checkout "$APPLICATION_BRANCH"

git tag "$APPLICATION_VERSION" -a -m "Update to $APPLICATION_VERSION"
git push origin --tags