import { platform } from "os";

const { HOME = "~", GITHUB_WORKSPACE } = process.env;

const pathByPlatform = {
  linux: {
    pip: `${HOME}/.cache/pip`,
  },
  darwin: {
    pip: `${HOME}/Library/Caches/pip`,
  },
  win32: {
    pip: `${HOME}\\AppData\\Local\\pip\\Cache`,
  },
};

export const pip = {
  path: pathByPlatform[platform()].pip,
  hashFiles: ["requirements.txt"],
  keyPrefix: "pip-",
  restoreKeys: "pip-",
};
export const npm = {
  path: `${HOME}/.npm`,
  hashFiles: ["package-lock.json"],
  keyPrefix: "npm-",
  restoreKeys: "npm-",
};
export const npmDev = {
  path: `${HOME}/.npm`,
  hashFiles: ["package-lock.json"],
  keyPrefix: "npmDev-",
  restoreKeys: "npmDev-",
};
export const bundler = {
  path: `${GITHUB_WORKSPACE}/vendor/bundle/ruby/3.0.0/cache`,
  hashFiles: ["Gemfile.lock"],
  keyPrefix: "bundler-",
  restoreKeys: "bundler-",
};
export const gem = {
  path: "/opt/hostedtoolcache/Ruby/3.0.0/x64/lib/ruby/gems/3.0.0/cache",
  hashFiles: [],
  keyPrefix: "gem-",
  restoreKeys: "gem-",
};
