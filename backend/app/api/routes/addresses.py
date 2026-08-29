import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user
from app.api.serializers import address_out
from app.core.database import get_db
from app.models import Address, User
from app.schemas.address import AddressIn, AddressOut, AddressUpdate

router = APIRouter(prefix="/addresses", tags=["addresses"])


async def _get_owned(db: AsyncSession, user: User, address_id: str) -> Address:
    address = await db.scalar(select(Address).where(Address.id == address_id, Address.user_id == user.id))
    if address is None:
        raise HTTPException(status_code=404, detail="Address not found")
    return address


@router.get("", response_model=list[AddressOut])
async def list_addresses(user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    addresses = await db.scalars(
        select(Address).where(Address.user_id == user.id).order_by(Address.is_default.desc(), Address.created_at.asc())
    )
    return [address_out(a) for a in addresses]


@router.post("", response_model=AddressOut, status_code=status.HTTP_201_CREATED)
async def create_address(
    payload: AddressIn,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if payload.is_default:
        await db.execute(Address.__table__.update().where(Address.user_id == user.id).values(is_default=False))
    address = Address(
        user_id=user.id,
        name=payload.name,
        phone=payload.phone,
        street=payload.street,
        city=payload.city,
        state=payload.state,
        zip_code=payload.zip_code,
        country=payload.country,
        is_default=payload.is_default,
    )
    db.add(address)
    await db.commit()
    await db.refresh(address)
    return address_out(address)


@router.put("/{address_id}", response_model=AddressOut)
async def update_address(
    address_id: str,
    payload: AddressUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    address = await _get_owned(db, user, address_id)
    if payload.is_default:
        await db.execute(Address.__table__.update().where(Address.user_id == user.id).values(is_default=False))
        address.is_default = True
    for field, value in payload.model_dump(exclude_unset=True).items():
        if field != "is_default":
            setattr(address, field, value)
    await db.commit()
    await db.refresh(address)
    return address_out(address)


@router.put("/{address_id}/default", response_model=AddressOut)
async def set_default_address(
    address_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    address = await _get_owned(db, user, address_id)
    await db.execute(Address.__table__.update().where(Address.user_id == user.id).values(is_default=False))
    address.is_default = True
    await db.commit()
    await db.refresh(address)
    return address_out(address)


@router.delete("/{address_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_address(address_id: str, user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    address = await _get_owned(db, user, address_id)
    await db.delete(address)
    await db.commit()
    return None
