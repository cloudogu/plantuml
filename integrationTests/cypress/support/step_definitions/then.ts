import {Then} from '@badeball/cypress-cucumber-preprocessor';

Then('diagram matches', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('#diagram-txt:contains("Carl")', { timeout: 1000 });
    cy.get('#diagram-txt', { timeout: 1000 }).invoke('text').then((text) => {
        cy.readFile('cypress/fixtures/diagram.txt').should('eq', text)
    })
});

Then('diagram matches existing .puml', () => {
    cy.clickWarpMenuCheckboxIfPossible();

    const downloadedFile = `${Cypress.config('downloadsFolder')}/diagram.puml`;

    // Wait for the file to exist before comparing
    cy.readFile(downloadedFile, { timeout: 5000 }).should('exist');
    cy.readFile(downloadedFile).then((actualContent) => {
        cy.readFile('cypress/fixtures/diagram_expected.puml').then((expectedContent) => {
            expect(actualContent).to.eq(expectedContent);
        });
    });
});

Then('picture gets downloaded', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.readFile('output.png').should('exist');
});

Then('plantuml is shown', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('.header').should('contain.text', 'PlantUML');
})

Then('warp menu exists', () => {
    // warp menu is located in shadow dom
    cy.get('#warp-menu-shadow-host').shadow().find('#warp-toggle');
    cy.clickWarpMenuCheckboxIfPossible();
})