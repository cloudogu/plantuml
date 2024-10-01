import {Then} from '@badeball/cypress-cucumber-preprocessor';

Then('diagram matches', () => {
    cy.get('#diagram-txt:contains("Carl")', { timeout: 1000 });
    cy.get('#diagram-txt', { timeout: 1000 }).invoke('text').then((text) => {
        cy.readFile('cypress/fixtures/diagram.txt').should('eq', text)
    })
});

Then('diagram matches existing .puml', () => {
    cy.readFile('cypress/fixtures/diagram_expected.puml').then((file) => {
        cy.readFile(`${Cypress.config('downloadsFolder')}/diagram.puml`).should('eq', file);
    })
});

Then('picture gets downloaded', () => {
    cy.readFile('output.png').should('exist');
});

Then('plantuml is shown', () => {
    cy.get('.header').should('contain.text', 'PlantUML');
})

Then('warp menu exists', () => {
    // warp menu is located in shadow dom
    cy.get('#warp-menu-shadow-host').shadow().find('#warp-toggle');
})