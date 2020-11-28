################### ZSH, iterm2 #############
export LC_ALL=en_US.UTF-8
export ZSH='/Users/danielmagyar/.oh-my-zsh'
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"

POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_VIRTUALENV_BACKGROUND='purple'
POWERLEVEL9K_TIME_BACKGROUND='darkgrey'
POWERLEVEL9K_TIME_FOREGROUND='grey'
POWERLEVEL9K_DATE_BACKGROUND='darkgrey'
POWERLEVEL9K_DATE_FOREGROUND='grey'
export AWS_DEFAULT_PROFILE=$AWS_OKTA_PROFILE
POWERLEVEL9K_AWS_BACKGROUND='orange1'
POWERLEVEL9K_AWS_FOREGROUND='black'
POWERLEVEL9K_KUBECONTEXT_BACKGROUND='steelblue'
POWERLEVEL9K_KUBECONTEXT_FOREGROUND='black'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(date time newline custom_shell_level aws kubecontext newline docker_machine virtualenv dir vcs status)
POWERLEVEL9K_CUSTOM_SHELL_LEVEL="if (( SHLVL > 1 )); then echo $SHLVL; fi" #print how many levels deep the current shell is if its a subshell
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

ZSH_THEME="powerlevel9k/powerlevel9k"
plugins=(
  git
  git-prompt
  zsh-syntax-highlighting
  fasd
)


source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.iterm2_shell_integration.zsh
source ~/gitrepos/dotfiles/scripts/zsh-interactive-cd.plugin.zsh
source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/gitrepos/opensource/pomodoro/pomodoro.sh
autoload bashcompinit
bashcompinit
source ~/.bashrc

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# misc
alias lookUpHistoryFor='history -i | grep'
alias getHistoryBetween='fc -lf'
alias ls='exa --long --header --links --git --time-style long-iso --all --color-scale'
alias chtsh='~/bin/cht.sh'
alias hcat='highlight --out-format=ansi' #print file with syntax highlighting
alias mkd='mkdir -pv'
alias cp='cp -v' # verbose copy
alias mv='mv -v' # verbose move
alias rm='rm -v' # verbose remove
dotcmd(){
	#cd in a subshell, to execute a command locally
	(cd ~/gitrepos/dotfiles && command $@)
}

################################### Java #########################################
# switch to java version
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
alias j8='export JAVA_HOME=$JAVA_8_HOME'
alias j11='export JAVA_HOME=$JAVA_11_HOME'

#use java8 by default
j8

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

alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'
alias kget='kubectl get'
alias kdsc='kubectl describe'

######################  git aliases and utilities ################################
alias s='git show --format=fuller'
alias ch='git checkout '
alias cam='git commit -a -m '
alias gpr='git pull --rebase'
alias c='git commit -a -v'
alias grv='git remote -v'
alias d='git diff '
alias dg='git difftool --gui --no-prompt '
alias plc="git log --full-history --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias pl="git log HEAD --full-history --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias reml="git log origin/master --full-history --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -20"
alias prl="git reflog --format='%C(auto)%h %<|(20)%gd %C(blue)%cr%C(reset) %gs (%s)'"
alias st='git status'

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

###########################  Oh my god, it's so fuzzy I'm gonna die ############################

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

######################################################### Cloudera specific utils ###########################################################
source ~/gitrepos/cloudera-scrpits/cloudera-utils.sh

