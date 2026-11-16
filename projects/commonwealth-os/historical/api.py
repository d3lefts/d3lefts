"""Read-only historical dashboard API backed solely by shipped fictional fixtures."""
from __future__ import annotations

import os
from pathlib import Path
from typing import Annotated

from fastapi import FastAPI, HTTPException, Query, Request
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from .engine import HistoricalEngine, SyntheticOnlyError, valid_date

ROOT = Path(__file__).resolve().parent


def create_app(db_path: str | None = None) -> FastAPI:
    # Synthetic-only database is intentionally disjoint from both governance backends.
    engine = HistoricalEngine(db_path or os.environ.get('CW_HIST_DB_PATH',
                               str(ROOT / 'historical-synthetic.sqlite3')))
    web_dir = ROOT / 'web'
    app = FastAPI(title='Commonwealth Historical Intelligence — Synthetic Only',
                  version='0.1.0', docs_url=None, redoc_url=None)

    app.mount('/living-voter/assets', StaticFiles(directory=str(web_dir)), name='living_voter_assets')

    @app.get('/living-voter', include_in_schema=False)
    def living_voter():
        return FileResponse(str(web_dir / 'index.html'))

    @app.middleware('http')
    async def safe_headers(request: Request, call_next):
        response = await call_next(request)
        response.headers['Cache-Control'] = 'no-store'
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Commonwealth-Data-Mode'] = 'SYNTHETIC_ONLY'
        if request.url.path.startswith('/living-voter'):
            response.headers['Content-Security-Policy'] = (
                "default-src 'none'; script-src 'self'; style-src 'self'; "
                "connect-src 'self'; img-src 'self'; base-uri 'none'; "
                "form-action 'none'; frame-ancestors 'none'")
        else:
            response.headers['Content-Security-Policy'] = "default-src 'none'; frame-ancestors 'none'"
        return response

    @app.get('/api/v1/historical/health')
    def health():
        return {'status': 'ok', 'data_mode': 'SYNTHETIC_ONLY',
                'real_government_data_connected': False,
                'external_source_adapters_enabled': False,
                'official_ballots_supported': False}

    @app.get('/api/v1/historical/sources')
    def sources():
        return {'data_mode': 'SYNTHETIC_ONLY', 'sources': engine.sources()}

    @app.get('/api/v1/historical/issues')
    def issues():
        return {'data_mode': 'SYNTHETIC_ONLY', 'issues': engine.issues()}

    @app.get('/api/v1/historical/representatives')
    def representatives(chamber: str, district: str,
                        as_of: str = '2025-06-01'):
        try:
            members = engine.representative_history(chamber, district, as_of)
        except (ValueError, SyntheticOnlyError) as exc:
            raise HTTPException(422, str(exc)) from exc
        return {'data_mode': 'SYNTHETIC_ONLY', 'chamber': chamber,
                'district': district, 'as_of': as_of,
                'representatives': members, 'complete_history': False}

    @app.get('/api/v1/historical/votes/{record_id}')
    def vote(record_id: str):
        record = engine.record(record_id)
        if record is None:
            raise HTTPException(404, 'No such fictional vote record')
        return {'data_mode': 'SYNTHETIC_ONLY', 'record': record}

    @app.get('/api/v1/historical/dashboard')
    def dashboard(issue_id: str | None = None, chamber: str | None = None,
                  house_district: str = '07',
                  municipal_ward: str = '02', as_of: str = '2025-12-31',
                  limit: Annotated[int, Query(ge=1, le=100)] = 20,
                  offset: Annotated[int, Query(ge=0, le=100000)] = 0):
        try:
            return engine.dashboard(issue_id=issue_id, house_district=house_district,
                                    municipal_ward=municipal_ward, as_of=as_of,
                                    limit=limit, offset=offset, chamber=chamber)
        except KeyError as exc:
            raise HTTPException(404, str(exc)) from exc
        except (ValueError, SyntheticOnlyError) as exc:
            raise HTTPException(422, str(exc)) from exc

    return app


app = create_app()
