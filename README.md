# Dotfiles
*Full of vim and vigour*

## Setup
1. Clone this repository

2. Install `brew` and run `brew bundle` from this directory

3. Install `rcm`
    ```sh
    brew install rcm
    ```

4. Symlink the wanted files to the default location of these files
    ```sh
    rcup -v -x 'README.md' -d ~/gitrepos/dotfiles
    ```
   
5. Install ohmyzsh
    ```sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```


