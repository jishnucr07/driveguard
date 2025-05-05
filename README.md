# DriveGuard

**DriveGuard** is an intelligent accident detection system that uses machine learning to analyze driving patterns and detect potential accidents in real-time. The system consists of a Flutter mobile application frontend and a Python-based machine learning backend.

DriveGuard consists of:
- A **Flutter mobile application** for real-time data collection, user interface, and notifications.
- A **Python-based backend** running machine learning models (CNN, LSTM, LightGBM, etc.) for classifying driver behavior and predicting accidents.

---

## 🧱 Project Structure
```bash
driveguard/
├── flutter-app/ # Flutter frontend
│ └── lib/
│ └── ml-section/
│ └── repo/ # Contains API call logic to ML server
├── ml/ # Python backend (Machine Learning models)
├── app3.py # Main server file to run ML backend

```
---

## ⚙️ Configuration

Before running the application, make the following changes:

### ✅ Update IP addresses

- In `flutter-app/lib/ml-section/repo/ml-repo.dart`, update the `base URL` to your server's IP address.
- In `app3.py`, update the IP address configuration (usually in the `app.run()` section or where `host` is specified).

### ✅ Update file paths

Due to a known bug, absolute paths are used in the code. Update these paths to match your system:

- In all model files under the `ml/` directory, update paths to your local dataset and saved model files.
- In `app3.py`, ensure all file paths (e.g., loading models, saving logs) use valid local paths.

---

## 🚀 Running the Project

### 1. Start the ML Backend

Navigate to the accident_prd folder of the project and run:

```bash
python app3.py
```
Navigate to the flutter folder directory

```bash
flutter run
