from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column

from shared.db.base import Base


class Item(Base):
    __tablename__ = "items"

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
