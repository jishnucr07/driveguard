from flask import Flask, request, jsonify
import numpy as np
import tensorflow as tf
import datetime
from datetime import datetime as dt
import joblib
import pandas as pd
import json
import os
import logging
import traceback
from typing import Dict, Any
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Global variables for driving behavior model
real_time_data = []
predictions = []

# Initialize model paths for second app
MODEL_DIR = "models"
MODEL_PATH = os.path.join(MODEL_DIR, "accident_model.joblib")


# Load LSTM-CNN and LightGBM models
def load_driving_resources():
    global lstm_cnn_model, lightgbm_model, preprocessor

    # Load LSTM-CNN model
    try:
        lstm_cnn_model = tf.keras.models.load_model("improved_lstm_cnn_model.h5")
        logger.info("LSTM-CNN model loaded successfully!")
    except Exception as e:
        logger.error(f"Error loading LSTM-CNN model: {e}")
        lstm_cnn_model = None

    # Load LightGBM model
    try:
        lightgbm_model = joblib.load("lightgbm_tuned_model.pkl")
        logger.info("LightGBM model loaded successfully!")
    except Exception as e:
        logger.error(f"Error loading LightGBM model: {e}")
        lightgbm_model = None

    # Load preprocessor
    try:
        preprocessor = joblib.load("preprocessor.pkl")
        logger.info("Preprocessor loaded successfully!")
    except Exception as e:
        logger.error(f"Error loading preprocessor: {e}")
        preprocessor = None


