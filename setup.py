#!/usr/bin/env python

from setuptools import setup

setup(name='Draco',
      version='0.1',
      description='Visualization recommendation using consraints',
      author='Dominik Moritz, Chenglong Wang',
      author_email='domoritz@cs.washington.edu, clwang@cs.washington.edu',
      license='BSD-3',
      url='https://github.com/domoritz/draco',
      packages=['draco'],
      entry_points={
        'console_scripts':['draco=main:main'],
      },
      setup_requires=['pytest-runner'],
      tests_require=['pytest'],
     )
