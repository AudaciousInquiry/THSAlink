import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {ApiComponent} from "./api/api.component";
import {WebComponent} from "./web/web.component";
import {ConsumerComponent} from "./consumer/consumer.component";
import {HomeComponent} from "./home/home.component";
import {UploadFileComponent} from "./uploadfile/uploadfile.component";

const routes: Routes = [
  { path: 'home', component: HomeComponent },
  { path: 'api', component: ApiComponent },
  { path: 'web', component: WebComponent },
  { path: 'consumer', component: ConsumerComponent },
  {path: 'upload', component: UploadFileComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
