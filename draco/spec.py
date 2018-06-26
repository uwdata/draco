'''
Tasks, Encoding, and Query helper classes for draco.
'''

import json
import logging
import os
from collections import defaultdict
from copy import deepcopy
from typing import Any, Dict, Iterable, List, Optional, Tuple, Union

import agate
import numpy as np
import pandas as pd
import scipy.stats as stats
from agate.table import Table
from clyngor.answers import Answers
from random_words import RandomWords

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

HOLE = '?' # I want the system to fill something for this
NULL = 'null' # I don't want the system fill anything in this place
# if it is None, the system decide itself whether to fill it and what to fill

def normalize_field_name(s: Optional[str]) -> Optional[str]:
    # normalize the field
    if s is HOLE or s is NULL or s is None:
        return s
    else:
        return s.replace(' ', '_').lower()

def recover_field_name(s:str, field_names: List[str]) -> str:
    """ recover fields for visualization purpose """
    for k in field_names:
        if normalize_field_name(k) == s:
            return k
    return s


class Field():

    def __init__(self, name: str, ty: str,
                 cardinality: Optional[int] = None,
                 entropy: Optional[float] = None,
                 extent: Optional[Tuple[float, float]] = None,
                 interesting: Optional[bool] = None) -> None:

        if cardinality is not None:
            assert cardinality > 0

        if entropy is not None:
            assert entropy >= 0

        self.name = name

        # column data type, should be a string represented type,
        # one of ('string', 'number', 'datetime', 'boolean')
        self.ty = ty
        self.cardinality = cardinality
        self.entropy = entropy
        self.extent = extent
        self.interesting = interesting

    @staticmethod
    def from_obj(obj: Dict[str, Any]):
        ''' Build a field from a field represented as a dictionary. '''
        return Field(
            obj['name'],
            obj['type'],
            obj.get('cardinality'),
            obj.get('entropy'),
            obj.get('extent'),
            obj.get('interesting'))

    def to_asp(self) -> str:
        name = normalize_field_name(self.name)
        asp_str = f'fieldtype({name},{self.ty}).\n'
        if self.cardinality is not None:
            asp_str += f'cardinality({name},{self.cardinality}).\n'
        if self.entropy is not None:
            # asp only supports integers
            asp_str += f'entropy({name},{int(self.entropy * 10)}).\n'
        if self.extent is not None:
            # asp only supports integers
            lo, hi = self.extent
            mult = 1
            if isinstance(lo, float) or isinstance(hi, float) and lo < 10 and hi < 10:
                # TODO: make this better
                mult = 100
                lo *= mult
                hi *= mult
            asp_str += f'extent({name},{int(lo)},{int(hi)}).\n'
        if self.interesting == True:
            asp_str += f'interesting({name}).\n'
        return asp_str

    def __str__(self):
        return f'<{self.name},{self.ty},{self.cardinality},{self.entropy},{self.interesting}>'


