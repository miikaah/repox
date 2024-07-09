import { execSync } from "node:child_process";
import fs from "node:fs/promises";
import path from "node:path";

export const RED = "\x1b[31m";
export const GREEN = "\x1b[32m";
export const YELLOW = "\x1b[33m";
export const END = "\x1b[0m";

export const greenText = (text) => `${GREEN}${text}${END}`;
export const yellowText = (text) => `${YELLOW}${text}${END}`;

export const logOk = () => console.log(greenText("OK"));

export const dirExists = async (dirpath) => {
  try {
    const stats = await fs.stat(dirpath);
    return stats.isDirectory();
  } catch (err) {
    if (err.code === "ENOENT") {
      return false;
    } else {
      throw err;
    }
  }
};

export const assertAllReposExist = async (repodir, repos) => {
  for (const repo of repos) {
    await fs.stat(path.join(repodir, repo));
  }
};

export const printHeader = (repo) => {
  console.log();
  console.log("---------------------------------------------");
  console.log("Repository: ", repo);
};

export const printFooter = () => {
  console.log("---------------------------------------------");
  console.log();
};

export const checkBranch = (cwd) => {
  const cmd1Output = execSync("git rev-parse --abbrev-ref origin/HEAD", {
    cwd,
  });
  const cmd2Output = execSync("git branch --show-current", { cwd });
  const defaultBranch = cmd1Output.toString().split("/").pop().trim();
  const currentBranch = cmd2Output.toString().trim();
  const isOnDefaultBranch = currentBranch === defaultBranch;

  if (!isOnDefaultBranch) {
    console.warn(yellowText(`Not on default branch "${defaultBranch}"`));
  }

  return isOnDefaultBranch;
};

export const runCommandInAllRepos = ({
  repodir,
  repolist,
  cb,
  runIfNotOnDefaultBranch,
}) => {
  assertAllReposExist(repodir, repolist);

  for (const repo of repolist) {
    const cwd = path.join(repodir, repo);

    printHeader(repo);
    const isOnDefaultBranch = checkBranch(cwd);
    if (isOnDefaultBranch || runIfNotOnDefaultBranch) {
      cb({ cwd, stdio: "inherit", isOnDefaultBranch });
    }
    printFooter();
  }
};
