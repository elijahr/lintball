module.exports = {
  pip: {
    path: [`${process.env.HOME}/.cache/pip`],
    hashFiles: ["requirements.txt"],
    keyPrefix: "pip-",
    restoreKeys: "pip-",
  },
  npm: {
    path: [`${process.env.HOME}/.npm`],
    hashFiles: ["package-lock.json"],
    keyPrefix: "npm-",
    restoreKeys: "npm-",
  },
  npmdev: {
    path: [`${process.env.HOME}/.npm`],
    hashFiles: ["package-lock.json"],
    keyPrefix: "npmdev-",
    restoreKeys: "npmdev-",
  },
  bundler: {
    path: [`${process.env.GITHUB_WORKSPACE}/vendor/bundle/ruby/3.0.0/cache`],
    hashFiles: ["Gemfile.lock"],
    keyPrefix: "bundler-",
    restoreKeys: "bundler-",
  },
  gem: {
    path: ["/opt/hostedtoolcache/Ruby/3.0.0/x64/lib/ruby/gems/3.0.0/cache"],
    keyPrefix: "gem-",
    restoreKeys: "gem-",
  },
};
