import * as ort from 'onnxruntime-web';
import { Imports } from './tensor';
import { Config } from './schema';
export declare function runInference(imageData: ImageData, config: Config, imports: Imports, session: ort.InferenceSession): Promise<ImageData>;
