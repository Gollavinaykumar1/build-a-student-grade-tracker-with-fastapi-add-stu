# Step-by-Step Deployment Guide

## Prerequisites
* Docker installed on your system
* Docker Compose installed on your system
* A PostgreSQL database set up
* A Redis instance set up
* An Nginx server set up

## Step 1: Clone the repository
Clone the repository using the following command:
```bash
git clone https://github.com/your-username/student-grade-tracker.git
```

## Step 2: Create a .env file
Create a .env file in the root of the project with the following contents:
```makefile
DATABASE_URL=postgresql://user:password@localhost:5432/database
REDIS_URL=redis://localhost:6379/0
SECRET_KEY=your_secret_key_here
```

## Step 3: Build the Docker image
Build the Docker image using the following command:
```bash
docker build -t student-grade-tracker .
```

## Step 4: Run the Docker container
Run the Docker container using the following command:
```bash
docker run -p 8000:8000 student-grade-tracker
```

## Step 5: Set up the database
Set up the database by running the following command:
```bash
docker exec -it student-grade-tracker python manage.py migrate
```

## Step 6: Set up the Redis instance
Set up the Redis instance by running the following command:
```bash
docker exec -it student-grade-tracker python manage.py redis
```

## Step 7: Set up the Nginx server
Set up the Nginx server by creating a new file called nginx.conf with the following contents:
```nginx
http {
    server {
        listen 80;
        server_name example.com;

        location / {
            proxy_pass http://localhost:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## Step 8: Run the Nginx server
Run the Nginx server using the following command:
```bash
sudo nginx -t
sudo nginx
```

## Step 9: Test the application
Test the application by navigating to http://example.com in your web browser.

## Step 10: Deploy to production
Deploy the application to production by following the instructions in the .github/workflows/deploy.yml file.