class Data():

    def __init__(self,
                 fields: Iterable[Field],
                 size: Optional[int] = None,
                 content: Optional[Iterable[Any]] = None,
                 url: Optional[str] = None) -> None:

        if size is not None:
            assert size > 0

        self.fields = fields
        self.size = size
        self.content = content
        self.url = url

    @staticmethod
    def from_obj(obj: Dict[str, str], path_prefix: Optional[str] = None) -> 'Data':
        ''' Build a data object from a dict-represented
            Vega-Lite object represting data'''
        if 'url' in obj:
            # load data from url
            file_path = obj['url']
            if path_prefix is not None:
                file_path = os.path.join(path_prefix, file_path)
            if file_path.endswith("csv"):
                return Data.from_csv(file_path)
            elif file_path.endswith("json"):
                return Data.from_json(file_path)
            else:
                raise Exception('The data format is not recognized.')
        else:
            # a dict represented data already included in the file
            return Data.from_agate_table(agate.Table.from_object(obj['values']))

    @staticmethod
    def from_csv(filename: str) -> 'Data':
        ''' load data form a csv file '''
        table = agate.Table.from_csv(filename)
        dt = Data.from_agate_table(table)
        dt.url = filename
        return dt

    @staticmethod
    def from_json(filename: str) -> 'Data':
        ''' load from json file '''
        table = agate.Table.from_json(filename)
        dt = Data.from_agate_table(table)
        dt.url = filename
        return dt

    @staticmethod
    def from_agate_table(agate_table: Table) -> 'Data':
        ''' Create a Data object from an agate table,
            data content and datatypes are based on how agate interprets them
        '''
        fields: List[Field] = []

        for column in agate_table.columns:
            agate_type = column.data_type
            type_name = 'string'

            data = column.values_without_nulls()

            entropy = None
            extent = None

            if isinstance(agate_type, agate.Text):
                type_name = 'string'
                _, dist = np.unique(data, return_counts=True)
                dist = dist / np.sum(dist)
                entropy = stats.entropy(dist)
            elif isinstance(agate_type, agate.Number):
                type_name = 'number'
                h = np.histogram(np.array(data).astype(float), 100)
                entropy = stats.entropy(h[0])
                # clip to int32
                extent = [max(np.min(data), -2147483647), min(np.max(data), 2147483647)]
            elif isinstance(agate_type, agate.Boolean):
                type_name = 'boolean'
                _, dist = np.unique(data, return_counts=True)
                dist = dist / np.sum(dist)
                entropy = stats.entropy(dist)
            elif isinstance(agate_type, agate.Date):
                type_name = 'datetime' # FIXME
            elif isinstance(agate_type, agate.DateTime):
                type_name = 'datetime'

            fields.append(Field(column.name, type_name, len(set(data)), entropy, extent))

        # store the table into a dict
        content = []
        for row in agate_table.rows:
            row_obj = {}
            for j, c in enumerate(row):
                row_obj[fields[j].name] = str(c)
            content.append(row_obj)
        return Data(fields, len(agate_table), content=content)

    def fill_with_random_content(self, defaut_size=10, override=False):
        """ Fill the data with randomly generated data if the content its content is empty """

        # fix seed so we always get the same data
        np.random.seed(42)

        if not override:
            assert self.content is None

        size = self.size or defaut_size

        df = pd.DataFrame()

        rw = RandomWords()

        for f in self.fields:
            cardinality = f.cardinality or size
            if f.ty == "number":
                if f.cardinality > 0.8*size:  # almost unique
                    if f.extent:
                        lower, upper = f.extent
                        mu, sigma = 5, 0.7
                        data = stats.truncnorm((lower - mu) / sigma, (upper - mu) / sigma, loc=mu, scale=sigma).rvs(size)
                    else:
                        entropy = min((f.entropy or 0.5) / 4, 1)
                        he = int(size * entropy)
                        le = size - he
                        data = np.concatenate([np.random.normal(loc=1, scale=0.35, size=le), np.random.uniform(0, 2, size=he)])
                    data = list(map(lambda v: round(v, 4), data))
                else:  # probably some kind of ordinal
                    if f.extent:
                        l = np.random.randint(low=f.extent[0], high=f.extent[1], size=cardinality)
                    else:
                        l = np.random.randint(0, cardinality * 1.5, size=cardinality)
                    data = np.random.choice(l, size=size)
            elif f.ty == "string":
                l = rw.random_words(count=cardinality)
                data = np.random.choice(l, size=size)
            elif f.ty == "boolean":
                data = np.random.choice([True, False], size=size)
            df[f.name] = data

        self.content = list(df.T.to_dict().values())


    def __len__(self):
        return self.size

    def get_field_names(self):
        return [f.name for f in self.fields]

    def to_compassql(self):
        return self.to_vegalite() # same as to_vegalite function

    def to_vegalite(self) -> Dict[str, Any]:
        if self.url :
            return {'url': self.url}
        else:
            return {'values': self.content}

    def to_asp(self) -> str:
        asp = ''

        if self.url is not None:
            asp += f"data(\"{self.url}\").\n\n"

        if self.size is not None:
            asp += f'num_rows({self.size}).\n\n'

        return asp + '\n'.join([x.to_asp() for x in self.fields])


