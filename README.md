DriveGuard is an intelligent accident detection system that uses machine learning to analyze driving patterns and detect potential accidents in real-time. The system consists of a Flutter mobile application frontend and a Python-based machine learning backend.

driveguard/
├── flutter-app/            # Flutter frontend
│   └── lib/
│       └── ml-section/
│           └── repo/       # Contains API call logic to ML server
├── ml/                     # Python backend (Machine Learning models)
├── app3.py                 # Main server file to run ML backend

Configuration
Before running the application, you need to make the following changes:

Update IP addresses:

In flutter-app/lib/ml-section/repo/ml-repo.dart, update the base URL to your server's IP address

In app.py, update the IP address configuration

Update file paths:
Due to a known bug, absolute paths are used in the code. You'll need to update these paths:

In all ML model files (ml/ directory), update the paths to your dataset and model files

In app.py, update any file paths to match your local system paths



