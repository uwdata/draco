#!/usr/bin/env python3

from spec import *
import json
import argparse


def main():
    task = Task.load_from_vl_json("examples/ab.vl.json")
    print(task.to_asp())
    print(task.to_vl_json())
    
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.parse_args()
    main()