class Encoding():

    # keep track of what encodings we have already generated
    encoding_cnt = 0

    @staticmethod
    def gen_encoding_id() -> str:
        enc = f'e{Encoding.encoding_cnt}'
        Encoding.encoding_cnt += 1
        return enc

    @staticmethod
    def from_obj(obj: Dict[str, Any]) -> 'Encoding':
        ''' load encoding from a dict object representing the spec content
            Args:
                obj: a dict object representing channel encoding
            Returns:
                an encoding object
        '''

        def remove_if_star(v):
            return v if v != '*' else None

        scale = obj.get('scale')

        # bin can be bool or object
        binning = obj.get('bin')
        if isinstance(binning, dict):
            binning = binning['maxbins']

        # set log to true if set, and false if type type is not log
        log = None
        if scale and 'type' in scale.keys():
            log = scale['type'] == 'log'

        # if zero is not specified in ASP, then it means False and 
        # we need to set it to False in vegalite spec (if we don't set it in vegalite, the default would be true)
        zero = scale.get('zero') if scale else None
        if obj.get('type') == 'quantitative' and not binning:
            zero = True if zero is None else zero

        return Encoding(
            obj.get('channel'),
            remove_if_star(obj.get('field')),
            obj.get('type'),
            obj.get('aggregate'),
            binning,
            log,
            zero,
            obj.get('stack'))

    @staticmethod
    def from_cql(obj: Dict[str, Any]) -> 'Encoding':
        ''' load encoding from a dict object representing the spec content
            Args:
                obj: a dict object representing channel encoding
            Returns:
                an encoding object
        '''
        def subst_if_hole(v):
            return v if v != HOLE else None

        def remove_if_star(v):
            return v if v != '*' else None

        scale = subst_if_hole(obj.get('scale'))

        binning = subst_if_hole(obj.get('bin'))
        if binning and isinstance(binning, dict):
            binning = binning['maxbins']

        return Encoding(
            subst_if_hole(obj.get('channel')),
            remove_if_star(subst_if_hole(obj.get('field'))),
            subst_if_hole(obj.get('type')),
            subst_if_hole(obj.get('aggregate')),
            binning,
            subst_if_hole(scale.get('type')) == 'log' if scale else None,
            subst_if_hole(scale.get('zero')) if scale else None,
            subst_if_hole(obj.get('stack')))

    @staticmethod
    def parse_from_answer(encoding_id: str, encoding_props: Dict) -> 'Encoding':
        # if zero is not specified in ASP, then it means False and 
        # we need to set it to False in vegalite spec (if we don't set it in vegalite, the default would be true)
        zero = encoding_props.get('zero')
        if encoding_props['type'] == 'quantitative':
            zero = False if zero is None else zero
        return Encoding(
            encoding_props['channel'],
            encoding_props.get('field'),
            encoding_props['type'],
            encoding_props.get('aggregate'),
            encoding_props.get('bin'),
            encoding_props.get('log_scale'),
            zero,
            encoding_props.get('stack'),
            encoding_id)

    def __init__(self,
                 channel: Optional[str] = None,
                 field: Optional[str] = None,
                 ty: Optional[str] = None,
                 aggregate: Optional[str] = None,
                 binning: Optional[Union[int, bool]] = None,
                 log_scale: Optional[bool] = None,
                 zero: Optional[bool] = None,
                 stack: Optional[str] = None,
                 idx: Optional[str] = None) -> None:
        self.channel = channel
        self.field = field
        self.ty = ty
        self.aggregate = aggregate
        self.binning = binning
        self.log_scale = log_scale
        self.zero = zero
        self.stack = stack  # null will be treated as false
        self.id = idx if idx is not None else Encoding.gen_encoding_id()

    def to_compassql(self):
        # if it is None, we would not ask compassql to suggest
        encoding = {}
        if self.channel:
            encoding['channel'] = self.channel
        if self.field:
            encoding['field'] = self.field
        if self.ty:
            encoding['type'] = self.ty
        if self.aggregate:
            encoding['aggregate'] = self.aggregate
        if self.binning:
            encoding['bin'] = {'maxbins' : self.binning}
        if self.stack:
            encoding['stack'] = self.stack
        #TODO: log and zeros seems not supported by compassql?
        return encoding

    def to_vegalite(self, field_names=None):
        encoding = {
            'scale': {}
        }

        if self.field:
            if field_names is not None:
                encoding['field'] = recover_field_name(self.field, field_names)
            else:
                encoding['field'] = self.field
        if self.ty:
            encoding['type'] = self.ty
        if self.aggregate:
            encoding['aggregate'] = self.aggregate
        if self.binning:
            encoding['bin'] = {'maxbins' : self.binning}
        if self.log_scale:
            encoding['scale']['type'] = 'log'
        if self.stack:
            encoding['stack'] = self.stack

        if self.zero:
            encoding['scale']['zero'] = self.zero

        if not encoding['scale']:
            del encoding['scale']

        return encoding

    def to_asp(self) -> str:
        # generate asp query

        constraints = [f'encoding({self.id}).']

        def collect_val(prop: str, prop_type: str, value: Optional[Union[str, int]]): # collect a field with value
            if value is None: # ask the system to decide whether to fit
                pass
            elif value == NULL: # we do not want to fit anything in
                constraints.append(f':- {prop}({self.id},_).')
            elif value == HOLE: # we would fit something in
                constraints.append(f'1 = {{ {prop}({self.id},P): {prop_type}(P) }}.')
            else: #the value is already supplied
                constraints.append(f'{prop}({self.id},{value}).')

        def collect_boolean_val(prop, value): # collect a boolean field with value
            if value == True or (value == HOLE): # the value is set to True
                constraints.append(f'{prop}({self.id}).')
            elif value == False or (value == NULL): # we want to disable this
                constraints.append(f':- {prop}({self.id}).')
            elif value is None:
                pass

        collect_val('channel', 'channel', self.channel)

        field_name = normalize_field_name(self.field)
        collect_val('field', 'field', field_name)

        collect_val('type', 'type', self.ty)
        collect_val('aggregate', 'aggregate_op', self.aggregate)
        collect_val('stack', 'stacking', self.stack)

        if self.binning == True:
            collect_val('bin', 'binning', HOLE)
        elif self.binning == False:
            collect_val('bin', 'binning', NULL)
        else:
            collect_val('bin', 'binning', self.binning)

        collect_boolean_val('log', self.log_scale)
        collect_boolean_val('zero', self.zero)

        return  '\n'.join(constraints) + '\n'


