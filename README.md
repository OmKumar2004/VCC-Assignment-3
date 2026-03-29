# VCC-Assignment-3: Local VM to Cloud Auto-Scaling (GCP)

## Overview

This project implements a hybrid cloud auto-scaling system where a local virtual machine monitors its own resource usage and dynamically scales to Google Cloud Platform (GCP) when utilization exceeds defined thresholds.

The system demonstrates the concept of cloud bursting, where local infrastructure offloads excess workload to cloud resources during peak demand.



## Objective

- Create a local VM environment  
- Monitor CPU and memory usage in real time  
- Automatically scale to cloud when usage exceeds 75%  
- Scale down when load decreases  
- Deploy a sample application to verify scaling  



## Architecture

The system consists of three main components:

### 1. Local Infrastructure
- Host Machine (Windows)  
- VMware Workstation Pro  
- Kali Linux VM  

### 2. Monitoring & Control Layer
- Flask-based control panel (for load generation)  
- Custom resource monitoring script  
- Decision engine with thresholds and cooldown  

### 3. Cloud Infrastructure (GCP)
- Instance Template (om-a3-template)  
- Managed Instance Group (om-a3-mig)  
- Apache Web Server (auto-deployed)  



## How It Works

1. User increases load using Flask control panel  
2. Stress processes increase CPU usage  
3. Monitoring script tracks CPU and memory usage  
4. Decision engine evaluates thresholds  
5. gcloud CLI resizes Managed Instance Group  
6. New VMs are created with Apache server  
7. When load decreases, instances are removed  



## Scaling Logic

- Scale Up: CPU > 75% OR Memory > 75%  
- Scale Down: CPU < 30%  
- Cooldown: 60 seconds  

This asymmetric scaling prevents premature scale-down and ensures stability.



## Components

### Resource Monitoring Script
- Uses top and free commands  
- Runs continuously  
- Logs scaling events  

### Flask Control Panel
- Increase load (+1)  
- Decrease load (-1)  
- Stop load  
- View logs  

### Cloud Setup
- Stateless Managed Instance Group  
- Auto deployment using startup script  



## Cloud Configuration

- Region: asia-south2 (Delhi)  
- Machine Type: e2-medium  
- Min Instances: 1  
- Max Instances: 5  



## Sample Application

A simple Apache web server is deployed on each cloud instance using a startup script to verify that instances are active and serving requests.



## Cloud Bursting Concept

Instead of migrating processes, this system detects overload locally and provisions additional cloud resources dynamically. This allows the system to handle peak demand without modifying the core application.



## Screenshots

- Local VM Setup  
- Flask Control Panel  
- Scaling Logs  
- GCP Instance Scaling  
- Architecture Diagram  



## Repository Structure


├── resource_monitor.sh  
├── app.py  
├── architecture.png  
├── scaling.log  
├── B22CS081_A3_Report.pdf   
└── README.md  



## Key Learnings

- Practical implementation of auto-scaling  
- Hybrid cloud architecture design  
- Importance of cooldown and threshold tuning  
- Difference between scale-up and scale-down strategies  



## Notes

- Scaling decisions are based on real-time monitoring  
- Cooldown logic prevents rapid scaling fluctuations  
- Designed for demonstration purposes  