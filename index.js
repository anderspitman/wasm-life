import fs from 'fs';
import { run } from './run.js';

const data = fs.readFileSync('./life.wasm');
run(data);
