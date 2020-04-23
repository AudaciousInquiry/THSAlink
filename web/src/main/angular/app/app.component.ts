import {Component, OnInit} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {QuestionnaireResponseSimple} from './model/questionnaire-response-simple';
import {IQuestionnaireResponse, IQuestionnaireResponseItemComponent} from './fhir';
import saveAs from 'save-as';
import {LocationResponse} from './model/location-response';
import {NgbModal} from '@ng-bootstrap/ng-bootstrap';
import {SelectLocationsComponent} from './select-locations/select-locations.component';
import {CookieService} from 'ngx-cookie-service';
import {Subject} from 'rxjs';
import {debounceTime} from 'rxjs/operators';
import {getFhirNow} from './helper';
import {OAuthService} from 'angular-oauth2-oidc';
import {ToastService} from './toast.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  loading = false;
  response: QuestionnaireResponseSimple = new QuestionnaireResponseSimple();
  overflowLocations: LocationResponse[] = [];
  reportDateEvent = new Subject();
  user: any;

  constructor(
      private http: HttpClient,
      private modal: NgbModal,
      private cookieService: CookieService,
      private oauthService: OAuthService,
      public toastService: ToastService) {
    if (this.cookieService.get('overflowLocations')) {
      try {
        this.overflowLocations = JSON.parse(this.cookieService.get('overflowLocations'));
      } catch (ex) {}
    }

    this.reportDateEvent
      .pipe(debounceTime(500))
      .subscribe(async () => {
        await this.reload();
      });
  }

  get overflowLocationsDisplay() {
    const displays = this.overflowLocations.map(l => {
      const r = l.display || l.id;
      return r ? r.replace(/,/g, '') : 'Unknown';
    });

    return displays.join(', ');
  }

  submit() {
    const questionnaireResponse: IQuestionnaireResponse = {
      resourceType: 'QuestionnaireResponse',
      status: 'completed',
      questionnaire: 'http://hl7.org/fhir/us/hai/Questionnaire/hai-questionnaire-covid-19-pt-impact-hosp-capacity',
      item: []
    };

    if (this.response.facilityId) {
      questionnaireResponse.item.push({
        linkId: 'facility-id',
        text: 'Facility ID',
        answer: [{
          valueUri: this.response.facilityId
        }]
      });
    }

    if (this.response.summaryCensusId) {
      questionnaireResponse.item.push({
        linkId: 'summary-census-id',
        text: 'Summary Census ID',
        answer: [{
          valueUri: this.response.summaryCensusId
        }]
      });
    }

    if (this.response.date) {
      questionnaireResponse.item.push({
        linkId: 'collection-date',
        text: 'Date for which patient impact and hospital capacity counts are recorded',
        answer: [{
          valueDate: this.response.date
        }]
      });
    }

    const section1: IQuestionnaireResponseItemComponent = {
      linkId: 'covid-19-patient-impact-group',
      text: 'Patient Impact Section',
      item: []
    };

    if (this.response.hasOwnProperty('hospitalized')) {
      section1.item.push({
        linkId: 'numC19HospPats',
        text: 'Patients currently hospitalized in an inpatient bed who have suspected or confirmed COVID-19',
        answer: [{
          valueInteger: this.response.hospitalized
        }]
      });
    }

    if (this.response.hasOwnProperty('hospitalizedAndVentilated')) {
      section1.item.push({
        linkId: 'numC19MechVentPats',
        text: 'Patients currently hospitalized in an inpatient bed who have suspected or confirmed COVID-19 and are on a mechanical ventilator',
        answer: [{
          valueInteger: this.response.hospitalizedAndVentilated
        }]
      });
    }

    if (this.response.hasOwnProperty('hospitalOnset')) {
      section1.item.push({
        linkId: 'covid-19-numC19HOPats',
        text: 'Patients currently hospitalized in an inpatient bed with onset of suspected or confirmed COVID-19 fourteen or more days after hospital admission due to a condition other than COVID-19',
        answer: [{
          valueInteger: this.response.hospitalOnset
        }]
      });
    }

    if (this.response.hasOwnProperty('edOverflow')) {
      section1.item.push({
        linkId: 'numC19OverflowPats',
        text: 'Patients with suspected or confirmed COVID-19 who are currently in the Emergency Department (ED) or any overflow location awaiting an inpatient bed',
        answer: [{
          valueInteger: this.response.edOverflow
        }]
      });
    }

    if (this.response.hasOwnProperty('edOverflowAndVentilated')) {
      section1.item.push({
        linkId: 'numC19OFMechVentPats',
        text: 'Patients with suspected or confirmed COVID-19 who currently are in the ED or any overflow location awaiting an inpatient bed and on a mechanical ventilator',
        answer: [{
          valueInteger: this.response.edOverflowAndVentilated
        }]
      });
    }

    if (this.response.hasOwnProperty('deaths')) {
      section1.item.push({
        linkId: 'numC19Died',
        text: 'Patients with suspected or confirmed COVID-19 who died in the hospital, ED or any overflow location on the date for which you are reporting',
        answer: [{
          valueInteger: this.response.deaths
        }]
      });
    }

    if (section1.item.length > 0) {
      questionnaireResponse.item.push(section1);
    }

    const json = JSON.stringify(questionnaireResponse, null, '\t');
    const blob = new Blob([json], {type: 'application/json'});
    saveAs(blob, 'questionnaireResponse.txt');
  }

  async selectOverflowLocations() {
    const modalRef = this.modal.open(SelectLocationsComponent, { size: 'lg' });
    this.overflowLocations = (await modalRef.result) || [];
    this.cookieService.set('overflowLocations', JSON.stringify(this.overflowLocations));
  }

  async reload() {
    try {
      this.loading = true;

      let url = '/api/query?';

      if (this.overflowLocations.length > 0) {
        const ids = this.overflowLocations.map(ol => ol.id);
        url += 'overflowLocations=' + encodeURIComponent(ids.join(',')) + '&';
      }

      if (this.response.date) {
        url += 'reportDate=' + encodeURIComponent(this.response.date) + '&';
      } else {
        url += 'reportDate=' + encodeURIComponent(getFhirNow()) + '&';
      }

      this.response = await this.http.get<QuestionnaireResponseSimple>(url).toPromise();
      const keys = Object.keys(this.response);
      for (const key of keys) {
        if (this.response[key] === null) {
          delete this.response[key];
        }
      }

      this.toastService.showInfo('Successfully ran queries!');
    } catch (ex) {
      this.toastService.showException('Error running queries', ex);
    } finally {
      this.loading = false;
    }
  }

  login() {
    this.oauthService.initImplicitFlow();
  }

  logout() {
    this.oauthService.logOut();
  }

  async ngOnInit() {
    const issuer = '%auth.issuer%';
    const clientId = '%auth.clientId%';
    const scope = '%auth.scope%';

    this.oauthService.configure({
      issuer,
      redirectUri: window.location.origin + '/',
      clientId,
      responseType: 'code',
      scope,
      showDebugInformation: false,
      requestAccessToken: true,
      requireHttps: false
    });
    this.oauthService.setStorage(localStorage);
    await this.oauthService.loadDiscoveryDocument();

    const loggedIn: boolean = await this.oauthService.tryLogin();

    try {
      if (loggedIn) {
        this.user = await this.oauthService.loadUserProfile() as any;
      }
    } catch (ex) {

    }

    if (!this.user) {
      this.oauthService.initImplicitFlow();
    }
  }
}
