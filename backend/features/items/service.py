import uuid

from features.items.repository import ItemRepository
from features.items.schema import ItemCreate, ItemListResponse, ItemResponse, ItemUpdate
from shared.lib.exceptions import NotFoundException


class ItemService:
    def __init__(self, repository: ItemRepository) -> None:
        self.repository = repository

    async def get_by_id(self, item_id: uuid.UUID) -> ItemResponse:
        item = await self.repository.get_by_id(item_id)
        if not item:
            raise NotFoundException(f"Item {item_id} not found")
        return ItemResponse.model_validate(item)

    async def get_list(self, skip: int = 0, limit: int = 20) -> ItemListResponse:
        items, total = await self.repository.get_list(skip=skip, limit=limit)
        return ItemListResponse(
            items=[ItemResponse.model_validate(item) for item in items],
            total=total,
        )

    async def create(self, data: ItemCreate) -> ItemResponse:
        item = await self.repository.create(**data.model_dump())
        return ItemResponse.model_validate(item)

    async def update(self, item_id: uuid.UUID, data: ItemUpdate) -> ItemResponse:
        item = await self.repository.get_by_id(item_id)
        if not item:
            raise NotFoundException(f"Item {item_id} not found")
        updated = await self.repository.update(item, **data.model_dump(exclude_unset=True))
        return ItemResponse.model_validate(updated)

    async def delete(self, item_id: uuid.UUID) -> None:
        item = await self.repository.get_by_id(item_id)
        if not item:
            raise NotFoundException(f"Item {item_id} not found")
        await self.repository.delete(item)
