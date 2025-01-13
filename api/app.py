from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import boto3
from botocore.exceptions import ClientError
import json

# Function to retrieve the database URL from AWS Secrets Manager
def get_database_url():
    secret_name = "mysql_db"  # Replace with your secret name
    region_name = "us-east-1"  # Replace with your AWS region

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        secret = get_secret_value_response["SecretString"]

        # Parse the secret as JSON and extract the DBLINK field
        secret_dict = json.loads(secret)
        return secret_dict["DBLINK"]

    except ClientError as e:
        print(f"Error retrieving secret: {e}")
        raise
    except KeyError:
        print("The secret does not contain a 'DBLINK' field.")
        raise


# Retrieve the database connection URL from Secrets Manager
try:
    DATABASE_URL = get_database_url()
except Exception as e:
    print(f"Failed to retrieve database connection URL: {e}")
    raise

# Database setup
engine = create_engine(DATABASE_URL)
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

# CORS Middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust origins for better security in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic model for request validation
class NoteCreate(BaseModel):
    title: str
    content: str

# Endpoints
@app.get("/notes")
def read_notes():
    db = SessionLocal()
    try:
        notes = db.query(Note).all()
        return notes
    finally:
        db.close()


@app.post("/notes")
def create_note(note: NoteCreate):
    db = SessionLocal()
    try:
        new_note = Note(**note.dict())
        db.add(new_note)
        db.commit()
        db.refresh(new_note)
        return new_note
    finally:
        db.close()


@app.delete("/notes/{note_id}")
def delete_note(note_id: int):
    db = SessionLocal()
    try:
        note = db.query(Note).filter(Note.id == note_id).first()
        if not note:
            raise HTTPException(status_code=404, detail="Note not found")
        db.delete(note)
        db.commit()
        return {"message": "Note deleted"}
    finally:
        db.close()
