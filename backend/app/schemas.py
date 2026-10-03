from pydantic import BaseModel


class ArtisanCreate(BaseModel):
    name: str
    craft_type: str | None = None
    location: str | None = None
    language: str | None = None
    phone: str | None = None


class ArtisanResponse(ArtisanCreate):
    id: int

    class Config:
        from_attributes = True