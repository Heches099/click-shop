from pydantic import BaseModel, ConfigDict, Field


class AddressIn(BaseModel):
    name: str
    phone: str
    street: str
    city: str
    state: str
    zip_code: str
    country: str
    is_default: bool = False


class AddressUpdate(BaseModel):
    name: str | None = None
    phone: str | None = None
    street: str | None = None
    city: str | None = None
    state: str | None = None
    zip_code: str | None = None
    country: str | None = None
    is_default: bool | None = None


class AddressOut(BaseModel):
    """Response shape consumed by the app's AddressModel (camelCase)."""

    id: str
    name: str
    phone: str
    street: str
    city: str
    state: str
    zipCode: str
    country: str
    isDefault: bool = False
