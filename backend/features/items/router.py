import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from features.items.repository import ItemRepository
from features.items.schema import ItemCreate, ItemListResponse, ItemResponse, ItemUpdate
from features.items.service import ItemService
from shared.db.session import get_session

router = APIRouter()


def get_item_service(session: AsyncSession = Depends(get_session)) -> ItemService:
    return ItemService(ItemRepository(session))


@router.get("", response_model=ItemListResponse)
async def list_items(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    service: ItemService = Depends(get_item_service),
) -> ItemListResponse:
    return await service.get_list(skip=skip, limit=limit)


@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(
    item_id: uuid.UUID,
    service: ItemService = Depends(get_item_service),
) -> ItemResponse:
    return await service.get_by_id(item_id)


@router.post("", response_model=ItemResponse, status_code=201)
async def create_item(
    data: ItemCreate,
    service: ItemService = Depends(get_item_service),
) -> ItemResponse:
    return await service.create(data)


@router.put("/{item_id}", response_model=ItemResponse)
async def update_item(
    item_id: uuid.UUID,
    data: ItemUpdate,
    service: ItemService = Depends(get_item_service),
) -> ItemResponse:
    return await service.update(item_id, data)


@router.delete("/{item_id}", status_code=204)
async def delete_item(
    item_id: uuid.UUID,
    service: ItemService = Depends(get_item_service),
) -> None:
    await service.delete(item_id)
