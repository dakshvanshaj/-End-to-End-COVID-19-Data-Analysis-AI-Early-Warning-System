# COVID-19 Decision Intelligence & Risk Monitoring System

## Overview
An end-to-end platform designed to convert raw epidemic data into strategic situational awareness. It integrates high-performance Data Engineering (Medallion Architecture), Generative AI (Google Gemini/Gemma), and Business Intelligence into a unified executive command center.

## Problem Statement
Epidemiological decision-makers often face "Raw Data Overload," where fragmented data sources lead to significant downtime in analysis. This delay leads to longer decision cycles, making it impossible to act proactively before a surge occurs.

## Key Features
- **Master Orchestrator**: Automated ETL pipeline standardizing 40,000+ records in seconds.
- **AI Situation Room**: Automated strategic briefings and surveillance reports powered by LLMs.
- **Interactive BI Dashboard**: National-level situational awareness using Power BI with 7-day moving averages.
- **Risk Evaluation Tool**: Targeted Excel auditing allowing stakeholders to test "what-if" threshold scenarios.
- **Automation Nervous System**: n8n-powered logic for closed-loop alerting and stakeholder feedback.

## Tech Stack
- **Languages**: Python (SQLAlchemy, Pandas, Streamlit), SQL.
- **Database**: PostgreSQL 18.1 (Medallion Architecture: Bronze -> Silver -> Gold).
- **Automation**: n8n.
- **AI**: Google Gemini / Gemma.
- **Infrastructure**: Docker, Docker Compose.
- **BI Tools**: Power BI, Microsoft Excel.

## System Architecture
The system utilizes a consolidated "Hub" architecture where the application container manages both the user interface and the ETL orchestration workers.

**Data Flow Pipeline:**
Raw Data (CSVs)  
→ Python Ingestor (Bronze Staging)  
→ SQL Transformer (Silver Cleaning & Gold Feature Engineering)  
→ PostgreSQL Warehouse (Single Source of Truth)  
→ n8n Automation (AI Signal Extraction & Prompting)  
→ Multi-Layer Output (Streamlit Situation Room / Power BI / Excel)

## Results / Impact
- **90% Faster Deployment**: Reduced environment setup time from 4 hours to under 10 minutes via Docker.
- **Instant Data Refresh**: Automated ETL pipeline standardizes 40k+ records in < 30 seconds, replacing 6+ hours of manual effort.
- **95% Faster Decision Speed**: GenAI situation reports convert complex SQL signals into human strategy in < 60 seconds.
- **80% Efficient Monitoring**: Weighted Risk Scoring reduces administrative search time by focusing leadership only on critical "Hot Zones."

## Project Structure
- `.streamlit/`: Streamlit configuration and themes.
- `data/`: Directory for raw input CSVs and cleaned data exports.
- `docs/`: Technical deep-dives and strategic documentation.
- `excel/`: Interactive Risk Evaluation tool.
- `images/`: UI previews and architectural diagrams.
- `n8n_workflows/`: JSON blueprints for the automation engine.
- `SQL/scripts/`: Modular SQL logic for the Medallion pipeline.
- `src/`: Python source code for ingestion, transformation, and the web portal.

## Setup Instructions
1. **Launch the Stack**: Run `docker-compose up -d` from the project root.
2. **Import n8n Logic**: Import `n8n_workflows/COVID-Alert-System_v2.json` at `http://localhost:5678`.
3. **Initialize Warehouse**: In the Streamlit sidebar (`http://localhost:8501`), click **"🔄 Trigger ETL Pipeline"** to perform the first-time data load.

## Documentation
Detailed documentation is available in the `/docs` folder:
- **[Business Context & Risk Logic](docs/business_context.md)**: Stakeholder personas and risk formulas.
- **[AI Intelligence Setup](docs/ai_intelligence_setup.md)**: Prompt templates and data signal mapping.
- **[Infrastructure & Deployment](docs/infrastructure.md)**: Docker and volume management.

## Future Improvements
- **Self-Service Prompting**: UI component to allow users to override system prompts.
- **Local LLM Support**: Integration with Ollama for entirely local, private data analysis.
- **Persona-Based UI**: Tailored dashboard presets for Logistics vs. Epidemiological roles.
