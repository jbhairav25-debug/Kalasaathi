from datetime import datetime

from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from .database import Base


class Artisan(Base):
    __tablename__ = "artisans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    craft_type = Column(String(100), nullable=True)
    location = Column(String(150), nullable=True)
    language = Column(String(50), nullable=True)
    phone = Column(String(20), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    products = relationship(
        "Product",
        back_populates="artisan",
        cascade="all, delete-orphan",
    )


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    artisan_id = Column(
        Integer,
        ForeignKey("artisans.id"),
        nullable=False,
    )

    name = Column(String(200), nullable=False)
    category = Column(String(100), nullable=True)
    material = Column(String(100), nullable=True)
    description = Column(Text, nullable=True)
    tags = Column(String(500), nullable=True)
    image_path = Column(String(500), nullable=True)

    material_cost = Column(Float, default=0)
    work_hours = Column(Float, default=0)
    hourly_wage = Column(Float, default=0)
    packaging_cost = Column(Float, default=0)

    cost_floor = Column(Float, default=0)
    suggested_min_price = Column(Float, default=0)
    suggested_max_price = Column(Float, default=0)

    status = Column(String(50), default="draft")
    created_at = Column(DateTime, default=datetime.utcnow)

    artisan = relationship(
        "Artisan",
        back_populates="products",
    )

    orders = relationship(
        "Order",
        back_populates="product",
    )


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(
        Integer,
        ForeignKey("products.id"),
        nullable=False,
    )

    buyer_name = Column(String(100), nullable=True)
    buyer_phone = Column(String(20), nullable=True)
    quantity = Column(Integer, default=1)
    total_amount = Column(Float, default=0)
    status = Column(String(50), default="pending")

    created_at = Column(DateTime, default=datetime.utcnow)

    product = relationship(
        "Product",
        back_populates="orders",
    )