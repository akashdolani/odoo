from fastapi import FastAPI, HTTPException, File, UploadFile
from pydantic import BaseModel
from typing import List
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

# SQLAlchemy setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./crime_reports.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Define SQLAlchemy models
class CrimeReport(Base):
    __tablename__ = "crime_reports"

    id = Column(Integer, primary_key=True, index=True)
    type_of_crime = Column(String, index=True)
    location = Column(String, index=True)
    current_date = Column(DateTime, default=datetime.utcnow)
    crime_date = Column(DateTime)
    description = Column(Text)

Base.metadata.create_all(bind=engine)

# FastAPI app instance
app = FastAPI()

# Pydantic models for request/response validation
class CrimeReportCreate(BaseModel):
    type_of_crime: str
    location: str
    crime_date: datetime
    description: str

# Routes
@app.post("/api/submit_crime_report", response_model=CrimeReport)
def submit_crime_report(report: CrimeReportCreate):
    db = SessionLocal()
    try:
        db_report = CrimeReport(
            type_of_crime=report.type_of_crime,
            location=report.location,
            crime_date=report.crime_date,
            description=report.description,
        )
        db.add(db_report)
        db.commit()
        db.refresh(db_report)
        return db_report
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error submitting crime report: {str(e)}")
    finally:
        db.close()

@app.post("/api/upload_media")
def upload_media(files: List[UploadFile] = File(...)):
    # Handle file upload logic here (store files, etc.)
    return {"files_uploaded": [file.filename for file in files]}

# Run the FastAPI application with Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
