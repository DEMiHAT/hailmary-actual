"""
Thread-safe JSON file storage utility.
Handles reading/writing JSON files with proper error handling
and automatic file creation.
"""

import json
import os
import threading
from pathlib import Path
from typing import Any

# Base data directory
DATA_DIR = Path(__file__).parent.parent / "data"

# Thread lock for file operations
_file_lock = threading.Lock()


def _ensure_data_dir():
    """Create the data directory if it doesn't exist."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)


def read_json(filename: str) -> list | dict:
    """
    Read and return data from a JSON file.
    Creates the file with an empty list if it doesn't exist.

    Args:
        filename: Name of the JSON file (e.g., 'records.json')

    Returns:
        Parsed JSON data (list or dict)
    """
    _ensure_data_dir()
    filepath = DATA_DIR / filename

    with _file_lock:
        if not filepath.exists():
            # Create with empty list as default
            with open(filepath, "w", encoding="utf-8") as f:
                json.dump([], f)
            return []

        try:
            with open(filepath, "r", encoding="utf-8") as f:
                data = json.load(f)
            return data
        except (json.JSONDecodeError, IOError):
            # If file is corrupted, return empty list
            return []


def write_json(filename: str, data: Any) -> None:
    """
    Write data to a JSON file atomically.

    Args:
        filename: Name of the JSON file
        data: Data to serialize (must be JSON-serializable)
    """
    _ensure_data_dir()
    filepath = DATA_DIR / filename

    with _file_lock:
        # Write to temp file first, then rename for atomicity
        tmp_path = filepath.with_suffix(".tmp")
        try:
            with open(tmp_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False, default=str)
            # Atomic rename (on Windows, need to remove target first)
            if filepath.exists():
                filepath.unlink()
            tmp_path.rename(filepath)
        except Exception:
            # Clean up temp file on error
            if tmp_path.exists():
                tmp_path.unlink()
            raise


def append_json(filename: str, item: dict) -> None:
    """
    Append a single item to a JSON array file.

    Args:
        filename: Name of the JSON file
        item: Dictionary to append
    """
    data = read_json(filename)
    if isinstance(data, list):
        data.append(item)
    else:
        data = [item]
    write_json(filename, data)


def get_by_id(filename: str, item_id: str, id_field: str = "id") -> dict | None:
    """
    Find a single record by its ID.

    Args:
        filename: Name of the JSON file
        item_id: ID value to search for
        id_field: Name of the ID field (default: 'id')

    Returns:
        The matching record dict, or None
    """
    data = read_json(filename)
    if isinstance(data, list):
        for item in data:
            if isinstance(item, dict) and item.get(id_field) == item_id:
                return item
    return None


def filter_by_field(filename: str, field: str, value: Any) -> list:
    """
    Filter records by a field value.

    Args:
        filename: Name of the JSON file
        field: Field name to filter on
        value: Expected value

    Returns:
        List of matching records
    """
    data = read_json(filename)
    if isinstance(data, list):
        return [item for item in data if isinstance(item, dict) and item.get(field) == value]
    return []
