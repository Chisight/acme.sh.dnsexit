#!/bin/bash

#run export DNSEXITAPIKEY=[your api key]
#Usage: warning, this script will be sourced and then called as: dns_localdnsexit_add() _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
#where "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs" is the key that will be created under _acme-challenge.www.domain.com
#later dns_localdnsexit_rm() will be called with the same parameters
#warning, add creates new txt records, do not overwrite them as multiple records are needed.

#source code at https://github.com/Chisight/acme.sh.dnsexit

dnsexit_Api="https://api.dnsexit.com/dns/"

########  Public functions #####################
dns_localdnsexit_add() {
  echo "echo i got here!!"
  _info "info i got here!!"
  sleep 20
  _info "Using localdnsexit" 
  _debug "Command-line parameters:"$*""
  fulldomain=$1
  txtvalue=$2
  _debug "First detect the root zone"
  if ! _get_root "$fulldomain"; then
    _err "invalid domain"
    return 1
  fi
  _debug "fulldomain=$fulldomain"
  _debug "txtvalue=$txtvalue"
  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"

  _data=$( cat << EOF
{
  "domain": "$_domain",
  "add":{
    "type": "TXT",
    "name": "$_sub_domain",
    "content": "$txtvalue",
    "ttl": 0,
    "overwrite": false
  }
}
EOF
)
  _debug "json request=" ${_data}
  _dnsexit_rest ${_data}

#  curl  -H "Content-Type: application/json" -H "apikey: $DNSEXITAPIKEY" --data @$HOME/acme.json https://api.dnsexit.com/dns/

#use this instead of curl:
#export _H1="Content-Type: application/json"
#  _content="$(printf "*%s*\n" "$_content" | _json_encode)"
#  _subject="$(printf "*%s*\n" "$_subject" | _json_encode)"
#  _data="{\"token\": \"$PUSHOVER_TOKEN\",\"user\": \"$PUSHOVER_USER\",\"title\": \"$_subject\",\"message\": \"$_content\",\"sound\": \"$PUSHOVER_SOUND\", \"device\": \"$PUSHOVER_DEVICE\", \"priority\": \"$PUSHOVER_PRIORITY\"}"
#  response="$(_post "$_data" "$PUSHOVER_URI")"



  #rm ~/acme.json

  sleep 2m
}

#fulldomain txtvalue
dns_localdnsexit_rm() {
  fulldomain=$1
  txtvalue=$2
  _debug "First detect the root zone"
  if ! _get_root "$fulldomain"; then
    _err "invalid domain"
    return 1
  fi
  _debug "fulldomain=$fulldomain"
  _debug "txtvalue=$txtvalue"
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
#_acme-challenge.www.domain.com
#returns
# _sub_domain=_acme-challenge.www
# _domain=domain.com
# _domain_id=sdjkglgdfewsdfg
_get_root() {
  fullname=$1
  n=1
  _sub_domain=$(echo $fullname | cut -d. -f-$n)
  let n+=1
  _domain=$(echo $fullname | cut -d. -f$n-)
  while echo "$_domain"| nc whois.verisign-grs.com 43 | grep "No match for"; do 
    _sub_domain=$(echo $fullname | cut -d. -f-$n)
    let n+=1
    _domain=$(echo $fullname | cut -d. -f$n-)
    _debug $_sub_domain
    _debug $_domain
    if [ "$_domain" ]; then
      return 1
    fi
  done 
  return 0
}

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
