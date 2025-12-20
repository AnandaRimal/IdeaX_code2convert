from fastapi import FastAPI
from app.api.v1 import ml
from app.ml.xgboost_model import XGBoostPredictor
from app.ml.knn_model import KNNPredictor
from app.ml.forecasting_model import ForecastingPredictor
import os

app = FastAPI(title="Pasale ML Service")

app.include_router(ml.router, prefix="/api/v1/ml", tags=["ML"])

@app.on_event("startup")
def startup_event():
    # Check if models exist, if not, train them
    models = [
        "app/ml/saved_models/price_impact_model.pkl",
        "app/ml/saved_models/new_product_model.pkl",
        "app/ml/saved_models/forecasting_model.pkl"
    ]
    
    missing = False
    for p in models:
        if not os.path.exists(p):
            missing = True
            break
            
    if missing:
        print("Models missing. Starting initial training using kiran_store.csv...")
        try:
            XGBoostPredictor().train()
            KNNPredictor().train()
            ForecastingPredictor().train()
            print("Initial training complete.")
        except Exception as e:
            print(f"Error during startup training: {e}")

@app.get("/")
def root():
    return {"message": "Pasale ML Service Running"}
