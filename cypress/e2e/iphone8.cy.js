import job19178 from '../../example-api-repo/functions/test/mocks/job/19178';
import job19186 from '../../example-api-repo/functions/test/mocks/job/19186';
import job19206 from '../../example-api-repo/functions/test/mocks/job/19206';
import job19256 from '../../example-api-repo/functions/test/mocks/job/19256';
import job19267 from '../../example-api-repo/functions/test/mocks/job/19267';

import address19178 from '../../example-api-repo/functions/test/mocks/addresses/19178';
import address19186 from '../../example-api-repo/functions/test/mocks/addresses/19186';
import address19206 from '../../example-api-repo/functions/test/mocks/addresses/19206';
import address19256 from '../../example-api-repo/functions/test/mocks/addresses/19256';
import address19267 from '../../example-api-repo/functions/test/mocks/addresses/19267';

import recruiter19178 from '../../example-api-repo/functions/test/mocks/recruiters/19178';
import recruiter19186 from '../../example-api-repo/functions/test/mocks/recruiters/19186';
import recruiter19206 from '../../example-api-repo/functions/test/mocks/recruiters/19206';
import recruiter19256 from '../../example-api-repo/functions/test/mocks/recruiters/19256';
import recruiter19267 from '../../example-api-repo/functions/test/mocks/recruiters/19267';

const jobs = [
  job19178,
  job19186,
  job19206,
  job19256,
  job19267
];

const addresses = [
  address19178,
  address19186,
  address19206,
  address19256,
  address19267
];

const recruiters = [
  recruiter19178,
  recruiter19186,
  recruiter19206,
  recruiter19256,
  recruiter19267
];

const excerpts = {
  '2023-19178': 'Manages and directs multiple projects and programs of various size mostly focused on',
  '2023-19186': 'Responsible for workflow ensuring paper medical records get incorporated into the electronic',
  '2023-19206': 'A Registered Nurse at Springfield Burleman Hospital means becoming a part of a Magnet',
  '2023-19256': 'The incumbent will assist in providing access to services provided at the hospital',
  '2023-19267': 'Assists in providing access to services provided at the hospital and/or other service area.',
};

const addressFromJobLocation = (location) => location.split(' - ')[0]
const shift = (input) => input + ' Shift'

describe('iPhone 8', () => {
  beforeEach(() => {
    cy.viewport('iphone-8')
    cy.visit('http://localhost:8080/')
  })

  describe('Homepage', () => {
    it('should show the homepage', () => {
      cy.title().should('include', 'Homepage')
      cy.contains('Why Choose Burleman?').should('exist')
    })

    it('should open the primary nav menu and go to Job Search page', () => {
      cy.hamburgerMenuToJobSearch()
      cy.title().should('include', 'Job Search')
    })
  })

  describe('Job Search - summaries', () => {
    jobs.forEach((job, index) => {
      const extraAddress = addresses[index].data
      const jobExcerpt = excerpts[job.jobid]

      it(`should display job ${job.jobid}`, () => {
        cy.hamburgerMenuToJobSearch()

        cy.get(`#${job.jobid}`).within(() => {
          cy.contains(job.jobtitle).should('exist');
          cy.contains(addressFromJobLocation(job.joblocation.value)).should('exist');
          cy.get('.location').contains(`${extraAddress.addresscity}, ${extraAddress.addressstate.abbrev}`).should('exist');
          cy.get('.position-type').contains(`${job.positiontype.value}`).should('exist');
          cy.get('.shift').contains(shift(job.field39908.value)).should('exist');
          cy.get('.excerpt').invoke('text').should('include', jobExcerpt);
        });
      })
    })
  })

  describe('Job Search - details', () => {
    jobs.forEach((job, index) => {
      it(`should display job ${job.jobid}`, () => {
        cy.hamburgerMenuToJobSearch()

        cy.get(`#${job.jobid}`).click()
        cy.get('.tracking-code').contains(`Tracking Code ${job.jobid}`).should('exist')

        cy.get('.recruiter-info').within(() => {
          cy.contains(`${recruiters[index].data.firstname} ${recruiters[index].data.lastname}`).should('exist')
        })
      })
    })
  })
})

// Prevent TypeScript from reading file as legacy script
export {}
