import streamlit as st
import pandas as pd
import os
from sqlalchemy import create_engine
import time
import requests
from dotenv import load_dotenv

# 1. Page Config (Must be first!)
st.set_page_config(
    page_title="COVID-19 Executive Portal",
    page_icon="images/icons/covid-exclamation-line.svg",
    layout="wide"
)

# Load environment variables
load_dotenv()

def get_db_url():
    """Builds the connection string safely."""
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    db = os.getenv("DB_NAME")
    
    if not all([user, password, host, port, db]):
        st.error("Missing database credentials in .env file.")
        st.stop()
        
    return f"postgresql://{user}:{password}@{host}:{port}/{db}"

# 2. Cache the SQLAlchemy engine
@st.cache_resource
def get_sql_engine():
    url = get_db_url()
    return create_engine(url)


# fetch the engine once here
engine = get_sql_engine()

# Set up UI elements
st.logo("images/logo/logo.png", icon_image="images/icons/covid-exclamation-line.svg")

st.title("COVID-19 Executive Analysis & Alerting Portal")
st.caption("Integrated ETL Pipeline, Business Intelligence, and AI-Driven Surveillance System")

# --- SIDEBAR ---
with st.sidebar:
    st.header("Control Plane")
    
    # n8n Link
    st.markdown("### ⚙️ Automation Engine")
    st.link_button("Open n8n Workflow", "http://localhost:5678", width="stretch")
    
    st.markdown("---")
    
    # Manual System Refresh 
    if st.button("🔄 Trigger Full System Sync", width="stretch"):
        with st.spinner("🔄 Re-ingesting & Running Pipeline..."):
            try:
                # Import classes
                from ingest import Ingestor
                from transform import Transformer
                
                db_url = get_db_url()
                
                # Dependency Injection
                ingestor = Ingestor(db_url=db_url)
                transformer = Transformer(db_url=db_url)
                
                # Execute Pipeline
                ingestor.load_data()
                transformer.run_etl()
                
                st.success("System Sync Complete!")
                time.sleep(1)
                st.rerun()
                
            except Exception as e:
                st.error(f"Error during sync: {e}")

    st.markdown("---")
    st.subheader("📡 Infrastructure Status")
    
    # Check Database Status using the engine
    try:
        latest = pd.read_sql("SELECT MAX(date) as d FROM covid_summary_clean", engine)['d'].iloc[0]
        st.success(f"Warehouse Online \nLatest Data: {latest}")
    except Exception as e:
        print(f"Database connection failed: {e}") 
        st.error("Warehouse Offline (Run Sync)")

# --- MAIN INTERFACE ---
tab1, tab2, tab3, tab4 = st.tabs([ "AI Report","Executive Dashboards", "Exploratory Data (Excel)", "Data Warehouse"])


# Tab 1: AI Situation Room
with tab1:
    st.header("AI Serviellance Report")
    
    col_a, col_b = st.columns([2, 1])
    
    with col_a:
        st.subheader("Latest Intelligence Briefing")
        try:
            report = pd.read_sql("SELECT report_html, generated_at FROM latest_ai_report ORDER BY generated_at DESC LIMIT 1", engine)
            
            if not report.empty:
                st.info(f"Report Generated At: {report['generated_at'].dt.tz_localize('UTC').dt.tz_convert('Asia/Kolkata').iloc[0].strftime("%d %b %Y, %I:%M %p")})")

                raw_html = report['report_html'].iloc[0]
                combined_html = f'<div class="report-box">{raw_html}</div>'
                
                # Render the combined string once
                st.markdown(combined_html, unsafe_allow_html=True)
            else:
                st.warning("No AI report found. Trigger an audit to generate one.")
        except:
            st.error("AI Report table not found or empty. Run system sync first.")

    with col_b:
        st.subheader("Actions")
        if st.button("Run AI Risk Audit", width="stretch"):
            with st.spinner("Calling n8n Auditor..."):
                try:
                    # Standard n8n production URL for the webhook
                    response = requests.post("http://localhost:5678/webhook/audit-trigger")
                    if response.status_code == 200:
                        st.success("Audit Requested! Refreshing in 5s...")
                        time.sleep(5)
                        st.rerun()
                    else:
                        st.error(f"Webhook Failed: {response.text}")
                except Exception as e:
                    st.error(f"Could not reach n8n. Is it running? Error: {e}")
        
        st.markdown("---")
        st.subheader("🚩 Active Alert Flags")
        try:
            alerts = pd.read_sql("SELECT state, weighted_risk_score FROM v_critical_alerts WHERE date = (SELECT MAX(date) FROM v_critical_alerts) LIMIT 10", engine)
            if not alerts.empty:
                st.table(alerts)
            else:
                st.success("No active flags for today.")
        except:
            st.caption("Data sync required for alerts.")

    st.markdown("---")
    st.markdown("#### 📥 Download AI Report")
    
    # Safely handle file download
    st.download_button(
        label="Download AI Report",
        data=report['report_html'].iloc[0] if not report.empty else "", # Placeholder for actual report data
        file_name="AI_Risk_Report.html", # Assuming PDF format for a report
        mime="text/html",
        disabled=report.empty, # Disable if no report data
    )

