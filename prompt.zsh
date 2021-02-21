# https://gist.github.com/hirorinao/1ff4577dc381a58d11ee#file-prompt-zsh
# fork of agnoster's Theme - https://gist.github.com/3712874
# fork of https://gist.github.com/fcamblor/f8e824caa28f8bea5572
# powerline fonts
# echo "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699 \ue0b1"


# prompt参考（今は使ってない） 
# https://qiita.com/mollifier/items/8d5a627d773758dd8078#

setopt transient_rprompt  # 右側まで入力がきたらRPROMPTを消す
setopt prompt_subst       # 変数展開など便利なプロント

autoload -Uz is-at-least
autoload -Uz add-zsh-hook
autoload -Uz vcs_info

() {
    # It will be the same as the 'hook_com'
    local -A info_formats
    info_formats=(
        branch    '"%b"'
        revision  '"%i"'
        base-name '"%r"'
        base      '"%R"'
        subdir    '"%S"'
        staged    '"%c"'
        unstaged  '"%u"'
        action    '"%a"'
        misc      '"%m"'
    )
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr 'true'
    zstyle ':vcs_info:*' unstagedstr 'true'
    zstyle ':vcs_info:*' formats "${(kv)info_formats}"
    zstyle ':vcs_info:*' actionformats "${(kv)info_formats}"
}

if is-at-least 4.3.11; then
    zstyle ':vcs_info:git+set-message:*' hooks info-git-hook
    +vi-info-git-hook() {
        GIT_INFO=("${(kv@)hook_com}")
        return 0
    }
fi

