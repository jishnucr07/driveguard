import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import matplotlib.pyplot as plt
import seaborn as sns
import datetime
import joblib
from pathlib import Path


class AccidentPredictionModel:
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

        # Initialize model pipeline
        self.model = self._build_model()

        # Store encoders for later use
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

        # Severity mapping (for training data)
        self.severity_mapping = {
            "None": 0,
            "Minor": 0.25,
            "Moderate": 0.5,
            "Severe": 0.75,
            "Fatal": 1.0,
        }

    def _build_model(self):
        # Create preprocessor
        categorical_transformer = Pipeline(
            steps=[("onehot", OneHotEncoder(handle_unknown="ignore"))]
        )

        numerical_transformer = Pipeline(steps=[("scaler", StandardScaler())])

        preprocessor = ColumnTransformer(
            transformers=[
                ("cat", categorical_transformer, self.categorical_features),
                ("num", numerical_transformer, self.numerical_features),
            ]
        )

        # Create and return the full pipeline with Random Forest regressor (not classifier)
        return Pipeline(
            steps=[
                ("preprocessor", preprocessor),
                (
                    "regressor",
                    RandomForestRegressor(
                        n_estimators=100, max_depth=15, random_state=42
                    ),
                ),
            ]
        )

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

        # Add numerical features to our features list if needed
        updated_numerical = self.numerical_features + [
            "Normalized_Hour",
            "Is_Night",
            "Is_Rush_Hour",
        ]

        return df

    def train(self, training_data):
        """Train the model with a list of dictionaries containing accident data"""
        # Convert list of dictionaries to DataFrame
        df = pd.DataFrame(training_data)

        # Process time features
        time_features = df["Time_of_Day"].apply(lambda x: self._preprocess_time(x))
        df["Normalized_Hour"] = [t[0] for t in time_features]
        df["Is_Night"] = [t[1] for t in time_features]
        df["Is_Rush_Hour"] = [t[2] for t in time_features]
        df.drop(columns=["Time_of_Day"], inplace=True)

        # Convert severity to numerical values for regression
        y = df["Accident_Severity"].map(self.severity_mapping).values
        X = df.drop(columns=["Accident_Severity"])

        # Split the data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )

        # Update numerical features list
        updated_numerical = self.numerical_features + [
            "Normalized_Hour",
            "Is_Night",
            "Is_Rush_Hour",
        ]

        # Update the preprocessor in the model
        categorical_transformer = Pipeline(
            steps=[("onehot", OneHotEncoder(handle_unknown="ignore"))]
        )

        numerical_transformer = Pipeline(steps=[("scaler", StandardScaler())])

        preprocessor = ColumnTransformer(
            transformers=[
                ("cat", categorical_transformer, self.categorical_features),
                ("num", numerical_transformer, updated_numerical),
            ]
        )

        self.model.named_steps["preprocessor"] = preprocessor

        # Train the model
        self.model.fit(X_train, y_train)

        # Evaluate the model
        y_pred = self.model.predict(X_test)

        # Calculate metrics
        mse = mean_squared_error(y_test, y_pred)
        rmse = np.sqrt(mse)
        mae = mean_absolute_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)

        # Print evaluation metrics
        print(f"Mean Squared Error: {mse:.4f}")
        print(f"Root Mean Squared Error: {rmse:.4f}")
        print(f"Mean Absolute Error: {mae:.4f}")
        print(f"R² Score: {r2:.4f}")

        # Plot 1: Feature Importance
        plt.figure(figsize=(10, 8))
        if hasattr(self.model.named_steps["regressor"], "feature_importances_"):
            feat_imp = self.model.named_steps["regressor"].feature_importances_
            ct = self.model.named_steps["preprocessor"]
            feature_names = ct.get_feature_names_out()

            if len(feature_names) == len(feat_imp):
                feat_imp_df = pd.DataFrame(
                    {"Feature": feature_names, "Importance": feat_imp}
                )
                feat_imp_df = feat_imp_df.sort_values(
                    "Importance", ascending=False
                ).head(15)
                sns.barplot(x="Importance", y="Feature", data=feat_imp_df)
                plt.title("Top 15 Feature Importance")
                plt.tight_layout()
                plt.show()
            else:
                print(
                    "Skipping feature importance visualization due to length mismatch"
                )

        # Plot 2: Actual vs Predicted values
        plt.figure(figsize=(8, 6))
        plt.scatter(y_test, y_pred, alpha=0.3)
        plt.plot([0, 1], [0, 1], "r--")
        plt.xlabel("Actual Severity")
        plt.ylabel("Predicted Severity")
        plt.title("Actual vs Predicted Values")
        plt.tight_layout()
        plt.show()

        # Plot 3: Residual plot
        plt.figure(figsize=(8, 6))
        residuals = y_test - y_pred
        plt.scatter(y_pred, residuals, alpha=0.3)
        plt.axhline(y=0, color="r", linestyle="--")
        plt.xlabel("Predicted Values")
        plt.ylabel("Residuals")
        plt.title("Residual Plot")
        plt.tight_layout()
        plt.show()

        # Plot 4: Distribution of predictions
        plt.figure(figsize=(8, 6))
        sns.histplot(y_pred, kde=True, bins=20)
        plt.xlabel("Predicted Severity")
        plt.title("Distribution of Predictions")
        plt.tight_layout()
        plt.show()

        # Additional plot: Correlation matrix of numerical features
        numerical_df = X_train.select_dtypes(include=["number"])
        if not numerical_df.empty:
            plt.figure(figsize=(10, 8))
            corr_matrix = numerical_df.corr()
            sns.heatmap(corr_matrix, annot=True, cmap="coolwarm", center=0)
            plt.title("Correlation Matrix of Numerical Features")
            plt.tight_layout()
            plt.show()

        return {"mse": mse, "rmse": rmse, "mae": mae, "r2": r2}

    def predict_probability(self, input_data):
        """Predict accident probability from a single input data dictionary"""
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
        }

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

    def generate_synthetic_training_data(self, n_samples=1000):
        """Generate synthetic training data for model demonstration"""
        np.random.seed(42)

        # Define possible values for categorical features
        categories = self.feature_mapping

        # Create empty list to store data
        data = []

        # Generate samples
        for _ in range(n_samples):
            sample = {}

            # Generate random values for numerical features
            sample["Speed_Limit"] = np.random.randint(30, 130)
            sample["Number_of_Vehicles"] = np.random.randint(1, 6)
            sample["Driver_Age"] = np.random.randint(18, 80)
            sample["Driver_Experience"] = min(
                np.random.randint(0, 50), sample["Driver_Age"] - 18
            )
            sample["Traffic_Density"] = np.random.randint(0, 4)

            # Generate random values for categorical features
            for feat, options in categories.items():
                sample[feat] = np.random.choice(options)

            # Generate time
            hour = np.random.randint(0, 24)
            minute = np.random.randint(0, 60)
            second = np.random.randint(0, 60)
            sample["Time_of_Day"] = f"{hour:02d}:{minute:02d}:{second:02d}"

            # Calculate accident severity based on risk factors
            risk_score = 0

            # Speed factor
            risk_score += (sample["Speed_Limit"] - 60) / 100

            # Age and experience factor
            if sample["Driver_Age"] < 25:
                risk_score += (25 - sample["Driver_Age"]) / 25
            risk_score += (5 - min(sample["Driver_Experience"], 5)) / 10

            # Weather factor
            weather_risk = {
                "clear": 0,
                "cloudy": 0.1,
                "light rain": 0.2,
                "heavy rain": 0.4,
                "thunderstorm with heavy rain": 0.6,
                "snow": 0.5,
                "fog": 0.5,
            }
            risk_score += weather_risk.get(sample["Weather"], 0)

            # Road condition factor
            road_risk = {
                "dry": 0,
                "wet": 0.3,
                "icy": 0.7,
                "snowy": 0.6,
                "under_construction": 0.4,
            }
            risk_score += road_risk.get(sample["Road_Condition"], 0)

            # Vehicle type factor
            vehicle_risk = {
                "sedan": 0.2,
                "suv": 0.25,
                "truck": 0.3,
                "motorcycle": 0.7,
                "bus": 0.35,
                "van": 0.25,
            }
            risk_score += vehicle_risk.get(sample["Vehicle_Type"], 0)

            # Road type factor
            road_type_risk = {
                "highway": 0.3,
                "city_street": 0.2,
                "rural": 0.4,
                "mountain_pass": 0.6,
                "residential": 0.1,
                "bridge": 0.3,
            }
            risk_score += road_type_risk.get(sample["Road_Type"], 0)

            # Visibility factor
            visibility_risk = {
                "daylight": 0,
                "dawn_dusk": 0.2,
                "night": 0.4,
                "night_with_streetlights": 0.25,
            }
            risk_score += visibility_risk.get(sample["Road_Light_Condition"], 0)

            # Traffic density factor
            risk_score += sample["Traffic_Density"] * 0.1

            # Number of vehicles factor
            risk_score += (sample["Number_of_Vehicles"] - 1) * 0.05

            # Normalize and add some randomness
            risk_score = min(max(risk_score / 3 + np.random.normal(0, 0.1), 0), 1)

            # Map to severity categories
            if risk_score < 0.2:
                sample["Accident_Severity"] = "None"
            elif risk_score < 0.4:
                sample["Accident_Severity"] = "Minor"
            elif risk_score < 0.6:
                sample["Accident_Severity"] = "Moderate"
            elif risk_score < 0.8:
                sample["Accident_Severity"] = "Severe"
            else:
                sample["Accident_Severity"] = "Fatal"

            data.append(sample)

        return data

    def save_model(self, file_path):
        """Save the model to a file"""
        # Ensure the directory exists
        Path(file_path).parent.mkdir(parents=True, exist_ok=True)
        joblib.dump(self.model, file_path)
        print(f"Model saved to {file_path}")

    @classmethod
    def load_model(cls, file_path):
        """Load a model from file and return a new AccidentPredictionModel instance"""
        model = joblib.load(file_path)
        new_instance = cls()
        new_instance.model = model
        return new_instance


