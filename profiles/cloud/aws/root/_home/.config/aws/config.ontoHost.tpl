[sso-session ko-org]
sso_start_url = {{ secret "op://ProgrammaticAccess/aws_ko/sso_start_url" }}
sso_region = us-west-1
sso_registration_scopes = sso:account:access

[profile ko-identity]
sso_session = ko-org
sso_account_id = {{ secret "op://ProgrammaticAccess/aws_ko/account_identity" }}
sso_role_name = {{ secret "op://ProgrammaticAccess/aws_ko/user_admin" }}
region = us-east-1

[profile ko-management]
sso_session = ko-org
sso_account_id = {{ secret "op://ProgrammaticAccess/aws_ko/account_management" }}
sso_role_name = {{ secret "op://ProgrammaticAccess/aws_ko/user_admin" }}
region = us-east-1

[profile ko-ci]
sso_session = ko-org
sso_account_id = {{ secret "op://ProgrammaticAccess/aws_ko/account_ci" }}
sso_role_name = {{ secret "op://ProgrammaticAccess/aws_ko/user_admin" }}
region = us-east-1

[profile ko-staging]
sso_session = ko-org
sso_account_id = {{ secret "op://ProgrammaticAccess/aws_ko/account_staging" }}
sso_role_name = {{ secret "op://ProgrammaticAccess/aws_ko/user_admin" }}
region = us-east-1

[profile ko-production]
sso_session = ko-org
sso_account_id = {{ secret "op://ProgrammaticAccess/aws_ko/account_production" }}
sso_role_name = {{ secret "op://ProgrammaticAccess/aws_ko/user_admin" }}
region = us-east-1
