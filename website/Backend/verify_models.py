import sys
import os

# Ensure Backend is in path
sys.path.append(os.getcwd())

try:
    from app.ml.xgboost_model import XGBoostPredictor
    from app.ml.knn_model import KNNPredictor
    from app.ml.forecasting_model import ForecastingPredictor
except ImportError as e:
    print(f"Import Error: {e}")
    print("Please ensure dependencies are installed: pip install xgboost scikit-learn numpy")
    sys.exit(1)

def train_and_verify():
    print("--- 1. Training & Saving Price Impact Model (XGBoost) ---")
    xgb = XGBoostPredictor()
    xgb_res = xgb.train() # Saves .pkl
    print(f"Result: {xgb_res}")
    
    print("\n--- 2. Training & Saving New Product Model (KNN) ---")
    knn = KNNPredictor()
    knn_res = knn.train() # Saves .pkl
    print(f"Result: {knn_res}")

    print("\n--- 3. Training & Saving Forecasting Model (Linear Regression) ---")
    forecast = ForecastingPredictor()
    forecast_res = forecast.train() # Saves .pkl
    print(f"Result: {forecast_res}")

    # Verify files exist
    models = [
        "app/ml/saved_models/price_impact_model.pkl",
        "app/ml/saved_models/new_product_model.pkl",
        "app/ml/saved_models/forecasting_model.pkl"
    ]
    
    print("\n--- Verifying .pkl files ---")
    all_exist = True
    for path in models:
        if os.path.exists(path):
            print(f"[OK] Found {path}")
        else:
            print(f"[MISSING] Could not find {path}")
            all_exist = False
            
    if all_exist:
        print("\nSUCCESS: All models trained and saved successfully.")
    else:
        print("\nFAILURE: Some models were not saved.")

if __name__ == "__main__":
    train_and_verify()
