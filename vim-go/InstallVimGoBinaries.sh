#!/bin/bash
SRC_PATH=`go env GOPATH`/src
COMPONENTS_SRC=("github.com/nsf/gocode" \
	"github.com/alecthomas/gometalinter" \
	"github.com/golang/tools" \
	"github.com/golang/lint" \
	"github.com/rogpeppe/godef" \
	"github.com/kisielk/errcheck" \
	"github.com/jstemmer/gotags" \
	"github.com/klauspost/asmfmt" \
	"github.com/fatih/motion" \
	"github.com/fatih/gomodifytags" \
	"github.com/zmb3/gogetdoc" \
	"github.com/josharian/impl" \
	"github.com/dominikh/go-tools" \
	"github.com/davidrjenni/reftools")
COMPONENTS_DST=("github.com/nsf/gocode" \
	"github.com/alecthomas/gometalinter" \
	"golang.org/x/tools" \
	"golang.org/x/lint" \
	"github.com/rogpeppe/godef" \
	"github.com/kisielk/errcheck" \
	"github.com/jstemmer/gotags" \
	"github.com/klauspost/asmfmt" \
	"github.com/fatih/motion" \
	"github.com/fatih/gomodifytags" \
	"github.com/zmb3/gogetdoc" \
	"github.com/josharian/impl" \
	"github.com/dominikh/go-tools" \
	"github.com/davidrjenni/reftools")
COMPONENTS_BUILD=("github.com/nsf/gocode" \
	"github.com/alecthomas/gometalinter" \
	"golang.org/x/tools/cmd/goimports" \
	"golang.org/x/tools/cmd/guru" \
	"golang.org/x/tools/cmd/gorename" \
	"golang.org/x/lint/golint" \
	"github.com/rogpeppe/godef" \
	"github.com/kisielk/errcheck" \
	"github.com/jstemmer/gotags" \
	"github.com/klauspost/asmfmt/cmd/asmfmt" \
	"github.com/fatih/motion" \
	"github.com/fatih/gomodifytags" \
	"github.com/zmb3/gogetdoc" \
	"github.com/josharian/impl" \
	"github.com/dominikh/go-tools/cmd/keyify" \
	"github.com/davidrjenni/reftools/cmd/fillstruct")

for ((i=0; i<${#COMPONENTS_SRC[*]};i++))
do
	git clone https://${COMPONENTS_SRC[$i]}.git ${SRC_PATH}/${COMPONENTS_DST[$i]} >/dev/null 2>&1
	if [ $? -eq 128 ]
	then
		echo "You get ${SRC_PATH}/${COMPONENTS_DST[$i]} before. Now update it"
		pushd ${SRC_PATH}/${COMPONENTS_DST[$i]} >/dev/null
		git pull
		popd > /dev/null
	elif [ $? -eq 0 ]
	then
		echo "Download ${SRC_PATH}/${COMPONENTS_DST[$i]} Successfully"
	else
		echo "Download ${SRC_PATH}/${COMPONENTS_DST[$i]} Failed"
	fi
done
for ((i=0; i<${#COMPONENTS_BUILD[*]};i++))
do
	go get ${COMPONENTS_BUILD[$i]}
	if [ $? -eq 0 ]
	then
		echo "${COMPONENTS_BUILD[$i]} build Successfully"
	else
		echo "${COMPONENTS_BUILD[$i]} build Failed"
	fi
done