class Query():

    def __init__(self, mark: Optional[str], encodings: Iterable[Encoding] = None) -> None:
        # channels include 'x', 'y', 'color', 'size', 'shape', 'text', 'detail'
        self.mark = mark
        self.encodings = encodings if encodings is not None else []

    @staticmethod
    def from_obj(query_spec: Dict) -> 'Query':
        ''' Parse from a query object that uses a list for encoding. '''
        mark = query_spec.get('mark')
        # compassql uses "encodings" but some of our previous versions use encoding
        encoding_key = "encoding" if ("encoding" in query_spec) else "encodings"
        encodings = list(map(Encoding.from_obj, query_spec.get(encoding_key, [])))
        return Query(mark, encodings)

    @staticmethod
    def from_cql(query_spec: Dict) -> 'Query':
        ''' Parse from a compassql encoding object '''
        mark = query_spec.get('mark')
        encodings = list(map(Encoding.from_cql, query_spec.get("encodings", [])))
        return Query(mark, encodings)

    @staticmethod
    def from_vegalite(full_spec: Dict) -> 'Query':
        ''' Parse from Vega-Lite spec that uses map for encoding. '''
        full_spec = deepcopy(full_spec)

        encodings: List[Encoding] = []

        encoding = full_spec.get('encoding', {})

        mark = full_spec['mark']

        # bar and area automatically stack if there is a group by
        if mark == 'bar' or mark == 'area':
            need_stack = any(
                c in encoding and (encoding.get(c)['type'] in ['ordinal', 'nominal'] or encoding.get(c).get('bin'))
                    for c in ['color', 'detail']
            )

            if need_stack:
                for c in ['x', 'y']:
                    if c in encoding and (encoding[c]['type'] == 'quantitative' and not encoding[c].get('bin')):
                        if not encoding[c].get('stack') and encoding[c].get('aggregate') in [None, 'sum', 'count']:
                            encoding[c]['stack'] = 'zero'

        for channel, enc in encoding.items():
            enc['channel'] = channel

            # fix binning as the default is 10
            if enc.get('bin') == True or enc.get('bin') == {}:
                enc['bin'] = {'maxbins': 10}

            if not enc.get('scale'):
                enc['scale'] = {}

            # zero is the default for quantitative not binned (and always for size)
            if enc.get('type') == 'quantitative':
                if channel == 'size':
                    enc['scale']['zero'] = True
                elif not enc.get('bin'):
                    enc['scale']['zero'] = True

            # TODO: other defaults

            encodings.append(Encoding.from_obj(enc))

        return Query(mark, encodings)

    def to_compassql(self):
        query = {}
        if self.mark is None or self.mark is True:
            query["mark"] = '?'
        else:
            query["mark"] = self.mark
        query["encodings"] = []
        for e in self.encodings:
            query["encodings"].append(e.to_compassql())
        return query

    def to_vegalite(self, field_names=None):
        query = {}
        query['mark'] = self.mark
        query['encoding'] = {}
        for e in self.encodings:
            query['encoding'][e.channel] = e.to_vegalite(field_names)
        return query

    def to_asp(self) -> str:
        # the asp constraint comes from both mark and encodings
        prog = ''
        if self.mark is not None and (self.mark != HOLE):
            prog += f'mark({self.mark}).\n\n'
        prog += '\n'.join(list(map(lambda e: e.to_asp(), self.encodings)))
        return prog


