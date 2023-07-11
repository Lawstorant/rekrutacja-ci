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
    exit 1
fi

# possibly, we would need to configure git here
# to enable pushing to repository
git clone git@github.com:Lawstorant/rekrutacja-function.git
cd rekrutacja-function || exit

# check if the branch variable was set and checkout
[[ -n $APPLICATION_BRANCH ]] && git checkout "$APPLICATION_BRANCH"

echo "$APPLICATION_VERSION" > application.version
git stage application.version
git commit -m "Update to version $APPLICATION_VERSION"
git tag "$APPLICATION_VERSION" -a -m "Update to $APPLICATION_VERSION"

MAJOR_VERSION=$(echo "$APPLICATION_VERSION" | cut -d "." -f 1)
MINOR_VERSION=$(echo "$APPLICATION_VERSION" | cut -d "." -f 2)

MINOR_VERSION=$(( MINOR_VERSION + 1 ))
APPLICATION_VERSION="$MAJOR_VERSION.$MINOR_VERSION-SNAPSHOT"

echo "$APPLICATION_VERSION" > application.version
git stage application.version
git commit -m "Update to version $APPLICATION_VERSION"
git push
git push --tags

cd ..
rm -rf rekrutacja-function
