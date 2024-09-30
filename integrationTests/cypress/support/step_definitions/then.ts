import {Then} from '@badeball/cypress-cucumber-preprocessor';

Then('diagram matches', () => {
    // plantuml is really slow in applying the new inserted text
    cy.wait(1000);
    cy.get('#diagram-txt').invoke('text').then((text) => {
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
    cy.get('.header').should('have.value', 'PlantUML Server');
})

Then('warp menu exists', () => {
    cy.get('#warp-toggle');
})