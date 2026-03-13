import os
import argparse
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables
load_dotenv()

class Transformer:
    def __init__(self, db_url=None):

        self.engine = create_engine(db_url, echo=True)
        
        # Get project root (one level up from src/)
        self.root_dir = Path(__file__).resolve().parent.parent

    def run_sql_file(self, rel_path):
        """
        Reads a SQL file and executes it using SQLAlchemy.
        """

        file_path = self.root_dir / rel_path

        if not file_path.exists():
            print(f"Warning: File {file_path} not found. Skipping.")
            return
        
        print(f"Executing: {file_path}...")

        try:
            # Read the SQL content from the file
            with open(file_path, "r") as f:
                sql_content = f.read()
                
            with self.engine.begin() as conn:
                conn.execute(text(sql_content))
                
            print(f"Success: {rel_path}")
        except Exception as e:
            print(f"Error in {rel_path}: {e}")
            sys.exit(1)

    def initialize(self):
        """
        Phase 0 & 1: Schema Setup & Bronze Staging.
        """

        print("\n--- [INIT] Setting up Database Tables ---")

        self.run_sql_file("SQL/scripts/01_bronze.sql")

        print("--- [INIT] Completed ---\n")

    def run_etl(self):
        """
        Phase 2, 3 & 4: Silver, Gold, Validation.
        """

        print("\n--- [ETL] Running Transformation Pipeline ---")

        self.run_sql_file("SQL/scripts/02_silver.sql")
        self.run_sql_file("SQL/scripts/03_gold.sql")
        self.run_sql_file("SQL/scripts/04_validation.sql")

        print("--- [ETL] Pipeline Completed ---\n")

def main():

    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    db = os.getenv("DB_NAME")   

    if not all([user, password, host, port, db]):
            print("Error: Missing database credentials. Please check your .env file.")
            sys.exit(1)
            
    connection_url = f"postgresql://{user}:{password}@{host}:{port}/{db}"

    transformer = Transformer(db_url=connection_url)

    parser = argparse.ArgumentParser(description="COVID-19 Analysis Orchestrator")
    parser.add_argument("--init", action="store_true", help="Initialize database tables and dimensions")
    parser.add_argument("--run-etl", action="store_true", help="Run the full ETL pipeline (Silver -> Gold -> Validation)")
    
    args = parser.parse_args()

    if not any(vars(args).values()):
        parser.print_help()
        return

    if args.init:
        transformer.initialize()
    
    if args.run_etl:
        transformer.run_etl()

if __name__ == "__main__":
    main()
