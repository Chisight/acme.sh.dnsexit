#run export DNSEXITAPIKEY=[your api key]
#Usage: warning, this script will be sourced and then called as: dns_localdnsexit_add _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
#where "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs" is the key that will be created under _acme-challenge.www.domain.com
#later dns_localdnsexit_rm() will be called with the same parameters
#warning, add creates new txt records, do not overwrite them as multiple records are needed.

#source code at https://github.com/Chisight/acme.sh.dnsexit

dnsexit_Api="https://api.dnsexit.com/dns/"

########  Public functions #####################
dns_localdnsexit_add() {
  _info "Using localdnsexit" 
  _debug "Command-line parameters: $*"
  # Initialize _sub_domain
  _sub_domain=""
  _domain=""

  fulldomain=$1
  txtvalue=$2

  # Strip off _acme-challenge.
  if [[ $fulldomain == _acme-challenge.* ]]; then
    _sub_domain=_acme-challenge.
    _domain=${fulldomain#_acme-challenge.}
  fi

  # Remove leading '*' if present
  if [[ $_domain == \*.* ]]; then
    _domain=${_domain#\*.}
  fi  

  _debug "fulldomain=$fulldomain"
  _debug "txtvalue=$txtvalue"
  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"

  # Loop to handle the _dnsexit_rest call
  while true; do
    # Check if there's still a period left
    if [[ $_domain != *.* ]]; then
      _err "invalid domain"
      return 1
    fi

    # Prepare the JSON data
    _data=$(cat << EOF
{
  "domain": "$_domain",
  "add": {
    "type": "TXT",
    "name": "$_sub_domain",
    "content": "$txtvalue",
    "ttl": 0,
    "overwrite": false
  }
}
EOF
)

    _debug "json request= $_data"
    
    # Try the _dnsexit_rest call
    if _dnsexit_rest "$_data"; then
      break  # Success, exit the loop
    fi
    
    # move the first part of the domain to _subdomain
    _sub_domain=${_sub_domain}${_domain%%.*}
    _domain=${_domain#*.}

  done

  sleep 2m
  return 0
}

#fulldomain txtvalue
dns_localdnsexit_rm() {
  fulldomain=$1
  txtvalue=$2
  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"

  _data=$( cat << EOF
{
  "domain": "$_domain",
  "delete":{
    "type": "TXT",
    "name": "$_sub_domain"
  }
}
EOF
)
  _debug "json request=" ${_data}
  _dnsexit_rest ${_data}

  return 0
}

####################  Private functions below ##################################
_dnsexit_rest() {
  export _H1="Content-Type: application/json"
  export _H2="apikey: $DNSEXITAPIKEY"
  _response="$(_post "$_data" "$dnsexit_Api")"
  if [ "$?" = "0" ] && _contains "$_response" "{\"code\":0"; then
    _debug $_response
    _info "dnsexit send success."
    return 0
  fi
  _err "dnsexit send error."
  return 1
}
