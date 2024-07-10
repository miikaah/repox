import { cli } from "./cli.mjs";

const [, , ...restargs] = process.argv;

cli(...restargs);
