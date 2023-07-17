import { admin } from "../../support/util";

describe("users page", () => {
  before(() => {
    cy.apiLogin(admin())
      .then((res) => {
        cy.expect(res.status).to.eq(200);

        return cy.request({
          method: "GET",
          url: `${Cypress.env("apiUrl")}/users`,
          headers: {
            Authorization: `bearer ${res.body.access_token}`,
          },
        });
      })
      .then((res) => {
        cy.expect(res.status).to.eq(200);

        // Create users if the database is sparsely populated.
        if (res.body.length < 20) {
          for (let i = 0; i < 20; i++) {
            cy.createRandomUser().then((res) => {
              cy.expect(res.status).to.eq(201);
            });
          }
        } else {
          cy.log("Skipping creation of users");
        }
      });
  });

  it("contains users table", () => {
    cy.intercept("GET", "**/users*").as("listUsers");

    cy.login(admin());
    cy.get('a:contains("Users")').click();

    cy.wait("@listUsers");

    cy.contains("No items found").should("not.exist");

    cy.get('div:contains("Name")');
    cy.get('div:contains("Email")');
    cy.get('div:contains("Verified")');
  });

  it('shows "No items found" message', () => {
    cy.intercept("GET", "**/users*", []).as("listUsers");

    cy.login(admin());
    cy.get('a:contains("Users")').click();

    cy.wait("@listUsers");

    cy.contains("No items found");
  });

  it("lists users in response", () => {
    cy.intercept("GET", "**/users*", {
      fixture: "users.json",
    }).as("listUsers");

    cy.login(admin());
    cy.get('a:contains("Users")').click();

    cy.wait("@listUsers");

    cy.contains("No items found").should("not.exist");

    cy.get("tr").eq(2).contains("Bob");
    cy.get("tr").eq(2).contains("bob@builders.gov");
    cy.get("tr").eq(2).contains("Verified");

    cy.get("tr").eq(4).contains("Stan Marsh");
    cy.get("tr").eq(4).contains("stanley@tegrityfarms.com");
    cy.get("tr").eq(4).contains("Not Verified");
  });
});
