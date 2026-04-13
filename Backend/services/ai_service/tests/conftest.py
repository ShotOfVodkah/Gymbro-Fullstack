import os

if not os.environ.get("JWT_SECRET", "").strip():
    os.environ["JWT_SECRET"] = "test-jwt-secret-for-ci"
