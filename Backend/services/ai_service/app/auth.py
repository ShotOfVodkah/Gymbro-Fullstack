from __future__ import annotations

import logging
import os

import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

logger = logging.getLogger(__name__)

security = HTTPBearer(auto_error=False)


def require_jwt_secret() -> None:
    secret = os.environ.get("JWT_SECRET", "").strip()
    if not secret:
        raise RuntimeError("JWT_SECRET is not set")


async def get_authenticated_user_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(security),
) -> str:
    if credentials is None or not credentials.credentials.strip():
        raise HTTPException(status_code=401, detail="unauthorized")

    secret = os.environ.get("JWT_SECRET", "").strip()
    if not secret:
        logger.error("JWT_SECRET not configured")
        raise HTTPException(status_code=500, detail="server misconfiguration")

    try:
        payload = jwt.decode(
            credentials.credentials,
            secret,
            algorithms=["HS256"],
        )
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="unauthorized")

    uid = payload.get("user_id")
    if uid is None:
        raise HTTPException(status_code=401, detail="unauthorized")
    return str(uid)