class Task():

    def __init__(self,
                 data: Data,
                 query: Query,
                 task: Optional[str] = None,
                 cost: Optional[int] = None,
                 violations: Optional[Dict[str, int]] = None) -> None:
        self.data = data
        self.query = query
        self.task = task
        self.violations = violations
        self.cost = cost

    @staticmethod
    def from_obj(query_spec, data_dir: Optional[str]=None) -> 'Task':
        ''' from a dict_obj '''
        data = Data.from_obj(query_spec['data'], path_prefix=data_dir)
        query = Query.from_obj(query_spec)
        return Task(data, query)

    @staticmethod
    def from_cql(query_spec, data_dir: Optional[str]=None) -> 'Task':
        ''' from a compassql query'''
        data = Data.from_obj(query_spec['data'], path_prefix=data_dir)
        query = Query.from_cql(query_spec)
        return Task(data, query)

    @staticmethod
    def from_vegalite(full_spec: Dict, data_dir: Optional[str]=None) -> 'Task':
        """ load a task from a vegalite object """
        data = Data.from_obj(full_spec["data"], path_prefix=data_dir)
        query = Query.from_vegalite(full_spec)
        return Task(data, query)

    @staticmethod
    def parse_from_answer(clyngor_answer: Answers, 
                          data: Data, 
                          task: Optional[str] = None, 
                          cost: Optional[int] = None) -> 'Task':
        encodings: List[Encoding] = []
        mark = None

        raw_encoding_props: Dict = defaultdict(dict)
        violations: Dict[str, int] = defaultdict(int)

        for (head, body), in clyngor_answer:
            if head == 'mark':
                mark = body[0]
            elif head == 'cost':
                cost = int(body[0])
            elif head == 'violation':
                violations[body[0]] += 1
            elif head == "data":
                # the asp program includes data information
                pass
            else:
                # collect encoding properties
                raw_encoding_props[body[0]][head] = body[1] if len(body) > 1 else True

        # generate encoding objects from each collected encodings
        for k, v in raw_encoding_props.items():
            encodings.append(Encoding.parse_from_answer(k, v))

        query = Query(mark, encodings)

        return Task(data, query, task=task, cost=cost, violations=violations)

    def to_compassql(self):
        ''' generate compassql from task'''
        result = self.query.to_compassql()
        result['data'] = self.data.to_vegalite()
        return result

    def to_vegalite(self):
        ''' generate a vegalite spec from the object '''
        result = self.query.to_vegalite(self.data.get_field_names())
        result['data'] = self.data.to_vegalite()
        result['$schema'] = 'https://vega.github.io/schema/vega-lite/v2.json'
        return result

    def to_vegalite_json(self) -> str:
        ''' generate a vegalite json file form the object '''
        return json.dumps(self.to_vegalite(), sort_keys=True, indent=4)

    def to_asp(self) -> str:
        ''' generate asp constraints from the object '''
        asp_str = '% ====== Data definitions ======\n'
        asp_str += self.data.to_asp() + '\n\n'
        asp_str += '% ====== Query constraints ======\n'
        asp_str += self.query.to_asp() + '\n\n'
        if self.task:
            asp_str += '% ====== Task constraint ======\n'
            asp_str += f'task({self.task}).\n\n'
        return asp_str


