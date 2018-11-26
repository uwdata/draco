import read from 'datalib/src/import/read';
import dlstats from 'datalib/src/stats';

export interface Schema {
  stats: any;
  size: number;
}

export default function data2schema(data: any[]): Schema {
  const readData = read(data);
  const summary = dlstats.summary(readData);

  const keyedSummary = {};
  summary.forEach((column: any) => {
    const field = column.field;
    delete column.field;
    keyedSummary[field] = column;
  });

  return {
    stats: keyedSummary,
    size: data.length,
  };
}
