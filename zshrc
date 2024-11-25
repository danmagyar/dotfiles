# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

################### ZSH, iterm2 #############
export LC_ALL=en_US.UTF-8

# set up plugins by cloning them directly:
#     git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
#     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
zstyle :omz:plugins:keychain options --quiet
plugins=(
  git
  git-prompt
  zsh-autosuggestions
  zsh-syntax-highlighting
  autojump
  macos
  gpg-agent
  keychain
  alias-tips
)
export ZSH='/Users/dan/.oh-my-zsh'
source $ZSH/oh-my-zsh.sh
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$HOME/.scripts:$PATH:$HOME/.jetbrains-scripts"
source ~/gitrepos/unite-dotfiles/init.sh

# The original oh-my-zsh history size is only 10.000, bump it up a notch
export SAVEHIST=1000000
export HISTSIZE=1000000
export HISTFILE=~/.zsh_history
setopt APPEND_HISTORY       # Append history to the history file (don't overwrite)
setopt INC_APPEND_HISTORY   # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY        # Share history between all sessions
setopt HIST_IGNORE_DUPS     # Ignore duplicate commands in history
setopt HIST_IGNORE_SPACE    # Ignore commands that start with a space
setopt HIST_REDUCE_BLANKS   # Remove unnecessary blanks from commands

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# misc
source ~/gitrepos/dotfiles/scripts/zsh-interactive-cd.plugin.zsh

mkdir -p ~/.util-functions
for script in ~/.util-functions/*.sh; do
  source "$script"
done

alias lookUpHistoryFor='history -i | grep'
alias getHistoryBetween='fc -lf'
alias ls='eza --long --header --links --git --time-style long-iso --all --color-scale --hyperlink --color-scale-mode=gradient --color-scale=all'
alias hcat='highlight --out-format=ansi' #print file with syntax highlighting
alias mkd='mkdir -pv'
alias cp='cp -v' # verbose copy
alias mv='mv -v' # verbose move
alias rm='rm -v' # verbose remove
alias auth='auth-token.sh && export AUTH_TOKEN=$(cat /tmp/auth-token.txt)'


chtsh(){
    curl "cheat.sh/$@"
}

dotcmd(){
    #cd in a subshell, to execute a command locally
    (cd ~/gitrepos/dotfiles && command $@)
}

# from a jenkins job build url download its full console output and open it in vim
# creates a temporary directory so you can run :Rg <search term> in vim
getJenkinsLog(){
        TMP_DIR=$(mktemp -d)
        pushd $TMP_DIR
        JOB_URL=$(echo $1 | egrep -oh 'http.*job.*[0-9]+')
        LOG_URL="$JOB_URL/consoleText"
        LOG_FILE=$(echo "$JOB_URL.log" | egrep -oh 'job.*' | sed 's#\/#_#g')
        wget $LOG_URL -O $LOG_FILE
        vim $LOG_FILE '+?ERROR'
        popd
        rm -rf $TMP_DIR
}

awslogin() {
  output=$(aws-login.sh --profile "$1" --print-credentials)
  only_exports=$(echo "$output" | grep '^export ')
  eval "$only_exports"
}

alias awl=awslogin

awsloginAndOpenConsole() {
  awslogin "$1" && assume -c "$1"
}

alias awlo=awsloginAndOpenConsole


##################### Source private dotfiles scripts ############################

source_if_executable() {
  local file="$1"
  if [ -x "$file" ]; then
    . "$file"
  fi
}

local private_scripts_path="${HOME}/.private-scripts"

# Use find to recursively search the scripts directory
find -L "${private_scripts_path}" -type f | while IFS= read -r file; do
  source_if_executable "$file"
done

##################### Bluetooth ########################################
function bluetoothSwitch(){
  blueutil --power toggle
  if [[ $(blueutil -p) == "1" ]]; then
    blueutil --connect $SECRET_EARBUDS_ID &
    blueutil --connect $SECRET_HEADPHONE_ID &
  fi
}

################################### Java #########################################
function findClassRecursively(){
    local CLASSNAME=$1
    find . -name '*.jar' -exec grep -rHls "$CLASSNAME" {} \;
}

function listClassesRecursively(){
    find . -name '*.jar' -exec jar -tvf {} \;
}

###################### Docker ###################################################

# Pass docker image id and get back the Dockerfile
function getDockerfileFromImage(){
        docker history --no-trunc "$1" | \
        sed -n -e 's,.*/bin/sh -c #(nop) \(MAINTAINER .*[^ ]\) *0 B,\1,p' | \
        head -1
        docker inspect --format='{{range $e := .Config.Env}}
        ENV {{$e}}
        {{end}}{{range $e,$v := .Config.ExposedPorts}}
        EXPOSE {{$e}}
        {{end}}{{range $e,$v := .Config.Volumes}}
        VOLUME {{$e}}
        {{end}}{{with .Config.User}}USER {{.}}{{end}}
        {{with .Config.WorkingDir}}WORKDIR {{.}}{{end}}
        {{with .Config.Entrypoint}}ENTRYPOINT {{json .}}{{end}}
        {{with .Config.Cmd}}CMD {{json .}}{{end}}
        {{with .Config.OnBuild}}ONBUILD {{json .}}{{end}}' "$1"
}

