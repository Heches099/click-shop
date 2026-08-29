from pydantic import BaseModel, ConfigDict


class CategoryOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    slug: str
    parent_id: str | None = None
    image: str | None = None
    subcategories: list["CategoryOut"] = []


CategoryOut.model_rebuild()
