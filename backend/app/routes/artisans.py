from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Artisan
from ..schemas import ArtisanCreate, ArtisanResponse

router = APIRouter(
    prefix="/artisans",
    tags=["Artisans"]
)


@router.post("/register", response_model=ArtisanResponse)
def register_artisan(
    artisan_data: ArtisanCreate,
    db: Session = Depends(get_db)
):
    artisan = Artisan(
        name=artisan_data.name,
        craft_type=artisan_data.craft_type,
        location=artisan_data.location,
        language=artisan_data.language,
        phone=artisan_data.phone,
    )

    db.add(artisan)
    db.commit()
    db.refresh(artisan)

    return artisan


@router.get("/{artisan_id}", response_model=ArtisanResponse)
def get_artisan(
    artisan_id: int,
    db: Session = Depends(get_db)
):
    artisan = db.query(Artisan).filter(
        Artisan.id == artisan_id
    ).first()

    if not artisan:
        raise HTTPException(
            status_code=404,
            detail="Artisan not found"
        )

    return artisan