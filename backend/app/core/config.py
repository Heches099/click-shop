from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "ClickShop API"
    api_v1_prefix: str = "/v1"

    database_url: str = "postgresql+asyncpg://clickshop:clickshop@localhost:5432/clickshop"

    jwt_secret: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 10080

    admin_email: str = "admin@clickshop.com"
    admin_password: str = "ChangeMe123!"

    stripe_secret_key: str = ""
    stripe_webhook_secret: str = ""

    cors_origins: str = "http://localhost:8080,http://localhost:3000"

    store_base_url: str = "https://clickshop.example.com"
    affiliate_commission_rate: float = 0.10

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
