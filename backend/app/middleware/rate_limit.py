"""In-memory rate limiting middleware per client IP address."""

import time
from collections import defaultdict
from fastapi import Request, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Restricts API request bursts per client IP within a rolling time window."""

    def __init__(self, app, max_requests: int = 120, window_seconds: int = 60):
        super().__init__(app)
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests: dict[str, list[float]] = defaultdict(list)
        self._last_cleanup = time.time()

    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host if request.client else "127.0.0.1"
        now = time.time()

        # Periodic dictionary cleanup every 5 minutes to prevent memory leak
        if now - self._last_cleanup > 300:
            stale_cutoff = now - self.window_seconds
            keys_to_delete = [
                ip for ip, timestamps in self.requests.items()
                if not timestamps or timestamps[-1] < stale_cutoff
            ]
            for ip in keys_to_delete:
                self.requests.pop(ip, None)
            self._last_cleanup = now

        # Evict timestamps outside the active rolling window
        active_timestamps = [
            t for t in self.requests[client_ip] if now - t < self.window_seconds
        ]
        self.requests[client_ip] = active_timestamps

        if len(active_timestamps) >= self.max_requests:
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={"detail": "Too many requests. Please wait a moment before trying again."},
                headers={"Retry-After": str(self.window_seconds)},
            )

        self.requests[client_ip].append(now)
        return await call_next(request)
