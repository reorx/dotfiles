export ENV_AUTHORIZATION_FILE=$HOME/.env_auth

_dotenv_hash_pair() {
  env_file=$1
  env_shasum=$(shasum $env_file | cut -d' ' -f1)
  echo "$env_file:$env_shasum"
}

_dotenv_authorized_env_file() {
  env_file=$1
  pair=$(_dotenv_hash_pair $env_file)
  touch $ENV_AUTHORIZATION_FILE
  \grep -Gq $pair $ENV_AUTHORIZATION_FILE
}

_dotenv_authorize() {
  env_file=$1
  _dotenv_deauthorize $env_file
  _dotenv_hash_pair $env_file >> $ENV_AUTHORIZATION_FILE
}

_dotenv_deauthorize() {
  env_file=$1
  echo $(grep -Gv $env_file $ENV_AUTHORIZATION_FILE) > $ENV_AUTHORIZATION_FILE
}

_dotenv_print_unauthorized_message() {
  echo "Attempting to load unauthorized env: $1"
  echo ""
  echo "**********************************************"
  echo ""
  cat $1
  echo ""
  echo "**********************************************"
  echo ""
  echo "Would you like to authorize it? (y/n)"
}

_dotenv_source_env() {
    if [ -e .virtualenv ]; then
        name=$(cat .virtualenv)
        if [ $VIRTUAL_ENV ]; then
            if [ "$name" = "$(basename $VIRTUAL_ENV)" ]; then
                return
            fi
        fi
        workon $name
    fi
  #local env_path="$PWD"
  #local env_file="$PWD/.env"
  #if [ -n "$env_file_path" ]; then
    #if [ "${env_path#*$env_file_path}" = "$env_path" ]; then
      #unset_env
      #unset env_file_path
      #unset unset_env
      #unset set_env
    #fi
  #fi

  #if [[ -f $env_file ]]; then
    #if _dotenv_authorized_env_file $env_file; then
      #source $env_file
      #set_env
      #typeset -x env_file_path=$PWD
      #return 0
    #fi

    #_dotenv_print_unauthorized_message $env_file

    #read answer

    #if [[ $answer == 'y' ]]; then
      #_dotenv_authorize $env_file
      #source $env_file
      #set_env
      #typeset -x env_file_path=$PWD
    #fi
  #fi
}

chpwd_functions=(${chpwd_functions[@]} "_dotenv_source_env")