# Accident Predictor Class from first app
class AccidentPredictorAPI:
    def __init__(self, model_path="saved_model"):
        self.model = None
        self.feature_config = None
        try:
            self.load_model(model_path)
        except Exception as e:
            logger.error(f"Initialization failed: {str(e)}")
            raise

    def load_model(self, model_dir):
        """Load the model and feature config with robust error handling"""
        try:
            # Verify model directory exists
            if not os.path.exists(model_dir):
                raise FileNotFoundError(f"Model directory not found: {model_dir}")

            # Load model
            model_path = os.path.join(model_dir, "model.joblib")
            if not os.path.exists(model_path):
                raise FileNotFoundError(f"Model file not found: {model_path}")
            self.model = joblib.load(model_path)
            logger.info(f"Model loaded from {model_path}")

            # Load feature config
            config_path = os.path.join(model_dir, "feature_config.json")
            if not os.path.exists(config_path):
                raise FileNotFoundError(f"Config file not found: {config_path}")

            with open(config_path, "r") as f:
                try:
                    self.feature_config = json.load(f)
                except json.JSONDecodeError as e:
                    error_msg = f"Invalid JSON in config file at line {e.lineno}, column {e.colno}"
                    logger.error(error_msg)
                    raise ValueError(error_msg) from e

            logger.info(f"Feature config loaded from {config_path}")

        except Exception as e:
            logger.error(f"Failed to load model: {str(e)}")
            raise

    def _create_derived_features(self, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create derived features from input data"""
        derived = {}
        try:
            # Time of day handling
            time = input_data.get("Time_of_Day", "12:00:00")
            hour = int(time.split(":")[0]) if ":" in time else 12

            derived["Is_Night"] = 1 if hour >= 22 or hour <= 5 else 0

            # Weather handling
            weather = input_data.get("Weather", "").lower().split()[0]
            derived["Is_Extreme_Weather"] = (
                1 if weather in ["thunderstorm", "snow"] else 0
            )

            # Vehicle handling
            vehicle = input_data.get("Vehicle_Type", "").lower()
            derived["Risk_Vehicle"] = 1 if vehicle == "motorcycle" else 0

            # Numerical features
            derived["Experience_Ratio"] = input_data.get("Driver_Experience", 1) / max(
                1, input_data.get("Driver_Age", 18) - 18
            )
            derived["Speed_Ratio"] = input_data.get("Speed_Limit", 50) / 120.0
            derived["Traffic_Intensity"] = (
                input_data.get("Traffic_Density", 1)
                * input_data.get("Number_of_Vehicles", 1)
                / 10.0
            )

        except Exception as e:
            logger.error(f"Error creating derived features: {str(e)}")
            raise ValueError("Failed to create derived features") from e

        return derived

    def preprocess_input(self, input_data: Dict[str, Any]) -> pd.DataFrame:
        """Preprocess input data to match model requirements"""
        try:
            # Extract base features
            features = {
                "Speed_Limit": input_data.get("Speed_Limit", 50),
                "Number_of_Vehicles": input_data.get("Number_of_Vehicles", 1),
                "Driver_Age": input_data.get("Driver_Age", 30),
                "Driver_Experience": input_data.get("Driver_Experience", 5),
                "Traffic_Density": input_data.get("Traffic_Density", 1),
                "Weather": input_data.get("Weather", "clear").lower().split()[0],
                "Road_Type": input_data.get("Road_Type", "urban").lower(),
                "Time_of_Day": str(
                    input_data.get("Time_of_Day", "12:00:00").split(":")[0]
                ),
                "Road_Condition": input_data.get("Road_Condition", "dry").lower(),
                "Vehicle_Type": input_data.get("Vehicle_Type", "car").lower(),
                "Road_Light_Condition": input_data.get(
                    "Road_Light_Condition", "day"
                ).lower(),
            }

            # Add derived features
            features.update(self._create_derived_features(input_data))

            return pd.DataFrame([features])

        except Exception as e:
            logger.error(f"Preprocessing failed: {str(e)}")
            raise ValueError("Input preprocessing failed") from e

    def predict(self, input_data: Dict[str, Any]) -> float:
        """Make a prediction on new input data"""
        try:
            input_df = self.preprocess_input(input_data)
            probability = self.model.predict_proba(input_df)[0, 1]
            return float(probability)
        except Exception as e:
            logger.error(f"Prediction failed: {str(e)}")
            raise


def get_risk_level(probability: float) -> str:
    """Convert probability to risk level"""
    if probability >= 0.8:
        return "Extreme"
    elif probability >= 0.6:
        return "High"
    elif probability >= 0.4:
        return "Moderate"
    elif probability >= 0.2:
        return "Low"
    else:
        return "Very Low"


# Accident Prediction API from second app
class AccidentPredictionAPI:
    def __init__(self):
        # Define categorical and numerical features
        self.categorical_features = [
            "Weather",
            "Road_Type",
            "Road_Condition",
            "Vehicle_Type",
            "Road_Light_Condition",
        ]
        self.numerical_features = [
            "Speed_Limit",
            "Number_of_Vehicles",
            "Driver_Age",
            "Driver_Experience",
            "Traffic_Density",
        ]

        # Define valid values for categorical features
        self.feature_mapping = {
            "Weather": [
                "clear",
                "cloudy",
                "light rain",
                "heavy rain",
                "thunderstorm with heavy rain",
                "snow",
                "fog",
            ],
            "Road_Type": [
                "highway",
                "city_street",
                "rural",
                "mountain_pass",
                "residential",
                "bridge",
            ],
            "Road_Condition": ["dry", "wet", "icy", "snowy", "under_construction"],
            "Vehicle_Type": ["sedan", "suv", "truck", "motorcycle", "bus", "van"],
            "Road_Light_Condition": [
                "daylight",
                "dawn_dusk",
                "night",
                "night_with_streetlights",
            ],
        }

        # Load the model
        try:
            self.model = self._load_model(MODEL_PATH)
            print(f"Model loaded successfully from {MODEL_PATH}")
        except Exception as e:
            print(f"Error loading model: {str(e)}")
            self.model = None

    def _load_model(self, model_path):
        """Load the pre-trained model"""
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found at {model_path}")
        return joblib.load(model_path)

    def _preprocess_time(self, time_str):
        """Convert time string to features"""
        try:
            time_obj = datetime.datetime.strptime(time_str, "%H:%M:%S").time()
            hour = time_obj.hour

            # Create derived features
            is_night = 1 if (hour >= 22 or hour <= 5) else 0
            is_rush_hour = 1 if (7 <= hour <= 9 or 16 <= hour <= 19) else 0

            # Normalize hour to a value between 0 and 1
            normalized_hour = hour / 24.0

            return normalized_hour, is_night, is_rush_hour
        except:
            # Default values if time can't be parsed
            return 0.5, 0, 0

    def _transform_input(self, input_data):
        """Transform input data dictionary to pandas DataFrame"""
        # Convert to DataFrame for easier manipulation
        df = pd.DataFrame([input_data])

        # Handle Time_of_Day feature
        time_str = df["Time_of_Day"].iloc[0]
        norm_hour, is_night, is_rush_hour = self._preprocess_time(time_str)
        df["Normalized_Hour"] = norm_hour
        df["Is_Night"] = is_night
        df["Is_Rush_Hour"] = is_rush_hour

        # Remove the original Time_of_Day column
        df.drop(columns=["Time_of_Day"], inplace=True)

        # Remove Accident_Severity for prediction (it's our target and shouldn't be in input features)
        if "Accident_Severity" in df.columns:
            df.drop(columns=["Accident_Severity"], inplace=True)

        return df

    def _get_risk_rating(self, probability):
        """Convert probability to risk rating"""
        if probability < 0.2:
            return "Very Low"
        elif probability < 0.4:
            return "Low"
        elif probability < 0.6:
            return "Moderate"
        elif probability < 0.8:
            return "High"
        else:
            return "Very High"

    def _identify_risk_factors(self, input_data):
        """Identify key factors contributing to risk"""
        risk_factors = []

        # Speed check
        if input_data.get("Speed_Limit", 0) > 90:
            risk_factors.append("High speed")

        # Young driver check
        if (
            input_data.get("Driver_Age", 30) < 25
            and input_data.get("Driver_Experience", 5) < 3
        ):
            risk_factors.append("Inexperienced young driver")

        # Weather check
        high_risk_weather = [
            "thunderstorm with heavy rain",
            "heavy rain",
            "snow",
            "fog",
        ]
        if input_data.get("Weather", "") in high_risk_weather:
            risk_factors.append(f"Dangerous weather: {input_data['Weather']}")

        # Road condition check
        dangerous_conditions = ["icy", "snowy", "under_construction"]
        if input_data.get("Road_Condition", "") in dangerous_conditions:
            risk_factors.append(
                f"Dangerous road condition: {input_data['Road_Condition']}"
            )

        # Road type check
        if input_data.get("Road_Type", "") == "mountain_pass":
            risk_factors.append("Mountain pass: challenging terrain")

        # Nighttime check
        if input_data.get("Road_Light_Condition", "") == "night":
            risk_factors.append("Nighttime driving with reduced visibility")

        # Vehicle type check
        if input_data.get("Vehicle_Type", "") == "motorcycle":
            risk_factors.append("Motorcycle: higher vulnerability in accidents")

        # Traffic density check
        if input_data.get("Traffic_Density", 0) > 2:
            risk_factors.append("High traffic density")

        return risk_factors

    def validate_input(self, input_data):
        """Validate the input data"""
        required_fields = (
            self.categorical_features + self.numerical_features + ["Time_of_Day"]
        )
        errors = []

        # Check for missing fields
        for field in required_fields:
            if field not in input_data:
                errors.append(f"Missing required field: {field}")

        if errors:
            return False, errors

        # Validate categorical features
        for feature in self.categorical_features:
            if (
                feature in input_data
                and input_data[feature] not in self.feature_mapping[feature]
            ):
                valid_values = ", ".join(self.feature_mapping[feature])
                errors.append(
                    f"Invalid value for {feature}: {input_data[feature]}. Valid values are: {valid_values}"
                )

        # Validate numerical features
        for feature in self.numerical_features:
            if feature in input_data:
                try:
                    value = float(input_data[feature])
                    # Add specific range validations
                    if feature == "Speed_Limit" and (value < 0 or value > 250):
                        errors.append(
                            f"Speed_Limit must be between 0 and 250, got {value}"
                        )
                    elif feature == "Driver_Age" and (value < 16 or value > 100):
                        errors.append(
                            f"Driver_Age must be between 16 and 100, got {value}"
                        )
                    elif feature == "Driver_Experience" and (value < 0 or value > 80):
                        errors.append(
                            f"Driver_Experience must be between 0 and 80, got {value}"
                        )
                    elif feature == "Traffic_Density" and (value < 0 or value > 5):
                        errors.append(
                            f"Traffic_Density must be between 0 and 5, got {value}"
                        )
                    elif feature == "Number_of_Vehicles" and (value < 1 or value > 10):
                        errors.append(
                            f"Number_of_Vehicles must be between 1 and 10, got {value}"
                        )
                except ValueError:
                    errors.append(
                        f"Invalid numeric value for {feature}: {input_data[feature]}"
                    )

        # Validate Time_of_Day format
        if "Time_of_Day" in input_data:
            try:
                datetime.datetime.strptime(input_data["Time_of_Day"], "%H:%M:%S")
            except ValueError:
                errors.append("Time_of_Day must be in format HH:MM:SS")

        # Check logical constraints
        if "Driver_Age" in input_data and "Driver_Experience" in input_data:
            if (
                float(input_data["Driver_Experience"])
                > float(input_data["Driver_Age"]) - 16
            ):
                errors.append(
                    "Driver_Experience cannot be greater than Driver_Age minus 16"
                )

        return (True, []) if not errors else (False, errors)

    def predict(self, input_data):
        """Predict accident probability from input data"""
        if self.model is None:
            return {"error": "Model not loaded. Please check server logs."}, 500

        # Validate input data
        is_valid, errors = self.validate_input(input_data)
        if not is_valid:
            return {"error": "Invalid input data", "details": errors}, 400

        try:
            # Transform input data
            df = self._transform_input(input_data)

            # Predict probability
            prob = self.model.predict(df)[0]

            # Ensure probability is between 0 and 1
            prob = max(0, min(1, prob))

            # Calculate confidence based on the model's prediction
            confidence = min(0.5 + abs(prob - 0.5), 0.95)

            # Generate risk factors based on input
            risk_factors = self._identify_risk_factors(input_data)

            return {
                "accident_probability": float(prob),
                "confidence": float(confidence),
                "risk_rating": self._get_risk_rating(prob),
                "risk_factors": risk_factors,
            }, 200
        except Exception as e:
            print(traceback.format_exc())
            return {"error": "Prediction error", "details": str(e)}, 500


# Initialize all models
load_driving_resources()

# Initialize accident predictor from first app
try:
    predictor = AccidentPredictorAPI()
    logger.info("Accident Predictor initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize accident predictor: {str(e)}")
    predictor = None

# Create API instance from second app
api = AccidentPredictionAPI()

# Ensure model directory exists
Path(MODEL_DIR).mkdir(parents=True, exist_ok=True)


# ===== API ENDPOINTS FROM FIRST APP =====


# Endpoint to receive sensor data for LSTM-CNN model
@app.route("/send_data", methods=["POST"])
def send_data():
    global real_time_data, predictions

    try:
        # Get the data from the POST request
        data = request.json["data"]
        timestamp = dt.now().strftime("%Y-%m-%d %H:%M:%S")

        # Ensure the data has the correct shape (10 time steps, 14 features)
        if len(data) != 10 or any(len(row) != 14 for row in data):
            return jsonify({"error": "Invalid data shape. Expected (10, 14)."}), 400

        # Append the data with timestamp
        real_time_data.append({"timestamp": timestamp, "data": data})

        # Convert data to numpy array for prediction
        data_array = np.array(data).reshape(1, 10, -1)  # Reshape to (1, 10, 14)

        # Make a prediction
        prediction = lstm_cnn_model.predict(data_array)
        predicted_class = np.argmax(prediction, axis=1)[0]

        # Map the predicted class to driving behavior
        driving_behavior = (
            "Normal Driving" if predicted_class == 1 else "Aggressive Driving"
        )

        # Store the prediction
        predictions.append({"timestamp": timestamp, "prediction": driving_behavior})

        # Return the prediction as a JSON response
        return jsonify({"status": "success", "driving_behavior": driving_behavior})

    except Exception as e:
        logger.error(f"Error in /send_data: {e}")
        return jsonify({"error": str(e)}), 500


# Endpoint to calculate the driver's score after the journey
@app.route("/calculate_score", methods=["GET"])
def calculate_score():
    global predictions

    if not predictions:
        logger.warning("No predictions available for scoring.")
        return jsonify({"error": "No data available for scoring"}), 400

    try:
        # Get additional parameters from the request
        max_speed = float(
            request.args.get("max_speed", 0)
        )  # Max speed during the drive
        speed_limit = float(
            request.args.get("speed_limit", 0)
        )  # Speed limit of the road
        accident_percentage = float(
            request.args.get("accident_percentage", 0)
        )  # Predicted accident percentage

        # Calculate Normal Driving Score
        normal_driving_count = sum(
            1 for p in predictions if p["prediction"] == "Normal Driving"
        )
        total_predictions = len(predictions)
        normal_driving_score = (normal_driving_count / total_predictions) * 100

        # Calculate Speed Compliance Score
        if max_speed <= speed_limit:
            speed_compliance_score = 100  # Full score if speed limit is not exceeded
        else:
            # Penalize proportionally for exceeding the speed limit
            speed_compliance_score = max(
                0, 100 - ((max_speed - speed_limit) / speed_limit * 100)
            )

        # Calculate Accident Risk Score
        # Higher accident percentage → Lower score
        accident_risk_score = max(0, 100 - accident_percentage)

        # Calculate Composite Driver Score
        # Weighted average of the three scores
        normal_driving_weight = 0.5  # 50%
        speed_compliance_weight = 0.3  # 30%
        accident_risk_weight = 0.2  # 20%

        driver_score = (
            (normal_driving_score * normal_driving_weight)
            + (speed_compliance_score * speed_compliance_weight)
            + (accident_risk_score * accident_risk_weight)
        )

        # Log the results
        logger.info(f"Predictions: {predictions}")
        logger.info(f"Normal Driving Count: {normal_driving_count}")
        logger.info(f"Total Predictions: {total_predictions}")
        logger.info(f"Normal Driving Score: {normal_driving_score}")
        logger.info(f"Max Speed: {max_speed}")
        logger.info(f"Speed Limit: {speed_limit}")
        logger.info(f"Speed Compliance Score: {speed_compliance_score}")
        logger.info(f"Accident Percentage: {accident_percentage}")
        logger.info(f"Accident Risk Score: {accident_risk_score}")
        logger.info(f"Driver Score: {driver_score}")

        # Clear the data for the next journey
        real_time_data.clear()
        predictions.clear()

        # Return the single driver score
        return jsonify({"driver_score": driver_score})

    except Exception as e:
        logger.error(f"Error in /calculate_score: {e}")
        return jsonify({"error": str(e)}), 500


# Endpoint to predict accident likelihood using LightGBM model
@app.route("/predict_accident", methods=["POST"])
def predict_accident():
    try:
        input_data = request.json
        logger.debug(f"Input Data: {input_data}")

        # Validate input
        if not input_data:
            return jsonify({"error": "No input data provided."}), 400

        # Convert and validate numeric fields
        numeric_fields = [
            "Speed_Limit",
            "Number_of_Vehicles",
            "Driver_Age",
            "Driver_Experience",
        ]
        for field in numeric_fields:
            if field not in input_data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
            try:
                input_data[field] = float(
                    input_data[field]
                )  # Use float to handle decimals
            except ValueError:
                return jsonify(
                    {"error": f"Invalid value for {field}. Must be a number."}
                ), 400

        # Create DataFrame
        input_df = pd.DataFrame([input_data])

        # Feature engineering
        input_df["Speed_Vehicle_Ratio"] = (
            input_df["Speed_Limit"] / input_df["Number_of_Vehicles"]
        )
        input_df["Driver_Experience_Age_Ratio"] = (
            input_df["Driver_Experience"] / input_df["Driver_Age"]
        )

        # Validate all required features
        required_features = [
            "Speed_Limit",
            "Number_of_Vehicles",
            "Driver_Age",
            "Driver_Experience",
            "Speed_Vehicle_Ratio",
            "Driver_Experience_Age_Ratio",
            "Weather",
            "Road_Type",
            "Time_of_Day",
            "Traffic_Density",
            "Accident_Severity",
            "Road_Condition",
            "Vehicle_Type",
            "Road_Light_Condition",
        ]
        missing_features = [f for f in required_features if f not in input_df.columns]
        if missing_features:
            return jsonify({"error": f"Missing features: {missing_features}"}), 400

        # Check if preprocessor and model are loaded
        if preprocessor is None:
            return jsonify({"error": "Preprocessor not loaded."}), 500
        if lightgbm_model is None:
            return jsonify({"error": "LightGBM model not loaded."}), 500

        # Preprocess input
        input_processed = preprocessor.transform(input_df)

        # Convert processed input to a DataFrame with feature names
        feature_names = preprocessor.get_feature_names_out()
        input_processed_df = pd.DataFrame(input_processed, columns=feature_names)
        logger.debug(f"Processed input shape: {input_processed_df.shape}")

        # Predict
        accident_likelihood = lightgbm_model.predict_proba(input_processed_df)[0][1]
        return jsonify(
            {"status": "success", "accident_likelihood": accident_likelihood}
        )

    except Exception as e:
        logger.error(f"Error in /predict_accident: {str(e)}")
        return jsonify({"error": "Internal server error. Check logs for details."}), 500


# Endpoint for accident prediction using the dedicated AccidentPredictorAPI from first app
@app.route("/accident_predictor", methods=["POST"])
def accident_predictor():
    if predictor is None:
        return jsonify({"error": "Model not loaded"}), 503

    try:
        input_data = request.json

        # Validate required fields
        required_fields = [
            "Speed_Limit",
            "Number_of_Vehicles",
            "Driver_Age",
            "Driver_Experience",
            "Weather",
            "Road_Type",
            "Time_of_Day",
            "Traffic_Density",
            "Road_Condition",
            "Vehicle_Type",
            "Road_Light_Condition",
        ]

        missing_fields = [field for field in required_fields if field not in input_data]
        if missing_fields:
            return jsonify(
                {"error": "Missing required fields", "missing_fields": missing_fields}
            ), 400

        probability = predictor.predict(input_data)

        return jsonify(
            {
                "status": "success",
                "accident_probability": probability,
                "risk_level": get_risk_level(probability),
            }
        )

    except Exception as e:
        logger.error(f"API error: {str(e)}")
        return jsonify({"error": "Prediction failed", "details": str(e)}), 500


# ===== API ENDPOINTS FROM SECOND APP =====


# Endpoint from second app for accident prediction
@app.route("/predict", methods=["POST"])
def predict():
    """Prediction endpoint"""
    try:
        # Get input data from request
        input_data = request.get_json()
        if not input_data:
            return jsonify({"error": "No input data provided"}), 400

        # Call the predict method
        result, status_code = api.predict(input_data)

        return jsonify(result), status_code
    except Exception as e:
        print(traceback.format_exc())
        return jsonify({"error": "Server error", "details": str(e)}), 500


@app.route("/features", methods=["GET"])
def get_features():
    """Get feature information for API documentation"""
    return jsonify(
        {
            "categorical_features": api.feature_mapping,
            "numerical_features": api.numerical_features,
            "required_fields": api.categorical_features
            + api.numerical_features
            + ["Time_of_Day"],
            "example_input": {
                "Speed_Limit": 60,
                "Number_of_Vehicles": 2,
                "Driver_Age": 35,
                "Driver_Experience": 10,
                "Traffic_Density": 1,
                "Weather": "clear",
                "Road_Type": "city_street",
                "Road_Condition": "dry",
                "Vehicle_Type": "sedan",
                "Road_Light_Condition": "daylight",
                "Time_of_Day": "14:30:00",
            },
        }
    ), 200


# ===== COMBINED HEALTH CHECK =====


@app.route("/health", methods=["GET"])
def health_check():
    """Combined health check endpoint"""
    return jsonify(
        {
            "status": "ready"
            if predictor is not None
            and lstm_cnn_model is not None
            and api.model is not None
            else "partially ready"
            if predictor is not None
            or lstm_cnn_model is not None
            or api.model is not None
            else "not ready",
            "models_loaded": {
                "accident_predictor": predictor is not None,
                "lstm_cnn_model": lstm_cnn_model is not None,
                "lightgbm_model": lightgbm_model is not None,
                "preprocessor": preprocessor is not None,
                "accident_prediction_api": api.model is not None,
            },
        }
    )


# Error handlers
@app.errorhandler(400)
def bad_request(error):
    return jsonify({"error": "Bad request", "details": str(error)}), 400


@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found", "details": str(error)}), 404


@app.errorhandler(500)
def server_error(error):
    return jsonify({"error": "Server error", "details": str(error)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