alias dockviz='docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz'

function printDockerImageMap(){
        TMP_FILE=$(mktemp --suffix ".png")
        dockviz images -d | dot -Tpng -o $TMP_FILE
        imgcat $TMP_FILE
#        rm $TMP_FILE #imgcat breaks on big pictures if the file gets deleted
}

###################### kubernetes (k8s) aliases ########################################
export EDITOR=vim
export K9S_EDITOR=vim
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'
alias kget='kubectl get'
alias kdsc='kubectl describe'

######################  git aliases and utilities ################################
alias s='git show --format=fuller'
alias ch='git checkout '
function chrb(){
        local remote_branch=${1}
        local local_branch=${remote_branch#*/}
        git checkout $remote_branch -B $local_branch
}
alias gpr='git pull --rebase'
alias c='git commit -a -v'
alias ca='git commit -a -v --amend'
alias grv='git remote -v'
alias d='git diff '
alias dg='git difftool --gui --no-prompt '
#alias plc="git log --full-history --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias plc="vim -c Commits!"
alias pl="vim -c 'Commits! --full-history --all --graph'"
# alias pl="git log HEAD --full-history --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# alias vpl="vim +Commits --full-history --all --graph!"
alias reml="git log origin/master --full-history --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -20"
alias prl="git reflog --format='%C(auto)%h %<|(20)%gd %C(blue)%cr%C(reset) %gs (%s)'"
alias st='git status'

workon() {
    if [ -z "$1" ]; then
        echo "Usage: workon \"<branch description>\""
        return 1
    fi
    git switch -C $(sluggify.sh $1)
    git push --set-upstream origin $(git_current_branch)
}

# checkout previous commit
function chprev() {
        git checkout HEAD~
}

# checkout next commit
function chnext() {
    git log --reverse --pretty=%H master | grep -A 1 $(git rev-parse HEAD) | tail -n1 | xargs git checkout
}

#squashes the last n commit and creates a new commit
nSquashCommit(){
        git reset --hard HEAD~$1
        git merge --squash HEAD@{1}
        git commit
}

########################### Github aliases ########################################
alias cs='gh copilot suggest -t shell'

###########################  Oh my god, it's so fuzzy I'm gonna die ############################

source ~/gitrepos/fzf-git.sh/fzf-git.sh
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git" '

# useful command line shortcuts, e.g CTRL+R support
# this line is generated by running `$(brew --prefix)/opt/fzf/install` as per https://github.com/junegunn/fzf/issues/1428#issuecomment-496591086
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

git_switch_fzf() {
  local branches branch
  branches=$(git for-each-ref --sort=-committerdate refs/heads/ --format="%(refname:short)") && \
  branch=$(echo "$branches" | fzf +s +m -e) && \
  git switch "$branch"
}
alias gsf='git_switch_fzf'

fcs() {
    PROMPT_EOL_MARK=''
    local commits commit
    commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
    commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
    echo -n $(echo "$commit" | sed "s/ .*//" | sed 's|%||')
}

# fuzzy checkout commit
fchc() {
    local commits commit
    commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
    commit=$(echo "$commits" | fzf --tac +s +m -e) &&
    git checkout $(echo "$commit" | sed "s/ .*//")
}

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

# fchc_preview - checkout commit with diff previews
fchc_preview() {
    local commit
    commit=$( glNoGraph |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" ) &&
    git checkout $(echo "$commit" | sed "s/ .*//")
}

# fs_preview - git commit browser with previews
fs_preview() {
    glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
        --ansi --preview="$_viewGitLogLine" \
        --header "enter to view, alt-y to copy hash" \
        --bind "enter:execute:$_viewGitLogLine   | less -R" \
        --bind "alt-y:execute:$_gitLogLineToHash | xclip"
}

# fuzzy git diff, showing files changed on the left, changed lines on the right in preview
fs() {
  preview="git show $@ --color=always -- {-1}"
  git show $@ --name-only | fzf --multi --ansi --preview $preview
}

# fuzzy git diff, showing files changed on the left, changed lines on the right in preview
fd() {
  preview="git diff $@ --color=always -- {-1}"
  git diff $@ --name-only | fzf --multi --ansi --preview $preview
}

alias vimfiles='vim -p $(fzf -m)'

#fuzzy history: show history with timestamps and print the chosen entry without timestamps
alias fhistory="history -i | fzf +s --tac | cut -d' ' -f5-"

# fuzzy find in man pages
fman() {
    export MANPATH='/usr/share/man'
    f=$(fd . $MANPATH/man${1:-1} -t f -x echo {/.} | fzf) && man $f
}
 # find-in-file: - usage: fif <searchTerm>
fif() { rg --files-with-matches --no-messages $1 | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 $1 || rg --ignore-case --pretty --context 10 $1 {}" }

#fuzzy checkout git ref (branch/tag) local or remote
fchr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout -B $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fchr_preview - checkout git ref, with a preview showing the commits between the tag/branch and HEAD
fchr_preview() {
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(git branch --all | grep -v HEAD |
        sed "s/.* //" | sed "s#remotes/[^/]*/##" |
        sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
        fzf --no-hscroll --no-multi --delimiter="\t" -n 2 \
            --ansi --preview="git log -200 --pretty=format:%s $(echo {+2..} |  sed 's/$/../' )" ) || return
    git checkout $(echo "$target" | awk '{print $2}')
}


################################################################## FASD #############################################################3#####
# fasd & fzf change directory - open best matched file using `fasd` if given argument, filter output of `fasd` using `fzf` else
vimhistory() {
   [ $# -gt 0 ] && fasd -f -e ${EDITOR} "$*" && return
   local file
   file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && vim "${file}" || return 1
}
############################################################### Todoist ######################################################################
# closes a todoist task
tddone() {
         todoist list | fzf | awk '{print $1};' | xargs todoist close
}

alias td='todoist --color'
alias tdc="todoist sync; todoist l | fzf | sed -r 's/p.*$//' | xargs todoist c"


######################################################### Taskwarrior ###########################################################
alias tw='taskwarrior-tui'

task_add_subtask() {
  parent_id=$1
  subtask_description=$2

  # Get the description and urgency of the parent task
  parent_description=$(task _get $parent_id.description)
  parent_urgency=$(task _get $parent_id.urgency)

  # Construct the new task description
  new_description="$parent_description / $subtask_description"

  # Add the new subtask with dependency on the parent task
  task add "$new_description" depends:$parent_id urgency:$parent_urgency
}

######################################################### MISC generated ###########################################################
source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="/opt/homebrew/opt/maven@3.5/bin:$PATH"
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"

source /Users/dan/.config/broot/launcher/bash/br
