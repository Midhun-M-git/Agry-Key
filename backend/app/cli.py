"""Developer and Operator CLI management commands for Agry-Key backend."""

import argparse
import logging
import sys

from app.core.config import settings
from app.core.database import SessionLocal, engine, Base
from sqlalchemy import text, inspect

logger = logging.getLogger(__name__)


def check_demo_data() -> bool:
    """Verifies whether any rows with source_id == 'demo_seed' exist in any table."""
    db = SessionLocal()
    has_demo_data = False
    try:
        inspector = inspect(engine)
        for table_name in inspector.get_table_names():
            columns = [c["name"] for c in inspector.get_columns(table_name)]
            if "source_id" in columns:
                count = db.execute(
                    text(f"SELECT COUNT(*) FROM {table_name} WHERE source_id = 'demo_seed'")
                ).scalar() or 0
                if count > 0:
                    logger.critical(
                        f"CRITICAL: Table '{table_name}' contains {count} demo_seed rows."
                    )
                    has_demo_data = True
    finally:
        db.close()
    return has_demo_data


def seed_demo_data():
    """Manual developer CLI command to seed demo data. Strictly disallowed in production."""
    if getattr(settings, "is_deployed", False):
        print(f"ERROR: Cannot seed demo data in deployed environment '{settings.ENVIRONMENT}'.", file=sys.stderr)
        sys.exit(1)

    from scripts.seed_db import seed_database
    seed_database()
    print("Demo database seeding complete.")


def main():
    parser = argparse.ArgumentParser(description="Agry-Key Backend CLI Management Tool")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    subparsers.add_parser("seed-demo", help="Seed developer demonstration data (non-production only)")
    subparsers.add_parser("verify-clean", help="Check database for demo_seed rows (fails if found)")

    args = parser.parse_args()

    if args.command == "seed-demo":
        seed_demo_data()
    elif args.command == "verify-clean":
        if check_demo_data():
            print("FAILED: Database contains demo seed data.", file=sys.stderr)
            sys.exit(1)
        else:
            print("PASSED: Database is clean of demo seed data.")
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
