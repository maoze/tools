# vim编写markdown

## 下载vim-markdown
[官方地址](https://github.com/plasticboy/vim-markdown.git)是github的仓库，如果访问不了，可以在gitee上找个镜像仓库，如[这个](https://github.com/plasticboy/vim-markdown.git)。

进入vim插件安装目录，下载仓库

```
cd ~/.vim/pack/foo/start/
git clone https://github.com/plasticboy/vim-markdown.git
cd vim-markdown
```

## 环境配置

```
" 关闭自动折叠功能
let g:vim_markdown_folding_disabled = 1
```


## 下载markdown-preview

[官方地址](https://github.com/iamcco/markdown-preview.nvim.git)是github的仓库，如果访问不了，可以在gitee上找个镜像仓库，如[这个](https://gitee.com/irontec/markdown-preview.git)。

进入vim插件安装目录，下载仓库

```
cd ~/.vim/pack/foo/start/
git clone https://github.com/iamcco/markdown-preview.nvim.git
cd markdown-preview.nvim
```

运行vim，运行`:call mkdp#util#install()`命令，运行完成后markdown-preview的二进制运行程序就安装到插件仓库的app/bin目录下。

在markdown文档中运行`:MarkdownPreview`，会打开浏览器预览。

## 环境配置相关

TODO

