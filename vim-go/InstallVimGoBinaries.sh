#!/bin/bash
SRC_PATH=`go env GOPATH`/src
git clone https://github.com/nsf/gocode  ${SRC_PATH}/github.com/nsf/gocode
git clone https://github.com/alecthomas/gometalinter.git ${SRC_PATH}/github.com/alecthomas/gometalinter
git clone https://github.com/golang/tools.git ${SRC_PATH}/golang.org/x/tools
git clone https://github.com/golang/lint.git ${SRC_PATH}/github.com/golang/lint
git clone https://github.com/rogpeppe/godef.git ${SRC_PATH}/github.com/rogpeppe/godef
git clone https://github.com/kisielk/errcheck.git ${SRC_PATH}/github.com/kisielk/errcheck
git clone https://github.com/jstemmer/gotags.git ${SRC_PATH}/github.com/jstemmer/gotags
git clone https://github.com/klauspost/asmfmt.git ${SRC_PATH}/github.com/klauspost/asmfmt
git clone https://github.com/fatih/motion.git ${SRC_PATH}/github.com/fatih/motion
git clone https://github.com/fatih/gomodifytags.git ${SRC_PATH}/github.com/fatih/gomodifytags
git clone https://github.com/zmb3/gogetdoc.git ${SRC_PATH}/github.com/zmb3/gogetdoc
git clone https://github.com/josharian/impl.git ${SRC_PATH}/github.com/josharian/impl
git clone https://github.com/dominikh/go-tools.git ${SRC_PATH}/github.com/dominikh/go-tools
git clone https://github.com/davidrjenni/reftools.git ${SRC_PATH}/github.com/davidrjenni/reftools
go get github.com/nsf/gocode
go get github.com/alecthomas/gometalinter
go get golang.org/x/tools/cmd/goimports
go get golang.org/x/tools/cmd/guru
go get golang.org/x/tools/cmd/gorename
go get github.com/golang/lint/golint
go get github.com/rogpeppe/godef
go get github.com/kisielk/errcheck
go get github.com/jstemmer/gotags
go get github.com/klauspost/asmfmt/cmd/asmfmt
go get github.com/fatih/motion
go get github.com/fatih/gomodifytags
go get github.com/zmb3/gogetdoc
go get github.com/josharian/impl
go get github.com/dominikh/go-tools/cmd/keyify
go get github.com/davidrjenni/reftools/cmd/fillstruct
