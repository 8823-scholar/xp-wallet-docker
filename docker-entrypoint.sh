#!/usr/bin/env bash

# if command starts with an option, prepend XPd
if [ "${1:0:1}" = '-' ]; then
	set -- XPd "$@"
fi

#FILEID="1uKV7vd4FTm457rG9CoUPzZgP2j4W_TYd"
FILEID="1DZx3mzj81MYwV1QXtGXTEQ-1CXFfaHUX"
ZIP_TEMP_FILE=bootstrap.zip
ZIP_TEMP_DIR=ziptemp

_init_datafiles() {
	echo "Initializing data files..."
	timeout 3 XPd
	echo "done"
}

_download_from_gdrive() {
	echo "Downloading bootstrap..."
	curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=$1" > /dev/null
	local download_code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
	curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${download_code}&id=$1" -o $2
	echo "done"
}

_download_from_dropbox() {
	echo "Downloading bootstrap..."
	curl -Ls "https://www.dropbox.com/s/wz8sg14ujmx1dnm/xpcoin-bootstrap-peers.zip?dl=0" -o $1
	echo "done"
}

_deploy_bootstrap() {
	echo "Extracting bootstrap..."
	rm -f ${XPD_DATA_DIR}/database/*
	rm -fr $2/*
	unzip -d $2 $1
	for CONTENT_FILE in $(find ${2} -type f -and -not -name readme.txt -and -not -name xpcoin-startkit_v1.0.bat -and -not -name wallet.dat)
	do
		mv ${CONTENT_FILE} ${XPD_DATA_DIR}/$(echo ${CONTENT_FILE} | sed -r 's/^([^\/]*\/){2}//')
	done
	rm -fr $2
	rm -f $1
	echo "done"
}

if [ ! -d ${XPD_DATA_DIR}/database ]; then
	_init_datafiles
	_download_from_dropbox bootstrap-latest.zip
	_deploy_bootstrap bootstrap-latest.zip ziptemp
fi

exec "$@"
