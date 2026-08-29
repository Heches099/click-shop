from fastapi import APIRouter

from app.api.routes import (
    addresses,
    admin,
    affiliate,
    auth,
    cart,
    categories,
    health,
    orders,
    payments,
    products,
    reviews,
)

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(products.router)
api_router.include_router(categories.router)
api_router.include_router(reviews.router)
api_router.include_router(cart.router)
api_router.include_router(orders.router)
api_router.include_router(payments.router)
api_router.include_router(addresses.router)
api_router.include_router(affiliate.router)
api_router.include_router(admin.router)
