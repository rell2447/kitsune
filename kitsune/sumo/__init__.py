class ProgrammingError(Exception):
    """Somebody made a mistake in the code."""


# Just importing monkeypatch does the trick - don't remove this line
from kitsune.sumo import monkeypatch
