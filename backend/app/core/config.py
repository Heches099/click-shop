from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "ClickShop API"
    api_v1_prefix: str = "/v1"

    # Enable ONLY for local development. When False, API docs (/docs, /redoc,
    # /openapi.json) are disabled to reduce information disclosure.
    debug: bool = False

    database_url: str = "postgresql+asyncpg://clickshop:clickshop@localhost:5432/clickshop"

    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 10080

    admin_email: str = "admin@clickshop.com"
    admin_password: str = "ChangeMe123!"

    # Comma-separated list of emails that are automatically granted the owner/
    # admin role at sign-up / sign-in. Server-side only — never exposed to the
    # client, and never derived from anything the app sends.
    admin_emails: str = ""

    stripe_secret_key: str = ""
    stripe_webhook_secret: str = ""

    # Public Firebase Web API key used to verify Firebase ID tokens against
    # this project (accounts:lookup). Not a secret — it ships in the client.
    firebase_web_api_key: str = ""

    cors_origins: str = "http://localhost:8080,http://localhost:3000"

    store_base_url: str = "https://clickshop.example.com"
    affiliate_commission_rate: float = 0.10

    # Optional comma-separated list of trusted reverse-proxy IPs. The rate
    # limiter only trusts X-Forwarded-For when the direct peer is listed here;
    # leave empty to prevent header spoofing (client IP from the socket only).
    trusted_proxy_ips: str = ""

    # --- Amazon Associates ---
    # Affiliate-link mode is the default and requires NO credentials.
    # Keep amazon_api_enabled=false until the Associates account is
    # eligible for the Amazon Creators API / PA-API.
    amazon_api_enabled: bool = False

    # Public affiliate tracking ID (not a secret — appears in affiliate URLs).
    amazon_partner_tag: str = "clickshop03b-20"
    amazon_marketplace: str = "www.amazon.com"
    amazon_region: str = "us-east-1"

    # Future Amazon API credentials (backend-only, never returned to clients).
    amazon_access_key: str = ""
    amazon_secret_key: str = ""

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def admin_emails_list(self) -> list[str]:
        return [e.strip().lower() for e in self.admin_emails.split(",") if e.strip()]

    @property
    def stripe_enabled(self) -> bool:
        return bool(self.stripe_secret_key) and not self.stripe_secret_key.startswith("sk_test_REPLACE")

    @property
    def amazon_api_credentials_present(self) -> bool:
        """True only when both Amazon API credentials are configured."""
        return bool(self.amazon_access_key) and bool(self.amazon_secret_key)

    @property
    def amazon_api_ready(self) -> bool:
        """True only when the API is enabled AND fully configured."""
        return self.amazon_api_enabled and self.amazon_api_credentials_present


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
