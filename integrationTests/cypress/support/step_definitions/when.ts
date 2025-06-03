import {When} from '@badeball/cypress-cucumber-preprocessor';

When('diagram gets edited', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('.view-line').eq(1).click({ force: true }).type('{enter}Alice -> Bob : test {enter}Carl -> Carl : myself');
});

When('diagram gets exported', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('.editor-menu').click({ force: true });
    cy.get('.menu-item').eq(2).click({ force: true });
    cy.get('#diagram-export-ok-btn').click({ force: true });
    // wait for export
    cy.wait(1000);
});

When('picture link gets clicked', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('#url').invoke('val').then((value) => {
        cy.request('/' + Cypress.env('DoguName') + '/' + value, {failOnStatusCode: false}).then((res) => {
            cy.log(res.body);
            cy.writeFile('./output.png', res.body);
        })
    })
});
