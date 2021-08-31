#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

helm package ${DIR} -d ${DIR}

VERSION=$(cat ${DIR}/Chart.yaml | grep "^version" | sed -e 's/[[:space:]]//' | cut -d: -f2)
PACKAGE=$(cat ${DIR}/Chart.yaml | grep "^name" | sed -e 's/[[:space:]]//' | cut -d: -f2)

# credential extraction assumes you have your credentials in your 
# home directory in the following format (ignoring indentation):
#
#    username=myname
#    password=mypass
#

USERNAME=$(cat ${HOME}/.credentials/jfrog.txt | grep "^username" | cut -d= -f2)
PASSWORD=$(cat ${HOME}/.credentials/jfrog.txt | grep "^password" | cut -d= -f2)

curl -k -u${USERNAME}:${PASSWORD} -T "${DIR}/${PACKAGE}-${VERSION}.tgz" \
  "https://artifactory.portfolioplus.net/artifactory/app-helm-local/${PACKAGE}-${VERSION}.tgz"

rm "${DIR}/${PACKAGE}-${VERSION}.tgz"

