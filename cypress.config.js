const { defineConfig } = require('cypress');

module.exports = defineConfig({
  video: false,
  defaultCommandTimeout: 10000,
  e2e: {
    baseUrl: 'http://localhost:8080',
    includeShadowDom: true,
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
})
