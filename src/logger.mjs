const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const END = "\x1b[0m";

const PREFIX = "[repox]";

export const logger = {
  info: (...args) => console.log(PREFIX, ...args),
  error: (...args) => {
    console.error(`${RED}${PREFIX}`, ...args, END);
  },
  success: (...args) => {
    console.log(`${GREEN}${PREFIX}`, ...args, END);
  },
  warn: (...args) => {
    console.warn(`${YELLOW}${PREFIX}`, ...args, END);
  },
};
