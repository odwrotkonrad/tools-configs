##[>] 🤖🤖
if (( ! ${+OP_SERVICE_ACCOUNT_TOKEN} )) {
  export OP_SERVICE_ACCOUNT_TOKEN=$(security find-generic-password -s op-service-account-token -w 2>/dev/null)
}
##[<] 🤖🤖
