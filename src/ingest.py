import os
import pandas as pd
from sqlalchemy import create_engine, text
from pathlib import Path
from dotenv import load_dotenv

class Ingestor:
    def __init__(self, db_url: str):
        # Pass the connection URL in, rather than building it inside the class
        self.engine = create_engine(db_url)
        self.root_dir = Path(__file__).resolve().parent.parent 

        self.file_map = {
            "data/raw/covid_19_india.csv": "covid_19_india_staging",
            "data/raw/StatewiseTestingDetails.csv": "statewisetestingdetails_staging",
            "data/raw/covid_vaccine_statewise.csv": "covid_vaccine_statewise_staging"
        }

    def normalize_columns(self, df: pd.DataFrame) -> pd.DataFrame:
        """Standardizes column names to be Postgres-friendly using Regex."""
        df.columns = df.columns.str.strip().str.lower()
        
        # Replace spaces, slashes, parentheses, and dashes with an underscore
        df.columns = df.columns.str.replace(r'[\s/\(\)\-]', '_', regex=True)
        # Replace plus signs
        df.columns = df.columns.str.replace(r'\+', '_plus', regex=True)
        # Clean up any double underscores created by the regex
        df.columns = df.columns.str.replace(r'_+', '_', regex=True)
        
        # Ensure column names don't start with numbers
        df.columns = [f"c_{c}" if c and c[0].isdigit() else c for c in df.columns]
        return df 

    def load_data(self):
        """Loads all raw CSVs into staging tables safely."""
        print("\n--- [INGEST] Starting Data Load ---")
        
        for rel_path, table_name in self.file_map.items():
            file_path = self.root_dir / rel_path

            if not file_path.exists():
                print(f"Warning: File {file_path} not found. Skipping table '{table_name}'.")
                continue
            
            print(f"Loading {file_path.name} into {table_name}...")
            
            # Read and clean data
            df = pd.read_csv(file_path, dtype=str)
            df = self.normalize_columns(df)
            
            # Using engine.begin() creates a transaction. 
            # If to_sql fails, the TRUNCATE is rolled back safely (Postgres supports transactional DDL)
            try:
                with self.engine.begin() as conn:
                    conn.execute(text(f"TRUNCATE TABLE {table_name} CASCADE"))
                    
                    # method='multi' and chunksize optimize bulk inserts for Postgres
                    df.to_sql(
                        table_name, 
                        conn, 
                        if_exists='append', 
                        index=False,
                        method='multi',
                        chunksize=10000 
                    )
                print(f"Loaded {len(df)} rows successfully.")
            except Exception as e:
                print(f"Error loading {table_name}: {e}")
                
        print("--- [INGEST] Data Load Completed ---\n")

def main():
    # Load environment variables once at the entry point
    load_dotenv()
    
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    db = os.getenv("DB_NAME")
    
    # Simple validation to ensure env vars loaded
    if not all([user, password, host, port, db]):
        raise ValueError("Missing database environment variables. Check your .env file.")

    connection_url = f"postgresql://{user}:{password}@{host}:{port}/{db}"
    
    ingestor = Ingestor(db_url=connection_url)
    ingestor.load_data()

if __name__ == "__main__":
    main()