# Dotfiles
*Full of vim and vigour*

## Setup
1. Clone this repository

2. Install `brew` and run `brew bundle` from this directory to install everything from the `Brewfile`
   ```shell
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   brew bundle
   ```

3. Install `rcm`
    ```sh
    brew install rcm
    ```

4. Symlink the wanted files to the default location of these files
    ```sh
    rcup -v -x 'README.md' -d ~/gitrepos/dotfiles
    ```

5. Install ohmyzsh and plugins
    ```sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    ```

6. Install fzf-git
    ```shell
    git clone git@github.com:junegunn/fzf-git.sh.git ~/gitrepos/fzf-git.sh
    ```

7. load iterm2 preferences from this repository: ![](.README_images/iterm2-preferences.png)


## How to
### refresh brew bundle
```shell
rm Brewfile
brew bundle dump --describe
```