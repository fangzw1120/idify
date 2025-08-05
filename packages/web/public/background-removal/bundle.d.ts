export { preload, load };
import { Config } from './schema';
type Entry = {
    url: string | string[];
    size: number;
    mime: string;
};
export declare const MODEL_RESOLUTION: {
    u2netp: number;
    silueta: number;
    imgly_small: number;
    imgly_medium: number;
};
declare function load(key: string, config: Config): Promise<Blob>;
declare function preload(config: Config): Promise<Map<string, Entry>>;
