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

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def stripe_enabled(self) -> bool:
        return bool(self.stripe_secret_key) and not self.stripe_secret_key.startswith("sk_test_REPLACE")


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
