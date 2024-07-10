import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { logger } from "./logger.mjs";
import * as util from "./util.mjs";

const DEFAULT_CONFIG_DIRNAME = ".repox";
const DEFAULT_CONFIG_DIR = path.join(os.homedir(), DEFAULT_CONFIG_DIRNAME);
const DEFAULT_CONFIG_FILENAME = "repoxSettings.json";
const DEFAULT_CONFIG_FILE = path.join(
  DEFAULT_CONFIG_DIR,
  DEFAULT_CONFIG_FILENAME,
);
const DEFAULT_CONFIG = {
  repodir: "",
  repolist: [],
};

export const readConfig = async () => {
  try {
    const file = await fs.readFile(DEFAULT_CONFIG_FILE).catch(async (err) => {
      if (err.code === "ENOENT") {
        logger.warn("Config file doesn't exist");

        if (!(await util.dirExists(DEFAULT_CONFIG_DIR))) {
          await fs.mkdir(DEFAULT_CONFIG_DIR);
          logger.success(`Created ${DEFAULT_CONFIG_DIR}`);
        }

        await writeConfig(DEFAULT_CONFIG);
        logger.success(`Wrote config file to ${DEFAULT_CONFIG_FILE}`);
        return JSON.stringify(DEFAULT_CONFIG, null, 2);
      }
      throw err;
    });

    return JSON.parse(file);
  } catch (error) {
    logger.error("Failed to read config file", error);
    process.exit(1);
  }
};

export const writeConfig = async (config) => {
  try {
    await fs.writeFile(DEFAULT_CONFIG_FILE, JSON.stringify(config, null, 2));
  } catch (error) {
    logger.error("Failed to write config file", error);
    process.exit(1);
  }
};
