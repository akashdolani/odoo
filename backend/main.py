from fastapi import FastAPI, HTTPException, Query, Body
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from typing import List, Dict

app = FastAPI()

class Marker(BaseModel):
    latitude: float
    longitude: float

class CrimeReport(BaseModel):
    type_of_crime: str
    location: str
    current_date: datetime
    crime_date: datetime
    description: str
    markers: List[Marker]

@app.post("/api/submit_crime_report")
async def submit_crime_report(report: CrimeReport):
    # Here you would process the crime report data
    # For demonstration purposes, let's just print the received data
    print("Received Crime Report:")
    print(f"Type of Crime: {report.type_of_crime}")
    print(f"Location: {report.location}")
    print(f"Current Date: {report.current_date.date()}")
    print(f"Current Time: {report.current_date.time().strftime('%H:%M:%S')}")
    print(f"Crime Date: {report.crime_date.date()}")
    print(f"Crime Time: {report.crime_date.time().strftime('%H:%M:%S')}")
    print(f"Description: {report.description}")
    print("Markers:")
    for marker in report.markers:
        print(f"Latitude: {marker.latitude}, Longitude: {marker.longitude}")
    
    # Assuming success in processing the report
    return {"message": "Crime report submitted successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
