set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'git://github.com/klen/python-mode.git'
Plugin 'git://github.com/davidhalter/jedi-vim.git'
Plugin 'kien/ctrlp.vim'
Plugin 'bling/vim-airline'
Plugin 'git://github.com/scrooloose/nerdtree.git'
" vim markdown
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'

" " The following are examples of different formats supported.
" " Keep Plugin commands between vundle#begin/end.
" " plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" " plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" " Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" " git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" " The sparkup vim script is in a subdirectory of this repo called vim.
" " Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" " Avoid a name conflict with L9
" Plugin 'user/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Disable Folding (禁止vim-markdown折叠)
let g:vim_markdown_folding_disabled = 1

" 由于pymode与jedi的兼容性，安装jedi-vim则必须禁止pymode_rope
" 配置快捷键 ',,' 运行python脚本
let g:pymode_run_bind = ',,'
let g:pymode_run = 1
let g:pymode_rope = 0
let g:pymode_rope_completion = 0

" 配置自动补全快捷键 Ctrl+N
let g:jedi#completions_command = '<C-N>'

" 这里注意下需要额外配置python的第三方包路径（这样就可以用vim查看pip安装都第三方库文档）
if $VIRTUAL_ENV != ''
  let $PYTHONPATH = $VIRTUAL_ENV.'/lib/python3.5/site-packages'
endif


"============================================================
" 配置NERDTree打开Python文件时自动加载
" 配置ctrl+n开启或关闭NERDTree
" autocmd vimenter *.py NERDTree
" map <C-n> :NERDTreeToggle<CR>
"
" ctrl+w+w光标自动切换左右窗口
"
" 切换工作目录：1-cd选择CWD 2-CD将工作目录切换至CWD
"   - cd:change the CWD to the
"   - CD:change tree root to CWD
" 新建文件/目录、删除、重命名等
"   - 选择目录树位置，按 'm'，'a'则为新建(以'/'结尾表示创建目录)
"   - 删除重命名类似，按 'm'，然后再选择

map <F2> :NERDTreeToggle<CR>
" 将 NERDTree 的窗口设置在 vim 窗口的右侧（默认为左侧）
" let NERDTreeWinPos="right"
" 当打开 NERDTree 窗口时，自动显示 Bookmarks
let NERDTreeShowBookmarks=1

" ctrl+w r 交换两边的窗口

" To make vsplit put the new buffer on the right of the current buffer:
set splitright
" Similarly, to make split put the new buffer below the current buffer:
set splitbelow
"============================================================


" CtrlP基本操作:
"   * 支持递归创建文件目录(dir1/dir2/1.txt 然后按'<C-y>'则可以新建)
"   * '<C-f>' mru-最近打开的文件 buffers-缓冲区 files-文件状态
"   * '<C-d>' 使用文件名搜索代替全路径搜索
" 设置ctrlp快捷键为',,'(默认为'<C-p>')
"let g:ctrlp_map = ',,'
" 设置全局搜索时忽略以下类型的文件或目录，不推荐
" set wildignore+=*/.git/*,*.so,*.swp,*.zip
" 设置ctrlp搜索忽略特定文件目录(使用正则表达式，'\v'表示垂直制表符)
let g:ctrlp_custom_ignore = {
            \ 'dir': '\v[\/]\.(git|svn)$|__pycache__',
            \ 'file': '\v\.(so|swp|zip|log|jpg|png|jpeg)$',
            \ 'link': ''
\ }


" set airline appear all the time
set laststatus=2
" open airline_powerline_fonts
let g:airline_powerline_fonts = 1


" 文件打开的编码，指vim读取文件时所用的编码
" 尝试按从左到右顺序编码打开，下面编码也是从宽到严顺序来的
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
" 终端显示的编码，就是你显示屏看到的编码了
set termencoding=utf-8
" vim保存文件的编码
set encoding=utf-8

" 设置默认文件换行符格式为unix的 <NL> \n
" :help fileformat
" set ff=unix
set fileformat=unix
" set fileformats=unix,dos
" 所以如果想转换格式为unix可以这样：
" set ff=unix 然后 :wq 保存退出即可
" 或者命令行执行：sed -i 's/\r$//' file


set nu
set cursorline          "突出显示当前行
set hlsearch            "高亮度反白, 设定是否将搜寻的字符串反白
set backspace=2
set tabstop=4           "设置（软）制表符宽度为4
set softtabstop=4
set shiftwidth=4        "设置缩进的空格数为4
" 开启鼠标模式后，光标选取会失效变成vim的视图模式
" 所以一般只在需要的时候开启鼠标，如需要滚动查看的情况
"set mouse=a             "开启鼠标
"set mouse=              "关闭鼠标


syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized
