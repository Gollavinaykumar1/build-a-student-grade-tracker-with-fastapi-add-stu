# LLM Output

### Project Overview
The following is a complete FastAPI project for a student grade tracker. It includes the following features:
- Adding students
- Assigning grades to students
- Calculating GPA for each student
- Generating a report for each student

### Project Structure
The project consists of the following files:
- `main.py`: The main application file
- `models.py`: Defines the database models
- `database.py`: Handles database operations
- `services.py`: Provides business logic for the application
- `requirements.txt`: Lists the required dependencies
- `README.md`: Provides an overview of the project

### Code

=== FILE: main.py ===
```python
from fastapi import FastAPI, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from database import get_db_session
from services import StudentService
from models import Student, Grade

app = FastAPI()

class StudentRequest(BaseModel):
    name: str
    email: str

class GradeRequest(BaseModel):
    student_id: int
    subject: str
    grade: float

@app.post("/students/")
async def create_student(student_request: StudentRequest, db_session: AsyncSession = Depends(get_db_session)):
    student_service = StudentService(db_session)
    student = await student_service.create_student(student_request.name, student_request.email)
    return JSONResponse(content={"id": student.id, "name": student.name, "email": student.email}, status_code=201)

@app.post("/students/{student_id}/grades/")
async def create_grade(student_id: int, grade_request: GradeRequest, db_session: AsyncSession = Depends(get_db_session)):
    student_service = StudentService(db_session)
    grade = await student_service.create_grade(student_id, grade_request.subject, grade_request.grade)
    return JSONResponse(content={"id": grade.id, "student_id": grade.student_id, "subject": grade.subject, "grade": grade.grade}, status_code=201)

@app.get("/students/{student_id}/gpa/")
async def get_gpa(student_id: int, db_session: AsyncSession = Depends(get_db_session)):
    student_service = StudentService(db_session)
    gpa = await student_service.calculate_gpa(student_id)
    return JSONResponse(content={"gpa": gpa}, status_code=200)

@app.get("/students/{student_id}/report/")
async def get_report(student_id: int, db_session: AsyncSession = Depends(get_db_session)):
    student_service = StudentService(db_session)
    report = await student_service.generate_report(student_id)
    return JSONResponse(content=report, status_code=200)
```
=== END ===

=== FILE: models.py ===
```python
from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class Student(Base):
    __tablename__ = "students"
    id = Column(Integer, primary_key=True)
    name = Column(String)
    email = Column(String)
    grades = relationship("Grade", backref="student")

class Grade(Base):
    __tablename__ = "grades"
    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey("students.id"))
    subject = Column(String)
    grade = Column(Float)
```
=== END ===

=== FILE: database.py ===
```python
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.ext.asyncio import AsyncSession
from models import Base

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

# Create a database engine
database_url = os.environ.get("DATABASE_URL")
engine = create_engine(database_url)
async_engine = create_async_engine(database_url)

# Create a session maker
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
AsyncSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=async_engine, class_=AsyncSession)

# Create the database tables
async def init_models():
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# Get a database session
async def get_db_session():
    async with AsyncSessionLocal() as session:
        yield session
```
=== END ===

=== FILE: services.py ===
```python
from sqlalchemy.ext.asyncio import AsyncSession
from models import Student, Grade

class StudentService:
    def __init__(self, db_session: AsyncSession):
        self.db_session = db_session

    async def create_student(self, name: str, email: str):
        student = Student(name=name, email=email)
        self.db_session.add(student)
        await self.db_session.commit()
        await self.db_session.refresh(student)
        return student

    async def create_grade(self, student_id: int, subject: str, grade: float):
        grade_obj = Grade(student_id=student_id, subject=subject, grade=grade)
        self.db_session.add(grade_obj)
        await self.db_session.commit()
        await self.db_session.refresh(grade_obj)
        return grade_obj

    async def calculate_gpa(self, student_id: int):
        grades = await self.db_session.execute("SELECT grade FROM grades WHERE student_id = :student_id", {"student_id": student_id})
        grades = [grade[0] for grade in grades.all()]
        if not grades:
            return 0
        return sum(grades) / len(grades)

    async def generate_report(self, student_id: int):
        student = await self.db_session.get(Student, student_id)
        grades = await self.db_session.execute("SELECT subject, grade FROM grades WHERE student_id = :student_id", {"student_id": student_id})
        grades = [{"subject": grade[0], "grade": grade[1]} for grade in grades.all()]
        return {
            "name": student.name,
            "email": student.email,
            "grades": grades,
            "gpa": await self.calculate_gpa(student_id)
        }
```
=== END ===

=== FILE: requirements.txt ===
```
fastapi
uvicorn[standard]
sqlalchemy
asyncpg
pydantic
python-dotenv
```
=== END ===

=== FILE: README.md ===
# Student Grade Tracker
This is a FastAPI application that allows you to track student grades. You can add students, assign grades to students, calculate GPA for each student, and generate a report for each student.

## Installation
1. Install the required dependencies: `pip install -r requirements.txt`
2. Create a .env file with the following environment variables:
   - `DATABASE_URL`: the URL of your database
3. Run the application: `uvicorn main:app --host 0.0.0.0 --port $PORT`

## API Endpoints
- `POST /students/`: Create a new student
- `POST /students/{student_id}/grades/`: Create a new grade for a student
- `GET /students/{student_id}/gpa/`: Calculate the GPA for a student
- `GET /students/{student_id}/report/`: Generate a report for a student
```
=== END ===