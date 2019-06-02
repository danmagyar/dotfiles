################### ZSH, iterm2 #############

export ZSH='/Users/danielmagyar/.oh-my-zsh'
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"
#ZSH_THEME="agnoster"
ZSH_THEME="powerlevel9k/powerlevel9k"
plugins=(
  git
  git-prompt
  zsh-syntax-highlighting
)


source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.iterm2_shell_integration.zsh
source ~/gitrepos/dotfiles/scripts/zsh-interactive-cd.plugin.zsh
source $ZSH/oh-my-zsh.sh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# misc
alias a='atom'
alias lookUpHistoryFor='history -i | grep'
alias getHistoryBetween='fc -lf'
alias ls='exa --long --header --links --git --time-style long-iso --all --color-scale'
alias cht.sh='~/bin/cht.sh'
alias hcat='highlight --out-format=ansi' #print file with syntax highlighting
alias mkd='mkdir -pv'
dotcmd(){
	pushd ~/gitrepos/dotfiles
	command $@
	popd
}


######################  git aliases and utilities ################################
alias s='git show '
alias ch='git checkout '
alias cam='git commit -a -m '
alias gpr='git pull --rebase'
alias grv='git remote -v'
alias d='git diff '
alias dg='git difftool --gui --no-prompt '
alias plc="git log --full-history --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias pl="git log HEAD --full-history --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias reml="git log origin/master --full-history --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -20"
alias prl="git reflog --format='%C(auto)%h %<|(20)%gd %C(blue)%cr%C(reset) %gs (%s)'"

#squashes the last n commit and creates a new commit
#EXAMPLE: nSquashCommit 15
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

fvim() {
	file=$(ll | fzf | awk '{print $NF}')
	vim $file
}

alias fhistory='history | fzf +s --tac'

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
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
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


################################################################## Autojump #############################################################3#####
#Autojump installation:
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

#Autojump j works with fuzzy find
j(){
    if [[ "$#" -ne 0 ]]; then
        cd $(autojump $@)
        return
    fi
    cd "$(autojump -s | sed '/_____/Q; s/^[0-9,.:]*\s*//' |  fzf --height 40% --reverse --inline-info)"
}


############################################################### Todoist ######################################################################
alias td='todoist --color'
#todoist close and modify task using fzf
alias tdc="todoist sync; todoist l | fzf | sed -r 's/p.*$//' | xargs todoist c"


######################################################### Cloudera specific utils ###########################################################
source ~/gitrepos/cloudera-scrpits/cloudera-utils.sh

