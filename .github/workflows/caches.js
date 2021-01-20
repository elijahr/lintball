const os = require("os");
const execSync = require("child_process").execSync;

const { HOME = "~", GITHUB_WORKSPACE } = process.env;

const pathByPlatform = {
  linux: {
    pip: `${HOME}/.cache/pip`,
    brew: `${HOME}/.cache/Homebrew`
  },
  darwin: {
    pip: `${HOME}/Library/Caches/pip`,
    brew: `${HOME}/Library/Caches/Homebrew/`
  },
  win32: {
    pip: `${HOME}\\AppData\\Local\\pip\\Cache`
  }
};

const RUBY_VERSION = execSync(
  "bash -c \"gem environment | grep -F 'RUBY VERSION' | awk '{ print \\$4 }'\""
)
  .toString()
  .trim();

const GEM_INSTALLATION_DIRECTORY = execSync(
  "bash -c \"gem environment | grep -F 'INSTALLATION DIRECTORY' | head -n1 | awk '{ print \\$4 }'\""
)
  .toString()
  .trim();

module.exports = {
  pip: {
    path: pathByPlatform[os.platform()].pip,
    hashFiles: ["deps/requirements-pip.txt"],
    keyPrefix: "pip-",
    restoreKeys: "pip-"
  },
  npm: {
    path: `${HOME}/.npm`,
    hashFiles: ["deps/package-lock.json"],
    keyPrefix: "npm-",
    restoreKeys: "npm-"
  },
  npmDev: {
    path: `${HOME}/.npm`,
    hashFiles: ["deps/package-lock.json"],
    keyPrefix: "npmDev-",
    restoreKeys: "npmDev-"
  },
  bundler: {
    path: `${GITHUB_WORKSPACE}/deps/vendor/bundle/ruby/${RUBY_VERSION}/cache`,
    hashFiles: ["deps/Gemfile.lock"],
    keyPrefix: "bundler-",
    restoreKeys: "bundler-"
  },
  gem: {
    path: `${GEM_INSTALLATION_DIRECTORY}/cache`,
    hashFiles: [],
    keyPrefix: "gem-",
    restoreKeys: "gem-"
  },
  brew: {
    path: pathByPlatform[os.platform()].brew,
    hashFiles: ["deps/requirements-brew.txt"],
    keyPrefix: "brew-",
    restoreKeys: "brew-"
  },
  apt: {
    path: "/var/cache/apt/archives",
    hashFiles: ["deps/requirements-apt.txt"],
    keyPrefix: "apt-",
    restoreKeys: "apt-"
  },
  cargo: {
    path: `${HOME}/.cargo/registry/cache`,
    hashFiles: [],
    keyPrefix: "cargo-",
    restoreKeys: "cargo-"
  }
};