# GIT_INFO
#   branch          ブランチ情報
#   revision        リビジョン番号またはリビジョンID
#   repo_name       リポジトリ名
#   repo_path       リポジトリのルートディレクトリのパス
#   subdir          リポジトリルートから見た今のディレクトリの相対パス
#   action          アクション名(mergeなど) actionformats のみで指定可
#   staged          stagedstr 文字列
#   unstaged        unstagedstr 文字列
#   misc            その他の情報
#   is_repo         リポジトリ内
#   is_repo_work    リポジトリ内(.gitを除く)
#   revision_short  リビジョンID ショート
#   stash_count     stash数
#   remote          リモート
#   ahead_count     リモートブランチより新しい
#   behind_count    リモートブランチより古い
#   changed_count   変更された数
#   untracked_count 追加されていない数
#   is_clean        変更がない
get_git_info() {
    if ! is-at-least 4.3.11; then
        GIT_INFO=($(printf "$vcs_info_msg_0_"))
        GIT_INFO=("${(kv@)${(kv@)GIT_INFO#\"}%\"}")
    fi
    # repo_name
    [[ -n $GIT_INFO[base-name] ]] && GIT_INFO[repo_name]=$GIT_INFO[base-name]
    # repo_path
    [[ -n $GIT_INFO[base] ]]      && GIT_INFO[repo_path]=$GIT_INFO[base]

    # is_repo
    # $(git rev-parse 2> /dev/null) && GIT_INFO[is_repo]='true'
    [[ -n $GIT_INFO[branch] ]] && GIT_INFO[is_repo]='true'

    # is_repo_work
    # [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == 'true' ]] && GIT_INFO[is_repo_work]='true'
    [[ -n $GIT_INFO[repo_name] ]] && GIT_INFO[is_repo_work]='true'

    # is_detached_head
    # [[ -z $(git symbolic-ref HEAD 2> /dev/null) ]] && GIT_INFO[is_detached_head]='true'
    [[ $GIT_INFO[branch] =~ 'heads/HEAD' ]] && GIT_INFO[is_detached_head]='true'

    # revision-short
    [[ -n $GIT_INFO[revision] ]] && GIT_INFO[revision_short]=${(r:7:)GIT_INFO[revision]}

    if [[ -n $GIT_INFO[is_repo_work] ]]; then
        # stash
        GIT_INFO[stash_count]=$(git stash list | wc -l | tr -d ' ')

        # remote
        # GIT_INFO[remote]=${$(git rev-parse --verify ${GIT_INFO[repo_name]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
        # if [[ -n $GIT_INFO[remote] ]]; then
        #   GIT_INFO[ahead_count]=$(git rev-list ${GIT_INFO[repo_name]}@{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
        #   GIT_INFO[behind_count]=$(git rev-list HEAD..${GIT_INFO[repo_name]}@{upstream} 2>/dev/null | wc -l | tr -d ' ')
        # fi

        local branch_info remote_info
        local -a flags git_status
        flags+='--ignore-submodules=dirty'
        [[ -n $OPTIONS[untracked_files_no_disp] ]] && flags+='--untracked-files=no'

        git_status=("${(f)$(git status --porcelain --branch ${flags} 2> /dev/null)}")
        # ## master...origin/master [ahead 2, behind 1]
        branch_info="${${git_status[1]}#\#\# }"

        [[ $branch_info =~ '\.\.\.([^ ]+)' ]] && GIT_INFO[remote]=${match[1]}
        if [[ -n $GIT_INFO[remote] ]]; then
          GIT_INFO[ahead_count]=0
          GIT_INFO[behind_count]=0
        fi
        if [[ $branch_info =~ '\[(.+)\]' ]]; then
          remote_info=${match[1]}
          [[ $remote_info =~ 'ahead ([0-9]+)' ]]  && GIT_INFO[ahead_count]=${match[1]}
          [[ $remote_info =~ 'behind ([0-9]+)' ]] && GIT_INFO[behind_count]=${match[1]}
        fi

        shift git_status
        GIT_INFO[changed_count]=${#git_status:#\?\?*}
        GIT_INFO[untracked_count]=${(M)#git_status:#\?\?*}
        if [[ -n $OPTIONS[untracked_files_to_clean] ]]; then
            (( $GIT_INFO[changed_count] == 0 )) && GIT_INFO[is_clean]='true'
        else
            (( $#git_status == 0 )) && GIT_INFO[is_clean]='true'
        fi

    fi
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
        echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
        echo -n "%{%k%}"
    fi
    echo -n "%{%f%}\n"
    echo -n "%{%F{green}%} >%{%f%}"
    CURRENT_BG=''
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
    local symbols
    symbols=()
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

    [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
    prompt_segment black white "%(!.%{%F{yellow}%}.)$USER@%m"
}

# Dir: current working directory
prompt_dir() {
    prompt_segment blue white

    if [[ -n $GIT_INFO[repo_path] ]]; then
        local repo_top_path current_path sub_path
        repo_top_path=$GIT_INFO[repo_path]
        current_path=$(pwd)
        sub_path=${current_path#$repo_top_path}
        [[ ${repo_top_path#$HOME} != ${repo_top_path} ]] && repo_top_path="~${repo_top_path#$HOME}"
        echo -n "%{%U%}$repo_top_path%{%u%}$sub_path"
    else
        echo -n '%~'
    fi
}

# Git: branch/detached head, dirty status
prompt_git() {
    if [[ -z $GIT_INFO[is_repo_work] ]] && return

    if [[ $GIT_INFO[stash_count] -ne 0 ]]; then
        prompt_segment white black
        echo -n "⚑${GIT_INFO[stash_count]}"
    fi

    if [[ -n $GIT_INFO[is_clean] ]]; then
        prompt_segment green black
    else
        prompt_segment yellow black
    fi
    if [[ -z $GIT_INFO[is_detached_head] ]]; then
        echo -n " ${GIT_INFO[branch]}";
    else
        echo -n "➦ ${GIT_INFO[revision_short]}";
    fi
    if [[ -n $GIT_INFO[remote] ]]; then
        echo -n " ⬆ ${GIT_INFO[ahead_count]}";
    fi
    if (( $GIT_INFO[changed_count] + $GIT_INFO[untracked_count] > 0 )); then
        echo -n "  "
        if (( $GIT_INFO[changed_count] > 0 )); then
            echo -n "± "
        fi
        if (( $GIT_INFO[untracked_count] > 0 )); then
            echo -n "??"
        fi
    fi

    if [[ -n $GIT_INFO[remote] ]]; then
        if (( $GIT_INFO[behind_count] > 0 )); then
            prompt_segment magenta white
        else
            prompt_segment cyan black
        fi
        echo -n " ${GIT_INFO[remote]} ⬇ ${GIT_INFO[behind_count]}"
    fi
}

## Main prompt
build_prompt() {
    local RETVAL=$?
    local CURRENT_BG='NONE'
    local SEGMENT_SEPARATOR=''
    local -A GIT_INFO
    local -A OPTIONS

    # OPTIONS[debug]=true
    # OPTIONS[untracked_files_to_clean]=true
    # OPTIONS[untracked_files_no_disp]=true

    vcs_info
    get_git_info

    if [[ -n $OPTIONS[debug] && (( $#GIT_INFO > 0 )) ]]; then
        echo "--------"
        echo "\$GIT_INFO =>"
        for key in ${(ok)GIT_INFO:#*_orig}; do
            echo "  ${(r:17:: :)$(echo "[${key}]")} => [${GIT_INFO[$key]}]"
        done
        echo "--------"
    fi

    prompt_status
    prompt_dir
    prompt_git
    prompt_end
}

add-zsh-hook precmd () { PROMPT='
%{%f%b%k%}$(build_prompt) ' }
