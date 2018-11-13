import pytest

from draco.cli import create_parser


class TestCli:
    @classmethod
    def setup_class(cls):
        cls.parser = create_parser()

    def test_with_unknown_args(self):
        with pytest.raises(SystemExit):
            self.parser.parse_args(["--foo"])
