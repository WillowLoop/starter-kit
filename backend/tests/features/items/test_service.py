import uuid
from datetime import UTC, datetime
from unittest.mock import AsyncMock

import pytest

from features.items.schema import ItemCreate, ItemUpdate
from features.items.service import ItemService
from shared.db.models.item import Item
from shared.lib.exceptions import NotFoundException


def _make_item(**kwargs: object) -> Item:
    defaults: dict[str, object] = {
        "id": uuid.uuid4(),
        "name": "Test Item",
        "description": None,
        "created_at": datetime.now(tz=UTC),
        "updated_at": datetime.now(tz=UTC),
    }
    defaults.update(kwargs)
    item = Item()
    for key, value in defaults.items():
        setattr(item, key, value)
    return item


async def test_get_by_id_returns_item() -> None:
    item = _make_item(name="Found")
    repo = AsyncMock()
    repo.get_by_id.return_value = item

    service = ItemService(repo)
    result = await service.get_by_id(item.id)

    assert result.name == "Found"
    repo.get_by_id.assert_called_once_with(item.id)


async def test_get_by_id_raises_not_found() -> None:
    repo = AsyncMock()
    repo.get_by_id.return_value = None

    service = ItemService(repo)
    with pytest.raises(NotFoundException):
        await service.get_by_id(uuid.uuid4())


async def test_create_item() -> None:
    item = _make_item(name="New Item")
    repo = AsyncMock()
    repo.create.return_value = item

    service = ItemService(repo)
    result = await service.create(ItemCreate(name="New Item"))

    assert result.name == "New Item"
    repo.create.assert_called_once()


async def test_update_item() -> None:
    item = _make_item(name="Old")
    updated_item = _make_item(id=item.id, name="Updated")
    repo = AsyncMock()
    repo.get_by_id.return_value = item
    repo.update.return_value = updated_item

    service = ItemService(repo)
    result = await service.update(item.id, ItemUpdate(name="Updated"))

    assert result.name == "Updated"


async def test_delete_raises_not_found() -> None:
    repo = AsyncMock()
    repo.get_by_id.return_value = None

    service = ItemService(repo)
    with pytest.raises(NotFoundException):
        await service.delete(uuid.uuid4())