# Example usage
def demonstrate_model():
    # Initialize the model
    model = AccidentPredictionModel()

    # Generate synthetic training data
    print("Generating synthetic training data...")
    training_data = model.generate_synthetic_training_data(2000)

    # Train the model
    print("\nTraining model...")
    metrics = model.train(training_data)

    # Save the model
    model.save_model("models/accident_model.joblib")

    # Example input data
    input_data = {
        "Speed_Limit": 120,
        "Number_of_Vehicles": 5,
        "Driver_Age": 18,
        "Driver_Experience": 0,
        "Weather": "thunderstorm with heavy rain",
        "Road_Type": "mountain_pass",
        "Time_of_Day": "23:45:00",
        "Traffic_Density": 3,
        "Road_Condition": "icy",
        "Vehicle_Type": "motorcycle",
        "Road_Light_Condition": "night",
    }

    # Make prediction
    print("\nMaking prediction for high-risk scenario...")
    prediction = model.predict_probability(input_data)

    # Print prediction
    print(f"\nAccident Probability: {prediction['accident_probability']:.2f}")
    print(f"Confidence: {prediction['confidence']:.2f}")
    print(f"Risk Rating: {prediction['risk_rating']}")
    print("Risk Factors:")
    for factor in prediction["risk_factors"]:
        print(f"- {factor}")

    # Compare with a low-risk scenario
    low_risk_input = {
        "Speed_Limit": 50,
        "Number_of_Vehicles": 1,
        "Driver_Age": 40,
        "Driver_Experience": 20,
        "Weather": "clear",
        "Road_Type": "city_street",
        "Time_of_Day": "14:30:00",
        "Traffic_Density": 1,
        "Road_Condition": "dry",
        "Vehicle_Type": "sedan",
        "Road_Light_Condition": "daylight",
    }

    print("\nMaking prediction for low-risk scenario...")
    low_risk_prediction = model.predict_probability(low_risk_input)

    # Print low-risk prediction
    print(f"\nAccident Probability: {low_risk_prediction['accident_probability']:.2f}")
    print(f"Confidence: {low_risk_prediction['confidence']:.2f}")
    print(f"Risk Rating: {low_risk_prediction['risk_rating']}")
    print("Risk Factors:")
    for factor in low_risk_prediction["risk_factors"]:
        print(f"- {factor}")


if __name__ == "__main__":
    demonstrate_model()
