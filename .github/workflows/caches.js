module.exports = {
  pip: {
    path: [`${process.env.HOME}/.cache/pip`],
    hashFiles: ["requirements*.txt"],
    keyPrefix: "pip-",
    restoreKeys: "pip-",
  },
  npm: {
    path: [`${process.env.HOME}/.npm`],
    hashFiles: [
      `package-lock.json`,
      `*/*/package-lock.json`,
      `!node_modules/*/package-lock.json`,
    ],
  },
  // npm: {
  //   path: [`${process.env.HOME}/.npm`],
  //   hashFiles: [
  //     `package-lock.json`,
  //     `*/*/package-lock.json`,
  //     `!node_modules/*/package-lock.json`,
  //   ],
  // },
};
