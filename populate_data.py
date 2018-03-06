import json
import argparse

def main(args):
    with open(args.file) as f:
        data = json.load(f)
        populate(data, args.data_url)

        with open(args.file, 'w') as outfile:
            json.dump(data, outfile, indent=4)

def populate(data, data_url):
    if (is_spec(data)):
        data['data'] = { 'url': data_url }
    else:
        if (type(data) is dict):
            for child in data:
                populate(data[child], data_url)
        elif (type(data) is list):
            for child in data:
                populate(child, data_url)

    return

def is_spec(data):
    return (type(data) is dict) and ('mark' in data and 'encoding' in data)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='the json containing specs')
    parser.add_argument('data_url', help='the url to insert as data')

    args = parser.parse_args()
    main(args)