class AspTask(Task):
    '''
    Mock task that has the ASP in it already.
    '''

    def __init__(self, asp: str) -> None:
        self.asp = asp
        super(AspTask, self).__init__(Data([], url='__none__'), Query(None, None), None, None, None)

    def to_asp(self):
        return self.asp

    def to_vegalite_json(self):
        raise NotImplementedError

    def to_vegalite(self):
        raise NotImplementedError

    def to_compassql(self):
        raise NotImplementedError

import re

if __name__ == '__main__':

    # convert compassql examples from vegalite->asp and asp->vegalite

    vl_dir = "../data/compassql_examples/output"
    data_dir = ".."

    vl_specs = []
    asp_specs = []

    for fname in os.listdir(vl_dir):
        if fname.endswith(".json"): 
            full_fname = os.path.join(vl_dir, fname)
            with open(full_fname, "r") as f:

                Encoding.encoding_cnt = 0

                content = "".join(f.readlines())
                task = Task.from_vegalite(json.loads(content), data_dir)
                vl_str = json.dumps(task.to_vegalite())
                vl_specs.append(json.loads(vl_str.replace("../data/", "data/")))

                field_names = task.data.get_field_names()

                asp_str = task.to_asp()
                data_decl = re.search('data(.+).', asp_str)
                if data_decl:
                    data_decl_str = ("data" + data_decl.group(1) + ".\n").replace("../data/", "data/")
                    # split into list
                    asp_list = list(filter(lambda x: x != "", 
                                     map(lambda x: x.strip(),
                                         (data_decl_str + asp_str[asp_str.index("mark("):]).split("\n"))))
                
                def recover_field_name_asp(asp_fact, field_names):
                    if asp_fact.startswith("field("):
                        splits = asp_fact.split(",")
                        return f'{splits[0]},"{recover_field_name(splits[1][:-1], field_names)}")'
                    return asp_fact

                # remove "." from each asp fact
                asp_specs.append([recover_field_name_asp(x[:-1], field_names) for x in asp_list])

    vl_specs_str = "export const vlSpecs : TopLevelFacetedUnitSpec[] = {};".format(json.dumps(vl_specs))
    asp_specs_str = "export const aspSpecs = {};".format(json.dumps(asp_specs))

    print("import { TopLevelFacetedUnitSpec } from 'vega-lite/build/src/spec';")
    print(vl_specs_str)
    print("")
    print(asp_specs_str)



