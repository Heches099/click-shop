"""Convert ORM objects into the JSON shapes consumed by the Flutter app."""


def product_out(product) -> dict:
    return {
        "id": product.id,
        "name": product.name,
        "description": product.description,
        "price": product.price,
        "originalPrice": product.original_price,
        "images": product.images or [],
        "rating": product.rating,
        "reviewCount": product.review_count,
        "category": product.category.slug if product.category else "",
        "stock": product.stock,
        "brand": product.brand,
        "specifications": product.specifications or {},
        "colors": product.colors or [],
        "sizes": product.sizes or [],
        "isFeatured": product.is_featured,
        "isBestSeller": product.is_best_seller,
        "isNewArrival": product.is_new_arrival,
        "isFlashSale": product.is_flash_sale,
    }


def category_out(category) -> dict:
    return {
        "id": category.id,
        "name": category.name,
        "slug": category.slug,
        "parentId": category.parent_id,
        "image": category.image,
        "subcategories": [category_out(c) for c in category.subcategories],
    }


def cart_item_out(cart_item) -> dict:
    return {
        "id": cart_item.id,
        "product": product_out(cart_item.product),
        "quantity": cart_item.quantity,
        "selectedColor": cart_item.selected_color,
        "selectedSize": cart_item.selected_size,
    }


def address_out(a) -> dict:
    """Address ORM -> app AddressModel shape (camelCase)."""
    return {
        "id": a.id,
        "name": a.name,
        "phone": a.phone,
        "street": a.street,
        "city": a.city,
        "state": a.state,
        "zipCode": a.zip_code,
        "country": a.country,
        "isDefault": a.is_default,
    }


def address_dict_out(addr: dict) -> dict:
    """An Order's stored shipping_address is a plain dict already in app shape."""
    return {
        "id": addr.get("id", ""),
        "name": addr.get("name", ""),
        "phone": addr.get("phone", ""),
        "street": addr.get("street", ""),
        "city": addr.get("city", ""),
        "state": addr.get("state", ""),
        "zipCode": addr.get("zipCode", ""),
        "country": addr.get("country", ""),
        "isDefault": addr.get("isDefault", False),
    }


def order_out(order) -> dict:
    items = []
    for item in order.items:
        product = item.product
        snapshot = item.product_snapshot or {}
        product_dict = product_out(product) if product else {
            "id": snapshot.get("id", ""),
            "name": snapshot.get("name", ""),
            "description": snapshot.get("description", ""),
            "price": snapshot.get("price", 0),
            "originalPrice": snapshot.get("originalPrice"),
            "images": snapshot.get("images", []),
            "rating": 0.0,
            "reviewCount": 0,
            "category": snapshot.get("category", ""),
            "stock": 0,
            "brand": snapshot.get("brand", ""),
            "specifications": {},
            "colors": [],
            "sizes": [],
        }
        items.append(
            {
                "product": product_dict,
                "quantity": item.quantity,
                "selectedColor": item.selected_color,
                "selectedSize": item.selected_size,
            }
        )
    return {
        "id": order.id,
        "userId": order.user_id,
        "items": items,
        "subtotal": order.subtotal,
        "shippingFee": order.shipping_fee,
        "tax": order.tax,
        "total": order.total,
        "shippingAddress": address_dict_out(order.shipping_address or {}),
        "status": order.status,
        "createdAt": order.created_at.isoformat() if order.created_at else None,
        "trackingNumber": order.tracking_number,
        "paymentMethod": order.payment_method,
        "paymentId": order.payment_id,
    }
