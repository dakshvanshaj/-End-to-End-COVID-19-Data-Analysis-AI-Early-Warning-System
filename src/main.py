import os
import argparse
import sys
from dotenv import load_dotenv

# Import your classes from the other files
from ingest import Ingestor 
from transform import Transformer 

def get_db_url():
    """Fetches environment variables and builds the DB string."""
    load_dotenv()
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    db = os.getenv("DB_NAME")   

    if not all([user, password, host, port, db]):
        print("Error: Missing database credentials. Check your .env file.")
        sys.exit(1)

    return f"postgresql://{user}:{password}@{host}:{port}/{db}"

def main():
    parser = argparse.ArgumentParser(description="COVID-19 Master Data Pipeline")
    
    # Define our two main workflows
    parser.add_argument("--setup", action="store_true", help="Day 1: Full Setup (Init Tables -> Ingest -> ETL)")
    parser.add_argument("--daily", action="store_true", help="Day 2+: Daily Refresh (Ingest -> ETL)")
    
    args = parser.parse_args()

    # If no flags are passed, show help
    if not any(vars(args).values()):
        parser.print_help()
        return

    # Get DB connection once, pass it to both workers
    db_url = get_db_url()
    ingestor = Ingestor(db_url=db_url)
    transformer = Transformer(db_url=db_url)

    # --- WORKFLOW 1: FULL SETUP ---
    if args.setup:
        print("Starting FULL SETUP (Day 1 Workflow)...")
        transformer.initialize()  # 1. Create empty bronze tables (01_bronze.sql)
        ingestor.load_data()       # 2. Load CSVs into bronze tables
        transformer.run_etl()     # 3. Process Silver, Gold, Validation
        print("Full Setup Complete!")

    # --- WORKFLOW 2: DAILY REFRESH ---
    elif args.daily:
        print("Starting DAILY REFRESH (Day 2+ Workflow)...")
        # Notice we skip transformer.initialize() here!
        ingestor.load_data()       # 1. Truncate old data, load new CSVs
        transformer.run_etl()     # 2. Process Silver, Gold, Validation
        print("Daily Refresh Complete")

if __name__ == "__main__":
    main()