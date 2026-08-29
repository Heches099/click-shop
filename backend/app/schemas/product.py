from pydantic import BaseModel, ConfigDict, Field


class ProductCreate(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    name: str = Field(min_length=1, max_length=255)
    description: str = Field(min_length=1)
    price: float = Field(gt=0)
    original_price: float | None = Field(default=None, gt=0, alias="originalPrice")
    images: list[str] = []
    category_slug: str = Field(min_length=1, alias="categorySlug")
    brand: str = Field(min_length=1, max_length=120)
    stock: int = Field(default=0, ge=0)
    specifications: dict[str, str] = {}
    colors: list[str] = []
    sizes: list[str] = []
    is_featured: bool = Field(default=False, alias="isFeatured")
    is_best_seller: bool = Field(default=False, alias="isBestSeller")
    is_new_arrival: bool = Field(default=False, alias="isNewArrival")
    is_flash_sale: bool = Field(default=False, alias="isFlashSale")
    is_recommended: bool = Field(default=False, alias="isRecommended")


class ProductUpdate(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    name: str | None = Field(default=None, min_length=1, max_length=255)
    description: str | None = Field(default=None, min_length=1)
    price: float | None = Field(default=None, gt=0)
    original_price: float | None = Field(default=None, gt=0, alias="originalPrice")
    images: list[str] | None = None
    category_slug: str | None = Field(default=None, alias="categorySlug")
    brand: str | None = Field(default=None, min_length=1, max_length=120)
    stock: int | None = Field(default=None, ge=0)
    specifications: dict[str, str] | None = None
    colors: list[str] | None = None
    sizes: list[str] | None = None
    is_featured: bool | None = Field(default=None, alias="isFeatured")
    is_best_seller: bool | None = Field(default=None, alias="isBestSeller")
    is_new_arrival: bool | None = Field(default=None, alias="isNewArrival")
    is_flash_sale: bool | None = Field(default=None, alias="isFlashSale")
    is_recommended: bool | None = Field(default=None, alias="isRecommended")
    is_active: bool | None = Field(default=None, alias="isActive")


class ProductOut(BaseModel):
    """Response shape consumed by the Flutter app's ProductModel."""

    model_config = ConfigDict(populate_by_name=True)

    id: str
    name: str
    description: str
    price: float
    original_price: float | None = Field(default=None, alias="originalPrice")
    images: list[str] = []
    rating: float = 0.0
    review_count: int = Field(default=0, alias="reviewCount")
    category: str
    stock: int
    brand: str
    specifications: dict[str, str] = {}
    colors: list[str] = []
    sizes: list[str] = []
    is_featured: bool = Field(default=False, alias="isFeatured")
    is_best_seller: bool = Field(default=False, alias="isBestSeller")
    is_new_arrival: bool = Field(default=False, alias="isNewArrival")
    is_flash_sale: bool = Field(default=False, alias="isFlashSale")
