#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/scaffold-feature.sh <kebab-name> [singular-form]
NAME="${1:-}"
SINGULAR_OVERRIDE="${2:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: make scaffold name=feature-name [singular=singular-form]" >&2
  exit 1
fi

if [[ ! "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Error: Name must be kebab-case (lowercase letters, numbers, hyphens)." >&2
  exit 1
fi

# ── Name derivation ──────────────────────────────────────────────
snake_name="${NAME//-/_}"                                        # user-roles → user_roles

# Portable snake_case → PascalCase (works on macOS + Linux)
to_pascal() {
  echo "$1" | awk -F'_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS=''
}

pascal_name=$(to_pascal "$snake_name")                           # UserRoles

if [[ -n "$SINGULAR_OVERRIDE" ]]; then
  singular="$SINGULAR_OVERRIDE"
  singular_snake="${singular//-/_}"
else
  # Auto-derive: strip trailing 's'
  singular_snake="${snake_name%s}"
  singular="${NAME%s}"
fi

singular_pascal=$(to_pascal "$singular_snake")

# Platform-aware sed in-place (matches init-project.sh)
if [[ "$(uname)" == "Darwin" ]]; then
  sedi() { sed -i '' "$@"; }
else
  sedi() { sed -i "$@"; }
fi

echo "Scaffolding feature: ${NAME}"
echo "  snake_name:      ${snake_name}"
echo "  PascalName:      ${pascal_name}"
echo "  singular:        ${singular_snake}"
echo "  SingularPascal:  ${singular_pascal}"
echo ""

# ── Guard against overwriting ────────────────────────────────────
if [[ -d "backend/features/${snake_name}" ]]; then
  echo "Error: backend/features/${snake_name}/ already exists." >&2
  exit 1
fi
if [[ -d "frontend/src/features/${NAME}" ]]; then
  echo "Error: frontend/src/features/${NAME}/ already exists." >&2
  exit 1
fi

# ── Backend files ────────────────────────────────────────────────
mkdir -p "backend/features/${snake_name}"
mkdir -p "backend/shared/db/models"
mkdir -p "backend/tests/features/${snake_name}"

# __init__.py
touch "backend/features/${snake_name}/__init__.py"

# schema.py
cat > "backend/features/${snake_name}/schema.py" << PYEOF
import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class ${singular_pascal}Create(BaseModel):
    name: str
    description: str | None = None


class ${singular_pascal}Update(BaseModel):
    name: str | None = None
    description: str | None = None


class ${singular_pascal}Response(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    description: str | None
    created_at: datetime
    updated_at: datetime


class ${pascal_name}ListResponse(BaseModel):
    ${snake_name}: list[${singular_pascal}Response]
    total: int
PYEOF

# repository.py
cat > "backend/features/${snake_name}/repository.py" << PYEOF
import uuid

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from shared.db.models.${singular_snake} import ${singular_pascal}


class ${singular_pascal}Repository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_id(self, ${singular_snake}_id: uuid.UUID) -> ${singular_pascal} | None:
        return await self.session.get(${singular_pascal}, ${singular_snake}_id)

    async def get_list(self, skip: int = 0, limit: int = 20) -> tuple[list[${singular_pascal}], int]:
        total_result = await self.session.execute(select(func.count()).select_from(${singular_pascal}))
        total = total_result.scalar_one()

        result = await self.session.execute(
            select(${singular_pascal}).offset(skip).limit(limit).order_by(${singular_pascal}.created_at.desc())
        )
        items = list(result.scalars().all())

        return items, total

    async def create(self, **kwargs: object) -> ${singular_pascal}:
        entity = ${singular_pascal}(**kwargs)
        self.session.add(entity)
        await self.session.commit()
        await self.session.refresh(entity)
        return entity

    async def update(self, entity: ${singular_pascal}, **kwargs: object) -> ${singular_pascal}:
        for key, value in kwargs.items():
            setattr(entity, key, value)
        await self.session.commit()
        await self.session.refresh(entity)
        return entity

    async def delete(self, entity: ${singular_pascal}) -> None:
        await self.session.delete(entity)
        await self.session.commit()
PYEOF

# service.py
cat > "backend/features/${snake_name}/service.py" << PYEOF
import uuid

from features.${snake_name}.repository import ${singular_pascal}Repository
from features.${snake_name}.schema import ${singular_pascal}Create, ${pascal_name}ListResponse, ${singular_pascal}Response, ${singular_pascal}Update
from shared.lib.exceptions import NotFoundException


class ${singular_pascal}Service:
    def __init__(self, repository: ${singular_pascal}Repository) -> None:
        self.repository = repository

    async def get_by_id(self, ${singular_snake}_id: uuid.UUID) -> ${singular_pascal}Response:
        entity = await self.repository.get_by_id(${singular_snake}_id)
        if not entity:
            raise NotFoundException(f"${singular_pascal} {${singular_snake}_id} not found")
        return ${singular_pascal}Response.model_validate(entity)

    async def get_list(self, skip: int = 0, limit: int = 20) -> ${pascal_name}ListResponse:
        entities, total = await self.repository.get_list(skip=skip, limit=limit)
        return ${pascal_name}ListResponse(
            ${snake_name}=[${singular_pascal}Response.model_validate(e) for e in entities],
            total=total,
        )

    async def create(self, data: ${singular_pascal}Create) -> ${singular_pascal}Response:
        entity = await self.repository.create(**data.model_dump())
        return ${singular_pascal}Response.model_validate(entity)

    async def update(self, ${singular_snake}_id: uuid.UUID, data: ${singular_pascal}Update) -> ${singular_pascal}Response:
        entity = await self.repository.get_by_id(${singular_snake}_id)
        if not entity:
            raise NotFoundException(f"${singular_pascal} {${singular_snake}_id} not found")
        updated = await self.repository.update(entity, **data.model_dump(exclude_unset=True))
        return ${singular_pascal}Response.model_validate(updated)

    async def delete(self, ${singular_snake}_id: uuid.UUID) -> None:
        entity = await self.repository.get_by_id(${singular_snake}_id)
        if not entity:
            raise NotFoundException(f"${singular_pascal} {${singular_snake}_id} not found")
        await self.repository.delete(entity)
PYEOF

# router.py
cat > "backend/features/${snake_name}/router.py" << PYEOF
import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from features.${snake_name}.repository import ${singular_pascal}Repository
from features.${snake_name}.schema import ${singular_pascal}Create, ${pascal_name}ListResponse, ${singular_pascal}Response, ${singular_pascal}Update
from features.${snake_name}.service import ${singular_pascal}Service
from shared.db.session import get_session

router = APIRouter()


def get_${singular_snake}_service(session: AsyncSession = Depends(get_session)) -> ${singular_pascal}Service:
    return ${singular_pascal}Service(${singular_pascal}Repository(session))


@router.get("", response_model=${pascal_name}ListResponse)
async def list_${snake_name}(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    service: ${singular_pascal}Service = Depends(get_${singular_snake}_service),
) -> ${pascal_name}ListResponse:
    return await service.get_list(skip=skip, limit=limit)


@router.get("/{${singular_snake}_id}", response_model=${singular_pascal}Response)
async def get_${singular_snake}(
    ${singular_snake}_id: uuid.UUID,
    service: ${singular_pascal}Service = Depends(get_${singular_snake}_service),
) -> ${singular_pascal}Response:
    return await service.get_by_id(${singular_snake}_id)


@router.post("", response_model=${singular_pascal}Response, status_code=201)
async def create_${singular_snake}(
    data: ${singular_pascal}Create,
    service: ${singular_pascal}Service = Depends(get_${singular_snake}_service),
) -> ${singular_pascal}Response:
    return await service.create(data)


@router.put("/{${singular_snake}_id}", response_model=${singular_pascal}Response)
async def update_${singular_snake}(
    ${singular_snake}_id: uuid.UUID,
    data: ${singular_pascal}Update,
    service: ${singular_pascal}Service = Depends(get_${singular_snake}_service),
) -> ${singular_pascal}Response:
    return await service.update(${singular_snake}_id, data)


@router.delete("/{${singular_snake}_id}", status_code=204)
async def delete_${singular_snake}(
    ${singular_snake}_id: uuid.UUID,
    service: ${singular_pascal}Service = Depends(get_${singular_snake}_service),
) -> None:
    await service.delete(${singular_snake}_id)
PYEOF

# Model
cat > "backend/shared/db/models/${singular_snake}.py" << PYEOF
from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column

from shared.db.base import Base


class ${singular_pascal}(Base):
    __tablename__ = "${snake_name}"

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
PYEOF

# Tests
touch "backend/tests/features/${snake_name}/__init__.py"

cat > "backend/tests/features/${snake_name}/test_router.py" << PYEOF
import pytest
from httpx import AsyncClient


@pytest.mark.anyio
async def test_list_${snake_name}_empty(client: AsyncClient) -> None:
    response = await client.get("/api/v1/${NAME}")
    assert response.status_code == 200
    data = response.json()
    assert data["${snake_name}"] == []
    assert data["total"] == 0


@pytest.mark.anyio
async def test_create_${singular_snake}(client: AsyncClient) -> None:
    response = await client.post("/api/v1/${NAME}", json={"name": "Test ${singular_pascal}"})
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test ${singular_pascal}"
PYEOF

# ── Frontend files ───────────────────────────────────────────────
mkdir -p "frontend/src/features/${NAME}/components"

# types.ts
cat > "frontend/src/features/${NAME}/types.ts" << TSEOF
export interface ${singular_pascal} {
  id: string;
  name: string;
  description: string | null;
  created_at: string;
  updated_at: string;
}

export interface ${pascal_name}ListResponse {
  ${snake_name}: ${singular_pascal}[];
  total: number;
}
TSEOF

# api.ts
cat > "frontend/src/features/${NAME}/api.ts" << TSEOF
import { useQuery } from "@tanstack/react-query";
import { apiFetch } from "@/lib/api";
import type { ${pascal_name}ListResponse } from "./types";

export function use${pascal_name}() {
  return useQuery({
    queryKey: ["${NAME}"],
    queryFn: () => apiFetch<${pascal_name}ListResponse>("/api/v1/${NAME}"),
    retry: false,
  });
}
TSEOF

# index.ts
cat > "frontend/src/features/${NAME}/index.ts" << TSEOF
export { ${singular_pascal}List } from "./components/${singular}-list";
export type { ${singular_pascal}, ${pascal_name}ListResponse } from "./types";
TSEOF

# Component
KEBAB_SINGULAR="${singular//_/-}"
cat > "frontend/src/features/${NAME}/components/${KEBAB_SINGULAR}-list.tsx" << TSEOF
"use client";

import { use${pascal_name} } from "../api";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export function ${singular_pascal}List() {
  const { data, error, isLoading } = use${pascal_name}();

  if (isLoading) {
    return (
      <div className="space-y-3">
        {[1, 2, 3].map((i) => (
          <div
            key={i}
            className="bg-muted h-16 animate-pulse rounded-lg"
          />
        ))}
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Could not load ${NAME}</CardTitle>
          <CardDescription>
            Could not reach the backend. Is it running?
          </CardDescription>
        </CardHeader>
      </Card>
    );
  }

  if (!data?.${snake_name}.length) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base">No ${NAME} yet</CardTitle>
          <CardDescription>Create your first ${singular_snake}.</CardDescription>
        </CardHeader>
      </Card>
    );
  }

  return (
    <div className="space-y-3">
      {data.${snake_name}.map((item) => (
        <Card key={item.id}>
          <CardHeader>
            <CardTitle className="text-base">{item.name}</CardTitle>
            {item.description && (
              <CardDescription>{item.description}</CardDescription>
            )}
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground text-xs">
              Created {new Date(item.created_at).toLocaleDateString()}
            </p>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
TSEOF

# ── Next steps ───────────────────────────────────────────────────
echo ""
echo "Feature '${NAME}' scaffolded successfully!"
echo ""
echo "Next steps:"
echo "  1. Register router in backend/app/main.py:"
echo "       from features.${snake_name}.router import router as ${snake_name}_router"
echo "       app.include_router(${snake_name}_router, prefix=\"/api/v1/${NAME}\", tags=[\"${NAME}\"])"
echo "  2. Run: cd backend && make revision msg=\"add ${NAME} table\""
echo "  3. Run: cd backend && make migrate"
echo "  4. Add route in frontend/src/app/"

if [[ -z "$SINGULAR_OVERRIDE" ]]; then
  echo ""
  echo "Note: Singular form auto-derived as '${singular_snake}'."
  echo "  If incorrect, delete generated files and re-run with:"
  echo "  make scaffold name=${NAME} singular=correct-form"
fi
