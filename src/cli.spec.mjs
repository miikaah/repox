import { beforeEach, describe, expect, it, vi } from "vitest";
import { cli } from "./cli.mjs";
import { readConfig, writeConfig } from "./config.mjs";
import { logger } from "./logger.mjs";

vi.mock("./config.mjs");

vi.mock("./logger.mjs");

describe("repox", () => {
  beforeEach(() => {
    vi.mocked(readConfig).mockResolvedValue({
      repodir: "tmp",
      repolist: ["bar", "baz"],
    });
  });

  describe("dir", () => {
    it("sets repodir by arg", async () => {
      await cli("dir", "tmp");

      expect(writeConfig).toHaveBeenCalledWith({
        repodir: "tmp",
        repolist: ["bar", "baz"],
      });
    });

    it("throws if dir doesn't exist", async () => {
      await expect(() => cli("dir", "doesnotexist")).rejects.toThrow();

      expect(writeConfig).not.toHaveBeenCalled();
      expect(logger.error).toHaveBeenCalledWith(
        "Failed to set repo dir",
        expect.anything(),
      );
    });
  });

  describe("show", () => {
    it("prints config", async () => {
      await cli("show");

      expect(readConfig).toHaveBeenCalledTimes(1);
    });

    it("throws if something goes wrong", async () => {
      vi.mocked(readConfig).mockRejectedValueOnce(new Error("foo"));

      await expect(() => cli("show")).rejects.toThrow();

      expect(logger.error).toHaveBeenCalledWith(
        "Failed to print config",
        expect.anything(),
      );
    });
  });

  describe("add", () => {
    it("adds new repository", async () => {
      await cli("add", "newone");

      expect(writeConfig).toHaveBeenCalledWith({
        repodir: "tmp",
        repolist: ["bar", "baz", "newone"],
      });
    });

    it("throws if arg is empty", async () => {
      await expect(() => cli("add")).rejects.toThrow();

      expect(writeConfig).not.toHaveBeenCalled();
      expect(logger.error).toHaveBeenCalledWith(
        "Failed to add repositories",
        expect.anything(),
      );
    });

    it("throws if dir doesn't exist", async () => {
      await expect(() => cli("add", "doesnotexist")).rejects.toThrow();

      expect(logger.error).toHaveBeenCalledWith(
        "Failed to add repositories",
        expect.anything(),
      );
    });
  });

  describe("remove", () => {
    it("removes repository", async () => {
      await cli("remove", "bar");

      expect(writeConfig).toHaveBeenCalledWith({
        repodir: "tmp",
        repolist: ["baz"],
      });
    });

    it("throws if something goes wrong", async () => {
      vi.mocked(readConfig).mockRejectedValueOnce(new Error("foo"));

      await expect(() => cli("remove")).rejects.toThrow();

      expect(logger.error).toHaveBeenCalledWith(
        "Failed to remove repositories",
        expect.anything(),
      );
    });
  });

  describe("empty", () => {
    it("empties repository list", async () => {
      await cli("empty", "bar");

      expect(writeConfig).toHaveBeenCalledWith({
        repodir: "tmp",
        repolist: [],
      });
    });

    it("throws if something goes wrong", async () => {
      vi.mocked(readConfig).mockRejectedValueOnce(new Error("foo"));

      await expect(() => cli("empty")).rejects.toThrow();

      expect(logger.error).toHaveBeenCalledWith(
        "Failed to empty repositories",
        expect.anything(),
      );
    });
  });
});
