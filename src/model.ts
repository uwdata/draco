import { Facts, FactsObject, VegaLiteSpecDictionaryObject } from './facts';

export interface ModelObject {
  costs: number[];
  facts: FactsObject;
}

export class Model {
  static toVegaLiteSpecDictionary(model: ModelObject): VegaLiteSpecDictionaryObject {
    return Facts.toVegaLiteSpecDictionary(model.facts);
  }
}