# Tab 2: Power BI Dashboards
with tab2:
    st.header("BI Intelligence (Power BI)")
    st.write("Visual trends and deep-dive analytics from the production dashboard.")
    
    col1, col2 = st.columns(2)
    with col1:
        st.image("images/powerbi_dashboard.png", caption="Historical Case Analysis", width="stretch")
    with col2:
        st.image("images/powerbi_dashboard_2.png", caption="Vaccination & Testing Trends", width="stretch")
    
    st.markdown("---")
    st.markdown("#### 📥 Download Original Report")
    
    # Safely handle file download if the file is missing
    pbix_path = "powerbi/Covid_19_Dashboard.pbix"
    if os.path.exists(pbix_path):
        with open(pbix_path, "rb") as f:
            st.download_button(
                label="Download .PBIX File",
                data=f,
                file_name="Covid_19_Dashboard.pbix",
                mime="application/octet-stream",
                width="stretch"
            )
    else:
        st.warning(f"File not found: {pbix_path}")



# Tab 3: Excel EDA
with tab3:
    st.header("Excel Interactive Dashboard")
    st.write("Tools for targeted stakholder questions")
    
    st.image("images/excel_dashboard.png", caption="Excel Forecasting & EDA", width="stretch")

    st.markdown("---")
    st.markdown("#### 📥 Download Analysis Workbook")
    
    # Safely handle file download
    excel_path = "excel/EDA_Dashboard.xlsx"
    if os.path.exists(excel_path):
        with open(excel_path, "rb") as f:
            st.download_button(
                label="Download Excel Dashboard",
                data=f,
                file_name="EDA_Dashboard.xlsx",
                mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                width="stretch"
            )
    else:
        st.warning(f"File not found: {excel_path}")

# Tab 4: Data Warehouse
with tab4:
    st.header("📂 Data Warehouse (Gold Layer)")
    st.write("Direct access to the cleaned, feature-engineered production tables.")
    
    try:
        df_gold = pd.read_sql("SELECT * FROM covid_summary_clean ORDER BY date DESC", engine)
        
        # Search & Filter
        search = st.text_input("🔍 Search State", "")
        if search:
            # Dropdown/Search filter logic
            df_gold = df_gold[df_gold['state'].str.contains(search, case=False, na=False)]
            
        st.dataframe(df_gold, width="stretch", height=400)
        
        # Download logic
        csv = df_gold.to_csv(index=False).encode('utf-8')
        st.download_button(
            "📥 Export Full Gold Dataset (CSV)",
            data=csv,
            file_name="covid_gold_dataset.csv",
            mime="text/csv",
            width="stretch"
        )
    except:
        st.error("No data found in Gold layer. Please run the ETL pipeline.")

st.markdown("---")
st.caption("COVID-19 Executive Portal")