# 🚀 COVID-19 Automated Analysis & AI Early Warning System

## 📌 Project Overview
This project implements a fully automated, end-to-end **Data Engineering & Analytics pipeline** to analyze India’s COVID-19 pandemic data. Adopting a **Medallion Architecture**, it transforms raw data into high-signal insights and proactive early-warning alerts.

The system is a fully containerized, offering a **"one-click" deployment** that handles database initialization, data ingestion, and transformation automatically.

---

## 🏗️ System Architecture
The system operates as a unified stack of modular components:

1.  **Data Warehouse (PostgreSQL)**: Single source of truth using a Medallion schema (Bronze → Silver → Gold).
2.  **Orchestrator (Python/SQLAlchemy)**: The "Engine" that manages the sequence of SQL transformations.
3.  **Ingestor (Python/Pandas)**: The "Fuel" that handles bulk historical loads and simulated "Live Feed" drops.
4.  **Command Center (Streamlit)**: A unified web UI for real-time visualization, data exploration, and alert monitoring.
5.  **Nervous System (n8n + Gemini)**: Active surveillance that triggers AI-driven alerts with a **Closed-Loop Feedback** mechanism.

---

## 📂 Project Structure
```text
├── SQL/scripts/        # Modular SQL transformation phases (00-04)
├── src/                # Python Source Code
│   ├── main.py         # Orchestrator (Master Controller)
│   ├── ingestion.py    # Data Loading & Simulation logic
│   └── app.py          # Streamlit Command Center UI
├── n8n_workflows/      # Automation JSONs (Refined Alert System)
├── data/raw/           # Original CSV datasets
├── compose.yaml        # Docker stack definition
├── Dockerfile          # Shared Python environment
└── entrypoint.sh       # Auto-initialization script
```

---

## 🚀 Getting Started (The "Boom" Method)

The recommended way to run the system is using Docker. This ensures all dependencies and database schemas are configured correctly.

### **1. Prerequisites**
*   Docker & Docker Compose installed.
*   A `.env` file in the root directory:
    ```env
    # Database Configuration (Postgres)
    DB_USER=postgres
    DB_PASSWORD=password
    DB_HOST=db    # The default name of the database service in docker-compose.yaml
    DB_PORT=5432  
    DB_NAME=postgres

    # pgAdmin Configuration
    PGADMIN_DEFAULT_EMAIL=admin@admin.com
    PGADMIN_DEFAULT_PASSWORD=root
    ```

### **2. Launch the Stack**
Run the following command in your terminal:
```bash
docker-compose up 
```
After your work is done and want to shutdown the stack:
```bash
docker-compose down
```
check the services
```bash


### **3. What happens automatically?**
*   **Infrastructure**: Postgres, pgAdmin, and n8n services start.
*   **Initialization**: The `app` container waits for the DB, .
*   **Ingestion**: 40,000+ rows of historical data are bulk-loaded into the Bronze layer.
*   **Transformation**: The pipeline runs Silver (Cleaning) and Gold (Engineering) logic.
*   **UI Launch**: The `app` container starts the Streamlit app.

### **4. Access the Tools**
*   **Command Center (UI)**: `http://localhost:8501`
*   **pgAdmin (DB Debug)**: `http://localhost:5050` 
*   **n8n (Automation)**: `http://localhost:5678`

---

## ⚙️ How to Work with the System

### **A. Using the Command Center**
The Streamlit app is your primary interface:


