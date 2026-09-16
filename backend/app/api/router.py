from fastapi import APIRouter

from app.api.routes import (
    addresses,
    admin,
    affiliate,
    amazon,
    analytics,
    auth,
    cart,
    categories,
    contact,
    content,
    health,
    orders,
    payments,
    products,
    reviews,
    search,
)

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(products.router)
api_router.include_router(amazon.router)
api_router.include_router(categories.router)
api_router.include_router(reviews.router)
api_router.include_router(cart.router)
api_router.include_router(orders.router)
api_router.include_router(payments.router)
api_router.include_router(addresses.router)
api_router.include_router(affiliate.router)
api_router.include_router(content.router)
api_router.include_router(search.router)
api_router.include_router(analytics.router)
api_router.include_router(contact.router)
api_router.include_router(admin.router)
