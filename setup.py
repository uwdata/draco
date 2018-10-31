#!/usr/bin/env python

from codecs import open
from os.path import abspath, dirname, join
from subprocess import call

from setuptools import Command, setup

from draco import __version__

this_dir = abspath(dirname(__file__))
with open(join(this_dir, 'README.md'), encoding='utf-8') as file:
    long_description = file.read()


class RunTests(Command):
    '''Run all tests.'''
    description = 'run tests'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        '''Run all tests!'''

        print('=> Running Ansunit Tests:')

        errno_ansunit = call(['ansunit', 'asp/tests.yaml', '-v'])

        print('\n\n=> Running Python Tests:')
        errno_pytest = call(['pytest', 'tests', '--cov=draco', '--cov-report=term-missing'])

        print('\n\n=> Running MyPy:')
        errno_mypy = call(['mypy', 'draco', 'tests', '--ignore-missing-imports'])

        raise SystemExit(errno_ansunit + errno_pytest + errno_mypy)


setup(name='draco',
      version=__version__,
      description='Visualization recommendation using constraints',
      long_description=long_description,
      author='Dominik Moritz, Chenglong Wang',
      author_email='domoritz@cs.washington.edu, clwang@cs.washington.edu',
      license='BSD-3',
      url='https://github.com/uwdata/draco',
      packages = ['draco'],
      entry_points = {
        'console_scripts': [
            'draco=draco.cli:main',
        ],
      },
      extras_require = {
        'test': ['coverage', 'pytest', 'pytest-cov'],
      },
      cmdclass = {'test': RunTests},
     )
