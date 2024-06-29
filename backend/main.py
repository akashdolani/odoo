import random
import shutil
from fastapi import FastAPI, File, Form, HTTPException, Query, Body, Request, UploadFile
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from typing import List, Dict
import mysql.connector as con
from fastapi.middleware.cors import CORSMiddleware

import requests

app = FastAPI()

otp = ""
app.mount("/images", StaticFiles(directory="images"), name="images")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development, restrict as needed
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


mydb = con.connect(host="localhost", user="root", password="root",database="odoo")
cur = mydb.cursor(dictionary=True)

class Marker(BaseModel):
    latitude: float
    longitude: float

class LoginRequest(BaseModel):
    phone_number: str

class CrimeReport(BaseModel):
    type_of_crime: str
    location: str
    current_date: datetime
    crime_date: datetime
    description: str
    markers: List[Marker]
    phone_number: str
    images: Optional[List[UploadFile]] = None

@app.post("/api/submit_crime_report")
async def submit_crime_report(
    type_of_crime: str = Form(...),
    location: str = Form(...),
    current_date: datetime = Form(...),
    crime_date: datetime = Form(...),
    description: str = Form(...),
    markers: str = Form(...),
    phone_number: str = Form(...),
    images: List[UploadFile] = File(None)
):
    print("Received Crime Report:")
    print(f"Type of Crime: {type_of_crime}")
    print(f"Location: {location}")
    print(f"Current Date: {current_date.date()}")
    print(f"Crime Date: {crime_date.date()}")
    print(f"Description: {description}")
    print("Markers:", markers)
    print(f"Phone Number: {phone_number}")

    marker_list = eval(markers)

    for marker in marker_list:
        cur.execute(
            "INSERT INTO markers VALUES (%s, %s, %s)",
            (phone_number, marker['latitude'], marker['longitude'])
        )

    cur.execute(
        "INSERT INTO crime_report VALUES (%s, %s,%s,%s, %s, %s, %s)",
        (phone_number, location, current_date.date(),current_date.time(), crime_date.date(),crime_date.time(), description)
    )
    crime_id = cur.lastrowid

    if images:
        for image in images:
            image_path = f"images/{image.filename}"
            with open(image_path, "wb") as buffer:
                shutil.copyfileobj(image.file, buffer)
            cur.execute(
                "INSERT INTO crime_images VALUES (%s, %s)",
                (phone_number, image_path)
            )

    mydb.commit()
    return {"message": "Crime report submitted successfully"}


@app.post("/send_otp")
async def send_otp(request: Request, login_request: LoginRequest):
    phone_number = login_request.phone_number
    
    if not phone_number.isdigit() or len(phone_number) != 10:
        raise HTTPException(status_code=400, detail="Invalid phone number")
    global otp
    otp = str(random.randint(100000, 999999))
    try:
        # Generate a 6-digit random OTP
        otp = str(random.randint(100000, 999999))
        apiKeys = "x10fCNTlP2gecAOj86aLuYXZJ9qzKFMnbwVsGBD5rvIEydHhk7BMceCQjPR6IVkmqa0t1FAoxNhrwgus"
        
        url = f"https://www.fast2sms.com/dev/bulkV2?authorization={apiKeys}&route=q&message=your%20otp%20is%20-%20{otp}&flash=0&numbers={phone_number}"
        

        response = requests.get(url)
        result = response.json()
        print(result)
        print(f"Phone Number: {phone_number} OTP: {otp}")
        if result['return']:
            return {'success': True, 'otp': otp}
        else:
            raise Exception(result['message'])

    except Exception as e:
        raise HTTPException(status_code=400, detail="Invalid phone number")
   

@app.post("/resend_otp")
async def resend_otp(request: Request, login_request: LoginRequest):
    phone_number = login_request.phone_number
    
    
    global otp
    otp = str(random.randint(100000, 999999))
    print(f"Phone Number: {phone_number} Resend OTP: {otp}")
    return {"otp": otp, "error": None}

@app.get("/api/get_past_reports/{phone_number}")
async def get_past_reports(phone_number: str):
    try:
        cur.execute("SELECT * FROM crime_report WHERE crimeid = %s", (phone_number,))
        reports = cur.fetchall()
        print(reports)
        return reports
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/get_markers")
async def get_markers():
    try:
        print("Attempting to fetch markers...")
        cur.execute("SELECT CrimeID, latitude, longitude FROM markers GROUP BY CrimeID, latitude, longitude")
        markers_data = cur.fetchall()
        markers = []
        for marker in markers_data:
            markers.append({
                "CrimeID": marker['CrimeID'],
                "latitude": float(marker['latitude']),
                "longitude": float(marker['longitude'])
            })
        print(f"Fetched markers: {markers}")  # Debug print
        return markers
    except Exception as e:
        print(f"Failed to fetch markers: {str(e)}")  # Log the error
        raise HTTPException(status_code=500, detail=f"Failed to fetch markers: {str(e)}")



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
