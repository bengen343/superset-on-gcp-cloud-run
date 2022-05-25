import os

from flask_appbuilder.security.manager import AUTH_DB, AUTH_OAUTH

ENABLE_PROXY_FIX=True
ROW_LIMIT=5000
SECRET_KEY=os.getenv("SECRET_KEY")
SQLALCHEMY_DATABASE_URI=os.getenv("CONNECTION_STRING")
WTF_CSRF_ENABLED=True
CSRF_ENABLED=True

FEATURE_FLAGS = {
    "DASHBOARD_NATIVE_FILTERS": True,
}

OAUTH_PROVIDERS = [{
    "name": "google",
    "whitelist": ["@constellationpolitical.com"],
    "icon": "fa-google",
    "token_key": "access_token",
    "remote_app": {
        "client_id": os.getenv("GOOGLE_ID"),
        "client_secret": os.getenv("GOOGLE_SECRET"),
        "api_base_url": "https://www.googleapis.com/oauth2/v2/",
        "client_kwargs":{ "scope": "email profile" },
        "request_token_url": None,
        "access_token_url": "https://accounts.google.com/o/oauth2/token",
        "authorize_url": "https://accounts.google.com/o/oauth2/auth",
        "authorize_params": {"hd": "constellationpolitical.com"}
    }
}]

AUTH_TYPE=AUTH_OAUTH

AUTH_ROLE_ADMIN="Admin"
AUTH_ROLE_PUBLIC="Public"

AUTH_USER_REGISTRATION=True

AUTH_USER_REGISTRATION_ROLE="Admin"
