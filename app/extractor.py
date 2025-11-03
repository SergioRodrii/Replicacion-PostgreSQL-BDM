import pandas as pd

def extract_csv_in_batches(file_path: str, batch_size: int = 300):
    for chunk in pd.read_csv(file_path, chunksize=batch_size, iterator=True, encoding="utf-8"):
        yield chunk
