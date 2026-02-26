from sqlalchemy.ext.asyncio import AsyncSession

from features.items.repository import ItemRepository


async def test_create_and_get(session: AsyncSession) -> None:
    repo = ItemRepository(session)
    item = await repo.create(name="Repo Test", description="desc")

    assert item.name == "Repo Test"
    assert item.id is not None

    fetched = await repo.get_by_id(item.id)
    assert fetched is not None
    assert fetched.name == "Repo Test"


async def test_get_list(session: AsyncSession) -> None:
    repo = ItemRepository(session)
    await repo.create(name="List Item 1")
    await repo.create(name="List Item 2")

    items, total = await repo.get_list(skip=0, limit=10)
    assert total >= 2
    assert len(items) >= 2


async def test_update(session: AsyncSession) -> None:
    repo = ItemRepository(session)
    item = await repo.create(name="Before Update")

    updated = await repo.update(item, name="After Update")
    assert updated.name == "After Update"


async def test_delete(session: AsyncSession) -> None:
    repo = ItemRepository(session)
    item = await repo.create(name="To Delete")
    item_id = item.id

    await repo.delete(item)

    deleted = await repo.get_by_id(item_id)
    assert deleted is None


async def test_get_nonexistent(session: AsyncSession) -> None:
    import uuid

    repo = ItemRepository(session)
    result = await repo.get_by_id(uuid.uuid4())
    assert result is None
