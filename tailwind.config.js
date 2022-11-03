const formsPlugin = require('@tailwindcss/forms');

module.exports = {
  content: [
    './**/*.{html,md}',
    '!**/node_modules',
    '!**/_site'
  ],
  plugins: [
    formsPlugin
  ]
};
