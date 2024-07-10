import { execSync } from "node:child_process";
import fs from "node:fs/promises";
import path from "node:path";
import { readConfig, writeConfig } from "./config.mjs";
import { logger } from "./logger.mjs";
import * as utils from "./util.mjs";

export const cli = async (cmd, arg1, ...restargs) => {
  if (!cmd || cmd === "-h" || cmd === "--help" || cmd === "help") {
    console.log("\nRepox commands:\n");
    console.log("help  -h, --help \t Print this help");
    console.log("dir \t\t\t Set repository directory");
    console.log("show \t\t\t Print current config");
    console.log("add \t\t\t Add repositories");
    console.log("remove \t\t\t Remove repositories");
    console.log("empty \t\t\t Remove all repositories");
    console.log();
    console.log("fetch \t\t\t Run git fetch in all repositories");
    console.log("fs \t\t\t Run git fetch && git status in all repositories");
    console.log("status \t\t\t Run git status in all repositories");
    console.log("clean \t\t\t Remove node_modules directory in all repos");
    console.log("install  i \t\t Run npm i in all repos");
    console.log("pull \t\t\t Run git pull --rebase in all repos");
    console.log("pulli \t\t\t Run git pull --rebase && npm i in all repos");
    console.log();
    return;
  }

  if (cmd === "dir") {
    try {
      await fs.stat(arg1);

      const config = await readConfig();
      config.repodir = arg1;
      await writeConfig(config);
      return;
    } catch (error) {
      logger.error("Failed to set repo dir", error);
      process.exit(1);
    }
  }

  if (cmd === "show") {
    try {
      console.log(await readConfig());
      return;
    } catch (error) {
      logger.error("Failed to print config", error);
      process.exit(1);
    }
  }

  if (cmd === "add") {
    try {
      const config = await readConfig();
      const repos = [arg1, ...restargs];

      await fs.stat(config.repodir);
      await fs.stat(path.join(config.repodir, arg1));
      await utils.assertAllReposExist(config.repodir, repos);

      config.repolist = [...config.repolist, ...repos]
        .filter(Boolean)
        .sort((a, b) => a.localeCompare(b));

      await writeConfig(config);
      return;
    } catch (error) {
      logger.error("Failed to add repositories", error);
      process.exit(1);
    }
  }

  if (cmd === "remove") {
    try {
      const config = await readConfig();
      const repos = [arg1, ...restargs];

      config.repolist = config.repolist.filter((repo) => !repos.includes(repo));
      await writeConfig(config);
      return;
    } catch (error) {
      logger.error("Failed to remove repositories", error);
      process.exit(1);
    }
  }

  if (cmd === "empty") {
    try {
      const config = await readConfig();

      config.repolist = [];
      await writeConfig(config);
      return;
    } catch (error) {
      logger.error("Failed to empty repositories", error);
      process.exit(1);
    }
  }

  if (cmd === "fetch") {
    try {
      const { repodir, repolist } = await readConfig();

      utils.runCommandInAllRepos({
        repodir,
        repolist,
        cb: (params) => {
          execSync("git fetch", params);
          utils.logOk();
        },
      });
      return;
    } catch (error) {
      logger.error("Failed to fetch", error);
      process.exit(1);
    }
  }

  if (cmd === "fs") {
    try {
      const { repodir, repolist } = await readConfig();

      utils.runCommandInAllRepos({
        repodir,
        repolist,
        cb: (params) => {
          execSync("git fetch && git status", params);
          utils.logOk();
        },
      });
      return;
    } catch (error) {
      logger.error("Failed to fetch and status", error);
      process.exit(1);
    }
  }

  if (cmd === "status") {
    try {
      const { repodir, repolist } = await readConfig();

      utils.runCommandInAllRepos({
        repodir,
        repolist,
        runIfNotOnDefaultBranch: true,
        cb: ({ cwd, stdio, isOnDefaultBranch }) => {
          execSync("git status", { cwd, stdio });
          if (isOnDefaultBranch) {
            utils.logOk();
          }
        },
      });
      return;
    } catch (error) {
      logger.error("Failed to report status", error);
      process.exit(1);
    }
  }

  if (cmd === "i" || cmd === "install" || cmd === "isntall") {
    try {
      const { repodir, repolist } = await readConfig();

      utils.runCommandInAllRepos({
        repodir,
        repolist,
        cb: (params) => execSync("npm i", params),
      });
      return;
    } catch (error) {
      logger.error("Failed to install", error);
      process.exit(1);
    }
  }

  if (cmd === "clean") {
    try {
      const { repodir, repolist } = await readConfig();

      utils.runCommandInAllRepos({
        repodir,
        repolist,
        cb: (params) => {
          execSync("rm -rf node_modules", params);
          utils.logOk();
        },
      });
      return;
    } catch (error) {
      logger.error("Failed to clean", error);
      process.exit(1);
    }
  }

  if (cmd === "pull") {
    try {
      const { repodir, repolist } = await readConfig();

      utils.runCommandInAllRepos({
        repodir,
        repolist,
        cb: (params) => execSync("git pull --rebase", params),
      });
      return;
    } catch (error) {
      logger.error("Failed to pull", error);
      process.exit(1);
    }
  }

  if (cmd === "pulli") {
    try {
      const { repodir, repolist } = await readConfig();

      utils.runCommandInAllRepos({
        repodir,
        repolist,
        cb: (params) => execSync("git pull --rebase && npm i", params),
      });
      return;
    } catch (error) {
      logger.error("Failed to pull install", error);
      process.exit(1);
    }
  }

  if (cmd) {
    logger.error(`Command "${cmd}" not found`);
    process.exit(1);
  }
};
