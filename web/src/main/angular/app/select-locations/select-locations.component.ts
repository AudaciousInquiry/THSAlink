import {Component, Input, OnInit} from '@angular/core';
import {NgbActiveModal} from "@ng-bootstrap/ng-bootstrap";
import {HttpClient} from "@angular/common/http";
import {LocationResponse} from "../model/location-response";
import {Subject} from "rxjs";
import {debounceTime} from "rxjs/operators";
import {ToastService} from '../toast.service';

@Component({
  selector: 'app-select-locations',
  templateUrl: './select-locations.component.html',
  styleUrls: ['./select-locations.component.css']
})
export class SelectLocationsComponent implements OnInit {
  locations: LocationResponse[] = [];
  @Input() selected: LocationResponse[] = [];
  searchText: string;
  identifierText: string;
  criteriaChanged = new Subject<void>();

  constructor(
      public activeModal: NgbActiveModal,
      private http: HttpClient,
      private toastService: ToastService) {
    this.criteriaChanged
      .pipe(debounceTime(500))
      .subscribe(async () => {
        await this.reload();
      });
  }

  selectAll(value) {
    if (value.target.checked) {
      this.locations.forEach(location => {
        this.selected.push(location);
      });
    } else {
      this.selected = [];
    }
  }

  updateSearchText(value: string) {
    this.searchText = value;
    this.criteriaChanged.next();
  }

  updateIdentifierText(value: string) {
    this.identifierText = value;
    this.criteriaChanged.next();
  }

  async reload() {
    let url = '/api/location?';

    if (this.searchText) {
      url += `search=${encodeURIComponent(this.searchText)}&`;
    }

    if (this.identifierText) {
      url += `identifier=${encodeURIComponent(this.identifierText)}&`;
    }

    try {
      this.locations = await this.http.get<LocationResponse[]>(url).toPromise();
    } catch (ex) {
      this.toastService.showException('Error retrieving locations', ex);
    }
  }

  async ngOnInit() {
    await this.reload();
  }

  isSelected(id: string) {
    return !!this.selected.find(s => s.id === id);
  }

  selectionChanged(id: string, isSelected: boolean) {
    const found = this.selected.find(s => s.id === id);
    const index = found ? this.selected.indexOf(found) : -1;
    const location = this.locations.find(l => l.id === id);

    if (!found && isSelected) {
      this.selected.push(location);
    } else if (found && !isSelected) {
      this.selected.splice(index, 1);
    }
  }

  ok() {
    this.activeModal.close(this.selected);
  }
}
