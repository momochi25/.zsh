# promptの部分を別ファイルに
source ~/.zsh/prompt.zsh
export LANG=ja_JP.UTF-8
export PATH=$PATH:$HOME/bin
# micro path
export PATH=$HOME/local/bin:$PATH

# 色を使用出来るようにする
autoload -Uz colors

# HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# Emacs ライクな操作を有効にする（文字入力中に Ctrl-F,B でカーソル移動など）
# Vi ライクな操作が好みであれば `bindkey -v` とする
#bindkey -e

# 自動補完を有効にする
# コマンドの引数やパス名を途中まで入力して <Tab> を押すといい感じに補完してくれる
# 例： `cd path/to/<Tab>`, `ls -<Tab>`
autoload -U compinit; compinit

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
# 候補を選ぶには <Tab> か Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=1

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

#Ctrl-Yで上のディレクトリに移動できる
function cd-up { zle push-line && LBUFFER='builtin cd ..' && zle accept-line }
zle -N cd-up
bindkey "^Y" cd-up

#Ctrl-Wでパスの文字列などをスラッシュ単位でdeleteできる
autoload -U select-word-style
select-word-style bash

# 入力したコマンドが存在せず、かつディレクトリ名と一致するなら、ディレクトリに cd する
# 例： /usr/bin と入力すると /usr/bin ディレクトリに移動
setopt auto_cd

# ↑ を設定すると、 .. とだけ入力したら1つ上のディレクトリに移動できるので……
# 2つ上、3つ上にも移動できるようにする
alias ...='cd ../..'
alias ....='cd ../../..'

# "~hoge" が特定のパス名に展開されるようにする（ブックマークのようなもの）
# 例： cd ~hoge と入力すると /long/path/to/hogehoge ディレクトリに移動
hash -d hoge=/long/path/to/hogehoge

# cd した先のディレクトリをディレクトリスタックに追加する
# ディレクトリスタックとは今までに行ったディレクトリの履歴のこと
# `cd +<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd

# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups

# 拡張 glob を有効にする
# glob とはパス名にマッチするワイルドカードパターンのこと
# （たとえば `mv hoge.* ~/dir` における "*"）
# 拡張 glob を有効にすると # ~ ^ もパターンとして扱われる
# どういう意味を持つかは `man zshexpn` の FILENAME GENERATION を参照
setopt extended_glob

# 入力したコマンドがすでにコマンド履歴に含まれる場合、履歴から古いほうのコマンドを削除する
# コマンド履歴とは今まで入力したコマンドの一覧のことで、上下キーでたどれる
setopt hist_ignore_all_dups

# コマンドがスペースで始まる場合、コマンド履歴に追加しない
# 例： <Space>echo hello と入力
setopt hist_ignore_space

# Ctrl+Dでzshを終了しない
setopt ignore_eof

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# Ctrl-Sで前方検索（Ctrl-Rで後方検索は標準）
stty stop undef

# 単語の一部として扱われる文字のセットを指定する
# ここではデフォルトのセットから / を抜いたものとする
# こうすると、 Ctrl-W でカーソル前の1単語を削除したとき、 / までで削除が止まる
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

# エイリアス
alias ls='ls -G'
alias la='ls -AG'
alias ll='ls -lG'

alias rm='rm -i'
alias cp='cp -iv'
alias mv='mv -iv'
alias mk='touch'

#cdを打ったら自動的にlsを打ってくれる関数
function cd(){
	builtin cd $@ && ls;
}

# windowsWSL用alias
alias cdh='cd /mnt/c/Users/yusuk'
alias progwin='cd /mnt/c/Users/yusuk/Documents/prog'


#aliasの覚書メモ呼び出し
alias aliasmemo='cat /Users/yusuke/Documents/aliasmemo.txt'
alias openaliasmemo='atom /Users/yusuke/Documents/aliasmemo.txt'

#zsh再ログイン
alias relogin='exec $SHELL -l'
#zshrcオープン
alias zshrc='micro ~/.zsh/.zshrc'

alias mkdir='mkdir -p'

alias pwdcopy='pwd | pbcopy'

#プロキシ自動変換のための
alias nswitch="source ~/.switch_proxy"
# nswitch

# 'finder'でカレントディレクトリを開く
alias finder="open ."

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

#python3のエイリアス(無理やり感)
alias python='python3'

#C実行無理やり
alias ./a="./a.out"

#AVトレントリネーム
alias fanza="python3 /Users/yusuke/Google_drive/prog/python_test/py_scraping/fanzascraping.py"
#アンマウント
alias unmount_all='sh /Users/yusuke/Documents/sh_automation/unmount.sh'

alias ip4='ip -json a | jq ".[] | {ifname: .ifname, address:.address, addr_info: .addr_info[] | select(.family == \"inet\") | {local:.local}}"'
