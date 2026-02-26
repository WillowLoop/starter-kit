import uuid

from httpx import AsyncClient


async def test_create_item(client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/items",
        json={"name": "Test Item", "description": "A test item"},
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Item"
    assert data["description"] == "A test item"
    assert "id" in data
    assert "created_at" in data


async def test_list_items(client: AsyncClient) -> None:
    await client.post("/api/v1/items", json={"name": "Item 1"})
    await client.post("/api/v1/items", json={"name": "Item 2"})

    response = await client.get("/api/v1/items")
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "total" in data
    assert data["total"] >= 2


async def test_get_item(client: AsyncClient) -> None:
    create_response = await client.post("/api/v1/items", json={"name": "Get Me"})
    item_id = create_response.json()["id"]

    response = await client.get(f"/api/v1/items/{item_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Get Me"


async def test_update_item(client: AsyncClient) -> None:
    create_response = await client.post("/api/v1/items", json={"name": "Old Name"})
    item_id = create_response.json()["id"]

    response = await client.put(
        f"/api/v1/items/{item_id}",
        json={"name": "New Name"},
    )
    assert response.status_code == 200
    assert response.json()["name"] == "New Name"


async def test_delete_item(client: AsyncClient) -> None:
    create_response = await client.post("/api/v1/items", json={"name": "Delete Me"})
    item_id = create_response.json()["id"]

    response = await client.delete(f"/api/v1/items/{item_id}")
    assert response.status_code == 204

    get_response = await client.get(f"/api/v1/items/{item_id}")
    assert get_response.status_code == 404


async def test_get_nonexistent_item(client: AsyncClient) -> None:
    fake_id = uuid.uuid4()
    response = await client.get(f"/api/v1/items/{fake_id}")
    assert response.status_code == 404


async def test_delete_nonexistent_item(client: AsyncClient) -> None:
    fake_id = uuid.uuid4()
    response = await client.delete(f"/api/v1/items/{fake_id}")
    assert response.status_code == 404
