import {When} from '@badeball/cypress-cucumber-preprocessor';

When('diagram gets edited', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('.view-line').eq(1).click({ force: true }).type('{enter}Alice -> Bob : test {enter}Carl -> Carl : myself');
});

When('diagram gets exported', () => {
  cy.clickWarpMenuCheckboxIfPossible();

  cy.get('.editor-menu').click({ force: true });
  cy.get('.menu-item[title="Export diagram"]').click({ force: true });

  // Ensure modal is visible before clicking
  cy.get('#diagram-export')
    .should('have.attr', 'style')
    .and('not.contain', 'display: none');

  cy.get('#diagram-export-ok-btn')
    .scrollIntoView()
    .should('be.visible')
    .click({ force: true });
});


When('picture link gets clicked', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('#url').invoke('val').then((value) => {
        let url = value;

        // If the value starts with 'http' or 'https', treat it as absolute
        if (!/^https?:\/\//.test(value)) {
            url = '/' + Cypress.env('DoguName') + '/' + value;
        }

        cy.request({ url, failOnStatusCode: false }).then((res) => {
            cy.log(res.body);
            cy.writeFile('./output.png', res.body);
        });
    });
});

