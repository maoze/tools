# windows下安装gvim

[下载地址](https://github.com/vim/vim-win32-installer/releases)找到最新的版本，注意下载时选择`*_x64.exe`的版本。之前遇到的问题是[vim](https://www.vim.org/download.php#pc)上下载的版本是32位的，而python安装时选择了64位的包，出现了vim无法加载python动态库的问题。

**注意：** Windows环境下，不要将插件放在`*/Program Files/*`之类的带有空格的路径下，运行插件命令时会出错。
