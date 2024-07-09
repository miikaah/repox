import * as utils from "./util.mjs";

const PREFIX = "[repox]";

export const logger = {
  info: (...args) => console.log(PREFIX, ...args),
  error: (...args) => {
    console.error(`${utils.RED}${PREFIX}`, ...args, utils.END);
  },
  success: (...args) => {
    console.log(`${utils.GREEN}${PREFIX}`, ...args, utils.END);
  },
  warn: (...args) => {
    console.warn(`${utils.YELLOW}${PREFIX}`, ...args, utils.END);
  },
};
