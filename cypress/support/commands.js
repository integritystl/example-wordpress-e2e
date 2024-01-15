/// <reference types="cypress" />
// ***********************************************
// This example commands.ts shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })
//

Cypress.Commands.add('getAriaLabel', (ariaLabel) => {
  cy.get(`[aria-label="${ariaLabel}"]`)
})

Cypress.Commands.add('getAriaControls', (ariaControl) => {
  cy.get(`[aria-controls="${ariaControl}"]`)
})

Cypress.Commands.add('hamburgerMenuToJobSearch', () => {
  cy.getAriaControls('primary-menu').click()
  cy.contains('Job Search').click({ force: true })
})

Cypress.Commands.add('topNavToJobSearch', () => {
  cy.contains('Job Search').click({ force: true })
})

export {}
