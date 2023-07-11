#!/bin/bash

APPLICATION_VERSION="devel"
ENVIRONMENT=""
PRINCIPAL_SECRET=""
NOLOGIN=false

# detect parameters
while [[ $# -gt 0 ]]; do
    case "$1" in
        --environment)
            shift
            ENVIRONMENT="$1"
            shift
            ;;

        --prod)
            ENVIRONMENT="prod"
            shift
            ;;

        --version)
            shift
            APPLICATION_VERSION="$1"
            shift
            ;;

        --principal-secret)
            shift
            PRINCIPAL_SECRET="$1"
            shift
            ;;

        --nologin)
            NOLOGIN=true
            shift
            ;;
    esac
done

# check variables
if [[ -z $ENVIRONMENT ]]; then
    echo "Environment was not set!"
    exit 1
fi

# kinda unneeded, but lets keep it
if [[ -z $APPLICATION_VERSION ]]; then
    echo "APPLICATION_VERSION was not set!"
    exit 1
fi

if [[ -z $PRINCIPAL_SECRET && $NOLOGIN == false ]]; then
    echo "Service principal secret was not set!"
    exit 1
fi

# download the application repository
# this would normally be performed by pipeline
# repository set as artifact
# possibly, we would need to configure git here
git clone git@github.com:Lawstorant/rekrutacja-function.git
cd rekrutacja-function || exit 1
if [[ $APPLICATION_VERSION != "devel" ]]; then
    git checkout "$APPLICATION_VERSION"
fi

# create a zip file of all the files in the repository
# globbing pattern will exclude hidden ones
zip -R ../function_app.zip * .*
cd ..


# login into azure with the configured service principal
if [[ $NOLOGIN != true ]]; then
    source configure-env-variables.sh "$PRINCIPAL_SECRET"
    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
fi

# I almost pulled all of my hair with this one
az functionapp deployment source config-zip -g "rg-secretreader-$ENVIRONMENT" -n "sysadmins-secretreader-$ENVIRONMENT" --src function_app.zip --build-remote true

rm -rf function_app.zip rekrutacja-function
