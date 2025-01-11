from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Configuration
CONFIG = {
    "DATABASE_URL": "mysql+pymysql://user:password@localhost:3306/notes_db"
}

# Database setup
engine = create_engine(CONFIG["DATABASE_URL"])
Base = declarative_base()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Models
class Note(Base):
    __tablename__ = "notes"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    content = Column(Text, nullable=False)

Base.metadata.create_all(bind=engine)

# API setup
app = FastAPI()

class NoteCreate(BaseModel):
    title: str
    content: str

@app.get("/notes")
def read_notes():
    db = SessionLocal()
    notes = db.query(Note).all()
    db.close()
    return notes

@app.post("/notes")
def create_note(note: NoteCreate):
    db = SessionLocal()
    new_note = Note(**note.dict())
    db.add(new_note)
    db.commit()
    db.refresh(new_note)
    db.close()
    return new_note

@app.delete("/notes/{note_id}")
def delete_note(note_id: int):
    db = SessionLocal()
    note = db.query(Note).filter(Note.id == note_id).first()
    if not note:
        db.close()
        raise HTTPException(status_code=404, detail="Note not found")
    db.delete(note)
    db.commit()
    db.close()
    return {"message": "Note deleted"}
