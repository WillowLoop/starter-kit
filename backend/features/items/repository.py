import uuid

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from shared.db.models.item import Item


class ItemRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_id(self, item_id: uuid.UUID) -> Item | None:
        return await self.session.get(Item, item_id)

    async def get_list(self, skip: int = 0, limit: int = 20) -> tuple[list[Item], int]:
        total_result = await self.session.execute(select(func.count()).select_from(Item))
        total = total_result.scalar_one()

        result = await self.session.execute(
            select(Item).offset(skip).limit(limit).order_by(Item.created_at.desc())
        )
        items = list(result.scalars().all())

        return items, total

    async def create(self, **kwargs: object) -> Item:
        item = Item(**kwargs)
        self.session.add(item)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def update(self, item: Item, **kwargs: object) -> Item:
        for key, value in kwargs.items():
            setattr(item, key, value)
        await self.session.commit()
        await self.session.refresh(item)
        return item

    async def delete(self, item: Item) -> None:
        await self.session.delete(item)
        await self.session.commit()
