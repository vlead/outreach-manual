#SHELL := /bin/bash
BUILD_DIR=build

LITERATE_TOOLS="https://github.com/vlead/literate-tools.git"
LITERATE_DIR=literate-tools
ELISP_DIR=elisp
ORG_DIR=org-templates
STYLE_DIR=style
DOC_DIR=build/docs
SRC_DIR=src
PWD=$(shell pwd)
STATUS=0

DEST_HOST="root@vlabs-dev.vlabs.ac.in"
DEST_HOST_STAGE="root@staging-dev.vlabs.ac.in"
DEST_DIR="/var/www/html/documentation/outreach-manual"
REMOVE_COMMAND="rm -rf /var/www/html/documentation/outreach-manual/*"

all:  publish

clean-literate:
	rm -rf ${ELISP_DIR}
	rm -rf src/${ORG_DIR}
	rm -rf src/${STYLE_DIR}

pull-literate-tools:
	@echo "pulling literate support code"
	echo ${PWD}
ifeq ($(wildcard elisp),)
	@echo "proxy is..."
	echo $$http_proxy
	git clone ${LITERATE_TOOLS}
	mv ${LITERATE_DIR}/${ELISP_DIR} .
	mv ${LITERATE_DIR}/${ORG_DIR} ${SRC_DIR}
	mv ${LITERATE_DIR}/${STYLE_DIR} ${SRC_DIR}
	rm -rf ${LITERATE_DIR}
else
	@echo "Literate support code already present"
endif

init: pull-literate-tools
	rm -rf ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}

publish: init
	emacs  --script elisp/publish.el

clean:	clean-literate
	rm -rf ${BUILD_DIR}

export: pull publish
	ssh -o "StrictHostKeyChecking no" ${DEST_HOST} ${REMOVE_COMMAND}
	rsync -avz --progress ${DOC_DIR}/ ${DEST_HOST}":"${DEST_DIR}

stage: 	publish
	ssh -o "StrictHostKeyChecking no" ${DEST_HOST_STAGE} ${REMOVE_COMMAND}
	rsync -avz --progress ${DOC_DIR}/ ${DEST_HOST_STAGE}":"${DEST_DIR}
