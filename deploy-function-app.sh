#! /bin/bash

APPLICATION_VERSION="devel"

# detect parameters
case $1 in
    --environment)
        ENVIRONMENT="$2"
        shift
        shift
        ;;

    --prod)
        ENVIRONMENT="prod"
        shift
        ;;

    --version)
        APPLICATION_VERSION="$2"
        shift
        shift
        ;;

    --principal-secret)
        PRINCIPAL_SECRET="$2"
        shift
        shift
        ;;
esac

# check variables
if [[ -z ENVIRONMENT ]]; then
    echo "Environment was not set!"
    exit(1)
fi

# kinda unneeded, but lets keep it
if [[ -z APPLICATION_VERSION ]]; then
    echo "APPLICATION_VERSION was not set!"
    exit(1)
fi

if [[ -z PRINCIPAL_SECRET ]]; then
    echo "Service principal secret was not set!"
    exit(1)
fi

# download the application repository
# this would normally be performed by pipeline
# repository set as artifact
# possibly, we would need to configure git here
git clone git@github.com:Lawstorant/rekrutacja-function.git
cd rekrutacja-function
[[ APPLICATION_VERSION != "devel" ]] && git checkout tags/"$APPLICATION_VERSION"

# create a zip file of all the files in the repository
# globbing pattern will exclude hidden ones
zip ../function_app.zip *
cd ..


# login into azure with the configured service principal
source configure-env-variables "$PRINCIPAL_SECRET"
az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"

az functionapp deployment source config-zip -g "rg-secretreader-$ENVIRONMENT" -n "sysadmins-secretreader-$ENVIRONMENT" --src function_app.zip




