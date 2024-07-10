import fs from "node:fs/promises";
import { beforeEach, vi, beforeAll } from "vitest";

beforeAll(async () => {
  try {
    await fs.stat("tmp");
  } catch (error) {
    if (error.code === "ENOENT") {
      await fs.mkdir("tmp");
    }
  }
  try {
    await fs.stat("tmp/bar");
  } catch (error) {
    if (error.code === "ENOENT") {
      await fs.mkdir("tmp/bar");
    }
  }
  try {
    await fs.stat("tmp/baz");
  } catch (error) {
    if (error.code === "ENOENT") {
      await fs.mkdir("tmp/baz");
    }
  }
  try {
    await fs.stat("tmp/newone");
  } catch (error) {
    if (error.code === "ENOENT") {
      await fs.mkdir("tmp/newone");
    }
  }
});

beforeEach(() => {
  vi.clearAllMocks();
});
